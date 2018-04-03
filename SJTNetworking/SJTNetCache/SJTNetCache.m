//
//  SJTNetCache.m
//  SJTNetworking
//
//  Created by 58 on 2018/4/2.
//  Copyright © 2018年 LX. All rights reserved.
//

#import "SJTNetCache.h"
#import <CommonCrypto/CommonDigest.h>
#import "SJTNetworkingConfig.h"
#import "SJTRequest.h"
#import "SJTRequstPrivate.h"
#import "SJTCacheMetaData.h"
@implementation SJTNetCache
NSString *const SJTRequestCacheErrorDomain = @"com.sjt.request.cache";
+(instancetype)shareCache
{
    static SJTNetCache * cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[super allocWithZone:NULL]init];
    });
    return cache;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [SJTNetCache shareCache];
}

-(instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

- (NSError *)loadCacheWithRequest:(SJTRequest *)request
{
    //1.根据request和config 获取缓存路径
    NSString *filePath = [self filePathWithRequest:request];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    //2.读取meta缓存
    NSString *fileMetaPath = [NSString stringWithFormat:@"%@.meta",filePath];
    if ([fileManager fileExistsAtPath:fileMetaPath isDirectory:nil]) {
        return [NSError errorWithDomain:SJTRequestCacheErrorDomain code:SJTRequestCacheErrorMisMetaData userInfo:@{ NSLocalizedDescriptionKey:@"metadata not exist"}];
        
    }
    SJTCacheMetaData *cacheMetaData = nil;
    @try {
        cacheMetaData = [NSKeyedUnarchiver unarchiveObjectWithFile:fileMetaPath];
    } @catch (NSException *exception) {
    }
    if (!cacheMetaData) {
        return [NSError errorWithDomain:SJTRequestCacheErrorDomain code:SJTRequestCacheErrorInvalidMetadata userInfo:@{ NSLocalizedDescriptionKey:@"metadata invalidate"}];
    }
    //3.判断版本
    if (cacheMetaData.appVersionString.length) {
        
        if ([cacheMetaData.appVersionString compare:[SJTNetworkingConfig shareConfig].appVersion options:NSNumericSearch] == NSOrderedSame)
        {
            
        }else
        {
            return [NSError errorWithDomain:SJTRequestCacheErrorDomain code:SJTRequestCacheErrorAppVersionMismatch userInfo:@{ NSLocalizedDescriptionKey:@"appverion mismatch"}];
        }
        
    }
    //4.判断失效
    if (cacheMetaData.invalidateTime.length && cacheMetaData.creationDate) {
        NSDate * currentDate = [NSDate date];
        NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:cacheMetaData.creationDate];
        if (timeInterval >cacheMetaData.invalidateTime.longLongValue) {
            return [NSError errorWithDomain:SJTRequestCacheErrorDomain code:SJTRequestCacheErrorInvalidCacheTime userInfo:@{ NSLocalizedDescriptionKey:@"cachetime invalidate"}];
        }
    }
    
    //5.读取缓存数据
    if ([fileManager fileExistsAtPath:filePath isDirectory:nil]) {
        return [NSError errorWithDomain:SJTRequestCacheErrorDomain code:SJTRequestCacheErrorMisCacheData userInfo:@{ NSLocalizedDescriptionKey:@"cacheData not exist"}];
    }
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    request.isDataFromCache = YES;
    switch (request.responseSerializerType) {
        case kSJTResponseSerializerHTTP:
        {
            request.responseData = fileData;
        }
        case kSJTesponseSerializerJSON:
        {
            id json = [NSJSONSerialization JSONObjectWithData:fileData options:(NSJSONReadingOptions)0 error:&error];
            if (!error) {
                request.responseJSONObject = json;
            }
        }
        case kSJTesponseSerializerXML:
        {
            request.responseData = [[NSXMLParser alloc] initWithData:fileData];
        }
    }
    
    if (error) {
        return [NSError errorWithDomain:SJTRequestCacheErrorDomain code:SJTRequestCacheErrorInvalidCacheData userInfo:@{ NSLocalizedDescriptionKey:@"cacheData invalidate"}];
    }
    
    //6.如果有校验函数，进行校验,
    if (request.responseValidate) {
        if (request.responseValidate(request)) {
            return [NSError errorWithDomain:SJTRequestCacheErrorDomain code:SJTRequestCacheErrorInvalidCacheData userInfo:@{ NSLocalizedDescriptionKey:@"cacheData invalidate"}];
        }
    }
    return nil;
}

- (void)saveToCacheWithRequest:(SJTRequest *)request
{
    
}



-(NSString *)filePathWithRequest:(SJTRequest *)request
{
    NSString *requestUrl = request.url;
    NSString *baseUrl = [SJTNetworkingConfig shareConfig].baseUrl;
    id argument = request.requestParams;
    NSString *requestInfo = [NSString stringWithFormat:@"Method:%ld Host:%@ Url:%@ Argument:%@",
                             (long)request.requestMethod, baseUrl, requestUrl, argument];
    NSString *cacheFileName = [SJTNetCache md5StringFromString:requestInfo];
    NSString *path = [self cacheBasePath];
    path = [path stringByAppendingPathComponent:cacheFileName];
    return path;
}

-(NSString *)cacheBasePath
{
    NSString * namespace = @"SJTNetworkDefault";
    if ([SJTNetworkingConfig shareConfig].cacheSpaceName.length) {
        namespace = [SJTNetworkingConfig shareConfig].cacheSpaceName;
    }
    NSString * fullPathName = [self makeDiskCachePath:namespace];
    [self createDirectoryIfNeeded:fullPathName];
    return fullPathName;
}

-(NSString *)makeDiskCachePath:(NSString*)fullNamespace{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths[0] stringByAppendingPathComponent:fullNamespace];
}


- (void)createDirectoryIfNeeded:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        [self createBaseDirectoryAtPath:path];
    } else {
        if (!isDir) {
            NSError *error = nil;
            [fileManager removeItemAtPath:path error:&error];
            [self createBaseDirectoryAtPath:path];
        }
    }
}

- (void)createBaseDirectoryAtPath:(NSString *)path {
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES
                                               attributes:nil error:&error];
    if (error) {
        //日志
    }
}

+ (NSString *)md5StringFromString:(NSString *)string {
    NSParameterAssert(string != nil && [string length] > 0);
    
    const char *value = [string UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x", outputBuffer[count]];
    }
    
    return outputString;
}
@end
