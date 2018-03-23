//
//  SJTNetAdapter.m
//  SJTNetworking
//
//  Created by 58 on 2018/3/13.
//  Copyright © 2018年 LX. All rights reserved.
//

#import "SJTNetAdapter.h"
#import "SJTRequest.h"
#import "SJTRequstPrivate.h"
#import "AFNetworking.h"
#import "SJTNetworkingConfig.h"
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
        
        NSError *  requestSerializationError = nil;
        
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
    
    
    NSURLSessionDataTask * task = [_manager dataTaskWithRequest:urlRequest completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        [self handleResponse:response object:responseObject error:error request:request completionHandler:completionHandler];
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

-(void)handleResponse:(NSURLResponse *)response object:(id)responseObject error:(NSError *) error request:(SJTRequest *)request completionHandler:(SJTCompletionHandler )completionHandler
{
    NSError * __autoreleasing serializationError = nil;
    
    NSError *requestError = nil;
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
    
    if (error) {
        requestError = error;
    }else if(serializationError)
    {
        requestError = serializationError;
    }
    
    completionHandler(request,requestError);

}

-(void )processRequestWithConfig:(SJTRequest *)request
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


- (AFHTTPRequestSerializer *)requestSerializerForRequest:(SJTRequest *)request {
    AFHTTPRequestSerializer *requestSerializer = nil;
    if (request.requestSerializerType == kSJTRequestSerializerHTTP) {
        requestSerializer = [AFHTTPRequestSerializer serializer];
    } else if (request.requestSerializerType == kSJTRequestSerializerJSON) {
        requestSerializer = [AFJSONRequestSerializer serializer];
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
