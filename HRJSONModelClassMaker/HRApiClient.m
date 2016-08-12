//
//  HRApiClient.m
//  KeyboardTest
//
//  Created by ZhangHeng on 15/5/22.
//  Copyright (c) 2015年 ZhangHeng. All rights reserved.
//

#import "HRApiClient.h"

@implementation HRApiClient

static HRApiClient *_sharedClient = nil;

+(id)sharedClient{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[HRApiClient alloc] init];
        _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        
        //发送json数据
        _sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];
        //响应json数据
        _sharedClient.responseSerializer  = [AFJSONResponseSerializer serializer];
        
        NSMutableIndexSet *indexSets = [NSMutableIndexSet new];
        [indexSets addIndex:500];
        [indexSets addIndex:501];
        [indexSets addIndex:502];
        [indexSets addIndex:503];
        [indexSets addIndex:504];
        [indexSets addIndex:505];
        [indexSets addIndex:200];
        [indexSets addIndex:201];
        [indexSets addIndex:202];
        [indexSets addIndex:203];
        [indexSets addIndex:204];
        [indexSets addIndex:205];
        [indexSets addIndex:206];
        _sharedClient.responseSerializer.acceptableStatusCodes = indexSets;

        _sharedClient.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", @"text/plain",@"application/atom+xml",@"application/xml",@"text/xml",@"application/octet-stream",@"multipart/mixed", nil];
    });
    
    return _sharedClient;
}

/*
 基本post方法
 */
-(NSURLSessionDataTask *)postPath:(NSString *)aPath parameters:(NSDictionary *)parameters completion:(ApiCompletion)aCompletion {
    NSLog(@"请求post地址:%@ 参数:%@",aPath,parameters);

    NSURLSessionDataTask *task = [self POST:aPath parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        if (aCompletion) {
            if(responseObject)
                aCompletion(task, responseObject, nil);
            else{
                NSError *error = [[NSError alloc] initWithDomain:@"" code:-1 userInfo:responseObject];
                aCompletion(task,nil,error);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (aCompletion) {
            aCompletion(task, nil, error);
        }
    }];
    
    return task;
}

-(NSString *) jsonStringWithObject:(id) object{
    NSError *error;
    NSData *jsondata=[NSJSONSerialization dataWithJSONObject:object
                                                     options:kNilOptions
                                                       error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsondata
                            
                                                 encoding:NSUTF8StringEncoding];
    
    return jsonString;
}

/**
 *  @author Henry
 *
 *  基本get方法
 *
 *  @param aPath      路径
 *  @param parameters 参数
 *  @param completion 完成回调
 *
 *  @return
 */
-(NSURLSessionDataTask *)getPath:(NSString *)aPath parameters:(NSDictionary *)parameters completion:(ApiCompletion)completion{
    NSLog(@"请求get地址:%@ 参数:%@",aPath,parameters);
    NSURLSessionDataTask    *task = [self GET:aPath parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        if(completion)
            completion(task,responseObject,nil);
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        if(completion)
            completion(task,nil,error);
    }];
    
    return task;
}

/*
 兼容iOS7/8的上传方法，支持进度上传
 */
-(NSURLSessionDataTask *)postPathForUpload:(NSString *)path andParameters:(NSDictionary *)paremeters andData:(NSData *)data withName:(NSString *)name completion:(ApiCompletion)aCompletion andProgress:(UploadProgress)progress{
    
    NSURLSessionDataTask *task = [NSURLSessionDataTask new];
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:path]];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = self.responseSerializer.acceptableContentTypes;
    
    AFHTTPRequestOperation *operation = [manager POST:path parameters:paremeters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:@"file" fileName:name mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if(aCompletion)
            aCompletion(task,responseObject,nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSMutableDictionary    *errorDic   =   error.userInfo.mutableCopy;
        [errorDic setObject:errorDic.description forKey:@"msg"];
        NSError *anError = [NSError errorWithDomain:@"" code:-1 userInfo:errorDic];
        if(aCompletion)
            aCompletion(task,nil,anError);
    }];
    
    //上传进度
    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {
        if(progress){
            progress(totalBytesWritten,totalBytesExpectedToWrite);
        }
    }];
    [operation start];
    
    return task;
}

/**
 *  @author Henry
 *
 *  多表单方式上传多张图片
 *
 *  @param imagePaths 图片路径
 *  @param parameters 上传参数
 *  @param completion 完成回调
 *
 *  @return
 */
-(NSURLSessionDataTask *)uploadWithMultipartFormsparam:(NSString *)uploadPath
                                             imageUrls:(NSArray *)imagePaths
                                         andParameters:(NSDictionary *)parameters
                                        withCompletion:(ApiCompletion)completion{
    return [self POST:uploadPath parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (imagePaths && imagePaths.count != 0) {
            for(int i = 0; i < imagePaths.count; i++) {
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:[imagePaths objectAtIndex: i]]];
                // 上传的参数名
                NSString *name = [[imagePaths objectAtIndex:i] lastPathComponent];
                // 上传filename
                NSString *fileName = [[imagePaths objectAtIndex:i] lastPathComponent];
                
                [formData appendPartWithFileData:imageData name:name fileName:fileName mimeType:@"image/jpeg"];
            }
        }
        
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        if(completion)
            completion(nil,responseObject,nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(completion){
            completion(nil,nil,error);
        }
    }];
}

-(NSString *)getMIMETypeByFileName:(NSString *)fileName{
    NSArray *images = @[@"jpg",@"png",@"jpeg",@"bmp"];
    NSArray *sounds = @[@"caf",@"wav",@"amr",@"mp3",@"wma"];
    
    if([images containsObject:[[fileName pathExtension] lowercaseString]]){
        return @"image/jpeg";
    }else if([sounds containsObject:[[fileName pathExtension] lowercaseString]]){
        return @"audio/mp3";
    }else{
        return @"file/unkown";
    }
}

@end
