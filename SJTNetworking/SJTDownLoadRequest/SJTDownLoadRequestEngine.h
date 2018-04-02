//
//  SJTDownLoadRequestEngine.h
//  SJTNetworking
//
//  Created by 58 on 2018/3/29.
//  Copyright © 2018年 LX. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SJTDownLoadRequest;
@interface SJTDownLoadRequestEngine : NSObject


+(instancetype)shareEngine;

-(void)startDownLoadRequest:(SJTDownLoadRequest *)downloadRequest;

-(void)cancelDownLoadRequest:(SJTDownLoadRequest *)downloadRequest;

-(void)cancelAllDownLoadRequest;

@end
