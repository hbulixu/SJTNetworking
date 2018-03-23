//
//  SJTBatchRequest.h
//  SJTNetworking
//
//  Created by 58 on 2018/3/22.
//  Copyright © 2018年 LX. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SJTBatchRequest;
@class SJTRequest;
@protocol SJTBatchRequestDelegate <NSObject>

- (void)batchRequestSuccess:(SJTBatchRequest *)batchRequest;

- (void)batchRequestFailure:(SJTBatchRequest *)batchRequest;

- (void)batchRequestCancelled:(SJTBatchRequest *)batchRequest;

@end

@interface SJTBatchRequest : NSObject

@property (nonatomic, copy) void (^successBlock)(SJTBatchRequest *);

@property (nonatomic, copy) void (^failureBlock)(SJTBatchRequest *);

@property (nonatomic, strong, readonly) NSArray<SJTRequest *> *requestArray;

@property (nonatomic,weak) id <SJTBatchRequestDelegate> delegate;

-(instancetype)initWithRequestArray:(NSArray *)requestArray;

- (void)start;

- (void)cancell;


@end
