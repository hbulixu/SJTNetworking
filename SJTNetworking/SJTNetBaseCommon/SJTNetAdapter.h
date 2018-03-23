//
//  SJTNetAdapter.h
//  SJTNetworking
//
//  Created by 58 on 2018/3/13.
//  Copyright © 2018年 LX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class  SJTRequest;

typedef void(^SJTCompletionHandler)(SJTRequest * request, NSError * error);

@interface SJTNetAdapter : NSObject

+(instancetype)shareAdapter;

-(NSURLSessionDataTask*)dataTaskWith:(SJTRequest *)request completionHandler:(SJTCompletionHandler )completionHandler;

@end
