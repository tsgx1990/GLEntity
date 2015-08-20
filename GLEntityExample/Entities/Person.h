//
//  Person.h
//  TNCBaseEntityDemo
//
//  Created by guanglong on 15/8/10.
//  Copyright (c) 2015年 guanglong. All rights reserved.
//

#import "GLBaseEntity.h"
#import "Person_birthday.h"
#import "Person_sisters.h"

@interface Person : GLBaseEntity

@property (nonatomic) int column_age;
@property (nonatomic, strong) NSString* column_name;

@property (nonatomic, strong) Person_birthday* column_birthday;

//@property (nonatomic, strong) NSArray* column_birthday;

@property (nonatomic, strong) NSArray* column_sisters;

@property (nonatomic, strong) NSString* column_phones;

@end

