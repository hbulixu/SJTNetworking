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


typedef void(^SJTRequestSuccessBlock)( SJTBaseRequest *request);
typedef void(^SJTRequestFailureBlock)( SJTBaseRequest *request, NSError * error);

typedef void(^SJTBatchRequestSuccessBlock)( SJTBatchRequest *request);
typedef void(^SJTBatchRequestFailureBlock)( SJTBatchRequest *request);
#endif /* SJTNetCommomHeader_h */
