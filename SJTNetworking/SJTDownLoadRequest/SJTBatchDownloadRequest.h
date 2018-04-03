//
//  SJTBatchDownloadRequest.h
//  SJTNetworking
//
//  Created by 58 on 2018/4/2.
//  Copyright © 2018年 LX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJTNetCommomHeader.h"
@protocol SJTBatchDownloadRequestDelegate <NSObject>

- (void)batchDownloadRequestSuccess:(SJTBatchDownloadRequest *)batchDownloadRequest;

- (void)batchDownloadRequestFailure:(SJTBatchDownloadRequest *)batchDownloadRequest;

- (void)batchDownloadRequestCancelled:(SJTBatchDownloadRequest *)batchDownloadRequest;

@end

@interface SJTBatchDownloadRequest : NSObject

@property (nonatomic,copy)SJTBatchDownloadRequestSuccessBlock successBlock;
@property (nonatomic,copy)SJTBatchDownloadRequestFailureBlock failureBlock;
@property (nonatomic, strong, readonly) NSArray<SJTDownLoadRequest *> *requestArray;
@property (nonatomic,weak) id <SJTBatchDownloadRequestDelegate>delegate;


-(instancetype)initWithDownloadRequestArray:(NSArray <SJTDownLoadRequest *>*)requestArray;


- (void)start;
//失败后再次发起请求，成功的请求会自动过滤
- (void)retry;
//使用block请求，需要设置成功，失败block，使用delegate则不需要
- (void)retrySuccess:(SJTBatchDownloadRequestSuccessBlock) successBlock failure:(SJTBatchDownloadRequestFailureBlock)failureBlock;

- (void)cancell;

- (void)clearCompletionBlock;
@end
