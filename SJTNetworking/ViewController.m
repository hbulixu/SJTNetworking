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
    
    [SJTNetworkCenter GET:@"http://rapapi.org/mockjsdata/30918/http//advbanner.com" parameters:nil cachePolicy:SJTCachePolicyTalkServerAfterLoadCache success:^(SJTRequest *request) {
        NSLog(@"%@",request.responseJSONObject);
    } failure:^(SJTRequest *request, NSError *error) {

    }];
//    NSDictionary * dic = @{@"refer":@"http://localhost:8088/consultPhone",
//                           @"clientId":@"2",
//                           @"platform":@"baidu",
//                           @"ip":@"127.0.0.1",
//                           @"id58":@"c5/nn1sHiD9Nf5dHLukfAg==",
//                           @"source":@"1",
//                           @"channel":@"7",
//                           @"cityId":@"1",
//                           @"terminal":@"m"
//                           };
//    [SJTNetworkCenter GET:@"http://localhost:8088/consultPhone/Verify" parameters:dic success:^(SJTRequest *request) {
//        NSLog(@"%@",request.responseJSONObject);
//    } failure:^(SJTRequest *request, NSError *error) {
//
//    }];
    
    UIImage * image = [UIImage imageNamed:@"btg_icon_priority_0_selected@2x"];
    NSData * imageData = UIImagePNGRepresentation(image);
    NSString *uploadUrl = @"https://upload.58cdn.com.cn";
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:uploadUrl parameters:nil constructingBodyWithBlock:nil error:nil];
    
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"1" forHTTPHeaderField:@"Pic-Flash"];
    [request addValue:@"/p1/big/" forHTTPHeaderField:@"Pic-Path"];
    [request addValue:@"0*0" forHTTPHeaderField:@"Pic-Size"];
    [request addValue:@"0" forHTTPHeaderField:@"Pic-Bulk"];
    [request addValue:@"0" forHTTPHeaderField:@"Pic-dpi"];
    [request addValue:@"0*0*0*0" forHTTPHeaderField:@"Pic-Cut"];
    [request addValue:@"true" forHTTPHeaderField:@"Pic-IsAddWaterPic"];
    [request addValue:@"jpg" forHTTPHeaderField:@"File-Extensions"];
    [request setHTTPBody:imageData];
    [request setTimeoutInterval:60.0];
    SJTUploadRequest * uploadRequest = [SJTUploadRequest new];
    uploadRequest.customRequest = request;
    
    SJTUploadRequest * uploadRequest1 = [SJTUploadRequest new];
    uploadRequest1.customRequest = request;
//    [SJTNetworkCenter sendUploadRequest:uploadRequest process:^(NSProgress *progress) {
//
//    } success:^(SJTUploadRequest *request) {
//
//        NSString *picName = [[NSString alloc] initWithData:request.responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"http://pic1.58cdn.com.cn/p1/big/%@",picName);
//
//    } failure:^(SJTUploadRequest *request, NSError *error) {
//
//    }];
    
//    [SJTNetworkCenter sendUploadRequestArray:@[uploadRequest,uploadRequest1] success:^(SJTBatchUploadRequest *requests) {
//        for ( SJTUploadRequest * request in requests.requestArray) {
//            NSString *picName = [[NSString alloc] initWithData:request.responseObject encoding:NSUTF8StringEncoding];
//                    NSLog(@"http://pic1.58cdn.com.cn/p1/big/%@",picName);
//        }
//
//
//    } failure:^(SJTBatchUploadRequest *request, NSError *error) {
//
//    }];
//    SJTDownLoadRequest * downloadRequest = [SJTDownLoadRequest new];
//    downloadRequest.url = @"https://pic1.58cdn.com.cn/p1/big/n_v291d99e74318b48bfbe13e3ed5414bf00.png";
//
//
//    SJTDownLoadRequest * downloadRequest2 = [SJTDownLoadRequest new];
//    downloadRequest2.url = @"https://pic1.58cdn.com.cn/p1/big/n_v20c184e6b5816436aa3ac6fad2de3a36b.png";
//    [SJTNetworkCenter sendDownLoadRequestArray:@[downloadRequest,downloadRequest2] success:^(SJTBatchDownloadRequest *requests) {
//        for (SJTDownLoadRequest *request in requests.requestArray) {
//            NSLog(@"%@",request.downLoadPath);
//        }
//
//    } failure:^(SJTBatchDownloadRequest *request, NSError *error) {
//
//    }];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
