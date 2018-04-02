//
//  SJTNetworkCenter.m
//  SJTNetworking
//
//  Created by 58 on 2018/3/22.
//  Copyright © 2018年 LX. All rights reserved.
//

#import "SJTNetworkCenter.h"
#import "SJTUploadRequest.h"
#import "SJTRequest.h"
#import "SJTBatchRequest.h"
#import "SJTBatchUploadRequest.h"
#import "SJTDownLoadRequest.h"
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


+(SJTUploadRequest *)sendUploadRequest:(SJTUploadRequest *) uploadRequest
                               process:(SJTProgressBlock)process
                               success:(SJTUploadRequestSuccessBlock) success
                               failure:(SJTUploadRequestFailureBlock) failure
{
    if (!uploadRequest) {
        return nil;
    }
    
    uploadRequest.processBlock = process;
    uploadRequest.successBlock = success;
    uploadRequest.failureBlock = failure;
    [uploadRequest start];
    return uploadRequest;
}


+(SJTUploadRequest *)POST:(NSString *)URLString
constructingBodyWithBlock:(void(^)(SJTFormDataArray * formDataArray))block
               parameters:(NSDictionary*)parameters
                  process:(SJTProgressBlock)process
                  success:(SJTUploadRequestSuccessBlock) success
                  failure:(SJTUploadRequestFailureBlock) failure
{
    SJTUploadRequest * uploadRequest = [SJTUploadRequest new];
    uploadRequest.url = URLString;
    uploadRequest.requestParams = parameters;
    uploadRequest.successBlock = success;
    uploadRequest.failureBlock = failure;
    uploadRequest.processBlock = process;
    
    if (block) {
        SJTFormDataArray * formDatas = [SJTFormDataArray new];
        block(formDatas);
        uploadRequest.uploadFormDatas = [formDatas.formDataArray copy];
    }
    
    [uploadRequest start];
    return uploadRequest;
}


+(SJTBatchUploadRequest *)sendUploadRequestArray:(NSArray <SJTUploadRequest *>*)requestArray
                                         success:(SJTBatchUploadRequestSuccessBlock) success
                                         failure:(SJTBatchUploadRequestFailureBlock) failure
{
    SJTBatchUploadRequest * request = [[SJTBatchUploadRequest alloc]initWithUploadRequestArray:requestArray];
    request.successBlock = success;
    request.failureBlock = failure;
    [request start];
    return request;
}

+(SJTDownLoadRequest *)GET:(NSString *)URLString
                parameters:(NSDictionary *)parameters
                  filePath:(NSString *)downLoadFilepath
                   process:(SJTProgressBlock)process
                   success:(SJTDownloadRequestSuccessBlock)success
                   failure:(SJTDownloadRequestFailureBlock)failure
{
    SJTDownLoadRequest * requst = [SJTDownLoadRequest new];
    requst.url = URLString;
    requst.requestParams = parameters;
    requst.downLoadPath = downLoadFilepath;
    requst.processBlock = process;
    requst.successBlock = success;
    requst.failureBlock = failure;
    [requst start];
    return requst;
}


+(SJTDownLoadRequest *)sendDownloadRequest:(SJTDownLoadRequest *)downloadRequest
                                   process:(SJTProgressBlock)process
                                   success:(SJTDownloadRequestSuccessBlock)success
                                   failure:(SJTDownloadRequestFailureBlock)failure
{
    if (!downloadRequest) {
        return nil;
    }
    downloadRequest.processBlock = process;
    downloadRequest.successBlock = success;
    downloadRequest.failureBlock = failure;
    [downloadRequest start];
    return downloadRequest;
}

@end
