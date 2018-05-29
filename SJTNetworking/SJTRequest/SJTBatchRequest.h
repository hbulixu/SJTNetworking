//
//  SJTBatchRequest.h
//  SJTNetworking
//
//  Created by 58 on 2018/3/22.
//  Copyright © 2018年 LX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJTNetCommomHeader.h"
@class SJTBatchRequest;
@class SJTRequest;
@protocol SJTBatchRequestDelegate <NSObject>

- (void)batchRequestSuccess:(SJTBatchRequest *)batchRequest;

- (void)batchRequestFailure:(SJTBatchRequest *)batchRequest;

- (void)batchRequestCancelled:(SJTBatchRequest *)batchRequest;

@end

@interface SJTBatchRequest : NSObject

@property (nonatomic, copy) SJTBatchRequestSuccessBlock  successBlock;

@property (nonatomic, copy) SJTBatchRequestFailureBlock failureBlock;

@property (nonatomic, strong, readonly) NSArray<SJTRequest *> *requestArray;

@property (nonatomic,weak) id <SJTBatchRequestDelegate> delegate;

@property (nonatomic,strong) SJTRequest * firstErrorRequest;

-(instancetype)initWithRequestArray:(NSArray <SJTRequest *>*)requestArray;

- (void)start;

- (void)cancell;



@end
