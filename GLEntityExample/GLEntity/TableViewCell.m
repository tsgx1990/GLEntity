//
//  TableViewCell.m
//  GLEntity
//
//  Created by guanglong on 15/8/20.
//  Copyright (c) 2015年 guanglong. All rights reserved.
//

#import "TableViewCell.h"
#import "Person_birthday.h"

@implementation TableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self = [[NSBundle mainBundle] loadNibNamed:@"TableViewCell" owner:nil options:nil][0];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)cellWithInfo:(Person *)person
{
    self.nameLabel.text = person.column_name;
    self.ageLabel.text = [NSString stringWithFormat:@"%i", person.column_age];
    
    Person_birthday* birthday = person.column_birthday;
    self.birthdayLabel.text = [NSString stringWithFormat:@"生日:%@ %@ %@", birthday.column_year, birthday.column_month, birthday.column_day];
    
    return self;
}

@end
