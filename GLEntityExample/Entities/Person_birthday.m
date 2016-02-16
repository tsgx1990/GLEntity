//
//  Person_birthday.m
//  TNCBaseEntityDemo01
//
//  Created by guanglong on 15/8/10.
//  Copyright (c) 2015年 guanglong. All rights reserved.
//

#import "Person_birthday.h"
#import "Person.h"

@implementation Person_birthday

+ (NSString *)tableName
{
    return @"table_custom_birthday";
}

- (NSString *)sqlCreatingTable
{
//    NSString* sql = [NSString stringWithFormat:@"create table if not exists %@ \
//                     (Id integer primary key autoincrement, \
//                     column_year text, \
//                     column_month text, \
//                     column_day text)",
//                     self.tableName];
//    return sql;
    
    NSString* sql = [NSString stringWithFormat:@"create table if not exists %@ \
                     (  \
                     %@       text,  \
                     %@        text, \
                     %@       text, \
                     %@         text, \
                     primary key(%@) \
                     CONSTRAINT %@ foreign key(%@) references %@(%@) on delete cascade on update cascade \
                     )", // CONSTRAINT %@ http://blog.csdn.net/yohunl/article/details/13771537
                     self.tableName,
                     self.propertyColumnMap[@"foreign_name"],
                     self.propertyColumnMap[@"column_year"],
                     self.propertyColumnMap[@"column_month"],
                     self.propertyColumnMap[@"column_day"],
                     self.propertyColumnMap[@"foreign_name"],
                     self.superTableName,
                     self.propertyColumnMap[@"foreign_name"],
                     self.superTableName,
                     [self.superEntity propertyColumnMap][@"column_name"]];
    
    // primary key(person_name), 
    return sql;
}

- (NSString *)sqlInserting
{
    NSString* sql = [NSString stringWithFormat:@"replace into %@ \
                     (%@, %@, %@, %@) values \
                     ('%@', '%@', '%@', '%@')",
                     self.tableName,
                     self.propertyColumnMap[@"column_year"], self.propertyColumnMap[@"column_month"], self.propertyColumnMap[@"column_day"], self.propertyColumnMap[@"foreign_name"],
                     self.column_year, self.column_month, self.column_day, [self.superEntity column_name]];
    return sql;
}

+ (NSString *)sqlQueryConditionRelating:(Person *)entity
{
    return [NSString stringWithFormat:@"where %@='%@'", [self propertyColumnMap][@"foreign_name"], entity.column_name];
}

@end
