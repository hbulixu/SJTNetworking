//
//  SJTBatchUploadRequestEngine.m
//  SJTNetworking
//
//  Created by 58 on 2018/3/27.
//  Copyright © 2018年 LX. All rights reserved.
//

#import "SJTBatchUploadRequestEngine.h"
#import "SJTBatchUploadRequest.h"
@implementation SJTBatchUploadRequestEngine
{
    //递归锁,业务会有锁嵌套
    NSRecursiveLock  * _lock;
    NSMutableArray<SJTBatchUploadRequest *> *_batchUploadRequestArray;
}
+(instancetype)shareEngine
{
    static SJTBatchUploadRequestEngine * engine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        engine = [[super allocWithZone:NULL]init];
    });
    return engine;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [SJTBatchUploadRequestEngine shareEngine];
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        _batchUploadRequestArray = [NSMutableArray array];
    }
    return self;
}

-(void)addBatchUploadRequest:(SJTBatchUploadRequest *)batchUploadRequest
{
    [_lock lock];
    [_batchUploadRequestArray addObject:batchUploadRequest];
    [_lock unlock];
}

-(void)removeBatchUploadRequest:(SJTBatchUploadRequest *)batchUploadRequest
{
    [_lock lock];
    [_batchUploadRequestArray removeObject:batchUploadRequest];
    [_lock unlock];
}
@end
