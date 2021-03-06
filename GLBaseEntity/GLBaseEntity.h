//
//  GLBaseEntity.h
//  GLEntity
//
//  Created by guanglong on 15/8/5.
//  Copyright (c) 2015年 guanglong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "JSONKit.h"
#import "GLDBManager.h"
#import "NSString+AddFormatter.h"

#define GLEntityArray     NSArray

#define GL_TABLE_PREFIX        @"table_"
#define GL_COLUMN_PREFIX       @"column_"
#define GL_PURELIST_SUFFIX     @"_ls"
#define GL_FOREIGN_PREFIX      @"foreign_"

NSString* convertValid(NSString* rawString);

@class GLBaseEntity;

@protocol GLVirtualEntity <NSObject>

@optional
//@property (nonatomic, strong, readonly) NSArray* caredProperties;

#pragma mark - - sql语句

/*
 需要在子类实现的方法
 */

/**
 *  创建表的sql语句，需要子类实现
 *
 *  @return 创建表的sql语句
 */
- (NSString*)sqlCreatingTable;

/**
 *  执行插入操作的sql语句，子类需要实现
 *
 *  @return 插入操作的sql语句
 */
- (NSString*)sqlInserting;

/**
 *  关联查询条件，在子表中对应的entity类中需要实现
 *
 *  @param entity 一般为父表对应的entity
 *
 *  @return 关联查询条件
 */
+ (NSString*)sqlQueryConditionRelating:(GLBaseEntity*)entity;

/**
 *  如果属性中有数组或者entity属性，则需要实现该方法，用于指明他们所对应的entity类（Class）。方法 + (Class)classForKey:(NSString*)propertyName 就是通过该属性来获取一个entity属性或array属性对应的entity类
 *
 *  @return entity属性和Array属性与他们所对应的Class之间的映射关系
 */
+ (NSDictionary*)entitiesClassMap;

/**
 *  必要时，需要在子类中指定主键。注意：该主键应该是属性名，而不是表中的字段名。当需要指定复合主键时需要用逗号隔开。
 *
 *  @return 表中的主键
 */
+ (NSString*)primaryKey;

/*
 父类有默认实现，也可在子类重写的方法
 */

/**
 *  获取entity对应的表名，表名默认为：table_ + entityClassName。如果需要重新指定entity对应的表名，子类可以重写该方法，如果不是必须这么做，建议不要重写该方法改变entity的表名，以防止表名的重复
 *
 *  @return entity对应的表名
 */
+ (NSString*)tableName;

/**
 *  获取属性名和表中字段名的对应关系，默认情况下，二者是相同的。也可以在子类重写，要求：key为属性名，value为表名，且必须是一一映射关系
 *
 *  @return 属性名和表中字段名的映射关系
 */
+ (NSMutableDictionary*)propertyColumnMap;


@end

@interface GLBaseEntity : NSObject<GLVirtualEntity>

/**
 *  父表对应的entity
 */
@property (nonatomic, weak) id superEntity;

/**
 *  获取entity的表名，一定不要重写该属性的getter方法，如果需要改变entity类对应的表名，重写 +(NSString*)tableName 方法
 */
@property (nonatomic, strong, readonly) NSString* tableName;

/**
 *  获取属性名和表中字段的映射关系，一定不要重写该属性的getter方法，如果要改变映射关系，重写 + (NSDictionary*)propertyColumnMap 方法
 */
@property (nonatomic, strong, readonly) NSMutableDictionary* propertyColumnMap;

/**
 *  获取父表的表名，一定不要重写他的getter方法
 */
@property (nonatomic, strong, readonly) NSString* superTableName;

/**
 *  主键或复合主键，只有在子类实现了+ (NSString*)primaryKey，该属性才可用
 */
@property (nonatomic, strong, readonly) NSString* primaryKey;

/**
 *  获取所有entity属性的属性名，子类直接调用，一般情况下不需要重写
 *
 *  @return entity属性的所有属性名
 */
+ (NSArray*)propertyNamesOfEntityProperty;

/**
 *  获取所有NSArray属性的属性名，子类直接调用，一般情况下不需要重写
 *
 *  @return NSArray属性的所有属性名
 */
+ (NSArray*)propertyNamesOfArrayProperty;

/**
 *  返回某个entity属性名或array属性名对应的类，子类不要重写
 *
 *  @param propertyName 属性名
 *
 *  @return 属性名对应的类
 */
+ (Class)classForKey:(NSString*)propertyName;

/**
 *  该方法依赖于与其同名的静态方法，只是为了方便entity的调用，子类不要重写
 *
 *  @param propertyName 属性名
 *
 *  @return 属性名对应的类
 */
- (Class)classForKey:(NSString*)propertyName;

#pragma mark - - entity初始化操作

/**
 *  entity或entity数组的构建，不要子类重写
 *
 *  @param data 需要字典或者数组，传入其他类型的数据将会返回nil
 *
 *  @return 返回一个entity或entity数组，或nil
 */
+ (id)entitiesWithData:(id)data;

/**
 *  entity或entity数组的构建，不要子类重写
 *
 *  @param dict 需要字典或者数组，传入其他类型的数据将会返回nil
 *
 *  @return 返回一个entity或entity数组，或nil
 */
+ (instancetype)entityWithDict:(NSDictionary*)dict;

/**
 *  entity或entity数组的构建，不要子类重写
 *
 *  @param array 需要字典或者数组，传入其他类型的数据将会返回nil
 *
 *  @return 返回一个entity或entity数组，或nil
 */
