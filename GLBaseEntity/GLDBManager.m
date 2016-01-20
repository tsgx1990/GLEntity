//
//  GLDBManager.m
//  GLEntity
//
//  Created by guanglong on 15/8/11.
//  Copyright (c) 2015年 guanglong. All rights reserved.
//

#import "GLDBManager.h"
#import "GLBaseEntity.h"
#import "FMDB.h"

@interface GLDBManager ()

@property (nonatomic, strong) FMDatabaseQueue* fmdbQueue;

@end

@implementation GLDBManager

// 规则1：
// 表的命名方式为：table_(entityClassName)

+ (instancetype)shareInstance
{
    static GLDBManager* dbManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dbManager = [[GLDBManager alloc] init];
    });
    return dbManager;
}

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}


#pragma mark - -
- (BOOL)openForeignKey:(BOOL)open
{
    __block BOOL success = YES;
    [self.fmdbQueue inDatabase:^(FMDatabase *db) {
        success = [db executeStatements:[NSString stringWithFormat:@"PRAGMA foreign_keys=%i", (open ? 1:0)]];
    }];
    return success;
}

- (BOOL)addColumsIfNeededOfEntity:(GLBaseEntity*)entity withDB:(FMDatabase*)db
{
    static NSMutableSet* mClassSet = nil;
    @synchronized([self class]) {
        
        if (!mClassSet) {
            mClassSet = [NSMutableSet setWithCapacity:6];
        }
        if (![mClassSet containsObject:[entity class]]) {
            // 如果表存在，则判断表中是否有全部所需字段，如果没有则添加，只需要执行一次即可
            
            NSArray* allNeededColumns = [entity.propertyColumnMap allValues];
            for (NSString* columStr in allNeededColumns) {
                if (![db columnExists:columStr inTableWithName:entity.tableName]) {
                    NSString* alterSql = [NSString stringWithFormat:@"alter table %@ add %@ text default ''", entity.tableName, columStr];
                    if (![db executeStatements:alterSql]) {
                        return NO;
                    }
                }
            }
            [mClassSet addObject:[entity class]];
        }
    }
    return YES;
}

- (BOOL)createTableByEntity:(GLBaseEntity*)entity withDB:(FMDatabase*)db
{
    NSAssert2([entity isKindOfClass:[GLBaseEntity class]], @"<%@>必须属于类[%@]", entity, [GLBaseEntity class]);
    
    if (![db tableExists:entity.tableName]) {
        
        if ([entity respondsToSelector:@selector(sqlCreatingTable)]) {
            if ([db executeStatements:entity.sqlCreatingTable]) {
                return [self addColumsIfNeededOfEntity:entity withDB:db];
            }
            else {
                return NO;
            }
        }
        else {
            @try {
                NSString* exceptionReson = [NSString stringWithFormat:@"The table_%@ perhaps need be created first", NSStringFromClass([entity class])];
                @throw [NSException exceptionWithName:@"Method no implement"
                                               reason:exceptionReson
                                             userInfo:nil];
            }
            @catch (NSException *exception) {
                NSLog(@"exception -- name:%@ -- reason:%@", exception.name, exception.reason);
            }
            return NO;
        }
    }
    else {
        return [self addColumsIfNeededOfEntity:entity withDB:db];
    }
    return YES;
}

- (BOOL)saveDataArray:(NSArray*)dataArray withFMDB:(FMDatabase*)db
{
    for (id entity in dataArray) {
        
        unsigned int count;
        objc_property_t *properties = class_copyPropertyList([entity class], &count);
        for(int i = 0; i < count; i++)
        {
            objc_property_t property = properties[i];
            NSString* propertyStr = [NSString stringWithFormat:@"%s", property_getName(property)];
            
            if ([propertyStr hasPrefix:GL_COLUMN_PREFIX]) {
                
                id propertyValue = [entity valueForKey:propertyStr];
//                NSLog(@"propertyValue->Class:%@", [propertyValue class]);
                if ([propertyValue isKindOfClass:[NSArray class]]) {
                    if (![self saveDataArray:(NSArray*)propertyValue withFMDB:db]) {
                        return NO;
                    }
                }
                else if ([propertyValue isKindOfClass:[GLBaseEntity class]]) {
                    if (![self saveDataArray:@[propertyValue] withFMDB:db]) {
                        return NO;
                    }
                }
                else {
                    // do nothing
                }
            }
        }
        free(properties);
        
        if ([self createTableByEntity:entity withDB:db]) {
            
            assert([entity respondsToSelector:@selector(sqlInserting)]);
            if (![db executeUpdate:[entity sqlInserting]]) {
                NSLog(@"[db lastErrorMessage]:%@", [db lastErrorMessage]);
                NSLog(@"[db lastErrorCode]:%i", [db lastErrorCode]);
                NSLog(@"[db lastError]:%@", [db lastError]);
                return NO;
            }
            else {
                continue;
            }
        }
        else {
            return NO;
        }
    }
    return YES;
}

- (BOOL)insertEntities:(NSArray *)entities
{
    __block BOOL success = YES;
    
    // 关闭外键支持，否则无法完成关联表的插入操作
    [self openForeignKey:NO];
    [self.fmdbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try {
            
            if (![self saveDataArray:entities withFMDB:db]) {
                *rollback = YES;
                success = NO;
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%s exception:%@", __func__, exception);
            *rollback = YES;
            success = NO;
        }
        @finally {
//            [db commit];
        }
    }];
    return success;
}

- (BOOL)deleteBySql:(NSString*)deleteSql
{
    __block BOOL success = YES;
    
    // 打开外键支持，对于关联表的删除操作，这一步是必须的，注意需要放在 inTransaction 外面
    [self openForeignKey:YES];
    
    [self.fmdbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try {
            if (![db executeStatements:deleteSql]) {
                *rollback = YES;
                success = NO;
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%s exception:%@", __func__, exception);
            *rollback = YES;
            success = NO;
        }
    }];
    
//    [self.fmdbQueue inDatabase:^(FMDatabase *db) {
//        [db executeStatements:@"PRAGMA foreign_keys=0"];
//    }];
    return success;
}

- (BOOL)updateBySql:(NSString*)updateSql
{
    __block BOOL success = YES;
    
    // 打开外键支持，对于关联表的更新操作，这一步是必须的，注意需要放在 inTransaction 外面
    [self openForeignKey:YES];
    [self.fmdbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try {
            
//            NSString* updateSql = [NSString stringWithFormat:@"update %@ %@ %@", entity.tableName, params, condition];
            if (![db executeStatements:updateSql]) {
                *rollback = YES;
                success = NO;
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%s exception:%@", __func__, exception);
            *rollback = YES;
            success = NO;
        }
    }];
    return success;
}

- (NSArray *)queryBySql:(NSString *)querySql
{
    NSMutableArray* mDataArray = [NSMutableArray array];
    
    [self.fmdbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet* resultSet = [db executeQuery:querySql];
        while ([resultSet next]) {
            [mDataArray addObject:[resultSet resultDictionary]];
        }
    }];
    
    return mDataArray;
}

- (NSInteger)countBySql:(NSString *)countSql
{
    __block NSInteger count = 0;
    [self.fmdbQueue inDatabase:^(FMDatabase *db) {
        count = [db intForQuery:countSql];
    }];
    return count;
}

#pragma mark - - create dbQueue
- (FMDatabaseQueue *)fmdbQueue{
    if (!_fmdbQueue) {
        NSString* docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *dbPath = [NSString stringWithFormat:@"%@/content_%@.db", docPath, @"userid"];
        _fmdbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    }
    return _fmdbQueue;
}

@end
