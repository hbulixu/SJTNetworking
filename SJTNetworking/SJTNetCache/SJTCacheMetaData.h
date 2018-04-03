//
//  SJTCacheMetaData.h
//  SJTNetworking
//
//  Created by 58 on 2018/4/2.
//  Copyright © 2018年 LX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SJTCacheMetaData : NSObject

@property (nonatomic, strong) NSString *invalidateTime;
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, strong) NSString *appVersionString;
@end
