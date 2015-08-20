//
//  TNCBaseEntity.m
//  Toon
//
//  Created by guanglong on 15/8/5.
//  Copyright (c) 2015年 思源. All rights reserved.
//

#import "GLBaseEntity.h"

NSString* convertValid(NSString* rawString)
{
    rawString = rawString ? rawString : @"";
    assert([rawString isKindOfClass:[NSString class]]);
    return rawString;
}

@implementation GLBaseEntity

@synthesize propertyColumnMap = _propertyColumnMap;

// 规则1：
// entity的属性名的命名规则为 column_ + key名

// 规则2：
// 如果字典中有字典，需要将该字典设为一个entity属性

// 规则3：
// 如果字典里有一个数组且数组元素是字典，则需要将该数组设为一个存储entity的数组；如果这个数组元素不是字典，则将该数组设为entity的一个字符串属性，用于存储该数组的json串

// 规则4：
// 字典中包含字典的情况下，假如外层字典对应的entity类名为 "Entity"，内字典的key名为 "key"，则内层字典的entity类名命名规则为："Entity_key"

// 规则5：
// 字典中包含数组（且该数组元素为字典）的情况下，数组中的字典元素对应的entity类名的命名规则，和字典中包含字典的情况相同

// 规则6：
// 对于需要设置为外键的属性，属性名前面必须加前缀 foreign_

// 规则7：
// entity类的属性类型和它实际存储数据的类型一定要一致，不能出现类似这种情况：属性类型为Entity类，但是实际存储的却是一个数组。

// 规则8：
// foreign属性和column属性都不要设为readonly

// 默认1：
// 一个entity类对应的表名默认为 table_ + entity类名，可以重写 + (NSString*)tableName 方法重新给表命名，但是一般情况下不必这么做

// 默认2：
// 表中的字段名默认和entity的属性名相同，可以重写 + (NSMutableDictionary*)propertyColumnMap 改变二者之间的对应关系

#pragma mark - - entity or entities 的初始化操作
+ (TNCEntityArray *)entitiesWithArray:(NSArray *)array
{
    if (![array isKindOfClass:[NSArray class]]) {
        return [self entitiesWithData:array];
    }
    
    NSMutableArray* mEntities = [NSMutableArray array];
    for (id element in array) {
        id entity = nil;
        if ([element isKindOfClass:[NSArray class]]) {
            Class subEntitiesClass = [self subEntitiesClass];
            entity = [subEntitiesClass entitiesWithArray:(NSArray*)element];
        }
        else if ([element isKindOfClass:[NSDictionary class]]) {
            entity = [self entityWithDict:(NSDictionary*)element];
        }
        else { // 一般为字符串
            entity = element;
        }
        
        if (entity) {
            [mEntities addObject:entity];
        }
    }
    
    return mEntities;
}

+ (instancetype)entityWithDict:(NSDictionary *)dict
{
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return [self entitiesWithData:dict];
    }
    
    GLBaseEntity* entity = [self new];
    for (NSString* key in dict.allKeys) {
        
        id value = [dict objectForKey:key];
        NSString* columnKey = [NSString stringWithFormat:@"%@%@", TNC_COLUMN_PREFIX, key];
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            Class subEntityClass = [self subEntityClassForKey:key];
            GLBaseEntity* subEntity = [subEntityClass entityWithDict:(NSDictionary*)value];
            subEntity.superEntity = entity;
            [entity setValue:subEntity forKey:columnKey];
        }
        else if ([value isKindOfClass:[NSArray class]]) {
            
            // value是数据还要分为两种情况，一种是元素为字符串，一种是元素为字典
            // 元素为字典的情况，将字典转换成entity对象
            // 元素为字符串的情况，将该数组转换成json对象
            
            // 其实还有一种情况，元素为数组，目前暂采用转换成json串的形式
            
            if ([[value firstObject] isKindOfClass:[NSDictionary class]]) {
                
                Class subEntityClass = [self subEntityClassForKey:key];
                TNCEntityArray* subEntities = [subEntityClass entitiesWithArray:(NSArray*)value];
                [subEntities setSuperEntity:entity];
                [entity setValue:subEntities forKey:columnKey];
            }
            
            if ([[value firstObject] isKindOfClass:[NSString class]]) {
                [entity setValue:[value JSONString] forKey:columnKey];
            }
            
            // 目前暂采用转换成json串的形式
            if ([[value firstObject] isKindOfClass:[NSArray class]]) {
                [entity setValue:[value JSONString] forKey:columnKey];
            }
        }
        else { // 一般情况下为字符串
            [entity setValue:value forKey:columnKey];
        }
    }
    return entity;
}

