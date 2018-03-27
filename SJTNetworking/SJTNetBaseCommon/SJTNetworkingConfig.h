//
//  SJTNetworkingConfig.h
//  SJTNetworking
//
//  Created by 58 on 2018/3/1.
//  Copyright © 2018年 LX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJTNetCommomHeader.h"

@interface SJTNetworkingConfig : NSObject

@property (nonatomic,copy)NSString * baseUrl;
/**最好根据用户隔离*/
@property (nonatomic,copy)NSString * cachePath;

/**全局设置，如果要特殊处理，请设置单独的SJTRequest*/
/**默认kSJTRequestSerializerHTTP*/
@property (nonatomic,assign)SJTRequestSerializerType  requestSerializerType;

/**默认kSJTesponseSerializerJSON*/
@property (nonatomic,assign)SJTResponseSerializerType  responseSerializerType;

/**统一的http请求头*/
@property (nonatomic,strong)NSDictionary * requestHeaderFieldValueDictionary;

/**
 为业务保留的接口，当校验不通过时会调用failure分支,返回error为是吧，nil为成功
 */
@property (nonatomic,copy)SJTResponseValidate responseValidate;

/**
 为业务保留接口，当校验不通过时，不会缓存
 */
@property (nonatomic,copy)SJTResponseCanCache responseCanCache;

+(instancetype)shareConfig;
@end
