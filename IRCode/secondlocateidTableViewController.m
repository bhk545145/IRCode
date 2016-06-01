//
//  TVViewController.m
//  IRCode
//
//  Created by 白洪坤 on 16/5/31.
//  Copyright © 2016年 白洪坤. All rights reserved.
//

#import "secondlocateidTableViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "JSONKit.h"
#import "STBmodel.h"
#import "MJExtension.h"
#import "providerTableViewController.h"
#import "STBlocateidprovideridViewController.h"
@interface secondlocateidTableViewController ()<UITableViewDataSource,UITableViewDelegate>{
    
    NSMutableArray *STBmodelarray;
    NSMutableArray *STBlocateprovideridmodelarray;
    NSString *filepathFolder;
}

@end

@implementation secondlocateidTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    STBmodelarray = [[NSMutableArray alloc]init];
    STBlocateprovideridmodelarray = [[NSMutableArray alloc]init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    filepathFolder = [paths objectAtIndex:0];
    int LocateId = [_STBmodel.LocateId intValue];
    [self getsubarea:LocateId];
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
    cell.textLabel.text =  Stbmodel.LocateId;
    cell.detailTextLabel.text = Stbmodel.Name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    providerTableViewController *vc = [[providerTableViewController alloc]init];
    STBmodel *stbmodel = STBmodelarray[indexPath.row];
    vc.STBmodel = stbmodel;
    [self.navigationController pushViewController:vc animated:YES];
    //[self downloadirdata:STBmodelarray[indexPath.row]];
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
