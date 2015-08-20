//
//  Person_sister.m
//  TNCBaseEntityDemo
//
//  Created by guanglong on 15/8/10.
//  Copyright (c) 2015年 guanglong. All rights reserved.
//

#import "Person_sisters.h"
#import "Person.h"

@implementation Person_sisters

// 修改属性名和数据库字段名之间的映射关系
+ (NSDictionary *)propertyColumnMap
{
    return @{@"column_name":@"cname",
             @"foreign_name":@"fname",
             @"column_age":@"cage"};
}

#pragma mark - - override
- (NSString *)sqlCreatingTable
{
    NSString* sql = [NSString stringWithFormat:@"create table if not exists %@ \
                     ( \
                     %@      text,  \
                     %@      text, \
                     %@      text, \
                     primary key(%@, %@), \
                     foreign key(%@) references %@(%@) on delete cascade on update cascade \
                     )",
                     self.tableName,
                     self.propertyColumnMap[@"foreign_name"],
                     self.propertyColumnMap[@"column_name"],
                     self.propertyColumnMap[@"column_age"],
                     self.propertyColumnMap[@"foreign_name"],
                     self.propertyColumnMap[@"column_name"],
                     self.propertyColumnMap[@"foreign_name"],
                     self.superTableName,
                     [self.superEntity propertyColumnMap][@"column_name"]];
    return sql;
}

- (NSString *)sqlInserting
{
    NSString* sql = [NSString stringWithFormat:@"replace into %@ \
                     (%@, %@, %@) values \
                     ('%@', '%@', '%@')",
                     self.tableName,
                     self.propertyColumnMap[@"column_name"], self.propertyColumnMap[@"column_age"], self.propertyColumnMap[@"foreign_name"],
                     self.column_name, self.column_age, [self.superEntity column_name]];
    return sql;
}

+ (NSString *)sqlQueryConditionRelating:(Person *)entity
{
    return [NSString stringWithFormat:@"where %@='%@'",
            [self propertyColumnMap][@"foreign_name"],
            entity.column_name];
}

@end
