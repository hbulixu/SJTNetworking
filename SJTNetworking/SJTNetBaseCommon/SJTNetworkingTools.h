//
//  SJTNetworkingTools.h
//  SJTNetworking
//
//  Created by 58 on 2018/5/7.
//  Copyright © 2018年 LX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SJTNetworkingTools : NSObject

+ (void)createDirectoryIfNeeded:(NSString *)path ;

+(void)createBaseDirectoryAtPath:(NSString *)path ;

+(NSString *)makeDiskCachePath:(NSString*)fullNamespace;

+ (NSString *)md5StringFromString:(NSString *)string;
@end