+ (id)entitiesWithData:(id)data
{
    if ([data isKindOfClass:[NSDictionary class]]) {
        return [self entityWithDict:data];
    }
    else if ([data isKindOfClass:[NSArray class]]) {
        return [self entitiesWithArray:data];
    }
    else {
        return nil;
    }
}

// 字典中含子字典，子字典entity的类命名方法
+ (Class)subEntityClassForKey:(NSString*)key
{
    NSString* entityClassStr = [NSString stringWithFormat:@"%@_%@", NSStringFromClass([self class]), key];
    Class subEntityClass = NSClassFromString(entityClassStr);
    
    NSString* assertStr = [NSString stringWithFormat:@"'[%@ class]' must be subclass of [TNCBaseEntity class]", entityClassStr];
    NSAssert([subEntityClass isSubclassOfClass:[GLBaseEntity class]], assertStr);
    
    return subEntityClass;
}

// 多维数组情况下，子数组entity的类命名方法
+ (Class)subEntitiesClass
{
    NSString* entitiesClassStr = [NSString stringWithFormat:@"%@%@", NSStringFromClass([self class]), TNC_PURELIST_SUFFIX];
    Class subEntitiesClass = NSClassFromString(entitiesClassStr);
    
    NSString* assertStr = [NSString stringWithFormat:@"'[%@ class]' must be subclass of [TNCBaseEntity class]", entitiesClassStr];
    NSAssert([subEntitiesClass isSubclassOfClass:[GLBaseEntity class]], assertStr);
    
    return subEntitiesClass;
}

#pragma mark - -  entity 属性 或 NSArray 属性列表获取
+ (NSArray*)columnPropertiesOfClass:(Class)specialClass
{
    NSMutableArray* mPropertyNames = [NSMutableArray array];
    
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for(int i = 0; i < count; i++)
    {
        objc_property_t property = properties[i];
        NSString* propertyStr = [NSString stringWithFormat:@"%s", property_getName(property)];
        
        if ([propertyStr hasPrefix:TNC_COLUMN_PREFIX]) {
            
            // 获取属性的数据类型
            char* attrChar = property_copyAttributeValue(property, "T");
            NSString* attrStr = [NSString stringWithFormat:@"%s", attrChar];
            Class aClass = nil;
            if ([attrStr hasPrefix:@"@"]) {
                attrStr = [attrStr stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@\""]];
                aClass = NSClassFromString(attrStr);
            }
            free(attrChar);
            
            // 表示是对象类型，且是entity类型或者NSArray类型
            if (aClass && [aClass isSubclassOfClass:specialClass]) {
                [mPropertyNames addObject:propertyStr];
            }
            else {
                // do nothing
            }
        }
    }
    free(properties);
    
    return mPropertyNames;
}

+ (NSArray *)propertyNamesOfEntityProperty
{
    return [self columnPropertiesOfClass:[GLBaseEntity class]];
}

+ (NSArray *)propertyNamesOfArrayProperty
{
    return [self columnPropertiesOfClass:[NSArray class]];
}

+ (Class)classForKey:(NSString *)propertyName
{
    return [[self entitiesClassMap] objectForKey:propertyName];
}

- (Class)classForKey:(NSString *)propertyName
{
    return [[self class] classForKey:propertyName];
}

#pragma mark - - 数据库操作
+ (NSMutableDictionary *)propertyColumnMap
{
    NSMutableDictionary* propertyColumnMap = [NSMutableDictionary dictionary];
    
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for(int i = 0; i < count; i++)
    {
        objc_property_t property = properties[i];
        NSString* propertyStr = [NSString stringWithFormat:@"%s", property_getName(property)];
        
        if ([propertyStr hasPrefix:TNC_COLUMN_PREFIX] || [propertyStr hasPrefix:TNC_FOREIGN_PREFIX]) {
            
            // 获取属性的数据类型
            char* attrChar = property_copyAttributeValue(property, "T");
            NSString* attrStr = [NSString stringWithFormat:@"%s", attrChar];
            Class aClass = nil;
            if ([attrStr hasPrefix:@"@"]) {
                attrStr = [attrStr stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@\""]];
                aClass = NSClassFromString(attrStr);
            }
            free(attrChar);
            
            // 表示是对象类型且是entity类型或者NSArray类型
            if (aClass && ([aClass isSubclassOfClass:[GLBaseEntity class]] || [aClass isSubclassOfClass:[NSArray class]])) {
                
                // 表示不是数据库中的需要存的字段属性 do nothing
            }
            else {
                [propertyColumnMap setValue:propertyStr forKey:propertyStr];
            }
        }
    }
    free(properties);
    
    return propertyColumnMap;
}

