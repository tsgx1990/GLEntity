//
//  Person.m
//  TNCBaseEntityDemo
//
//  Created by guanglong on 15/8/10.
//  Copyright (c) 2015年 guanglong. All rights reserved.
//

#import "Person.h"

@implementation Person

#pragma mark - - override

+ (NSString *)tableName
{
    return @"table_custom_person";
}

+ (NSDictionary *)entitiesClassMap
{
    return @{@"column_birthday":[Person_birthday class],
             @"column_sisters":[Person_sisters class]};
}

+ (NSString *)primaryKey
{
    return @"column_name";
}

#pragma mark - - sql statement
- (NSString *)sqlCreatingTable
{
//    NSString* sql = [NSString stringWithFormat:@"create table if not exists %@ \
//                     (Id integer primary key autoincrement, \
//                     column_age text, \
//                     column_name text)",
//                     self.tableName];
//    return sql;
    
    
    NSString* sql = [NSString stringWithFormat:@"create table if not exists %@ \
                     ( \
                     %@        text, \
                     %@        text, \
                     primary key(%@) \
                     )",
                     self.tableName,
                     self.propertyColumnMap[@"column_name"],
                     self.propertyColumnMap[@"column_age"],
                     self.propertyColumnMap[@"column_name"]];
    return sql;
}

- (NSString *)sqlInserting
{
    NSString* sql = [NSString stringWithFormat:@"replace into %@ \
                     (%@, %@, %@) values \
                     ('%i', '%@', '%@')",
                     self.tableName,
                     self.propertyColumnMap[@"column_age"], self.propertyColumnMap[@"column_name"], self.propertyColumnMap[@"column_phones"],
                     self.column_age, self.column_name, self.column_phones];
    return sql;
}

@end
