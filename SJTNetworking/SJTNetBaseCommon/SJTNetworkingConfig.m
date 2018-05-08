//
//  SJTNetworkingConfig.m
//  SJTNetworking
//
//  Created by 58 on 2018/3/1.
//  Copyright © 2018年 LX. All rights reserved.
//

#import "SJTNetworkingConfig.h"
#import "SJTNetworkingTools.h"
#import "SJTBaseRequest.h"
@implementation SJTNetworkingConfig

+(instancetype)shareConfig
{
    static SJTNetworkingConfig * config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[super allocWithZone:NULL]init];
    });
    return config;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [SJTNetworkingConfig shareConfig];
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        _requestSerializerType = kSJTRequestSerializerHTTP;
        _responseSerializerType = kSJTesponseSerializerJSON;

        _fileDownLoadPath = [SJTNetworkingTools makeDiskCachePath:@"SJTNetworkDownLoadDefault" ];
        [SJTNetworkingTools createDirectoryIfNeeded:_fileDownLoadPath];
        
    }
    return self;
}

-(void )processRequestWithConfig:(SJTBaseRequest *)request
{
    if (!request.requestSerializerType) {
        request.requestSerializerType = self.requestSerializerType;
    }
    if (!request.responseSerializerType) {
        request.responseSerializerType = self.responseSerializerType;
    }
    if (!request.requestHeaderFieldValueDictionary) {
        request.requestHeaderFieldValueDictionary = self.requestHeaderFieldValueDictionary;
    }
}
@end
