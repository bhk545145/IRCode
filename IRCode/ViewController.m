//
//  ViewController.m
//  IRCode
//
//  Created by 白洪坤 on 16/5/31.
//  Copyright © 2016年 白洪坤. All rights reserved.
//

#import "ViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "JSONKit.h"
#import "Cloudmodel.h"
#import "MJExtension.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>{
    Cloudmodel *Cmodel;
    NSMutableArray *Cmodelarray;
    NSString *filepathFolder;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    Cmodelarray = [[NSMutableArray alloc]init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    filepathFolder = [paths objectAtIndex:0];
    [self getacversion];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setCloudmodel:(Cloudmodel *)Cloudmodel{
    _Cloudmodel = Cloudmodel;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [Cmodelarray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"reuseIdentifier"];
    }
    cell.textLabel.text = Cmodelarray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self geturlbybrand:Cmodelarray[indexPath.row]];
}

//16、 根据空调品牌ID获取空调型号
- (void)getacversion{
    NSString *str = [NSString stringWithFormat:@"http://172.16.10.206:18880/publicircode/v1/cloudac/getacversion"];
    NSURL *url = [NSURL URLWithString:str];
    //请求的body数据
    int brandid = [_Cloudmodel.brandid intValue];
        NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys: @(brandid), @"brandid", nil];
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
            Cmodelarray = [[reqblock.responseData objectFromJSONData] objectForKey:@"versionarray"];
            [self.tableView reloadData];
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"%d",reqblock.responseStatusCode);
    }];
    
}

//17、 根据空调品牌ID和型号获取空调红码临时下载ID和随机数
- (void)geturlbybrand:(NSString *)version{
    NSString *str = [NSString stringWithFormat:@"http://172.16.10.206:18880/publicircode/v1/cloudac/geturlbybrand"];
    NSURL *url = [NSURL URLWithString:str];
    //请求的body数据
    int brandid = [_Cloudmodel.brandid intValue];
    NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys: @(brandid), @"brandid", version,@"version",@"",@"devid",@"",@"appid",nil];
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
            NSString *geturlbybrand = [[[reqblock.responseData objectFromJSONData] objectForKey:@"data"] objectForKey:@"downloadurl"];
            geturlbybrand = [geturlbybrand substringWithRange:NSMakeRange(83,8)];
            [self downloadlua:geturlbybrand];
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"%d",reqblock.responseStatusCode);
    }];
    
}

//19、 固件空调红码下载（根据临时下载ID和随机数）
- (void)downloadlua:(NSString *)urlbybrand{
    NSString *str = [NSString stringWithFormat:@"http://172.16.10.206:18880/publicircode/v1/cloudac/downloadlua?interimid=%@",urlbybrand];
    NSURL *url = [NSURL URLWithString:str];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request startAsynchronous];
    __block ASIHTTPRequest *reqblock = request;
    [request setCompletionBlock:^{
        if (reqblock.responseStatusCode == 200)
        {
            NSString *filepath = [filepathFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.lua", _Cloudmodel.brand]];
            NSLog(@"filepath: %@", filepath);
            if ([reqblock.responseData writeToFile:filepath atomically:YES]){
                NSLog(@"空调红码下载成功!!!");
            }
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"%d",reqblock.responseStatusCode);
    }];
    
}
@end
