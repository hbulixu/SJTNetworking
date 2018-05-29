//
//  SJTRequstPrivate.h
//  SJTNetworking
//
//  Created by 58 on 2018/3/13.
//  Copyright © 2018年 LX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJTBaseRequest.h"
@interface SJTBaseRequest (setter)

@property (nonatomic, strong, readwrite) NSURLSessionTask *requestTask;

@property (nonatomic, strong, readwrite) NSURLResponse * response;

@property (nonatomic, strong, readwrite) id responseObject;

@property (nonatomic, strong, readwrite) id responseJSONObject;

@property (nonatomic, strong, readwrite) NSError *error;

@property (nonatomic, assign, readwrite) BOOL isDataFromCache;

@property (nonatomic, strong, readwrite) id responseData;

-(void)clearCompletionBlock;
@end
