//
//  SJTBatchRequest.m
//  SJTNetworking
//
//  Created by 58 on 2018/3/22.
//  Copyright © 2018年 LX. All rights reserved.
//

#import "SJTBatchRequest.h"
#import "SJTRequest.h"
#import "SJTBatchRequestEngine.h"
@interface SJTBatchRequest()<SJTRequestDelegate>

@property (nonatomic,assign)NSInteger finishCount;
@end

@implementation SJTBatchRequest


-(instancetype)initWithRequestArray:(NSArray <SJTRequest *>*)requestArray
{
    self = [super init];
    if (self) {
        _requestArray = [requestArray copy];
        for (SJTRequest * request in _requestArray) {
            if (![request isKindOfClass:[SJTRequest class]]) {
                return nil;
            }
        }
    }
    return self;
}

- (void)start
{
    [[SJTBatchRequestEngine shareEngine] addBatchRequest:self];
    for (SJTRequest * request in self.requestArray) {
        request.delegate = self;
        [request start];
    }

}

- (void)cancell
{
    for (SJTRequest * request in self.requestArray) {
        [request cancell];
    }
    
    [[SJTBatchRequestEngine shareEngine]removeBatchRequest:self];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([self.delegate respondsToSelector:@selector(batchRequestCancelled:)]) {
            [self.delegate batchRequestCancelled:self];
        }
    });
    [self clearCompletionBlock];

}

-(void)clearCompletionBlock
{
    self.successBlock = nil;
    self.failureBlock = nil;
}

#pragma mark -SJTRequestDelegate

- (void)requestSuccess:(SJTRequest *)request
{
    //因为这个函数在主线程执行，不需要考虑加锁
    _finishCount ++;
    //完成
    if (_finishCount == self.requestArray.count) {
        
        if ([self.delegate respondsToSelector:@selector(batchRequestSuccess:)]) {
            
            [self.delegate batchRequestSuccess:self];
        }
        
        if (self.successBlock) {
            self.successBlock(self);
        }
        [self clearCompletionBlock];

    }
}

//普通批量请求有一个失败，其它的都不请求了
- (void)requestFailed:(SJTRequest *)request error:(NSError *)error
{
    self.firstErrorRequest =request;
    [self cancell];
    if ([self.delegate respondsToSelector:@selector(batchRequestFailure:)]) {
        [self.delegate batchRequestFailure:self];
    }
    
    if (self.failureBlock) {
        self.failureBlock(self);
    }
    [self clearCompletionBlock];

}

@end
