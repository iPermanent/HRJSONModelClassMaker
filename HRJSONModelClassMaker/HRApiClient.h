//
//  HRApiClient.h
//  KeyboardTest
//
//  Created by ZhangHeng on 15/5/22.
//  Copyright (c) 2015年 ZhangHeng. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>


typedef void(^ApiCompletion)(NSURLSessionDataTask *task, NSDictionary *aResponse, NSError* anError);
typedef void (^UploadProgress)(long long sent, long long expectSend);

@interface HRApiClient : AFHTTPSessionManager

+(id)sharedClient;

/**
 *  @author Henry
 *
 *  基本post方法
 *
 *  @param aPath       路径
 *  @param parameters  参数
 *  @param aCompletion 回调
 *
 *  @return
 */
-(NSURLSessionDataTask *)postPath:(NSString *)aPath parameters:(NSDictionary *)parameters completion:(ApiCompletion)aCompletion;

/**
 *  @author Henry
 *
 *  基本get方法
 *
 *  @param aPath      路径
 *  @param parameters 参数
 *  @param completion 完成的回调
 *
 *  @return
 */
-(NSURLSessionDataTask *)getPath:(NSString *)aPath parameters:(NSDictionary *)parameters completion:(ApiCompletion)completion;

/**
 *  @author Henry
 *
 *  带进度block的上传
 *
 *  @param path        相对路径
 *  @param paremeters  参数
 *  @param data        二进制数据
 *  @param name        数据名
 *  @param aCompletion 完成回调
 *  @param progress    进度跟踪block
 *
 *  @return
 */
-(NSURLSessionDataTask *)postPathForUpload:(NSString *)path
                             andParameters:(NSDictionary *)paremeters
                                   andData:(NSData *)data
                                 withNames:(NSString *)name
                                completion:(ApiCompletion)aCompletion
                               andProgress:(UploadProgress)progress;


/**
 *  @author Henry
 *
 *  多表单上传图片
 *
 *  @param uploadPath  上传路径
 *  @param imagePaths  图片路径地址
 *  @param parameters 参数
 *  @param completion 完成回调
 *
 *  @return
 */
-(NSURLSessionDataTask *)uploadWithMultipartFormsparam:(NSString *)uploadPath
                                             imageUrls:(NSArray *)imagePaths
                                         andParameters:(NSDictionary *)parameters
                                        withCompletion:(ApiCompletion)completion;

@end
