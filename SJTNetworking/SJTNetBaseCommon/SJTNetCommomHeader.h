//
//  SJTNetCommomHeader.h
//  SJTNetworking
//
//  Created by 58 on 2018/3/22.
//  Copyright © 2018年 LX. All rights reserved.
//

#ifndef SJTNetCommomHeader_h
#define SJTNetCommomHeader_h
@class SJTBaseRequest;
@class SJTFormData;
@class SJTBatchRequest;
@class SJTRequest;
@class SJTUploadRequest;
@class SJTFormDataArray;
@class SJTBatchUploadRequest;
@class SJTDownLoadRequest;
@class SJTBatchDownloadRequest;

typedef NS_ENUM(NSUInteger, SJTRequestMethod) {
    SJTRequestMethodGet,
    SJTRequestMethodPost
};

/**默认是0 default*/
typedef NS_ENUM(NSUInteger, SJTRequestPriority) {
    SJTRequestPriorityLow = -2,
    SJTRequestPriorityDefault  = 0,
    SJTRequestPriorityHigh = 2
};

typedef NS_ENUM(NSInteger, SJTRequestSerializerType) {
    kSJTRequestSerializerHTTP     = 1,
    kSJTRequestSerializerJSON    = 2
};


typedef NS_ENUM(NSInteger, SJTResponseSerializerType) {
    kSJTResponseSerializerHTTP    = 1,
    kSJTesponseSerializerJSON   = 2,
    kSJTesponseSerializerXML    = 3
};

typedef NS_ENUM(NSInteger,  SJTCachePolicy)
{
    //不管怎么样都不写缓存
    SJTCachePolicyDontWriteToCache = 0,
    //如果有缓存那么先访问缓存（不管缓存是否已经过期，然后再去服务端请求新数据，请求失败后不再读缓存）
    SJTCachePolicyTalkServerAfterLoadCache = 1,
    //仅仅访问缓存，如果没有找到缓存，那么会回调cancel,这个缓存策略有内存泄漏问题，没有释放manager暂时不要使用
    SJTCacheOnlyLoadCache = 2,
    
} ;


typedef void(^SJTRequestSuccessBlock)( SJTRequest *request);
typedef void(^SJTRequestFailureBlock)( SJTRequest *request, NSError * error);

typedef void(^SJTBatchRequestSuccessBlock)( SJTBatchRequest *request);
typedef void(^SJTBatchRequestFailureBlock)( SJTBatchRequest *request);

typedef void(^SJTUploadRequestSuccessBlock)( SJTUploadRequest *request);
typedef void(^SJTUploadRequestFailureBlock)( SJTUploadRequest *request, NSError * error);

typedef void (^SJTBatchUploadRequestSuccessBlock)(SJTBatchUploadRequest *request);
typedef void (^SJTBatchUploadRequestFailureBlock)(SJTBatchUploadRequest *request, NSError * error);

typedef void (^SJTProgressBlock)(NSProgress *progress);

typedef NSError * (^SJTResponseValidate)(SJTBaseRequest *request);
typedef BOOL (^SJTResponseCanCache) (SJTBaseRequest *request);

typedef void (^SJTDownloadRequestSuccessBlock)(SJTDownLoadRequest *request);
typedef void (^SJTDownloadRequestFailureBlock)(SJTDownLoadRequest *request, NSError * error);

typedef void (^SJTBatchDownloadRequestSuccessBlock)(SJTBatchDownloadRequest *request);
typedef void (^SJTBatchDownloadRequestFailureBlock)(SJTBatchDownloadRequest *request, NSError * error);

#endif /* SJTNetCommomHeader_h */
