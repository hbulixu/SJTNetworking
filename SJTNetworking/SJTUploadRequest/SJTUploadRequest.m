//
//  SJTUploadRequest.m
//  SJTNetworking
//
//  Created by 58 on 2018/3/13.
//  Copyright © 2018年 LX. All rights reserved.
//

#import "SJTUploadRequest.h"

@implementation SJTUploadRequest

@end


@implementation SJTFormData

+ (instancetype)formDataWithName:(NSString *)name fileData:(NSData *)fileData {
    SJTFormData *formData = [[SJTFormData alloc] init];
    formData.name = name;
    formData.fileData = fileData;
    return formData;
}

+ (instancetype)formDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileData:(NSData *)fileData {
    SJTFormData *formData = [[SJTFormData alloc] init];
    formData.name = name;
    formData.fileName = fileName;
    formData.mimeType = mimeType;
    formData.fileData = fileData;
    return formData;
}

+ (instancetype)formDataWithName:(NSString *)name fileURL:(NSURL *)fileURL {
    SJTFormData *formData = [[SJTFormData alloc] init];
    formData.name = name;
    formData.fileURL = fileURL;
    return formData;
}

+ (instancetype)formDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileURL:(NSURL *)fileURL {
    SJTFormData *formData = [[SJTFormData alloc] init];
    formData.name = name;
    formData.fileName = fileName;
    formData.mimeType = mimeType;
    formData.fileURL = fileURL;
    return formData;
}

@end
