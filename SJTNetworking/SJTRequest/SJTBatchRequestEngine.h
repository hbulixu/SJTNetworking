//
//  SJTBatchRequestEngine.h
//  SJTNetworking
//
//  Created by 58 on 2018/3/22.
//  Copyright © 2018年 LX. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SJTBatchRequest;
@interface SJTBatchRequestEngine : NSObject


+(instancetype)shareEngine;

-(void)addBatchRequest:(SJTBatchRequest *)batchRequest;

-(void)removeBatchRequest:(SJTBatchRequest *)batchRequest;

@end
