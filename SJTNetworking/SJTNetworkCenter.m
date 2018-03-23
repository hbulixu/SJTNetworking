//
//  SJTNetworkCenter.m
//  SJTNetworking
//
//  Created by 58 on 2018/3/22.
//  Copyright © 2018年 LX. All rights reserved.
//

#import "SJTNetworkCenter.h"

@implementation SJTNetworkCenter

+(SJTRequest *)sendRequest:(SJTRequest *) request
           success:(SJTRequestSuccessBlock) success
           failure:(SJTRequestFailureBlock) failure
{
    request.successBlock = success;
    request.failureBlock = failure;
    [request start];
    return request;
}

+(SJTRequest *)GET:(NSString *)URLString
        parameters:(id)parameters
           success:(SJTRequestSuccessBlock) success
           failure:(SJTRequestFailureBlock) failure
{
    SJTRequest * request =  [SJTRequest new];
    request.url = URLString;
    request.requestParams = parameters;
    request.successBlock =  success;
    request.failureBlock = failure;
    request.requestMethod = SJTRequestMethodGet;
    [request start];
    return request;
}

+(SJTRequest *)POST:(NSString *)URLString
         parameters:(id)parameters
            success:(SJTRequestSuccessBlock) success
            failure:(SJTRequestFailureBlock) failure
{
    SJTRequest * request =  [SJTRequest new];
    request.url = URLString;
    request.requestParams = parameters;
    request.successBlock =  success;
    request.failureBlock = failure;
    request.requestMethod = SJTRequestMethodPost;
    [request start];
    return request;
}
#pragma mark batchRequest

+(SJTBatchRequest *)sendRequestArray:(NSArray <SJTRequest *>*)requestArray
                        success:(SJTBatchRequestSuccessBlock) success
                        failure:(SJTBatchRequestFailureBlock) failure
{
    SJTBatchRequest * batchRequest = [[SJTBatchRequest alloc]initWithRequestArray:requestArray];
    batchRequest.successBlock = success;
    batchRequest.failureBlock = failure;
    [batchRequest start];
    return batchRequest;
}
@end
