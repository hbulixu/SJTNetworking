//
//  SJTBatchUploadRequest.h
//  SJTNetworking
//
//  Created by 58 on 2018/3/27.
//  Copyright © 2018年 LX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJTNetCommomHeader.h"
@protocol SJTBatchUploadRequestDelegate <NSObject>

- (void)batchUploadRequestSuccess:(SJTBatchUploadRequest *)batchUploadRequest;

- (void)batchUploadRequestFailure:(SJTBatchUploadRequest *)batchUploadRequest;

- (void)batchUploadRequestCancelled:(SJTBatchUploadRequest *)batchUploadRequest;

@end

@interface SJTBatchUploadRequest : NSObject

@property (nonatomic, copy) SJTBatchUploadRequestSuccessBlock  successBlock;

@property (nonatomic, copy) SJTBatchUploadRequestFailureBlock failureBlock;

@property (nonatomic, strong, readonly) NSArray<SJTUploadRequest *> *requestArray;

@property (nonatomic,weak) id <SJTBatchUploadRequestDelegate> delegate;

-(instancetype)initWithUploadRequestArray:(NSArray <SJTUploadRequest *>*)requestArray;

- (void)start;
//失败后再次发起请求，成功的请求会自动过滤
- (void)reTry;

- (void)cancell;

@end
