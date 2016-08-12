//
//  HRData.m
//  HRJSONModelClassMaker
//
//  Created by vhall on 16/8/12.
//  Copyright © 2016年 ZhangHeng. All rights reserved.
//

#import "HRData.h"

static HRData *_data = nil;

@implementation HRData

+(instancetype)shareData{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _data = [HRData new];
    });
    
    return _data;
}

@end
