//
//  SJTRequestEngine.h
//  SJTNetworking
//
//  Created by 58 on 2018/3/13.
//  Copyright © 2018年 LX. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SJTRequest;
@interface SJTRequestEngine : NSObject

+(instancetype)shareEngine;

-(void)startRequest:(SJTRequest *)request;

-(void)cancelRequest:(SJTRequest *)request;

-(void)cancelAllRequest;
@end
