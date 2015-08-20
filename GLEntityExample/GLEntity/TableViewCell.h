//
//  TableViewCell.h
//  GLEntity
//
//  Created by guanglong on 15/8/20.
//  Copyright (c) 2015年 guanglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"

@interface TableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *birthdayLabel;

- (instancetype)cellWithInfo:(Person*)person;

@end
