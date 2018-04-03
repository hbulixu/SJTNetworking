//
//  SJTBatchDownloadRequest.m
//  SJTNetworking
//
//  Created by 58 on 2018/4/2.
//  Copyright © 2018年 LX. All rights reserved.
//

#import "SJTBatchDownloadRequest.h"
#import "SJTDownLoadRequest.h"
#import "SJTBatchDownloadRequestEngine.h"
#import "SJTRequstPrivate.h"
@interface SJTBatchDownloadRequest()<SJTDownLoadRequestDelegate>

@property (nonatomic,assign)NSInteger finishCount;
@property (nonatomic,assign)NSInteger successCount;

@end

@implementation SJTBatchDownloadRequest

-(instancetype)initWithDownloadRequestArray:(NSArray <SJTDownLoadRequest *>*)requestArray
{
    self = [super init];
    if (self) {
        _requestArray = [requestArray copy];
        for (SJTDownLoadRequest * request in _requestArray) {
            if (![request isKindOfClass:[SJTDownLoadRequest class]]) {
                return nil;
            }
        }
    }
    return self;
}



- (void)start
{
    [[SJTBatchDownloadRequestEngine shareEngine] addBatchDownloadRequest:self];
    for (SJTDownLoadRequest * downloadRequest in self.requestArray) {
        downloadRequest.delegate = self;
        [downloadRequest start];
    }
}
//失败后再次发起请求，成功的请求会自动过滤
- (void)retry
{
    [self retrySuccess:nil failure:nil];
}

-(void)retrySuccess:(SJTBatchDownloadRequestSuccessBlock)successBlock failure:(SJTBatchDownloadRequestFailureBlock)failureBlock
{
    self.successBlock = successBlock;
    self.failureBlock = failureBlock;
    for (SJTDownLoadRequest * downloadRequest in _requestArray) {
        if (downloadRequest.error) {
            downloadRequest.delegate = self;
            [downloadRequest start];
        }
    }
}

- (void)cancell
{
    for (SJTDownLoadRequest * downloadRequest in self.requestArray) {
        [downloadRequest cancell];
    }
    
    [[SJTBatchDownloadRequestEngine shareEngine]removeBatchDownloadRequest:self];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([self.delegate respondsToSelector:@selector(batchDownloadRequestCancelled:)]) {
            [self.delegate batchDownloadRequestCancelled:self];
        }
    });
    [self clearCompletionBlock];
}

- (void)clearCompletionBlock
{
    self.successBlock =  nil;
    self.failureBlock =  nil;
}

#pragma mark - SJTDownLoadRequestDelegate

- (void)downLoadRequestSuccess:(SJTDownLoadRequest *)request
{
    _finishCount ++;
    _successCount ++;
    request.error = nil;
    //完成
    if (_successCount == self.requestArray.count) {
        
        if ([self.delegate respondsToSelector:@selector(batchDownloadRequestSuccess:)]) {
            
            [self.delegate batchDownloadRequestSuccess:self];
        }
        
        if (self.successBlock) {
            self.successBlock(self);
        }
        [self clearCompletionBlock];
        
    }
}

- (void)downLoadRequestFailed:(SJTDownLoadRequest *)request error:(NSError *)error
{
    _finishCount ++;
    request.error = error;
    if (_finishCount == self.requestArray.count && _finishCount > _successCount) {
        
        if ([self.delegate respondsToSelector:@selector(batchDownloadRequestFailure:)]) {
            [self.delegate batchDownloadRequestFailure:self];
        }
        
        if (self.failureBlock) {
            self.failureBlock(self,error);
        }
        [self clearCompletionBlock];
    }
}


@end
