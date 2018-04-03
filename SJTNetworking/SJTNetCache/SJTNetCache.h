//
//  SJTNetCache.h
//  SJTNetworking
//
//  Created by 58 on 2018/4/2.
//  Copyright © 2018年 LX. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SJTRequest;
extern NSString *const SJTRequestCacheErrorDomain ;

NS_ENUM(NSInteger) {
    //配置文件不存在
    SJTRequestCacheErrorMisMetaData = -1,
    //配置文件内容有误
    SJTRequestCacheErrorInvalidMetadata = -2,
    //缓存版本不匹配
    SJTRequestCacheErrorAppVersionMismatch = -3,
    //缓存时间过期
    SJTRequestCacheErrorInvalidCacheTime = -4,
    //缺少缓存文件
    SJTRequestCacheErrorMisCacheData = -5,
    //缓存内容校验失败
    SJTRequestCacheErrorInvalidCacheData = -6
};
@interface SJTNetCache : NSObject

+(instancetype)shareCache;

- (NSError *)loadCacheWithRequest:(SJTRequest *)request;

- (void)saveToCacheWithRequest:(SJTRequest *)request;
@end
