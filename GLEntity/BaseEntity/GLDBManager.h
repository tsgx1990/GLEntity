//
//  TNCDBManager.h
//  TNCBaseEntityDemo
//
//  Created by guanglong on 15/8/11.
//  Copyright (c) 2015年 guanglong. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TNCBaseEntity;

@interface TNCDBManager : NSObject

+ (instancetype)shareInstance;

- (BOOL)insertEntities:(NSArray*)entities;

- (BOOL)deleteBySql:(NSString*)deleteSql;

- (BOOL)updateBySql:(NSString*)updateSql;

- (NSArray*)queryBySql:(NSString*)querySql;

@end
