//
//  SJTUploadRequest.m
//  SJTNetworking
//
//  Created by 58 on 2018/3/13.
//  Copyright © 2018年 LX. All rights reserved.
//

#import "SJTUploadRequest.h"
#import "SJTUploadRequestEngine.h"
@implementation SJTUploadRequest

- (void)clearCompletionBlock
{
    self.successBlock = nil;
    self.failureBlock = nil;
    self.processBlock = nil;
}

-(void)start
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([self.delegate respondsToSelector:@selector(uploadRequestWillStart:)]) {
            [self.delegate uploadRequestWillStart:self];
        }
        
    });
    
    [[SJTUploadRequestEngine shareEngine] startUploadRequest:self];
}

-(void)cancell
{
    
    [[SJTUploadRequestEngine shareEngine] cancelUploadRequest:self];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([self.delegate respondsToSelector:@selector(uploadRequestCanceled:)]) {
            [self.delegate uploadRequestCanceled:self];
        }
        
    });
    [self clearCompletionBlock];
}


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

@interface SJTFormDataArray()

@property (nonatomic,strong,readwrite)NSMutableArray * formDataArray;

@end

@implementation SJTFormDataArray

-(instancetype)init
{
    self = [super init];
    if (self) {
        _formDataArray = [NSMutableArray array];
    }
    return self;
}

-(void)appendFormDataWithName:(NSString *)name fileData:(NSData *)fileData
{
    SJTFormData * formData = [SJTFormData formDataWithName:name fileData:fileData];
    [_formDataArray addObject:formData];
}

-(void)appendFormDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileData:(NSData *)fileData
{
    SJTFormData * formData = [SJTFormData formDataWithName:name fileName:fileName mimeType:mimeType fileData:fileData];
    [_formDataArray addObject:formData];
}

-(void)appendFormDataWithName:(NSString *)name fileURL:(NSURL *)fileURL
{
    SJTFormData * formData = [SJTFormData formDataWithName:name fileURL:fileURL];
    [_formDataArray addObject:formData];
}

-(void)appendFormDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileURL:(NSURL *)fileURL
{
    SJTFormData * formData = [SJTFormData formDataWithName:name fileName:fileName mimeType:mimeType fileURL:fileURL];
    [_formDataArray addObject:formData];
}
@end







