//
//  SJTDownLoadRequest.m
//  SJTNetworking
//
//  Created by 58 on 2018/3/28.
//  Copyright © 2018年 LX. All rights reserved.
//

#import "SJTDownLoadRequest.h"
#import "SJTNetAdapter.h"
#import "SJTNetworkingConfig.h"
#import "SJTRequstPrivate.h"

@interface SJTDownLoadRequestEngine : NSObject


+(instancetype)shareEngine;

-(void)startDownLoadRequest:(SJTDownLoadRequest *)downloadRequest;

-(void)cancelDownLoadRequest:(SJTDownLoadRequest *)downloadRequest;

-(void)cancelAllDownLoadRequest;

@end


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




@implementation SJTDownLoadRequest

-(void)start
{

    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([self.delegate respondsToSelector:@selector(downLoadRequestWillStart:)]) {
            [self.delegate downLoadRequestWillStart:self];
        }
        
    });
    
    [[SJTDownLoadRequestEngine shareEngine] startDownLoadRequest:self];
}

-(void)cancell
{
    
    [[SJTDownLoadRequestEngine shareEngine] cancelDownLoadRequest:self];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([self.delegate respondsToSelector:@selector(downLoadRequestCanceled:)]) {
            [self.delegate downLoadRequestCanceled:self];
        }
        [self clearCompletionBlock];
    });

}

-(void)clearCompletionBlock
{
    self.successBlock = nil;
    self.failureBlock = nil;
    self.processBlock = nil;
}

-(void)dealloc
{
    
}
@end


@interface SJTBatchDownloadRequestEngine : NSObject

+(instancetype)shareEngine;

-(void)addBatchDownloadRequest:(SJTBatchDownloadRequest *)batchDownloadRequest;

-(void)removeBatchDownloadRequest:(SJTBatchDownloadRequest *)batchDownloadRequest;

@end

@implementation SJTBatchDownloadRequestEngine
{
    //递归锁,业务会有锁嵌套
    NSRecursiveLock  * _lock;
    NSMutableArray<SJTBatchDownloadRequest *> *_batchDownloadRequestArray;
}

+(instancetype)shareEngine
{
    static SJTBatchDownloadRequestEngine * engine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        engine = [[super allocWithZone:NULL]init];
    });
    return engine;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [SJTBatchDownloadRequestEngine shareEngine];
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        _lock = [NSRecursiveLock new];
        _batchDownloadRequestArray = [NSMutableArray array];
    }
    return self;
}


-(void)addBatchDownloadRequest:(SJTBatchDownloadRequest *)batchDownloadRequest
{
    [_lock lock];
    [_batchDownloadRequestArray addObject:batchDownloadRequest];
    [_lock unlock];
}

-(void)removeBatchDownloadRequest:(SJTBatchDownloadRequest *)batchDownloadRequest
{
    [_lock lock];
    [_batchDownloadRequestArray removeObject:batchDownloadRequest];
    [_lock unlock];
}
@end



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
