//
//  HRModelUtil.h
//  HRJSONModelClassMaker
//
//  Created by ZhangHeng on 16/1/15.
//  Copyright © 2016年 ZhangHeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HRModelUtil : NSObject

@property(nonatomic,copy)NSString   *path;
@property(nonatomic,copy)NSString   *baseClassName;

+(HRModelUtil *)shareUtil;

-(void)dealClassWithDictionary:(NSDictionary *)dic WithClassName:(NSString *)className;

@end
