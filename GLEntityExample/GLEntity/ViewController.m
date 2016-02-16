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
    
    [self.mTableView registerClass:[TableViewCell class] forCellReuseIdentifier:@"cellID"];
    self.mTableView.tableHeaderView = self.titleBtn;
//    self.mTableView.tableFooterView = self.botButton;
    
    [self loadDataInitial];
}

- (void)loadDataInitial
{
    [self.botButton setTitle:@"更新数据" forState:UIControlStateNormal];
    [self loadData];
    perDataArray = [Person entities];
    [self.mTableView reloadData];
}

- (void)loadData
{
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
//                            @"sisters":@[],
                            @"phones":@[@"symbian", @"Nokia"]};
    
//    Person* per = [Person entityWithDict:dict];
//    [per saveData];
    
//    pers = @[[Person entityWithDict:dict],
//             [Person entityWithDict:dict1],
//             [Person entityWithDict:dict2]];
    
//    pers = [Person entitiesWithArray:@[dict, dict1, dict2]];
    pers = [Person entitiesWithData:@[dict, dict1, dict2]];
    [pers saveData];
}

- (void)loadNewData
{
    NSDictionary* dict = @{@"name":@"lgl",
                           @"birthday":@{@"year":@"1990",
                                         @"month":@"07",
                                         @"day":@"01"},
                           @"age":@"11",
                           @"sisters":@[@{@"name":@"xcc", @"age":@"45"},
                                        @{@"name":@"xyj", @"age":@"30"}],
                           @"phones":@[@"android", @"apple"]};
    
    
    NSDictionary* dict1 = @{@"name":@"lol123",
                            @"birthday":@{@"year":@"2080",
                                          @"month":@"01",
                                          @"day":@"03"},
                            @"age":@"4",
                            @"sisters":@[@{@"name":@"lol1", @"age":@"15"},
                                         @{@"name":@"lol2", @"age":@"60"},
                                         @{@"name":@"lol3", @"age":@"88"}]};
    
    NSDictionary* dict2 = @{@"name":@"lcc",
                            @"birthday":@{@"year":@"1980",
                                          @"month":@"12",
                                          @"day":@"12"},
                            @"age":@"11",
                            @"sisters":@[],
                            @"phones":@[@"symbian", @"Nokia", @"ios", @"apple"]};
    
    
//    pers = @[[Person entityWithDict:dict],
//             [Person entityWithDict:dict1],
//             [Person entityWithDict:dict2]];
    
//    pers = [Person entitiesWithArray:@[dict, dict1, dict2]];
    pers = [Person entitiesWithData:@[dict, dict1, dict2]];
    [pers saveData];
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
    Person* per = perDataArray[indexPath.row];
    NSArray* sisters = per.column_sisters;
    if (sisters.count) {
        SubViewController* subVC = [[SubViewController alloc] init];
        subVC.mySisters = sisters;
        [self.navigationController pushViewController:subVC animated:YES];
    }
    else {
        NSString* tipStr = [NSString stringWithFormat:@"%@暂时没有Sisters", per.column_name];
        UIAlertView* alert = [[UIAlertView alloc ]initWithTitle:tipStr message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }
}

- (IBAction)testBtnPressed:(id)sender {
//    [(Person*)pers[0] deleteData];

//    [Person deleteDataByCondition:@"where column_name='lgl' or column_name='lcc'"];
//    [Person deleteDataByCondition:nil];

//    [Person updateDataWithParams:@"set column_name='dabao'" byCondition:nil];

//    [Person_birthday updateDataWithParams:@"set column_year='2000'" byCondition:nil];

//    perDataArray = [Person entitiesWithProperties:@[@"column_name", @"column_age", @"column_birthday", @"column_sisters"]
//                                      byCondition:nil]; //[Person entities];

//    [pers saveData];
    
//    NSLog(@"perDataArray:%@", perDataArray);
//    NSLog(@"personDictArray:%@", [[perDataArray lastObject] dictionary]);
    
    NSLog(@"dictionaryArray:%@", perDataArray.dictionaryArray);
    NSLog(@"lastDictionary:%@", [[perDataArray lastObject] dictionary]);
    
    int testAge = 11;
    NSLog(@"meeting age = %i count:%li", testAge, (long)[Person countMeetingConditionFormat:@"where column_age='%i'", testAge]);
    
    NSString* phonesStr = [[[Person entitiesByCondition:@"where column_name='lyh'"] firstObject] column_phones];
    NSLog(@"phones:%@, phonesLength:%li", phonesStr, (long)phonesStr.length);
    
    /*
//    [Person updateDataWithParams:@{@"age":@"123"} byCondition:@"where name='lgl'"];
    [Person updateDataWithParams:@"set column_age='123'" byCondition:@"where column_name='lgl'"];
//    [Person_birthday updateDataWithParams:@"column_year='1999', column_month='13', column_day='33'" byCondition:@"where foreign_name='lgl'"];
    [Person_birthday updateDataWithParams:@{@"column_year":@"3999", @"column_month":@(13), @"column_day":@"33"} byCondition:@"where foreign_name='lgl'"];
     */
    
    /*
    NSDictionary* dict = @{@"name":@"lgl",
                           @"birthday":@{@"year":@"9990",
                                         @"month":@"072",
                                         @"day":@"201"},
                           @"age":@"101",
                           @"sisters":@[@{@"name":@"xcc", @"age":@"143"},
                                        @{@"name":@"xyj", @"age":@"310"}],
                           @"phones":@[@"android", @"apple"]
                           };
    [Person updateDataWithRawData:dict];
    */
    
//    [Person deleteDataByCondition:@"where column_name='lgl'"];
//    [Person deleteDataByConditionFormat:@"where column_name='%@'", nil];
//    [Person deleteDataByConditionFormat:nil];
    
    NSArray* entities1 = [Person entitiesWithProperties:@[@"column_name", @"column_age", @"column_birthday", @"column_sisters"]
                                      byConditionFormat:@"where column_name = '%@'", @"lgl"];
    NSLog(@"entities1:%@", entities1);
    
    NSArray* entities2 = [Person entitiesByConditionFormat:@"where column_age='%i'", 11];
    NSLog(@"entities2:%@", entities2);
    
    [Person updateDataWithParams:@{@"column_age":@"11", @"column_name":@"lgl123"} byConditionFormat:@"where column_name='%@'", @"lgl"];
    
    perDataArray = [Person entities];
    [self.mTableView reloadData];
}

- (IBAction)botBtnPressed:(UIButton*)sender {
    int flag = sender.tag % 3;
    
    if (flag == 0) {
        [sender setTitle:@"清空数据" forState:UIControlStateNormal];
        [self loadNewData];
        perDataArray = [Person entities];
    }
    if (flag == 1) {
        [sender setTitle:@"重新加载数据" forState:UIControlStateNormal];
        NSArray* deletedEntities = [perDataArray deleteData];
        perDataArray = [perDataArray minusArray:deletedEntities];
    }
    if (flag == 2) {
        [sender setTitle:@"更新数据" forState:UIControlStateNormal];
        [self loadData];
        perDataArray = [Person entities];
    }
    
    [self.mTableView reloadData];
    sender.tag++;
}
@end
