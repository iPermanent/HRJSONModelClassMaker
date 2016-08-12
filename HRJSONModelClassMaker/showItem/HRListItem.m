//
//  HRListItem.m
//  HRJSONModelClassMaker
//
//  Created by vhall on 16/8/11.
//  Copyright © 2016年 ZhangHeng. All rights reserved.
//

#import "HRListItem.h"

@implementation HRListItem

-(NSArray *)avalibleTypes{
    if(!_avalibleTypes){
        NSArray *strongTypes = @[@"NSString",@"NSDictionary",@"__NSCFConstantString"];
        if([strongTypes containsObject:_typeName]){
            _avalibleTypes = @[@"strong",@"weak",@"copy"];
        }else{
            _avalibleTypes = @[@"assign"];
        }
    }
    return _avalibleTypes;
}

@end
