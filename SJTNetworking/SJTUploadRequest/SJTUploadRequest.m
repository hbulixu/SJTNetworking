//
//  SJTUploadRequest.m
//  SJTNetworking
//
//  Created by 58 on 2018/3/13.
//  Copyright © 2018年 LX. All rights reserved.
//

#import "SJTUploadRequest.h"
#import "SJTNetAdapter.h"
#import "SJTRequstPrivate.h"

@interface SJTUploadRequestEngine : NSObject

+(instancetype)shareEngine;

-(void)startUploadRequest:(SJTUploadRequest *)uploadRequest;

-(void)cancelUploadRequest:(SJTUploadRequest *)uploadRequest;

-(void)cancelAllUploadRequest;
@end


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




@implementation SJTUploadRequest

- (void)clearCompletionBlock
{
    self.successBlock = nil;
    self.failureBlock = nil;
    self.processBlock = nil;
}

-(void)start
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([self.delegate respondsToSelector:@selector(uploadRequestWillStart:)]) {
            [self.delegate uploadRequestWillStart:self];
        }
        
    });
    
    [[SJTUploadRequestEngine shareEngine] startUploadRequest:self];
}

-(void)cancell
{
    
    [[SJTUploadRequestEngine shareEngine] cancelUploadRequest:self];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([self.delegate respondsToSelector:@selector(uploadRequestCanceled:)]) {
            [self.delegate uploadRequestCanceled:self];
        }
        [self clearCompletionBlock];
    });
 
}


@end


@implementation SJTFormData

+ (instancetype)formDataWithName:(NSString *)name fileData:(NSData *)fileData {
    SJTFormData *formData = [[SJTFormData alloc] init];
    formData.name = name;
    formData.fileData = fileData;
    return formData;
}

+ (instancetype)formDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileData:(NSData *)fileData {
    SJTFormData *formData = [[SJTFormData alloc] init];
    formData.name = name;
    formData.fileName = fileName;
    formData.mimeType = mimeType;
    formData.fileData = fileData;
    return formData;
}

+ (instancetype)formDataWithName:(NSString *)name fileURL:(NSURL *)fileURL {
    SJTFormData *formData = [[SJTFormData alloc] init];
    formData.name = name;
    formData.fileURL = fileURL;
    return formData;
}

+ (instancetype)formDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileURL:(NSURL *)fileURL {
    SJTFormData *formData = [[SJTFormData alloc] init];
    formData.name = name;
    formData.fileName = fileName;
    formData.mimeType = mimeType;
    formData.fileURL = fileURL;
    return formData;
}

@end

@interface SJTFormDataArray()

@property (nonatomic,strong,readwrite)NSMutableArray * formDataArray;

@end

@implementation SJTFormDataArray

-(instancetype)init
{
    self = [super init];
    if (self) {
        _formDataArray = [NSMutableArray array];
    }
    return self;
}

-(void)appendFormDataWithName:(NSString *)name fileData:(NSData *)fileData
{
    SJTFormData * formData = [SJTFormData formDataWithName:name fileData:fileData];
    [_formDataArray addObject:formData];
}

-(void)appendFormDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileData:(NSData *)fileData
{
    SJTFormData * formData = [SJTFormData formDataWithName:name fileName:fileName mimeType:mimeType fileData:fileData];
    [_formDataArray addObject:formData];
}

-(void)appendFormDataWithName:(NSString *)name fileURL:(NSURL *)fileURL
{
    SJTFormData * formData = [SJTFormData formDataWithName:name fileURL:fileURL];
    [_formDataArray addObject:formData];
}

-(void)appendFormDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileURL:(NSURL *)fileURL
{
    SJTFormData * formData = [SJTFormData formDataWithName:name fileName:fileName mimeType:mimeType fileURL:fileURL];
    [_formDataArray addObject:formData];
}

@end



@interface SJTBatchUploadRequestEngine : NSObject

+(instancetype)shareEngine;

-(void)addBatchUploadRequest:(SJTBatchUploadRequest *)batchUploadRequest;

-(void)removeBatchUploadRequest:(SJTBatchUploadRequest *)batchUploadRequest;
@end


@implementation SJTBatchUploadRequestEngine
{
    //递归锁,业务会有锁嵌套
    NSRecursiveLock  * _lock;
    NSMutableArray<SJTBatchUploadRequest *> *_batchUploadRequestArray;
}
+(instancetype)shareEngine
{
    static SJTBatchUploadRequestEngine * engine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        engine = [[super allocWithZone:NULL]init];
    });
    return engine;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [SJTBatchUploadRequestEngine shareEngine];
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        _lock = [NSRecursiveLock new];
        _batchUploadRequestArray = [NSMutableArray array];
    }
    return self;
}

-(void)addBatchUploadRequest:(SJTBatchUploadRequest *)batchUploadRequest
{
    [_lock lock];
    [_batchUploadRequestArray addObject:batchUploadRequest];
    [_lock unlock];
}

-(void)removeBatchUploadRequest:(SJTBatchUploadRequest *)batchUploadRequest
{
    [_lock lock];
    [_batchUploadRequestArray removeObject:batchUploadRequest];
    [_lock unlock];
}
@end

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

- (void)retry
{
    [self retrySuccess:nil failure:nil];
}

- (void)retrySuccess:(SJTBatchUploadRequestSuccessBlock) successBlock failure:(SJTBatchUploadRequestFailureBlock)failureBlock
{
    [[SJTBatchUploadRequestEngine shareEngine] addBatchUploadRequest:self];
    self.successBlock = successBlock;
    self.failureBlock = failureBlock;
    for (SJTUploadRequest * uploadRequest in _requestArray) {
        if (uploadRequest.error) {
            uploadRequest.delegate = self;
            [uploadRequest start];
        }
    }
}

-(void)clearCompletionBlock
{
    self.successBlock = nil;
    self.failureBlock = nil;
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
        [self clearCompletionBlock];
        [[SJTBatchUploadRequestEngine shareEngine]removeBatchUploadRequest:self];
        
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
        [self clearCompletionBlock];
        [[SJTBatchUploadRequestEngine shareEngine]removeBatchUploadRequest:self];
    }
}
@end