+ (GLEntityArray*)entitiesWithArray:(NSArray*)array;


#pragma mark - - 数据库操作
/**
 *  将从数据库中查询出来的字典数组转换成entity数组，子类直接调用
 *
 *  @param dbResults 从数据库中查询出来的字典数组
 *
 *  @return entity数组
 */
+ (NSArray*)entitiesWithDBResults:(NSArray*)dbResults;

/**
 *  根据条件，删除数据。如果为条件为nil，将删除表中的所有数据
 *
 *  @param condition 删除条件，写法为：where ...
 *
 *  @return 删除是否成功
 */
+ (BOOL)deleteDataByCondition:(NSString*)condition;

+ (BOOL)deleteDataByConditionFormat:(NSString*)conditionFormat, ...;

/**
 *  删除本条数据，可以在子类重写。但是建议在子类实现+ (NSString*)primaryKey方法，然后直接调用base类的- (BOOL)deleteData 方法来执行删除操作
 *
 *  @return 是否删除成功
 */
- (BOOL)deleteData;


/**
 *  根据条件，更新数据
 *
 *  @param params    需要更新的字段，形式为：set column_name='dabao', column_age='12'。也可以不加"set "，params也可以使用字典类型。
 *  @param condition 更新条件，如果为nil，则更新所有，形式为：where ...
 *
 *  @return 更新是否成功
 */
+ (BOOL)updateDataWithParams:(id)params byCondition:(NSString*)condition;

+ (BOOL)updateDataWithParams:(id)params byConditionFormat:(NSString *)conditionFormat, ...;

/**
 *  用新数据更新旧数据，新数据中如果有非关联表的字段缺失，则将出现空值。如果关联表的字段缺失，则原关联表中的数据不变。
 *
 *  @param rawData 更新用的原生数据（一个原生字典，或原生字典数组）
 *
 *  @return 是否更新成功
 */
+ (BOOL)updateDataWithRawData:(id)rawData;

/**
 *  满足条件的数据条数，直接调用
 *
 *  @param condition 数据查询条件
 *
 *  @return 满足条件的数据条数
 */
+ (NSInteger)countMeetingCondition:(NSString*)condition;

+ (NSInteger)countMeetingConditionFormat:(NSString*)conditionFormat, ...;

/**
 *  该方法的实现依赖于与其对应的静态方法，无需重写，直接调用
 *
 *  @param condition 数据查询条件
 *
 *  @return 满足条件的数据条数
 */
- (NSInteger)countMeetingCondition:(NSString*)condition;

- (NSInteger)countMeetingConditionFormat:(NSString*)conditionFormat, ...;

/*
 不需要在子类实现的方法
 */

/**
 *  保存本条数据
 *
 *  @return 是否保存成功
 */
- (BOOL)saveData;

/**
 *  更新某个特定属性（同时会更新数据库）
 *
 *  @param value 需要更新到的值
 *  @param key   待更新的属性名
 *
 *  @return 更新是否成功
 */
- (BOOL)updateValue:(id)value forKey:(NSString*)key;

/**
 *  查询出表中的所有数据
 *
 *  @return 一个entity列表
 */
+ (NSArray*)entities;

/**
 *  根据条件查询数据
 *
 *  @param condition 查询条件，如果为nil，表示查询出所有数据，同 + (NSArray*)entities
 *
 *  @return 一个entity列表
 */
+ (NSArray*)entitiesByCondition:(NSString*)condition;

+ (NSArray*)entitiesByConditionFormat:(NSString*)conditionFormat, ...;

/**
 *  根据查询条件和查询字段查出一个entity列表
 *
 *  @param properties 需要查询的属性名列表，可以是entity属性或NSArray属性
 *  @param condition  查询条件，如果为nil，表示查询所有
 *
 *  @return 一个entity列表
 */
+ (NSArray*)entitiesWithProperties:(NSArray*)properties byCondition:(NSString*)condition;

+ (NSArray*)entitiesWithProperties:(NSArray*)properties byConditionFormat:(NSString*)conditionFormat, ...;

///**
// *  将entity对象转换成字典
// *
// *  @return entity对应的字典
// */
//- (NSDictionary*)dictionary;

/**
 *  entity对应的字典
 */
@property (nonatomic, strong, readonly) NSDictionary* dictionary;

@end


#pragma mark - - GLEntityArray

@interface GLEntityArray (GLEntities)

/**
 *  设置array中每个entity的superEntity
 *
 *  @param superEntity 父表对应的entity，该方法一般不要主动调用
 */
- (void)setSuperEntity:(GLBaseEntity*)superEntity;

/**
 *  保存entity数组
 *
 *  @return 是否保存成功
 */
- (BOOL)saveData;

/**
 *  删除entity数组
 *
 *  @return 返回所有被删除的entity
 */
- (NSArray*)deleteData;

/**
 *  获取当前数组和给定数组的交集
 *
 *  @param anArray 给数组
 *
 *  @return 两个数组的交集
 */
- (NSArray*)intersectionWithArray:(NSArray*)anArray;

/**
 *  从当前数组中减去与给定数组的交集部分
 *
 *  @param anArray 给定数组
 *
 *  @return 当前数据 - 给定数组
 */
- (NSArray*)minusArray:(NSArray*)anArray;

///**
// *  将entity数组转化成字典数组
// *
// *  @return 字典数组
// */
//- (NSArray*)dictionaryArray;

/**
 *  entity数组转化成的字典数组
 */
@property (nonatomic, strong, readonly) NSArray* dictionaryArray;

@end
