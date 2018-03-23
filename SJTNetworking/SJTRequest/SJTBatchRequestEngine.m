//
//  SJTBatchRequestEngine.m
//  SJTNetworking
//
//  Created by 58 on 2018/3/22.
//  Copyright © 2018年 LX. All rights reserved.
//

#import "SJTBatchRequestEngine.h"
#import "SJTRequest.h"
#import "SJTBatchRequest.h"

@implementation SJTBatchRequestEngine
{
    //递归锁,业务会有锁嵌套
    NSRecursiveLock  * _lock;
    NSMutableArray<SJTBatchRequest *> *_batchRequestArray;
}


+(instancetype)shareEngine
{
    static SJTBatchRequestEngine * engine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        engine = [[super allocWithZone:NULL]init];
    });
    return engine;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [SJTBatchRequestEngine shareEngine];
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        _batchRequestArray = [NSMutableArray array];
    }
    return self;
}

-(void)addBatchRequest:(SJTBatchRequest *)batchRequest
{
    [_lock lock];
    [_batchRequestArray addObject:batchRequest];
    [_lock unlock];
}

-(void)removeBatchRequest:(SJTBatchRequest *)batchRequest
{
    [_lock lock];
    [_batchRequestArray removeObject:batchRequest];
    [_lock unlock];
}

@end
