//
//  SJTRequest.m
//  SJTNetworking
//
//  Created by 58 on 2018/3/1.
//  Copyright © 2018年 LX. All rights reserved.
//

#import "SJTRequest.h"
#import "SJTRequestEngine.h"
#import "SJTNetCache.h"
@implementation SJTRequest

+(instancetype)requestWithUrl:(NSString *)url requestMethod:(SJTRequestMethod)requestMethod requestParams:(NSDictionary *)requestParams
{
    SJTRequest * request = [SJTRequest new];
    request.url = url;
    request.requestMethod = requestMethod;
    request.requestParams = requestParams;
    return request;
}


-(void)start
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([self.delegate respondsToSelector:@selector(requestWillStart:)]) {
            [self.delegate requestWillStart:self];
        }
        
    });

    [[SJTRequestEngine shareEngine] startRequest:self];
}

-(void)cancell
{
  
    [[SJTRequestEngine shareEngine] cancelRequest:self];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([self.delegate respondsToSelector:@selector(requestCanceled:)]) {
            [self.delegate requestCanceled:self];
        }
        
    });
}

- (void)clearCompletionBlock
{
    self.successBlock = nil;
    self.failureBlock = nil;
}
@end
