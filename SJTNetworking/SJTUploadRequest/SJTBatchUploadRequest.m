//
//  SJTBatchUploadRequest.m
//  SJTNetworking
//
//  Created by 58 on 2018/3/27.
//  Copyright © 2018年 LX. All rights reserved.
//

#import "SJTBatchUploadRequest.h"
#import "SJTUploadRequest.h"
#import "SJTBatchUploadRequestEngine.h"
#import "SJTRequstPrivate.h"
@interface SJTBatchUploadRequest()<SJTUploadRequestDelegate>

@property (nonatomic,assign)NSInteger finishCount;
@property (nonatomic,assign)NSInteger successCount;

@end

@implementation SJTBatchUploadRequest


-(instancetype)initWithUploadRequestArray:(NSArray <SJTUploadRequest *>*)requestArray
{
    self = [super init];
    if (self) {
        _requestArray = [requestArray copy];
        for (SJTUploadRequest * request in _requestArray) {
            if (![request isKindOfClass:[SJTUploadRequest class]]) {
                return nil;
            }
        }
    }
    return self;
}

- (void)start
{
    
    [[SJTBatchUploadRequestEngine shareEngine] addBatchUploadRequest:self];
    for (SJTUploadRequest * uploadRequest in self.requestArray) {
        uploadRequest.delegate = self;
        [uploadRequest start];
    }
}

- (void)cancell
{
    for (SJTUploadRequest * uploadRequest in self.requestArray) {
        [uploadRequest cancell];
    }
    
    [[SJTBatchUploadRequestEngine shareEngine]removeBatchUploadRequest:self];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([self.delegate respondsToSelector:@selector(batchUploadRequestCancelled:)]) {
            [self.delegate batchUploadRequestCancelled:self];
        }
    });
}

- (void)reTry
{
    for (SJTUploadRequest * uploadRequest in _requestArray) {
        if (uploadRequest.error) {
            uploadRequest.delegate = self;
            [uploadRequest start];
        }
    }
}

#pragma mark - SJTUploadRequestDelegate

//都在主线程中
- (void)uploadRequestSuccess:(SJTUploadRequest *)request
{
    _finishCount ++;
    _successCount ++;
    request.error = nil;
    //完成
    if (_successCount == self.requestArray.count) {
        
        if ([self.delegate respondsToSelector:@selector(batchUploadRequestSuccess:)]) {
            
            [self.delegate batchUploadRequestSuccess:self];
        }
        
        if (self.successBlock) {
            self.successBlock(self);
        }
    }
}

- (void)uploadRequestFailed:(SJTUploadRequest *)request error:(NSError *)error
{
    _finishCount ++;
    request.error = error;
    if (_finishCount == self.requestArray.count && _finishCount > _successCount) {
        
        if ([self.delegate respondsToSelector:@selector(batchUploadRequestFailure:)]) {
            [self.delegate batchUploadRequestFailure:self];
        }
        
        if (self.failureBlock) {
            self.failureBlock(self,error);
        }
    }
}
@end
