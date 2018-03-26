//
//  SJTUploadRequestEngine.h
//  SJTNetworking
//
//  Created by 58 on 2018/3/26.
//  Copyright © 2018年 LX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJTNetCommomHeader.h"
@interface SJTUploadRequestEngine : NSObject

+(instancetype)shareEngine;

-(void)startUploadRequest:(SJTUploadRequest *)uploadRequest;

-(void)cancelUploadRequest:(SJTUploadRequest *)uploadRequest;

-(void)cancelAllUploadRequest;
@end
