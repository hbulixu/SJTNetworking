//
//  SJTBatchUploadRequestEngine.h
//  SJTNetworking
//
//  Created by 58 on 2018/3/27.
//  Copyright © 2018年 LX. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SJTBatchUploadRequest;
@interface SJTBatchUploadRequestEngine : NSObject

+(instancetype)shareEngine;

-(void)addBatchUploadRequest:(SJTBatchUploadRequest *)batchUploadRequest;

-(void)removeBatchUploadRequest:(SJTBatchUploadRequest *)batchUploadRequest;
@end
