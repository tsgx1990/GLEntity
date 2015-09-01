//
//  ViewController.m
//  GLEntity
//
//  Created by guanglong on 15/8/20.
//  Copyright (c) 2015年 guanglong. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import "Person_birthday.h"

#import "TableViewCell.h"
#import "SubViewController.h"

@interface ViewController ()

@end

@implementation ViewController
{
    NSArray* pers;
    NSArray* perDataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Person";
    // Do any additional setup after loading the view, typically from a nib.
    
    NSDictionary* dict = @{@"name":@"lgl",
                           @"birthday":@{@"year":@"1990",
                                         @"month":@"07",
                                         @"day":@"01"},
                           @"age":@"11",
                           @"sisters":@[@{@"name":@"xcc", @"age":@"45"},
                                        @{@"name":@"xyj", @"age":@"30"}],
                           @"phones":@[@"android", @"apple"]};
    
    NSDictionary* dict1 = @{@"name":@"lyh",
                            @"birthday":@{@"year":@"1980",
                                          @"month":@"01",
                                          @"day":@"03"},
                            @"age":@"12",
                            @"sisters":@[@{@"name":@"ay", @"age":@"15"},
                                         @{@"name":@"bfj", @"age":@"60"},
                                         @{@"name":@"ly", @"age":@"88"}]};
    
    
    NSDictionary* dict2 = @{@"name":@"lcc",
                            @"birthday":@{@"year":@"1970",
                                          @"month":@"05",
                                          @"day":@"02"},
                            @"age":@"11",
                            @"sisters":@[],
                            @"phones":@[@"symbian", @"Nokia"]};
    
    
//    Person* per = [Person entityWithDict:dict];
//    [per saveData];
    
    pers = @[[Person entityWithDict:dict],
             [Person entityWithDict:dict1],
             [Person entityWithDict:dict2]];
    [pers saveData];
    
    [self.mTableView registerClass:[TableViewCell class] forCellReuseIdentifier:@"cellID"];
    self.mTableView.tableHeaderView = self.titleBtn;
//    self.mTableView.tableFooterView = self.botButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return perDataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 93.0f;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    return [cell cellWithInfo:perDataArray[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* sisters = [perDataArray[indexPath.row] column_sisters];
    if (sisters.count) {
        SubViewController* subVC = [[SubViewController alloc] init];
        subVC.mySisters = sisters;
        [self.navigationController pushViewController:subVC animated:YES];
    }
}

- (IBAction)deleteSelf:(id)sender {
//    [(Person*)pers[0] deleteData];

//    [Person deleteDataByCondition:@"where column_name='lgl' or column_name='lcc'"];
//    [Person deleteDataByCondition:nil];

//    [Person updateDataWithParams:@"set column_name='dabao'" byCondition:nil];

//    [Person_birthday updateDataWithParams:@"set column_year='2000'" byCondition:nil];

//    perDataArray = [Person entitiesWithProperties:@[@"column_name", @"column_age", @"column_birthday", @"column_sisters"]
//                                      byCondition:nil]; //[Person entities];

//    [pers saveData];
    
    perDataArray = [Person entities];
    
    [self.mTableView reloadData];
    
//    NSLog(@"perDataArray:%@", perDataArray);
//    NSLog(@"personDictArray:%@", [[perDataArray lastObject] dictionary]);
    
    NSLog(@"count:%li", (long)[Person countMeetingCondition:@"where column_age='11'"]);
}

- (IBAction)botBtnPressed:(id)sender {
    
    NSArray* deletedEntities = [perDataArray deleteData];
    perDataArray = [perDataArray minusArray:deletedEntities];
    
    [self.mTableView reloadData];
    
}
@end
