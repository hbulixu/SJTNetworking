//
//  SJTCacheMetaData.m
//  SJTNetworking
//
//  Created by 58 on 2018/4/2.
//  Copyright © 2018年 LX. All rights reserved.
//

#import "SJTCacheMetaData.h"

@implementation SJTCacheMetaData

- (void)encodeWithCoder:(NSCoder *)aCoder {

    [aCoder encodeObject:self.invalidateTime forKey:NSStringFromSelector(@selector(invalidateTime))];
    [aCoder encodeObject:self.creationDate forKey:NSStringFromSelector(@selector(creationDate))];
    [aCoder encodeObject:self.appVersionString forKey:NSStringFromSelector(@selector(appVersionString))];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    if (!self) {
        return nil;
    }
    self.invalidateTime = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(invalidateTime))];
    self.creationDate = [aDecoder decodeObjectOfClass:[NSDate class] forKey:NSStringFromSelector(@selector(creationDate))];
    self.appVersionString = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(appVersionString))];
    
    return self;
}

@end
