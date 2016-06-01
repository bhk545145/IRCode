//
//  TVViewController.m
//  IRCode
//
//  Created by 白洪坤 on 16/5/31.
//  Copyright © 2016年 白洪坤. All rights reserved.
//

#import "providerTableViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "JSONKit.h"
#import "STBmodel.h"
#import "MJExtension.h"
#import "STBlocateidprovideridViewController.h"
@interface providerTableViewController ()<UITableViewDataSource,UITableViewDelegate>{
    
    NSMutableArray *STBmodelarray;
    NSMutableArray *STBlocateprovideridmodelarray;
    NSString *filepathFolder;
}

@end

@implementation providerTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    STBmodelarray = [[NSMutableArray alloc]init];
    STBlocateprovideridmodelarray = [[NSMutableArray alloc]init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    filepathFolder = [paths objectAtIndex:0];
    [self getprovider];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setSTBmodel:(STBmodel *)STBmodel{
    _STBmodel = STBmodel;
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
    cell.textLabel.text = Stbmodel.providerid;
    cell.detailTextLabel.text = Stbmodel.provider;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    STBlocateidprovideridViewController *vc = [[STBlocateidprovideridViewController alloc]init];
    STBmodel *stbmodel = STBmodelarray[indexPath.row];
    vc.STBmodel = stbmodel;
    [self.navigationController pushViewController:vc animated:YES];
}

//3、  根据区域id获取区域供应商ID和名称列表
- (void)getprovider{
    NSString *str = [NSString stringWithFormat:@"http://172.16.10.206:18880/publicircode/v1/stb/getprovider"];
    NSURL *url = [NSURL URLWithString:str];
    //请求的body数据
    int LocateId = [_STBmodel.LocateId intValue];
    NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys: @(LocateId), @"locateid",nil];
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
            NSArray *list = [[reqblock.responseData objectFromJSONData] objectForKey:@"providerinfo"];
            for (NSDictionary *dict in list) {
                STBmodel *Stbmodel = [STBmodel mj_objectWithKeyValues:dict];
                _STBmodel.providerid = Stbmodel.providerid;
                _STBmodel.provider = Stbmodel.provider;
                [STBmodelarray addObject:_STBmodel];
            }
            [self.tableView reloadData];
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"%d",reqblock.responseStatusCode);
    }];
}


@end
