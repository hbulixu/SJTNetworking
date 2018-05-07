//
//  SJTDownLoadRequest.m
//  SJTNetworking
//
//  Created by 58 on 2018/3/28.
//  Copyright © 2018年 LX. All rights reserved.
//

#import "SJTDownLoadRequest.h"
#import "SJTDownLoadRequestEngine.h"
@implementation SJTDownLoadRequest


-(void)start
{

    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([self.delegate respondsToSelector:@selector(downLoadRequestWillStart:)]) {
            [self.delegate downLoadRequestWillStart:self];
        }
        
    });
    
    [[SJTDownLoadRequestEngine shareEngine] startDownLoadRequest:self];
}

-(void)cancell
{
    
    [[SJTDownLoadRequestEngine shareEngine] cancelDownLoadRequest:self];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([self.delegate respondsToSelector:@selector(downLoadRequestCanceled:)]) {
            [self.delegate downLoadRequestCanceled:self];
        }
        
    });
    [self clearCompletionBlock];
}

-(void)clearCompletionBlock
{
    self.successBlock = nil;
    self.failureBlock = nil;
    self.processBlock = nil;
}

-(void)dealloc
{
    
}
@end
