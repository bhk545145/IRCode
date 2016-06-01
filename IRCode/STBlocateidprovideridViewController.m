//
//  STBlocateidprovideridViewController.m
//  IRCode
//
//  Created by 白洪坤 on 16/6/1.
//  Copyright © 2016年 白洪坤. All rights reserved.
//

#import "STBlocateidprovideridViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "JSONKit.h"
#import "STBmodel.h"
#import "MJExtension.h"

@interface STBlocateidprovideridViewController ()<UITableViewDataSource,UITableViewDelegate>{
    
    NSMutableArray *STBmodelarray;
    NSMutableArray *STBlocateprovideridmodelarray;
    NSString *filepathFolder;
}

@end

@implementation STBlocateidprovideridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    STBmodelarray = [[NSMutableArray alloc]init];
    STBlocateprovideridmodelarray = [[NSMutableArray alloc]init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    filepathFolder = [paths objectAtIndex:0];
    [self geturlbyarea];
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
    cell.textLabel.text = STBmodelarray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self downloadirdata:STBmodelarray[indexPath.row]];
}

//5、  根据区域id和供应商id获取机顶盒红码下载URL
- (void)geturlbyarea{
    NSString *str = [NSString stringWithFormat:@"http://172.16.10.206:18880/publicircode/v1/stb/geturlbyarea"];
    NSURL *url = [NSURL URLWithString:str];
    //请求的body数据
    int LocateId = [_STBmodel.LocateId intValue];
    int providerid = [_STBmodel.providerid intValue];
    NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys: @(LocateId), @"locateid",@(providerid),@"providerid",nil];
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
                STBmodel *Stbmodel = [STBmodel mj_objectWithKeyValues:dict];
                [STBmodelarray addObject:Stbmodel.downloadurl];
            }
            [self.tableView reloadData];
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"%d",reqblock.responseStatusCode);
    }];
}

//7.根据下载地址下载机顶盒红码
- (void)downloadirdata:(NSString *)urlbybrand{
    urlbybrand = [urlbybrand substringWithRange:NSMakeRange(82,8)];
    NSString *str = [NSString stringWithFormat:@"http://172.16.10.206:18880/publicircode/v1/tv/downloadirdata?interimid=%@",urlbybrand];
    NSURL *url = [NSURL URLWithString:str];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request startAsynchronous];
    __block ASIHTTPRequest *reqblock = request;
    [request setCompletionBlock:^{
        if (reqblock.responseStatusCode == 200)
        {
            NSString *filepath = [filepathFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.lua", _STBmodel.Name]];
            NSLog(@"filepath: %@", filepath);
            if ([reqblock.responseData writeToFile:filepath atomically:YES]){
                NSLog(@"STB红码下载成功!!!");
            }
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"%d",reqblock.responseStatusCode);
    }];
    
}
@end
