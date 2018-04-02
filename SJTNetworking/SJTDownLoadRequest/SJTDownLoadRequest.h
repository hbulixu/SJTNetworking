//
//  SJTDownLoadRequest.h
//  SJTNetworking
//
//  Created by 58 on 2018/3/28.
//  Copyright © 2018年 LX. All rights reserved.
//

#import "SJTBaseRequest.h"



@protocol SJTDownLoadRequestDelegate <NSObject>

@optional

- (void)downLoadRequestWillStart:(SJTDownLoadRequest *)request;

- (void)downLoadRequestCanceled:(SJTDownLoadRequest *)request;

- (void)downLoadRequestSuccess:(SJTDownLoadRequest *)request;

- (void)downLoadRequestFailed:(SJTDownLoadRequest *)request error:(NSError *)error;

- (void)downLoadRequestProcess:(SJTDownLoadRequest *)request progress:(NSProgress *)progress;

@end
@interface SJTDownLoadRequest : SJTBaseRequest

/**文件下载路径*/
@property (nonatomic,copy)NSString * downLoadPath;
@property (nonatomic, copy) SJTProgressBlock  processBlock;
@property (nonatomic, weak) id <SJTDownLoadRequestDelegate> delegate;
@property (nonatomic, copy)SJTDownloadRequestSuccessBlock successBlock;
@property (nonatomic, copy)SJTDownloadRequestFailureBlock failureBlock;

-(void)clearCompletionBlock;
@end
