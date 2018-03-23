//
//  SJTNetworkCenter.h
//  SJTNetworking
//
//  Created by 58 on 2018/3/22.
//  Copyright © 2018年 LX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJTRequest.h"
#import "SJTBatchRequest.h"
@interface SJTNetworkCenter : NSObject

//自定义request
+(SJTRequest *)sendRequest:(SJTRequest *) request
           success:(SJTRequestSuccessBlock) success
           failure:(SJTRequestFailureBlock) failure;

//通用request

+(SJTRequest *)GET:(NSString *)URLString
        parameters:(id)parameters
           success:(SJTRequestSuccessBlock) success
           failure:(SJTRequestFailureBlock) failure;

+(SJTRequest *)POST:(NSString *)URLString
        parameters:(id)parameters
           success:(SJTRequestSuccessBlock) success
           failure:(SJTRequestFailureBlock) failure;


//批量请求GET POST不明确，需要自定义request
+(SJTBatchRequest *)sendRequestArray:(NSArray <SJTRequest *>*)requestArray
                        success:(SJTBatchRequestSuccessBlock) success
                        failure:(SJTBatchRequestFailureBlock) failure;


@end
