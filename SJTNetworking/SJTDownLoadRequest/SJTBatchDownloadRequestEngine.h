//
//  SJTBatchDownloadRequestEngine.h
//  SJTNetworking
//
//  Created by 58 on 2018/4/2.
//  Copyright © 2018年 LX. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SJTBatchDownloadRequest;
@interface SJTBatchDownloadRequestEngine : NSObject

+(instancetype)shareEngine;

-(void)addBatchDownloadRequest:(SJTBatchDownloadRequest *)batchDownloadRequest;

-(void)removeBatchDownloadRequest:(SJTBatchDownloadRequest *)batchDownloadRequest;

@end
