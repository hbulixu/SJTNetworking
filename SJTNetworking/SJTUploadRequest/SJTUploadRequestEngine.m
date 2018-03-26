//
//  SJTUploadRequestEngine.m
//  SJTNetworking
//
//  Created by 58 on 2018/3/26.
//  Copyright © 2018年 LX. All rights reserved.
//

#import "SJTUploadRequestEngine.h"
#import "SJTUploadRequest.h"
#import "SJTNetAdapter.h"
@implementation SJTUploadRequestEngine
{
    NSMutableDictionary<NSNumber *, SJTUploadRequest *> *_requestStorer;
    //递归锁,业务会有锁嵌套
    NSRecursiveLock  * _lock;
}

+(instancetype)shareEngine
{
    static SJTUploadRequestEngine * engine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        engine = [[super allocWithZone:NULL]init];
    });
    return engine;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [SJTUploadRequestEngine shareEngine];
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



-(void)startUploadRequest:(SJTUploadRequest *)uploadRequest
{
    //会有循环引用，所以末尾要clearCompletionBlock
    __weak __typeof(self)weakSelf = self;
    [[SJTNetAdapter shareAdapter] uploadDataTaskWith:uploadRequest processBlock:^(NSProgress *progress) {
        if (uploadRequest.processBlock) {
            uploadRequest.processBlock(progress);
        }
        if ([uploadRequest.delegate respondsToSelector:@selector(uploadRequestProcess:progress:)]) {
            [uploadRequest.delegate uploadRequestProcess:uploadRequest progress:progress];
        }
        
        
    } completionHandler:^(SJTBaseRequest *request, NSError *error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        SJTUploadRequest * uploadRequest = (SJTUploadRequest *)request;
        if (error) {
            
            if (uploadRequest.failureBlock) {
                uploadRequest.failureBlock(uploadRequest,error);
            }
            if ([uploadRequest.delegate respondsToSelector:@selector(uploadRequestFailed:error:)]) {
                [uploadRequest.delegate uploadRequestFailed:uploadRequest error:error];
            }

        }else
        {
            if (uploadRequest.successBlock) {
                uploadRequest.successBlock(uploadRequest);
            }
            if ([uploadRequest.delegate respondsToSelector:@selector(uploadRequestSuccess:)]) {
                [uploadRequest.delegate uploadRequestSuccess:uploadRequest];
            }
        }
        [strongSelf removeRequestFromStorer:uploadRequest];
        [uploadRequest clearCompletionBlock];
    }];
    
    [self addRequestToStorer:uploadRequest];
}


-(void)cancelUploadRequest:(SJTUploadRequest *)uploadRequest
{
    [uploadRequest.requestTask cancel];
    [self removeRequestFromStorer:uploadRequest];
}

-(void)cancelAllUploadRequest
{
    [_lock lock];
    for (SJTUploadRequest *request  in _requestStorer) {
        [self cancelUploadRequest:request];
    }
    [_lock unlock];
}

- (void)removeRequestFromStorer:(SJTUploadRequest *)request {
    [_lock lock];
    [_requestStorer removeObjectForKey:@(request.requestTask.taskIdentifier)];
    [_lock unlock];
}

- (void)addRequestToStorer:(SJTUploadRequest *)request {
    [_lock lock];
    _requestStorer[@(request.requestTask.taskIdentifier)] = request;
    [_lock unlock];
}
@end
