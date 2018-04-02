//
//  SJTNetAdapter.h
//  SJTNetworking
//
//  Created by 58 on 2018/3/13.
//  Copyright © 2018年 LX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJTNetCommomHeader.h"

typedef void(^SJTCompletionHandler)(SJTBaseRequest * request, NSError * error);

@interface SJTNetAdapter : NSObject

+(instancetype)shareAdapter;

-(NSURLSessionDataTask*)dataTaskWith:(SJTRequest *)request completionHandler:(SJTCompletionHandler )completionHandler;

-(NSURLSessionUploadTask*)uploadDataTaskWith:(SJTUploadRequest *)uploadRequest processBlock:(SJTProgressBlock)proccessBlock completionHandler:(SJTCompletionHandler)completionHandler;

-(NSURLSessionDownloadTask *)downloadDataTaskWith:(SJTDownLoadRequest *)downLoadRequest processBlock:(SJTProgressBlock)processBlock completionHandler:(SJTCompletionHandler)completionHandler;

@end
