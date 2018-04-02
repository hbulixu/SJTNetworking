//
//  SJTBatchDownloadRequest.m
//  SJTNetworking
//
//  Created by 58 on 2018/4/2.
//  Copyright © 2018年 LX. All rights reserved.
//

#import "SJTBatchDownloadRequest.h"
#import "SJTDownLoadRequest.h"

@implementation SJTBatchDownloadRequest

-(instancetype)initWithDownloadRequestArray:(NSArray <SJTDownLoadRequest *>*)requestArray
{
    self = [super init];
    if (self) {
        _requestArray = [requestArray copy];
        for (SJTDownLoadRequest * request in _requestArray) {
            if (![request isKindOfClass:[SJTDownLoadRequest class]]) {
                return nil;
            }
        }
    }
    return self;
}

- (void)start
{
    
}
//失败后再次发起请求，成功的请求会自动过滤
- (void)reTry
{
    
}

- (void)cancell
{
    
}

- (void)clearCompletionBlock
{
    self.successBlock =  nil;
    self.failureBlock =  nil;
}
@end
