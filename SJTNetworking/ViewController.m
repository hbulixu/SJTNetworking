//
//  ViewController.m
//  SJTNetworking
//
//  Created by 58 on 2018/3/1.
//  Copyright © 2018年 LX. All rights reserved.
//

#import "ViewController.h"
#import "SJTNetworkCenter.h"
#import "AFNetworking.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    
//    [SJTNetworkCenter GET:@"http://rapapi.org/mockjsdata/30918/http//advbanner.com" parameters:nil success:^(SJTRequest *request) {
//        NSLog(@"%@",request.responseJSONObject);
//        
//    } failure:^(SJTRequest *request, NSError *error) {
//        NSLog(@"%ld",error.code);
//    }];
//    
//    NSMutableArray * requestArray = [NSMutableArray arrayWithCapacity:0];
//    for (int i =0 ; i < 10; i ++) {
//        SJTRequest * request = [SJTRequest requestWithUrl:@"http://rapapi.org/mockjsdata/30918/http//advbanner.com" requestMethod:SJTRequestMethodGet requestParams:nil];
//        [requestArray addObject:request];
//    }
//    
//    [SJTNetworkCenter sendRequestArray:requestArray success:^(SJTBatchRequest *request) {
//        for (SJTRequest *baseRequest in request.requestArray) {
//            NSLog(@"%@",baseRequest.responseJSONObject);
//            NSLog(@"%@",baseRequest);
//        }
//    } failure:^(SJTBatchRequest *request, NSError *error) {
//        
//    }];
    

}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    [SJTNetworkCenter GET:@"http://img-blog.csdn.net/20170527112511098?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQveWlyYWw=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center" parameters:nil filePath:nil process:^(NSProgress *progress) {
//        
//    } success:^(SJTDownLoadRequest *request) {
//        NSLog(@"%@",request.downLoadPath);
//    } failure:^(SJTDownLoadRequest *request, NSError *error) {
//        
//    }];
    
//    [SJTNetworkCenter GET:@"http://rapapi.org/mockjsdata/30918/http//advbanner.com" parameters:nil cachePolicy:SJTCachePolicyTalkServerAfterLoadCache success:^(SJTRequest *request) {
//        NSLog(@"%@",request.responseJSONObject);
//    } failure:^(SJTRequest *request, NSError *error) {
//
//    }];
    NSDictionary * dic = @{@"refer":@"http://localhost:8088/consultPhone",
                           @"clientId":@"2",
                           @"platform":@"baidu",
                           @"ip":@"127.0.0.1",
                           @"id58":@"c5/nn1sHiD9Nf5dHLukfAg==",
                           @"source":@"1",
                           @"channel":@"7",
                           @"cityId":@"1",
                           @"terminal":@"m"
                           };
    [SJTNetworkCenter GET:@"http://localhost:8088/consultPhone/Verify" parameters:dic success:^(SJTRequest *request) {
        NSLog(@"%@",request.responseJSONObject);
    } failure:^(SJTRequest *request, NSError *error) {
        
    }];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
