//
//  CloudTableViewController.m
//  IRCode
//
//  Created by 白洪坤 on 16/5/31.
//  Copyright © 2016年 白洪坤. All rights reserved.
//

#import "CloudTableViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "JSONKit.h"
#import "Cloudmodel.h"
#import "MJExtension.h"
#import "ViewController.h"

@interface CloudTableViewController ()<UITableViewDataSource,UITableViewDelegate>{
    
    NSMutableArray *Cmodelarray;
}

@end

@implementation CloudTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    Cmodelarray = [[NSMutableArray alloc]init];
    [self getacbrand];
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
    return [Cmodelarray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"reuseIdentifier"];
    }
    Cloudmodel *cmodel = Cmodelarray[indexPath.row];
    cell.textLabel.text =  cmodel.brandid;
    cell.detailTextLabel.text = cmodel.brand;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ViewController *vc = [[ViewController alloc]init];
    Cloudmodel *cmodel = Cmodelarray[indexPath.row];
    vc.Cloudmodel = cmodel;
    [self.navigationController pushViewController:vc animated:YES];
}

//15、 获取所有云空调品牌
- (void)getacbrand{
    NSString *str = [NSString stringWithFormat:@"http://172.16.10.206:18880/publicircode/v1/cloudac/getacbrand"];
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
                Cloudmodel *Cmodel = [Cloudmodel mj_objectWithKeyValues:dict];
                [Cmodelarray addObject:Cmodel];
            }
            [self.tableView reloadData];
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"%d",reqblock.responseStatusCode);
    }];
    
}


@end
