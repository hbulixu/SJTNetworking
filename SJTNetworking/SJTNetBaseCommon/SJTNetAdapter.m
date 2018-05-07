//
//  SJTNetAdapter.m
//  SJTNetworking
//
//  Created by 58 on 2018/3/13.
//  Copyright © 2018年 LX. All rights reserved.
//

#import "SJTNetAdapter.h"
#import "SJTRequest.h"
#import "SJTUploadRequest.h"
#import "SJTRequstPrivate.h"
#import "AFNetworking.h"
#import "SJTNetworkingConfig.h"
#import "SJTDownLoadRequest.h"
#import "SJTNetworkingTools.h"
@interface SJTNetAdapter()

@property (nonatomic,strong)AFJSONResponseSerializer * jsonResponseSerializer;
@property (nonatomic,strong)AFXMLParserResponseSerializer *xmlParserResponseSerialzier;
@end


@implementation SJTNetAdapter
{
    AFHTTPSessionManager *_manager;
    dispatch_queue_t _processingQueue;
}


+(instancetype)shareAdapter
{
    static SJTNetAdapter * adapter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        adapter = [[super allocWithZone:NULL]init];
    });
    return adapter;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [SJTNetAdapter shareAdapter];
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        _processingQueue = dispatch_queue_create("com.sjt.SJTNetAdapter.processing", DISPATCH_QUEUE_CONCURRENT);
        _manager = [AFHTTPSessionManager manager];
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _manager.completionQueue = _processingQueue;
    }
    return self;
}


-(NSURLSessionDataTask*)dataTaskWith:(SJTRequest *)request completionHandler:(SJTCompletionHandler )completionHandler
{
    //记得设置返回码区间
    NSMutableURLRequest *urlRequest;
    
    //自定request
    if (request.customRequest) {
        
        urlRequest = [request.customRequest mutableCopy];
        
    }else
    {
        [self processRequestWithConfig:request];
        
        SJTRequestMethod method = request.requestMethod;
        NSString * url = request.url;
        NSDictionary * params = request.requestParams;
        
       __autoreleasing NSError *  requestSerializationError = nil;
        
        AFHTTPRequestSerializer * requestSerializer = [self requestSerializerForRequest:request];
        NSString * requestMethod;
        switch (method) {
            case SJTRequestMethodGet:
                requestMethod = @"GET";
                break;
            case SJTRequestMethodPost:
                requestMethod = @"POST";
                break;
            default:
                break;
        }
        
        urlRequest = [requestSerializer requestWithMethod:requestMethod URLString:url parameters:params error:&requestSerializationError];
        
        if (requestSerializationError && completionHandler) {
            
            completionHandler(request,requestSerializationError);
            return nil;
        }
    }
    
    __weak __typeof(self)weakSelf = self;
    NSURLSessionDataTask * task = [_manager dataTaskWithRequest:urlRequest completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf handleResponse:response object:responseObject error:error request:request completionHandler:completionHandler];
    }];
    
    
    request.requestTask = task;
    
    if ([request.requestTask respondsToSelector:@selector(priority)]){
        switch (request.requestPriority) {
            case SJTRequestPriorityLow:
                task.priority = NSURLSessionTaskPriorityLow;
                break;
            case SJTRequestPriorityDefault:
                task.priority = NSURLSessionTaskPriorityDefault;
                break;
            case SJTRequestPriorityHigh:
                task.priority = NSURLSessionTaskPriorityHigh;
                break;
            default:
                task.priority = NSURLSessionTaskPriorityDefault;
                break;
        }
    }
    
    [task resume];
    return task;
}


