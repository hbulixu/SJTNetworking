//
//  SJTRequest.m
//  SJTNetworking
//
//  Created by 58 on 2018/3/1.
//  Copyright © 2018年 LX. All rights reserved.
//

#import "SJTRequest.h"
#import "SJTNetCache.h"
#import <pthread/pthread.h>
#import "SJTNetAdapter.h"
#import "SJTNetCache.h"
#import "SJTNetworkingConfig.h"
#import "SJTNetworkingTools.h"
#import "SJTRequstPrivate.h"

@interface SJTRequestEngine : NSObject

+(instancetype)shareEngine;

-(void)startRequest:(SJTRequest *)request;

-(void)cancelRequest:(SJTRequest *)request;

-(void)cancelAllRequest;
@end


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
    
    
    [[SJTNetworkingConfig shareConfig] processRequestWithConfig:request];
    
    if (!request.responseCanCache) {
        request.responseCanCache = [SJTNetworkingConfig shareConfig].responseCanCache;
    }
    
    if (!request.responseValidate) {
        request.responseValidate = [SJTNetworkingConfig shareConfig].responseValidate;
    }
    
    if (request.cachePolicy == SJTCachePolicyDontWriteToCache) {
        //do nothing
    }else if (request.cachePolicy == SJTCachePolicyTalkServerAfterLoadCache)
    {
        NSError * error =  [[SJTNetCache shareCache] loadCacheWithRequest:request];
        [self completionHandler:request error:error];
        
    }else if(request.cachePolicy == SJTCacheOnlyLoadCache)
    {
        NSError * error =  [[SJTNetCache shareCache] loadCacheWithRequest:request];
        [self completionHandler:request error:error];
        return;
    }
    
    
    __weak __typeof(self)weakSelf = self;
    [[SJTNetAdapter shareAdapter] dataTaskWith:request completionHandler:^(SJTBaseRequest *request, NSError *error) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        SJTRequest * tempRequest = (SJTRequest *)request;
        [strongSelf completionHandler:tempRequest error:error];
        if (!error) {
            
            switch (tempRequest.cachePolicy) {
                case SJTCachePolicyDontWriteToCache:
                    break;
                case SJTCachePolicyTalkServerAfterLoadCache:
                case SJTCacheOnlyLoadCache:
                    [[SJTNetCache shareCache]saveToCacheWithRequest:tempRequest];
                    break;
                default:
                    break;
            }
        }
        
        //主线程删除，防止提前释放造成crash
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf removeRequestFromStorer:tempRequest];
            //防止循环引用
            [tempRequest clearCompletionBlock];
        });
    }];
    
    [self addRequestToStorer:request];
    
}

-(void)completionHandler:(SJTRequest *)request error:(NSError *)error
{
    
    
    if(!error)
    {
        //json 校验
        if (request.validatorJson && request.responseJSONObject) {
            if (![SJTNetworkingTools validateJSON:request.responseJSONObject withValidator:request.validatorJson])
            {
                error = [NSError errorWithDomain:@"SJTJsonValidate" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"json校验失败"}];
            }
            
        }
        //业务校验接口
        if (!error && request.responseValidate) {
            error = request.responseValidate(request);
        }
        
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //从缓存读取错误的信息不调用错误回调
        if (error ) {
            
            if (!request.isDataFromCache) {
                if (request.failureBlock) {
                    request.failureBlock(request,error);
                }
                if ([request.delegate respondsToSelector:@selector(requestFailed:error:)]) {
                    [request.delegate requestFailed:request error:error];
                }
            }
            
        }else
        {
            if (request.successBlock) {
                request.successBlock(request);
            }
            if ([request.delegate respondsToSelector:@selector(requestSuccess:)]) {
                [request.delegate requestSuccess:request];
            }
        }
        
    });
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

@implementation SJTRequest

+(instancetype)requestWithUrl:(NSString *)url requestMethod:(SJTRequestMethod)requestMethod requestParams:(NSDictionary *)requestParams
{
    SJTRequest * request = [SJTRequest new];
    request.url = url;
    request.requestMethod = requestMethod;
    request.requestParams = requestParams;
    return request;
}


-(void)start
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([self.delegate respondsToSelector:@selector(requestWillStart:)]) {
            [self.delegate requestWillStart:self];
        }
        
    });

    [[SJTRequestEngine shareEngine] startRequest:self];
}

-(void)cancell
{
  
    [[SJTRequestEngine shareEngine] cancelRequest:self];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([self.delegate respondsToSelector:@selector(requestCanceled:)]) {
            [self.delegate requestCanceled:self];
        }
        
    });
}

- (void)clearCompletionBlock
{
    self.successBlock = nil;
    self.failureBlock = nil;
}

@end


@interface SJTBatchRequestEngine : NSObject


+(instancetype)shareEngine;

-(void)addBatchRequest:(SJTBatchRequest *)batchRequest;

-(void)removeBatchRequest:(SJTBatchRequest *)batchRequest;

@end

@implementation SJTBatchRequestEngine
{
    //递归锁,业务会有锁嵌套
    NSRecursiveLock  * _lock;
    NSMutableArray<SJTBatchRequest *> *_batchRequestArray;
}


+(instancetype)shareEngine
{
    static SJTBatchRequestEngine * engine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        engine = [[super allocWithZone:NULL]init];
    });
    return engine;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [SJTBatchRequestEngine shareEngine];
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        _batchRequestArray = [NSMutableArray array];
    }
    return self;
}

-(void)addBatchRequest:(SJTBatchRequest *)batchRequest
{
    [_lock lock];
    [_batchRequestArray addObject:batchRequest];
    [_lock unlock];
}

-(void)removeBatchRequest:(SJTBatchRequest *)batchRequest
{
    [_lock lock];
    [_batchRequestArray removeObject:batchRequest];
    [_lock unlock];
}

@end


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
        [[SJTBatchRequestEngine shareEngine]removeBatchRequest:self];
        
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
        self.failureBlock(self,error);
    }
    [self clearCompletionBlock];
    [[SJTBatchRequestEngine shareEngine]removeBatchRequest:self];
    
}


@end

