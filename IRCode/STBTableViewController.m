//
//  STBTableViewController.m
//  IRCode
//
//  Created by 白洪坤 on 16/5/31.
//  Copyright © 2016年 白洪坤. All rights reserved.
//

#import "STBTableViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "JSONKit.h"
#import "STBmodel.h"
#import "MJExtension.h"
#import "providerTableViewController.h"
#import "secondlocateidTableViewController.h"


@interface STBTableViewController (){
    
    NSMutableArray *STBmodelarray;
}

@end

@implementation STBTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    STBmodelarray = [[NSMutableArray alloc]init];
    [self getsubarea:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [STBmodelarray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"reuseIdentifier"];
    }
    STBmodel *Stbmodel = STBmodelarray[indexPath.row];
    cell.textLabel.text =  Stbmodel.LocateId;
    cell.detailTextLabel.text = Stbmodel.Name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    secondlocateidTableViewController *vc = [[secondlocateidTableViewController alloc]init];
    STBmodel *Stbmodel = STBmodelarray[indexPath.row];
    vc.STBmodel = Stbmodel;
    [self.navigationController pushViewController:vc animated:YES];
}

//2.根据区域ID获取下级区域ID和名称列表
- (void)getsubarea:(int)locateid{
    NSString *str = [NSString stringWithFormat:@"http://172.16.10.206:18880/publicircode/v1/stb/getsubarea"];
    NSURL *url = [NSURL URLWithString:str];
    //请求的body数据
    NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys: @(locateid), @"locateid",nil];
    NSMutableData *bodydata = [NSMutableData dataWithData:[NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error:nil]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostBody:bodydata];
    [request startAsynchronous];

    __block ASIHTTPRequest *reqblock = request;
    [request setCompletionBlock:^{
        if (reqblock.responseStatusCode == 200)
        {
            NSLog(@"%@",[reqblock.responseData objectFromJSONData]);
            NSMutableArray *list = [[reqblock.responseData objectFromJSONData] objectForKey:@"subareainfo"];
            
            for (NSMutableDictionary *dict in list)
            {
                STBmodel *Stbmodel = [STBmodel mj_objectWithKeyValues:dict];
                [STBmodelarray addObject:Stbmodel];
            }
            [self.tableView reloadData];
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"%d",reqblock.responseStatusCode);
    }];
    
}
@end
