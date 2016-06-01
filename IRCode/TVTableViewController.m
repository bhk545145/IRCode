//
//  TVTableViewController.m
//  IRCode
//
//  Created by 白洪坤 on 16/5/31.
//  Copyright © 2016年 白洪坤. All rights reserved.
//

#import "TVTableViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "JSONKit.h"
#import "TVmodel.h"
#import "MJExtension.h"
#import "TVViewController.h"


@interface TVTableViewController (){
    NSMutableArray *TVmodelarray;
}

@end

@implementation TVTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    TVmodelarray = [[NSMutableArray alloc]init];
    [self gettvbrand];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return [TVmodelarray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"reuseIdentifier"];
    }
    TVmodel *Tvmodel = TVmodelarray[indexPath.row];
    cell.textLabel.text =  Tvmodel.brandid;
    cell.detailTextLabel.text = Tvmodel.brand;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TVViewController *vc = [[TVViewController alloc]init];
    TVmodel *tvmodel = TVmodelarray[indexPath.row];
    vc.TVmodel = tvmodel;
    [self.navigationController pushViewController:vc animated:YES];
}

//1.获取所有电视品牌名称列表
- (void)gettvbrand{
    NSString *str = [NSString stringWithFormat:@"http://172.16.10.206:18880/publicircode/v1/tv/gettvbrand"];
    NSURL *url = [NSURL URLWithString:str];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request startAsynchronous];
    __block ASIHTTPRequest *reqblock = request;
    [request setCompletionBlock:^{
        if (reqblock.responseStatusCode == 200)
        {
            NSLog(@"%@",[reqblock.responseData objectFromJSONData]);
            NSMutableArray *list = [[reqblock.responseData objectFromJSONData] objectForKey:@"brand"];
            
            for (NSMutableDictionary *dict in list)
            {
                TVmodel *tvmodel = [TVmodel mj_objectWithKeyValues:dict];
                [TVmodelarray addObject:tvmodel];
            }
            [self.tableView reloadData];
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"%d",reqblock.responseStatusCode);
    }];
    
}
@end
