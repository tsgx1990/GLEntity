//
//  ViewController.h
//  GLEntity
//
//  Created by guanglong on 15/8/20.
//  Copyright (c) 2015年 guanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (weak, nonatomic) IBOutlet UIButton *titleBtn;
@property (strong, nonatomic) IBOutlet UIButton *botButton;

- (IBAction)botBtnPressed:(id)sender;

@end

