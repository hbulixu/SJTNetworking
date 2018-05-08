//
//  SJTDownLoadRequestEngine.m
//  SJTNetworking
//
//  Created by 58 on 2018/3/29.
//  Copyright © 2018年 LX. All rights reserved.
//

#import "SJTDownLoadRequestEngine.h"
#import "SJTDownLoadRequest.h"
#import "SJTNetAdapter.h"
#import "SJTNetworkingConfig.h"

@implementation SJTDownLoadRequestEngine
{
    NSMutableDictionary<NSNumber *, SJTDownLoadRequest *> *_requestStorer;
    //递归锁,业务会有锁嵌套
    NSRecursiveLock  * _lock;
}

+(instancetype)shareEngine
{
    static SJTDownLoadRequestEngine * engine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        engine = [[super allocWithZone:NULL]init];
    });
    return engine;
}


+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [SJTDownLoadRequestEngine shareEngine];
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

-(void)startDownLoadRequest:(SJTDownLoadRequest *)downloadRequest
{
    
    [[SJTNetworkingConfig shareConfig] processRequestWithConfig:downloadRequest];
    __weak __typeof(self)weakSelf = self;
    [[SJTNetAdapter shareAdapter] downloadDataTaskWith:downloadRequest processBlock:^(NSProgress *progress) {
        
        if (downloadRequest.processBlock) {
            downloadRequest.processBlock(progress);
        }
        if ([downloadRequest.delegate respondsToSelector:@selector(downLoadRequestProcess:progress:)]) {
            [downloadRequest.delegate downLoadRequestProcess:downloadRequest progress:progress];
        }
        
    } completionHandler:^(SJTBaseRequest *request, NSError *error) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        SJTDownLoadRequest * download = (SJTDownLoadRequest *)request;
        
        if (error) {
            
            if (download.failureBlock) {
                download.failureBlock(download,error);
            }
            if ([download.delegate respondsToSelector:@selector(downLoadRequestFailed:error:)]) {
                [download.delegate downLoadRequestFailed:downloadRequest error:error];
            }
            
        }else
        {
            if (download.successBlock) {
                download.successBlock(download);
            }
            if ([download.delegate respondsToSelector:@selector(downLoadRequestSuccess:)]) {
                [download.delegate downLoadRequestSuccess:download];
            }
        }
        [strongSelf removeRequestFromStorer:download];
        [download clearCompletionBlock];
    }];
    [self addRequestToStorer:downloadRequest];
}

-(void)cancelDownLoadRequest:(SJTDownLoadRequest *)downloadRequest
{
    [downloadRequest.requestTask cancel];
    [self removeRequestFromStorer:downloadRequest];
}

-(void)cancelAllDownLoadRequest
{
    [_lock lock];
    for (SJTDownLoadRequest *request  in _requestStorer) {
        [self cancelDownLoadRequest:request];
    }
    [_lock unlock];
}


- (void)removeRequestFromStorer:(SJTDownLoadRequest *)request {
    [_lock lock];
    [_requestStorer removeObjectForKey:@(request.requestTask.taskIdentifier)];
    [_lock unlock];
}

- (void)addRequestToStorer:(SJTDownLoadRequest *)request {
    [_lock lock];
    _requestStorer[@(request.requestTask.taskIdentifier)] = request;
    [_lock unlock];
}
@end
