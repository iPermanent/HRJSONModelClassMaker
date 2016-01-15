//
//  HRBaseModel.m
//  KeyboardTest
//
//  Created by ZhangHeng on 15/9/22.
//  Copyright © 2015年 ZhangHeng. All rights reserved.
//

//model解析时，类的前缀，可以为空
#define classPrefix @"MV_"

#import "HRBaseModel.h"

@implementation HRBaseModel

-(id)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if(self){
        for(NSString *key in [dictionary allKeys]){
            id obj = [dictionary objectForKey:key];
            if(!obj || [obj isKindOfClass:[NSNull class]]){
                NSLog(@"%@ is null",key);
                obj = @"";
            }
            if([obj isKindOfClass:[NSDictionary class]]){
                [self configDicValue:obj withKey:key];
            }else if([obj isKindOfClass:[NSArray class]]){
                [self configArrayValue:obj withKey:key];
            }else{
                NSDictionary *mapDic = [self mapDictionary];
                NSString *modelKey = key;
                if(mapDic && [mapDic objectForKey:key])
                    modelKey = [mapDic objectForKey:key];
                [self setValue:obj forKeyPath:key];
            }
        }
    }
    return self;
}

//简单的只有一层的数据对象型属性
-(void)configDicValue:(id)obj withKey:(NSString *)key{
    Class clazz = NSClassFromString([NSString stringWithFormat:@"%@%@",classPrefix,key]);
    if(clazz){
        id myObj = [[clazz alloc] initWithDictionary:obj];
        [self setValue:myObj forKeyPath:key];
    }else{
        NSLog(@"%@ class undeclare",key);
    }
}

//简单的数组类型，仅支持一层数据解析
-(void)configArrayValue:(id)obj withKey:(NSString *)key{
    NSString *className = [NSString stringWithFormat:@"%@%@",classPrefix,key];
    Class clazz = NSClassFromString(className);
    if(!clazz){
        NSLog(@"%@ class undeclare",key);
    }else{
        NSMutableArray *arrayObj = [NSMutableArray new];
        for(NSDictionary *dic in obj){
            id item = [[clazz alloc] initWithDictionary:dic];
            [arrayObj addObject:item];
        }
        [self setValue:arrayObj forKeyPath:key];
    }
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    //NSLog(@"class:%@ key:%@ not exist",NSStringFromClass([self class]),key);
}

-(NSDictionary *)mapDictionary{
    //NSLog(@"baseModel mapDic will never do anything");
    return nil;
}

@end
