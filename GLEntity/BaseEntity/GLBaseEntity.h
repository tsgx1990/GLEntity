//
//  TNCBaseEntity.h
//  Toon
//
//  Created by guanglong on 15/8/5.
//  Copyright (c) 2015年 思源. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "JSONKit.h"
#import "TNCDBManager.h"

#define TNCEntityArray     NSArray

#define TNC_TABLE_PREFIX        @"table_"
#define TNC_COLUMN_PREFIX       @"column_"
#define TNC_PURELIST_SUFFIX     @"_ls"
#define TNC_FOREIGN_PREFIX      @"foreign_"

NSString* convertValid(NSString* rawString);

/*
 
 后续考虑：entity类名和表名的映射，以实现表结构相同但是entity类名不一样时的复用
 
 */

@class TNCBaseEntity;

@protocol TNCVirtualEntity <NSObject>

@optional
//@property (nonatomic, strong, readonly) NSArray* caredProperties;

#pragma mark - - sql语句

/*
 需要在子类实现的方法
 */

// 创建表
- (NSString*)sqlCreatingTable;

// 插入，子类只需要实现一个
- (NSString*)sqlInserting;

// 关联查询的条件，在subEntity中需要实现该方法
+ (NSString*)sqlQueryConditionRelating:(TNCBaseEntity*)entity;

// 如果entity的属性中有数组或者entity属性，则需要实现该方法，用于指明他们所对应的entity类（Class），通过方法 + (Class)classForKey:(NSString*)propertyName 可以得到属性所对应的类
+ (NSDictionary*)entitiesClassMap;

// 删除本条数据
- (BOOL)deleteData;

/*
 父类有默认实现，也可在子类重写的方法
 */

// 该方法重写后可以改变该entity类对应的表名
+ (NSString*)tableName;

// 属性名和数据库中字段名的映射关系，可以在子类重写
// 不重写的话，默认属性名和数据库中的字段名是相同的
// key：属性名，value：数据库中的字段名，且是一一映射的关系
+ (NSMutableDictionary*)propertyColumnMap;

// 返回属性名称的数组，父类根据属性类型进行获取，子类可以直接调用，也可以重写
+ (NSArray*)propertyNamesOfEntityProperty;
+ (NSArray*)propertyNamesOfArrayProperty;

/* == 待确定的方法 == */
// 当需要更新某个特定属性（且涉及到更新数据库）时才需要实现
- (void)updateValue:(id)value forKey:(NSString*)key;

// 给已存在的表增加字段


@end

@interface TNCBaseEntity : NSObject<TNCVirtualEntity>

@property (nonatomic, weak) id superEntity;

// 对应的表名，一定不要重写该属性的getter方法，如果需要改变entity类对应的表名，重写 +(NSString*)tableName 方法
@property (nonatomic, strong, readonly) NSString* tableName;

// 属性名和数据库字段的映射关系，一定不要重写该属性的getter方法，如果要改变映射关系，重写 + (NSDictionary*)propertyColumnMap 方法
@property (nonatomic, strong, readonly) NSMutableDictionary* propertyColumnMap;

// 父表的表名，该属性无需子类重写getter方法，如果非要写，一定要保证正确性
@property (nonatomic, strong, readonly) NSString* superTableName;

// 这两个方法，实例方法依赖于类方法，返回的结果是一样的，只是为了方便调用
+ (Class)classForKey:(NSString*)propertyName;
- (Class)classForKey:(NSString*)propertyName;

#pragma mark - - entity初始化操作
// 这三个方法不需要子类重写，可以直接调用，参数只支持字典或数组
+ (id)entitiesWithData:(id)data;
+ (instancetype)entityWithDict:(NSDictionary*)dict;
+ (TNCEntityArray*)entitiesWithArray:(NSArray*)array;

#pragma mark - - 数据库操作
// 将从数据库中查询出来的字典数组装换成entity数组
+ (NSArray*)entitiesWithDBResults:(NSArray*)dbResults;

// 根据条件，删除某些数据
+ (BOOL)deleteDataByCondition:(NSString*)condition;

// 根据条件，更新某些数据
+ (BOOL)updateDataWithParams:(NSString*)params byCondition:(NSString*)condition;


/*
 不需要在子类实现的方法
 */

// 保存本条数据
- (BOOL)saveData;

// 查询出一个entity列表，条件为nil
+ (NSArray*)entities;

// 根据条件查询出一个entity列表
+ (NSArray*)entitiesByCondition:(NSString*)condition;

// 根据查询条件和查询字段查出一个entity列表
+ (NSArray*)entitiesWithProperties:(NSArray*)properties byCondition:(NSString*)condition;

// 将entity对象转换成字典
- (NSDictionary*)dictionary;

@end


#pragma mark - - TNCEntityArray

@interface TNCEntityArray (TNCEntities)

- (void)setSuperEntity:(TNCBaseEntity*)superEntity;

- (BOOL)saveData;

// 返回删除成功的entities
- (NSArray*)deleteData;

- (NSArray*)intersectionWithArray:(NSArray*)anArray;
- (NSArray*)minusArray:(NSArray*)anArray;

// 将entity数组转化成字典数组
- (NSArray*)dictionaryArray;

@end
