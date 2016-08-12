//
//  HRTool.h
//  HRJSONModelClassMaker
//
//  Created by vhall on 16/8/11.
//  Copyright © 2016年 ZhangHeng. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,numberType){
    numberTypeFloat = 0,
    numberTypeDouble,
    numberTypeInt,
    numberTypeLong,
    numberTypeBool,
    numberTypeLongLong,
    numberTypeUnkown
};

@interface HRTool : NSObject

+(NSString *)getNumberTypeString:(NSNumber *)number;

+(numberType)getNumberType:(NSNumber *)number;

@end
