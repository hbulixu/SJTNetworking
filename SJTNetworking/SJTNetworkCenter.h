//
//  SJTNetworkCenter.h
//  SJTNetworking
//
//  Created by 58 on 2018/3/22.
//  Copyright © 2018年 LX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJTNetCommomHeader.h"
@interface SJTNetworkCenter : NSObject

//自定义request
+(SJTRequest *)sendRequest:(SJTRequest *) request
                   success:(SJTRequestSuccessBlock) success
                   failure:(SJTRequestFailureBlock) failure;

//通用request

+(SJTRequest *)GET:(NSString *)URLString
        parameters:(NSDictionary *)parameters
           success:(SJTRequestSuccessBlock) success
           failure:(SJTRequestFailureBlock) failure;

+(SJTRequest *)POST:(NSString *)URLString
         parameters:(NSDictionary *)parameters
            success:(SJTRequestSuccessBlock) success
            failure:(SJTRequestFailureBlock) failure;


+(SJTRequest *)GET:(NSString *)URLString
        parameters:(NSDictionary *)parameters
       cachePolicy:(SJTCachePolicy)cachePolicy
           success:(SJTRequestSuccessBlock) success
           failure:(SJTRequestFailureBlock) failure;

+(SJTRequest *)POST:(NSString *)URLString
         parameters:(NSDictionary *)parameters
        cachePolicy:(SJTCachePolicy)cachePolicy
            success:(SJTRequestSuccessBlock) success
            failure:(SJTRequestFailureBlock) failure;

//批量请求GET POST不明确，需要自定义request
+(SJTBatchRequest *)sendRequestArray:(NSArray <SJTRequest *>*)requestArray
                             success:(SJTBatchRequestSuccessBlock) success
                             failure:(SJTBatchRequestFailureBlock) failure;

//上传定制
+(SJTUploadRequest *)sendUploadRequest:(SJTUploadRequest *) uploadRequest
                         process:(SJTProgressBlock)process
                         success:(SJTUploadRequestSuccessBlock) success
                         failure:(SJTUploadRequestFailureBlock) failure;

+(SJTUploadRequest *)POST:(NSString *)URLString
constructingBodyWithBlock:(void(^)(SJTFormDataArray * formDataArray))block
               parameters:(NSDictionary*)parameters
                  process:(SJTProgressBlock)process
                  success:(SJTUploadRequestSuccessBlock) success
                  failure:(SJTUploadRequestFailureBlock) failure;

+(SJTBatchUploadRequest *)sendUploadRequestArray:(NSArray <SJTUploadRequest *>*)requestArray
                                         success:(SJTBatchUploadRequestSuccessBlock) success
                                         failure:(SJTBatchUploadRequestFailureBlock) failure;

//download
+(SJTDownLoadRequest *)GET:(NSString *)URLString
                parameters:(NSDictionary *)parameters
                  filePath:(NSString *)downLoadFilepath
                   process:(SJTProgressBlock)process
                   success:(SJTDownloadRequestSuccessBlock)success
                   failure:(SJTDownloadRequestFailureBlock)failure;
                

+(SJTDownLoadRequest *)sendDownloadRequest:(SJTDownLoadRequest *)downloadRequest
                                   process:(SJTProgressBlock)process
                                   success:(SJTDownloadRequestSuccessBlock)success
                                   failure:(SJTDownloadRequestFailureBlock)failure;

+(SJTBatchDownloadRequest *)sendDownLoadRequestArray:(NSArray <SJTDownLoadRequest *>*)requestArray
                                             success:(SJTBatchDownloadRequestSuccessBlock) success
                                             failure:(SJTBatchDownloadRequestFailureBlock) failure;

@end
