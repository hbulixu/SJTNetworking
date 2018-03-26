//
//  SJTRequestEngine.m
//  SJTNetworking
//
//  Created by 58 on 2018/3/13.
//  Copyright © 2018年 LX. All rights reserved.
//

#import "SJTRequestEngine.h"
#import "SJTRequest.h"
#import <pthread/pthread.h>
#import "SJTNetAdapter.h"
@implementation SJTRequestEngine
{
    NSMutableDictionary<NSNumber *, SJTRequest *> *_requestStorer;
    //递归锁,业务会有锁嵌套
    NSRecursiveLock  * _lock;
}

+(instancetype)shareEngine
{
    static SJTRequestEngine * engine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        engine = [[super allocWithZone:NULL]init];
    });
    return engine;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [SJTRequestEngine shareEngine];
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        _requestStorer = [NSMutableDictionary dictionary];
        _lock = [NSRecursiveLock new];
    }
    return self;
}



-(void)startRequest:(SJTRequest *)request
{

    __weak __typeof(self)weakSelf = self;
    [[SJTNetAdapter shareAdapter] dataTaskWith:request completionHandler:^(SJTBaseRequest *request, NSError *error) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        SJTRequest * tempRequest = (SJTRequest *)request;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (error) {

                if (tempRequest.failureBlock) {
                    tempRequest.failureBlock(tempRequest,error);
                }
                if ([tempRequest.delegate respondsToSelector:@selector(requestFailed:error:)]) {
                    [tempRequest.delegate requestFailed:tempRequest error:error];
                }
            }else
            {
                if (tempRequest.successBlock) {
                    tempRequest.successBlock(tempRequest);
                }
                if ([tempRequest.delegate respondsToSelector:@selector(requestSuccess:)]) {
                    [tempRequest.delegate requestSuccess:tempRequest];
                }
            }
            
        });

        [strongSelf removeRequestFromStorer:tempRequest];
        //防止循环引用
        [tempRequest clearCompletionBlock];
    }];
    
    [self addRequestToStorer:request];

}


-(void)cancelRequest:(SJTRequest *)request
{
    [request.requestTask cancel];
    [self removeRequestFromStorer:request];
}

-(void)cancelAllRequest
{
    [_lock lock];
    for (SJTRequest *request  in _requestStorer) {
        [self cancelRequest:request];
    }
    [_lock unlock];
}

- (void)removeRequestFromStorer:(SJTRequest *)request {
    [_lock lock];
    [_requestStorer removeObjectForKey:@(request.requestTask.taskIdentifier)];
    [_lock unlock];
}

- (void)addRequestToStorer:(SJTRequest *)request {
    [_lock lock];
    _requestStorer[@(request.requestTask.taskIdentifier)] = request;
    [_lock unlock];
}
@end