-(NSURLSessionUploadTask*)uploadDataTaskWith:(SJTUploadRequest *)uploadRequest processBlock:(SJTProgressBlock)proccessBlock completionHandler:(SJTCompletionHandler)completionHandler
{
    NSMutableURLRequest * urlRequest;
    //自定义请求
    if (uploadRequest.customRequest) {
        
        urlRequest  = [uploadRequest.customRequest mutableCopy];
        
    }else
    {
        [self processRequestWithConfig:uploadRequest];
        AFHTTPRequestSerializer *requestSerializer = [self requestSerializerForRequest:uploadRequest];
        
         __block NSError *  requestSerializationError = nil;
        urlRequest = [requestSerializer multipartFormRequestWithMethod:@"POST" URLString:uploadRequest.url parameters:uploadRequest.requestParams constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            [uploadRequest.uploadFormDatas  enumerateObjectsUsingBlock:^(SJTFormData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.fileData) {
                    if (obj.fileName && obj.mimeType) {
                        [formData appendPartWithFileData:obj.fileData name:obj.name fileName:obj.fileName mimeType:obj.mimeType];
                    } else {
                        [formData appendPartWithFormData:obj.fileData name:obj.name];
                    }
                } else if (obj.fileURL) {
                    NSError *fileError = nil;
                    if (obj.fileName && obj.mimeType) {
                        [formData appendPartWithFileURL:obj.fileURL name:obj.name fileName:obj.fileName mimeType:obj.mimeType error:&fileError];
                    } else {
                        [formData appendPartWithFileURL:obj.fileURL name:obj.name error:&fileError];
                    }
                    if (fileError) {
                        requestSerializationError = fileError;
                        *stop = YES;
                    }
                }
            }];
            
        } error:&requestSerializationError];
        
        if (requestSerializationError && completionHandler) {
            
            completionHandler(uploadRequest,requestSerializationError);
            return nil;
        }
    }
    
    __weak __typeof(self)weakSelf = self;
    NSURLSessionUploadTask *uploadTask = [_manager uploadTaskWithStreamedRequest:urlRequest progress:proccessBlock completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf handleResponse:response object:responseObject error:error request:uploadRequest completionHandler:completionHandler];
        
    }];
    
    uploadRequest.requestTask = uploadTask;
    
    if ([uploadRequest.requestTask respondsToSelector:@selector(priority)]){
        switch (uploadRequest.requestPriority) {
            case SJTRequestPriorityLow:
                uploadTask.priority = NSURLSessionTaskPriorityLow;
                break;
            case SJTRequestPriorityDefault:
                uploadTask.priority = NSURLSessionTaskPriorityDefault;
                break;
            case SJTRequestPriorityHigh:
                uploadTask.priority = NSURLSessionTaskPriorityHigh;
                break;
            default:
                //默认上传优先级都是低的，保证其它请求的优先级
                uploadTask.priority = NSURLSessionTaskPriorityLow;
                break;
        }
    }
    
    [uploadTask resume];
    return uploadTask;
}



-(NSURLSessionDownloadTask *)downloadDataTaskWith:(SJTDownLoadRequest *)downLoadRequest processBlock:(SJTProgressBlock)processBlock completionHandler:(SJTCompletionHandler)completionHandler
{
    NSMutableURLRequest * urlRequest;
    //自定义请求
    if (downLoadRequest.customRequest) {
        urlRequest = [downLoadRequest.customRequest mutableCopy];
    }else
    {
        [self processRequestWithConfig:downLoadRequest];
        SJTRequestMethod method = downLoadRequest.requestMethod;
        NSString * url = downLoadRequest.url;
        NSDictionary * params = downLoadRequest.requestParams;
        
        __autoreleasing NSError *  requestSerializationError = nil;
        
        
        NSString * requestMethod;
        switch (method) {
            case SJTRequestMethodGet:
                requestMethod = @"GET";
                break;
            case SJTRequestMethodPost:
                requestMethod = @"POST";
                break;
            default:
                break;
                
        }
        
        AFHTTPRequestSerializer *requestSerializer = [self requestSerializerForRequest:downLoadRequest];
        
        urlRequest = [requestSerializer requestWithMethod:requestMethod URLString:url parameters:params error:&requestSerializationError];
        
        if (requestSerializationError && completionHandler) {
            
            completionHandler(downLoadRequest,requestSerializationError);
            return nil;
        }
    }
    
    //如果没有赋值下载路径，使用默认下载路径
    if (!downLoadRequest.downLoadPath) {
        downLoadRequest.downLoadPath = [SJTNetworkingConfig shareConfig].fileDownLoadPath;
    }
    NSURL *downloadFileSavePath;
    BOOL isDirectory;
    if(![[NSFileManager defaultManager] fileExistsAtPath:downLoadRequest.downLoadPath isDirectory:&isDirectory]) {
        isDirectory = NO;
    }
    if (isDirectory) {
        NSString *fileName = [SJTNetworkingTools md5StringFromString: urlRequest.URL.absoluteString ];
        downloadFileSavePath = [NSURL fileURLWithPath:[NSString pathWithComponents:@[downLoadRequest.downLoadPath, fileName]] isDirectory:NO];
    } else {
        downloadFileSavePath = [NSURL fileURLWithPath:downLoadRequest.downLoadPath isDirectory:NO];
    }

    
   NSURLSessionDownloadTask * downloadTask = [_manager downloadTaskWithRequest:urlRequest progress:processBlock destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSLog(@"%@",targetPath);
        return downloadFileSavePath;
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        downLoadRequest.response = response;
        completionHandler(downLoadRequest,error);

    }];
    [downloadTask resume];
    return nil;
}

