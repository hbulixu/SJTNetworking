//
//  SJTBatchDownloadRequestEngine.m
//  SJTNetworking
//
//  Created by 58 on 2018/4/2.
//  Copyright © 2018年 LX. All rights reserved.
//

#import "SJTBatchDownloadRequestEngine.h"
#import "SJTBatchDownloadRequest.h"

@implementation SJTBatchDownloadRequestEngine
{
    //递归锁,业务会有锁嵌套
    NSRecursiveLock  * _lock;
    NSMutableArray<SJTBatchDownloadRequest *> *_batchDownloadRequestArray;
}

+(instancetype)shareEngine
{
    static SJTBatchDownloadRequestEngine * engine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        engine = [[super allocWithZone:NULL]init];
    });
    return engine;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [SJTBatchDownloadRequestEngine shareEngine];
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        _lock = [NSRecursiveLock new];
        _batchDownloadRequestArray = [NSMutableArray array];
    }
    return self;
}


-(void)addBatchDownloadRequest:(SJTBatchDownloadRequest *)batchDownloadRequest
{
    [_lock lock];
    [_batchDownloadRequestArray addObject:batchDownloadRequest];
    [_lock unlock];
}

-(void)removeBatchDownloadRequest:(SJTBatchDownloadRequest *)batchDownloadRequest
{
    [_lock lock];
    [_batchDownloadRequestArray removeObject:batchDownloadRequest];
    [_lock unlock];
}
@end
