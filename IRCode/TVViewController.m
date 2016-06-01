//
//  TVViewController.m
//  IRCode
//
//  Created by 白洪坤 on 16/5/31.
//  Copyright © 2016年 白洪坤. All rights reserved.
//

#import "TVViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "JSONKit.h"
#import "TVmodel.h"
#import "MJExtension.h"
@interface TVViewController ()<UITableViewDataSource,UITableViewDelegate>{
    
    NSMutableArray *TVmodelarray;
    NSString *filepathFolder;
}

@end

@implementation TVViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    TVmodelarray = [[NSMutableArray alloc]init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    filepathFolder = [paths objectAtIndex:0];
    [self geturlbybrand];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setTVmodel:(TVmodel *)TVmodel{
    _TVmodel = TVmodel;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [TVmodelarray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
 if(cell == nil){
 cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"reuseIdentifier"];
 }
 cell.textLabel.text = TVmodelarray[indexPath.row];
 
 return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self downloadirdata:TVmodelarray[indexPath.row]];
}

//4、根据品牌（型号暂未使用）获取电视红码下载URL
- (void)geturlbybrand{
    NSString *str = [NSString stringWithFormat:@"http://172.16.10.206:18880/publicircode/v1/tv/geturldbybrand"];
    NSURL *url = [NSURL URLWithString:str];
    //请求的body数据
    int brandid = [_TVmodel.brandid intValue];
    NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys: @(brandid), @"brandid",nil];
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
            NSMutableArray *list = [[reqblock.responseData objectFromJSONData] objectForKey:@"data"];
            for (NSDictionary *dict in list) {
                TVmodel *Tvmodel = [TVmodel mj_objectWithKeyValues:dict];
                [TVmodelarray addObject:Tvmodel.downloadurl];
            }
            [self.tableView reloadData];
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"%d",reqblock.responseStatusCode);
    }];
}

//6.根据下载地址下载电视红码
- (void)downloadirdata:(NSString *)urlbybrand{
    urlbybrand = [urlbybrand substringWithRange:NSMakeRange(81,8)];
    NSString *str = [NSString stringWithFormat:@"http://172.16.10.206:18880/publicircode/v1/tv/downloadirdata?interimid=%@",urlbybrand];
    NSURL *url = [NSURL URLWithString:str];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request startAsynchronous];
    __block ASIHTTPRequest *reqblock = request;
    [request setCompletionBlock:^{
        if (reqblock.responseStatusCode == 200)
        {
            NSString *filepath = [filepathFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.lua", _TVmodel.brand]];
            NSLog(@"filepath: %@", filepath);
            if ([reqblock.responseData writeToFile:filepath atomically:YES]){
                NSLog(@"TV红码下载成功!!!");
            }
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"%d",reqblock.responseStatusCode);
    }];
    
}
@end
