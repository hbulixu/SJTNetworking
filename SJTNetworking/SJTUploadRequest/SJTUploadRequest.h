//
//  SJTUploadRequest.h
//  SJTNetworking
//
//  Created by 58 on 2018/3/13.
//  Copyright © 2018年 LX. All rights reserved.
//

#import "SJTBaseRequest.h"

@interface SJTUploadRequest : SJTBaseRequest

@property (nonatomic, strong) NSMutableArray<SJTFormData *> *uploadFormDatas;
@end

@interface SJTFormData : NSObject

/**
 The name to be associated with the specified data. This property must not be `nil`.
 */
@property (nonatomic, copy) NSString *name;

/**
 The file name to be used in the `Content-Disposition` header. This property is not recommended be `nil`.
 */
@property (nonatomic, copy) NSString *fileName;

/**
 The declared MIME type of the file data. This property is not recommended be `nil`.
 */
@property (nonatomic, copy) NSString *mimeType;

/**
 The data to be encoded and appended to the form data, and it is prior than `fileURL`.
 */
@property (nonatomic, strong) NSData *fileData;

/**
 The URL corresponding to the file whose content will be appended to the form, BUT, when the `fileData` is assigned，the `fileURL` will be ignored.
 */
@property (nonatomic, strong) NSURL *fileURL;

// NOTE: Either of the `fileData` and `fileURL` should not be `nil`, and the `fileName` and `mimeType` must both be `nil` or assigned at the same time,

///-----------------------------------------------------
/// @name Quickly Class Methods For Creates A New Object
///-----------------------------------------------------

+ (instancetype)formDataWithName:(NSString *)name fileData:(NSData *)fileData;

+ (instancetype)formDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileData:(NSData *)fileData;

+ (instancetype)formDataWithName:(NSString *)name fileURL:(NSURL *)fileURL;

+ (instancetype)formDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileURL:(NSURL *)fileURL;
@end
