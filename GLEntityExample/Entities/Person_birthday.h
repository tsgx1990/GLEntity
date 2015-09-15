//
//  Person_birthday.h
//  TNCBaseEntityDemo01
//
//  Created by guanglong on 15/8/10.
//  Copyright (c) 2015年 guanglong. All rights reserved.
//

#import "GLBaseEntity.h"

@interface Person_birthday : GLBaseEntity

// 外键，为使用方便，可以重写其getter方法
@property (nonatomic, strong) NSString* foreign_name;

@property (nonatomic, strong) NSString* column_year;
@property (nonatomic, strong) NSString* column_month;
@property (nonatomic, strong) NSString* column_day;

@end
