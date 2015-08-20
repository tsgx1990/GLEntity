//
//  TNCBaseEntity.m
//  Toon
//
//  Created by guanglong on 15/8/5.
//  Copyright (c) 2015年 思源. All rights reserved.
//

#import "TNCBaseEntity.h"

NSString* convertValid(NSString* rawString)
{
    rawString = rawString ? rawString : @"";
    assert([rawString isKindOfClass:[NSString class]]);
    return rawString;
}

@implementation TNCBaseEntity

@synthesize propertyColumnMap = _propertyColumnMap;

// 规则1：
// entity的属性名的命名方法为 column_(key)

// 规则2：
// 如果entity里有一个字典，需要将该字典设为一个entity属性

// 规则3：
// 如果entity里有一个数组，则需要将该数组变成一个存储entity的数组，如果数组中是字符串，则不进行这样的转换

// 规则4：
// 如果entity1（假如类名为BodyEntity）里有一个entity2属性（假如其在字典的中key为字符串“face”），则entity2类的命名为：BodyEntiy_face

// 规则5：
// 如果entity1中有一个entity数组，则数组中元素entity的命名规则同规则4

// 规则6：
// 如果数组entities的元素还是数组，若entities中本应该存储的entity的类名为BodyEntity，则元素数组中应该存储的entity的类名为BodyEntity_ls

// 规则7：
// 由规则6可推出，对于多维数组的结构，构建entity时，一个entity类应该只有一个属性，即一个entity数组。

// 规则8：
// 由规则4、5、6，_ls后缀 和 _(key)后缀可以进行组合

// 规则9：
// 对于外键属性和字段，前面加前缀 foreign_

// 规则10：
// 对于每个entity类的colum属性，类型一定要正确，不能出现类似：column为数组，但是类型却为BaseEntity的情况，否则会影响entity从数据库的取值

// 规则11：
// 不要将外键属性设置为readonly

// 规则12：
// 如果源数据包含字符串数组，则将该数组存为json串，也就是说在构建entity类的时候，不要将该属性作为数组，而应视为字符串

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
    
    TNCBaseEntity* entity = [self new];
    for (NSString* key in dict.allKeys) {
        
        id value = [dict objectForKey:key];
        NSString* columnKey = [NSString stringWithFormat:@"%@%@", TNC_COLUMN_PREFIX, key];
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            Class subEntityClass = [self subEntityClassForKey:key];
            TNCBaseEntity* subEntity = [subEntityClass entityWithDict:(NSDictionary*)value];
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
    NSAssert([subEntityClass isSubclassOfClass:[TNCBaseEntity class]], assertStr);
    
    return subEntityClass;
}

// 多维数组情况下，子数组entity的类命名方法
+ (Class)subEntitiesClass
{
    NSString* entitiesClassStr = [NSString stringWithFormat:@"%@%@", NSStringFromClass([self class]), TNC_PURELIST_SUFFIX];
    Class subEntitiesClass = NSClassFromString(entitiesClassStr);
    
    NSString* assertStr = [NSString stringWithFormat:@"'[%@ class]' must be subclass of [TNCBaseEntity class]", entitiesClassStr];
    NSAssert([subEntitiesClass isSubclassOfClass:[TNCBaseEntity class]], assertStr);
    
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
    return [self columnPropertiesOfClass:[TNCBaseEntity class]];
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
            if (aClass && ([aClass isSubclassOfClass:[TNCBaseEntity class]] || [aClass isSubclassOfClass:[NSArray class]])) {
                
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
        TNCBaseEntity* entity = [self new];
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

+ (NSArray*)entitiesByQueryClass:(Class)queryClass relateEntity:(TNCBaseEntity*)relateEntity
{
    SEL entitiesSel = @selector(entitiesByCondition:); //NSSelectorFromString(@"entitiesByCondition:");
    IMP entitiesImp = [queryClass methodForSelector:entitiesSel];
    NSArray*(*entitiesFunc)(Class, SEL, NSString*) = (void*)entitiesImp;
    
    SEL conditionSel = @selector(sqlQueryConditionRelating:); //NSSelectorFromString(@"sqlQueryConditionRelating:");
    IMP conditionImp = [queryClass methodForSelector:conditionSel];
    NSString*(*conditionFunc)(Class, SEL, TNCBaseEntity*) = (void*)conditionImp;
    
    return entitiesFunc(queryClass, entitiesSel, conditionFunc(queryClass, conditionSel, relateEntity));
}

+ (NSArray*)entities:(NSArray*)entities byEntityProperties:(NSArray*)entityProperties andArrayProperties:(NSArray*)arrayProperties
{
    if (entityProperties || arrayProperties) {
        
        for (TNCBaseEntity* entity in entities) {
            
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
    NSArray* dbResults = [[TNCDBManager shareInstance] queryBySql:querySql];
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
    NSArray* dbResults = [[TNCDBManager shareInstance] queryBySql:querySql];
    NSArray* entities = [self entitiesWithDBResults:dbResults];
    
    NSArray* entityColumns = [properties intersectionWithArray:entityPropertyNames];
    NSArray* arrayColumns = [properties intersectionWithArray:arrayPropertyNames];
    
    return [self entities:entities byEntityProperties:entityColumns andArrayProperties:arrayColumns];
}

+ (BOOL)deleteDataByCondition:(NSString *)condition
{
    NSString* deleteSql = [NSString stringWithFormat:@"delete from %@ %@", [self tableName], convertValid(condition)];
    return [[TNCDBManager shareInstance] deleteBySql:deleteSql];;
}

+ (BOOL)updateDataWithParams:(NSString*)params byCondition:(NSString*)condition
{
    NSString* updateSql = [NSString stringWithFormat:@"update %@ %@ %@", [self tableName], convertValid(params), convertValid(condition)];
    return [[TNCDBManager shareInstance] updateBySql:updateSql];
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
            else if ([propertyValue isKindOfClass:[TNCBaseEntity class]]) {
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

- (void)setSuperEntity:(TNCBaseEntity *)superEntity
{
    for (TNCBaseEntity* entity  in self) {
        if ([entity isKindOfClass:[TNCBaseEntity class]]) {
            entity.superEntity = superEntity;
        }
    }
}

- (BOOL)saveData
{
    return [[TNCDBManager shareInstance] insertEntities:self];
}

- (NSArray*)deleteData
{
    NSMutableArray* mDeletedEntities = [NSMutableArray array];
    for (TNCBaseEntity* entity in self) {
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
    for (TNCBaseEntity* entity in self) {
        [mDictArr addObject:entity.dictionary];
    }
    return mDictArr;
}

@end

