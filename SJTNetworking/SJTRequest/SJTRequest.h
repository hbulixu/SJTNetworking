//
//  SJTRequest.h
//  SJTNetworking
//
//  Created by 58 on 2018/3/1.
//  Copyright © 2018年 LX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJTBaseRequest.h"
@class SJTRequest;
@protocol SJTRequestDelegate <NSObject>

@optional

- (void)requestWillStart:(SJTRequest *)request;

- (void)requestCanceled:(SJTRequest *)request;

- (void)requestSuccess:(SJTRequest *)request;

- (void)requestFailed:(SJTRequest *)request error:(NSError *)error;

@end

@interface SJTRequest : SJTBaseRequest

@property (nonatomic, weak) id<SJTRequestDelegate> delegate;

@property (nonatomic, copy)SJTRequestSuccessBlock successBlock;

@property (nonatomic, copy)SJTRequestFailureBlock failureBlock;

@property (nonatomic, assign) SJTCachePolicy cachePolicy;

@property (nonatomic,retain)NSDictionary * validatorJson;

+(instancetype)requestWithUrl:(NSString *)url requestMethod:(SJTRequestMethod)requestMethod requestParams:(NSDictionary *)requestParams;

- (void)clearCompletionBlock;
@end
