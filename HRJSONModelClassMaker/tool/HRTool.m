//
//  HRTool.m
//  HRJSONModelClassMaker
//
//  Created by vhall on 16/8/11.
//  Copyright © 2016年 ZhangHeng. All rights reserved.
//

#import "HRTool.h"

@implementation HRTool

+(NSString *)getNumberTypeString:(NSNumber *)number{
    if (strcmp([number objCType], @encode(float)) == 0){
        return @"float";
    }else if (strcmp([number objCType], @encode(double)) == 0){
        return @"double";
    }else if (strcmp([number objCType], @encode(int)) == 0){
        return @"int";
    }else if (strcmp([number objCType], @encode(long)) == 0){
        return @"long";
    }else if (strcmp([number objCType], @encode(BOOL)) == 0){
        return @"bool";
    }else if(strcmp([number objCType], @encode(long long)) == 0){
        return @"long long";
    }
    return @"unknown";
}

+(numberType)getNumberType:(NSNumber *)number{
    if (strcmp([number objCType], @encode(float)) == 0){
        return numberTypeFloat;
    }else if (strcmp([number objCType], @encode(double)) == 0){
        return numberTypeDouble;
    }else if (strcmp([number objCType], @encode(int)) == 0){
        return numberTypeInt;
    }else if (strcmp([number objCType], @encode(long)) == 0){
        return numberTypeLong;
    }else if (strcmp([number objCType], @encode(BOOL)) == 0){
        return numberTypeBool;
    }else if(strcmp([number objCType], @encode(long long)) == 0){
        return numberTypeLongLong;
    }
    return numberTypeUnkown;
}

@end