-(void)handleResponse:(NSURLResponse *)response object:(id)responseObject error:(NSError *) error request:(SJTBaseRequest *)request completionHandler:(SJTCompletionHandler )completionHandler
{
    NSError * __autoreleasing serializationError = nil;
    NSError *requestError = nil;
    NSError *responseValidateError = nil;
    request.response = response;
    
    BOOL success = YES;
    if (error) {
        success = NO;
        requestError = error;
    }
    
    //报文解析
    if (success) {
        request.responseObject = responseObject;
        if ([request.responseObject isKindOfClass:[NSData class]]) {
            request.responseData = responseObject;
            switch (request.responseSerializerType) {
                case kSJTResponseSerializerHTTP:
                    // Default serializer. Do nothing.
                    break;
                case kSJTesponseSerializerJSON:
                    request.responseObject = [self.jsonResponseSerializer responseObjectForResponse:response data:request.responseData error:&serializationError];
                    request.responseJSONObject = request.responseObject;
                    break;
                case kSJTesponseSerializerXML:
                    request.responseObject = [self.xmlParserResponseSerialzier responseObjectForResponse:response data:request.responseData error:&serializationError];
                    break;
            }
        }
        
        if(serializationError)
        {
            success = NO;
            requestError = serializationError;
        }
        
    }
    
    //业务校验接口
    if(success)
    {
        if (request.responseValidate) {
            responseValidateError = request.responseValidate(request);
        }
        if (responseValidateError) {
            success = NO;
            requestError = responseValidateError;
        }
    }

    completionHandler(request,requestError);

}

-(void )processRequestWithConfig:(SJTBaseRequest *)request
{
    if (!request.requestSerializerType) {
        request.requestSerializerType = [SJTNetworkingConfig shareConfig].requestSerializerType;
    }
    if (!request.responseSerializerType) {
        request.responseSerializerType = [SJTNetworkingConfig shareConfig].responseSerializerType;
    }
    if (!request.requestHeaderFieldValueDictionary) {
        request.requestHeaderFieldValueDictionary = [SJTNetworkingConfig shareConfig].requestHeaderFieldValueDictionary;
    }
}


- (AFHTTPRequestSerializer *)requestSerializerForRequest:(SJTBaseRequest *)request {
    AFHTTPRequestSerializer *requestSerializer = nil;
    
    if (request.requestSerializerType == kSJTRequestSerializerJSON) {
        requestSerializer = [AFJSONRequestSerializer serializer];
    } else {
        requestSerializer = [AFHTTPRequestSerializer serializer];
    }
    
    requestSerializer.timeoutInterval = [request requestTimeoutInterval];
    
    NSDictionary<NSString *, NSString *> *headerFieldValueDictionary = [request requestHeaderFieldValueDictionary];
    if (headerFieldValueDictionary != nil) {
        for (NSString *httpHeaderField in headerFieldValueDictionary.allKeys) {
            NSString *value = headerFieldValueDictionary[httpHeaderField];
            [requestSerializer setValue:value forHTTPHeaderField:httpHeaderField];
        }
    }
    return requestSerializer;
}

- (AFJSONResponseSerializer *)jsonResponseSerializer {
    if (!_jsonResponseSerializer) {
        _jsonResponseSerializer = [AFJSONResponseSerializer serializer];
        
    }
    return _jsonResponseSerializer;
}

- (AFXMLParserResponseSerializer *)xmlParserResponseSerialzier {
    if (!_xmlParserResponseSerialzier) {
        _xmlParserResponseSerialzier = [AFXMLParserResponseSerializer serializer];
    }
    return _xmlParserResponseSerialzier;
}

@end