- (NSMutableDictionary *)propertyColumnMap
{
    if (!_propertyColumnMap) {
        _propertyColumnMap = [[self class] propertyColumnMap];
    }
    return _propertyColumnMap;
}

+ (NSArray *)entitiesWithDBResults:(NSArray *)dbResults
{
    // 首先获取该类的属性和数据库字段的映射关系
    NSDictionary* propertyColumnMap = [self propertyColumnMap];
    
    NSMutableArray* mEntities = [NSMutableArray array];
    for (NSDictionary* dbDict in dbResults) {
        GLBaseEntity* entity = [self new];
        for (NSString* dbKey in dbDict.allKeys) {
            // 由数据库中的字段名获取属性名
            NSString* propertyStr = [[propertyColumnMap allKeysForObject:dbKey] firstObject];
            [entity setValue:dbDict[dbKey] forKey:propertyStr];
        }
        [mEntities addObject:entity];
    }
    return mEntities;
}

- (BOOL)saveData
{
    return [@[self] saveData];
}

+ (NSArray *)entities
{
    return [self entitiesByCondition:nil];
}

+ (NSArray*)entitiesByQueryClass:(Class)queryClass relateEntity:(GLBaseEntity*)relateEntity
{
    SEL entitiesSel = @selector(entitiesByCondition:); //NSSelectorFromString(@"entitiesByCondition:");
    IMP entitiesImp = [queryClass methodForSelector:entitiesSel];
    NSArray*(*entitiesFunc)(Class, SEL, NSString*) = (void*)entitiesImp;
    
    SEL conditionSel = @selector(sqlQueryConditionRelating:); //NSSelectorFromString(@"sqlQueryConditionRelating:");
    IMP conditionImp = [queryClass methodForSelector:conditionSel];
    NSString*(*conditionFunc)(Class, SEL, GLBaseEntity*) = (void*)conditionImp;
    
    return entitiesFunc(queryClass, entitiesSel, conditionFunc(queryClass, conditionSel, relateEntity));
}

+ (NSArray*)entities:(NSArray*)entities byEntityProperties:(NSArray*)entityProperties andArrayProperties:(NSArray*)arrayProperties
{
    if (entityProperties || arrayProperties) {
        
        for (GLBaseEntity* entity in entities) {
            
            // 对entity类型的属性赋值
            for (NSString* property in entityProperties) {
                
                Class proClass = [entity classForKey:property];
                id value = [[self entitiesByQueryClass:proClass relateEntity:entity] firstObject];
                [entity setValue:value forKey:property];
            }
            
            // 对数组类型的属性赋值
            for (NSString* property in arrayProperties) {
                
                Class eleClass = [entity classForKey:property];
                if (eleClass) {
                    id value = [self entitiesByQueryClass:eleClass relateEntity:entity];
                    [entity setValue:value forKey:property];
                }
                else {
                    NSLog(@"数组属性 %@ 对应的 entityClass 为空，请检查！如果你确定使用该属性，请在 %@类 的 + (NSDictionary*)entitiesClassMap 方法中进行映射", property, NSStringFromClass([entity class]));
                }
            }
        }
    }
    return entities;
}

+ (NSArray*)entitiesByCondition:(NSString *)condition
{
//    NSDictionary* map = [self propertyColumnMap];
//    NSLog(@"%@ map:%@", NSStringFromClass([self class]), map);
    
    NSString* querySql = [NSString stringWithFormat:@"select * from %@ %@", [self tableName], convertValid(condition)];
    NSArray* dbResults = [[GLDBManager shareInstance] queryBySql:querySql];
    NSArray* entities = [self entitiesWithDBResults:dbResults];
    
    NSArray* entityPropertyNames = [self propertyNamesOfEntityProperty];
    NSArray* arrayPropertyNames = [self propertyNamesOfArrayProperty];
    
    return [self entities:entities byEntityProperties:entityPropertyNames andArrayProperties:arrayPropertyNames];
}

