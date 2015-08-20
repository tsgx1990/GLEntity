//
//  SubViewController.h
//  GLEntity
//
//  Created by guanglong on 15/8/20.
//  Copyright (c) 2015年 guanglong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Person_sisters;

@interface SubViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *mTableView;

@property (nonatomic, strong) NSArray* mySisters;

@end
