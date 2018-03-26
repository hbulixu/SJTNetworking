//
//  SJTBaseRequest.h
//  SJTNetworking
//
//  Created by 58 on 2018/3/13.
//  Copyright © 2018年 LX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJTNetCommomHeader.h"

@interface SJTBaseRequest : NSObject

@property (nonatomic, strong, readonly) NSURLSessionTask *requestTask;

@property (nonatomic, strong, readonly) id responseObject;

@property (nonatomic, strong, readonly) id responseData;

@property (nonatomic, strong, readonly) id responseJSONObject;

@property (nonatomic, strong, readonly) NSError *error;

@property (nonatomic, assign, readonly) BOOL isDataFromCache;

@property (nonatomic, strong)NSString * url;

@property (nonatomic, assign)SJTRequestMethod requestMethod;

@property (nonatomic, strong)NSDictionary * requestParams;

@property (nonatomic, assign)SJTRequestPriority requestPriority;

@property (nonatomic, strong)NSDictionary * requestHeaderFieldValueDictionary;

@property (nonatomic, assign)NSInteger requestTimeoutInterval;

@property (nonatomic, assign)SJTRequestSerializerType  requestSerializerType;

@property (nonatomic, assign)SJTResponseSerializerType responseSerializerType;

@property (nonatomic, readonly, getter=isCancelled) BOOL cancelled;

@property (nonatomic, readonly, getter=isExecuting) BOOL executing;

@property (nonatomic, strong)NSURLRequest * customRequest;


-(void)start;

-(void)cancell;


@end