+ (NSArray*)entitiesWithProperties:(NSArray*)properties byCondition:(NSString*)condition
{
    NSArray* entityPropertyNames = [self propertyNamesOfEntityProperty];
    NSArray* arrayPropertyNames = [self propertyNamesOfArrayProperty];
    NSArray* queryColums = [[properties minusArray:entityPropertyNames] minusArray:arrayPropertyNames];
    
    NSString* columsStr = queryColums.count ? [queryColums componentsJoinedByString:@","] : @"*";
    NSString* querySql = [NSString stringWithFormat:@"select %@ from %@ %@", columsStr, [self tableName], convertValid(condition)];
    NSArray* dbResults = [[GLDBManager shareInstance] queryBySql:querySql];
    NSArray* entities = [self entitiesWithDBResults:dbResults];
    
    NSArray* entityColumns = [properties intersectionWithArray:entityPropertyNames];
    NSArray* arrayColumns = [properties intersectionWithArray:arrayPropertyNames];
    
    return [self entities:entities byEntityProperties:entityColumns andArrayProperties:arrayColumns];
}

+ (BOOL)deleteDataByCondition:(NSString *)condition
{
    NSString* deleteSql = [NSString stringWithFormat:@"delete from %@ %@", [self tableName], convertValid(condition)];
    return [[GLDBManager shareInstance] deleteBySql:deleteSql];;
}

+ (BOOL)updateDataWithParams:(NSString*)params byCondition:(NSString*)condition
{
    NSString* updateSql = [NSString stringWithFormat:@"update %@ %@ %@", [self tableName], convertValid(params), convertValid(condition)];
    return [[GLDBManager shareInstance] updateBySql:updateSql];
}

#pragma mark - - entity转字典
- (NSDictionary *)dictionary
{
    NSMutableDictionary* mEntityDict = [NSMutableDictionary dictionary];
    
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for(int i = 0; i < count; i++)
    {
        objc_property_t property = properties[i];
        NSString* propertyStr = [NSString stringWithFormat:@"%s", property_getName(property)];
        
        if ([propertyStr hasPrefix:TNC_COLUMN_PREFIX]) {
            
            id propertyValue = [self valueForKey:propertyStr];
            
            NSString* nonPrefixPropertyStr = [propertyStr substringFromIndex:TNC_COLUMN_PREFIX.length];
            
            if ([propertyValue isKindOfClass:[NSArray class]]) {
                [mEntityDict setValue:[propertyValue dictionaryArray] forKey:nonPrefixPropertyStr];
            }
            else if ([propertyValue isKindOfClass:[GLBaseEntity class]]) {
                [mEntityDict setValue:[propertyValue dictionary] forKey:nonPrefixPropertyStr];
            }
            else {
                [mEntityDict setValue:propertyValue forKey:nonPrefixPropertyStr];
            }
        }
    }
    free(properties);
    
    return mEntityDict;
}


#pragma mark - - table name
- (NSString *)tableName
{
    return [[self class] tableName];
}

+ (NSString *)tableName
{
    return [NSString stringWithFormat:@"%@%@", TNC_TABLE_PREFIX, NSStringFromClass([self class])];
}

- (NSString *)superTableName
{
    return [self.superEntity tableName];
}

@end

#pragma mark - - TNCEntityArray

@implementation TNCEntityArray (TNCEntities)

- (void)setSuperEntity:(GLBaseEntity *)superEntity
{
    for (GLBaseEntity* entity  in self) {
        if ([entity isKindOfClass:[GLBaseEntity class]]) {
            entity.superEntity = superEntity;
        }
    }
}

- (BOOL)saveData
{
    return [[GLDBManager shareInstance] insertEntities:self];
}

- (NSArray*)deleteData
{
    NSMutableArray* mDeletedEntities = [NSMutableArray array];
    for (GLBaseEntity* entity in self) {
        if ([entity deleteData]) {
            [mDeletedEntities addObject:entity];
        }
    }
    return mDeletedEntities;
}

- (NSArray *)intersectionWithArray:(NSArray *)anArray
{
    NSMutableArray* intersectionArr = [NSMutableArray arrayWithCapacity:anArray.count];
    for (id selfObj in self) {
        for (id anObj in anArray) {
            if ([selfObj isEqual:anObj]) {
                [intersectionArr addObject:selfObj];
            }
        }
    }
    return intersectionArr;
}

- (NSArray *)minusArray:(NSArray *)anArray
{
    NSMutableArray* mRawArr = [NSMutableArray arrayWithArray:self];
    for (id selfObj in self) {
        for (id anObj in anArray) {
            if ([selfObj isEqual:anObj]) {
                [mRawArr removeObject:selfObj];
            }
        }
    }
    return mRawArr;
}

#pragma mark - - entities 转字典
- (NSArray *)dictionaryArray
{
    NSMutableArray* mDictArr = [NSMutableArray arrayWithCapacity:self.count];
    for (GLBaseEntity* entity in self) {
        [mDictArr addObject:entity.dictionary];
    }
    return mDictArr;
}

@end

