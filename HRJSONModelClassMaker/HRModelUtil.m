//
//  HRModelUtil.m
//  HRJSONModelClassMaker
//
//  Created by ZhangHeng on 16/1/15.
//  Copyright © 2016年 ZhangHeng. All rights reserved.
//

#import "HRModelUtil.h"

static HRModelUtil *_modelUtl = nil;
@implementation HRModelUtil

+(HRModelUtil *)shareUtil{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _modelUtl = [[HRModelUtil alloc] init];
    });
    
    return _modelUtl;
}

-(void)dealClassWithDictionary:(NSDictionary *)dic WithClassName:(NSString *)className{
    //if it's array type, get the first element
    if([dic isKindOfClass:[NSArray class]]){
        dic = [(NSArray *)dic objectAtIndex:0];
    }
    NSString *headerContent = [self getClassHeaderContentStringByDictionary:dic WithClassName:className];
    NSString *bodyContent = [self getClassBodyContentStringByDictionary:dic withClassName:className];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *headData = [headerContent dataUsingEncoding:NSUTF8StringEncoding];
        [headData writeToFile:[_path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.h",className]] atomically:YES];
        
        NSData *bodyData = [bodyContent dataUsingEncoding:NSUTF8StringEncoding];
        [bodyData writeToFile:[_path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m",className]] atomically:YES];
    });
}

-(NSString *)getClassHeaderContentStringByDictionary:(NSDictionary *)dictionary WithClassName:(NSString *)className{
    NSMutableString *writeString = [NSMutableString new];
    
    //add Header
    [writeString appendString:@"#import <Foundation/Foundation.h>\n\n"];
    
    //add properties
    [writeString appendFormat:@"@interface %@ : %@<NSCoding>\n\n",className,_baseClassName?_baseClassName:@"NSObject"];
    for(NSString *key in dictionary.allKeys){
        NSLog(@"%@",key);
        [writeString appendString:[self getPropertyParamStringByProperty:key value:dictionary[key]]];
        if([dictionary[key] isKindOfClass:[NSDictionary class]]){
            NSRange range = [writeString rangeOfString:@".h\"" options:NSBackwardsSearch];
            if(range.location == NSNotFound){
                range = [writeString rangeOfString:@".h>"];
            }
            NSString *insertHeader = [NSString stringWithFormat:@"\n#import \"%@.h\"",key];
            [writeString insertString:insertHeader atIndex:range.location+range.length];
        }
    }
    
    //add end
    [writeString appendString:@"@end"];
    
    return writeString;
}

-(NSString *)getPropertyParamStringByProperty:(NSString *)property value:(id)value{
    if([value isKindOfClass:[NSString class]]){
        return [NSString stringWithFormat:@"@property (nonatomic, copy) NSString *%@;\n",property];
    }else if([value isKindOfClass:[NSDictionary class]]){
        [self dealClassWithDictionary:value WithClassName:property];
        return [NSString stringWithFormat:@"@property (nonatomic, strong) %@ *%@;\n",property,property];
    }else if([value isKindOfClass:[NSNumber class]]){
        return [NSString stringWithFormat:@"@property (nonatomic, strong) NSNumber *%@;\n",property];
    }else if([value isKindOfClass:[NSArray class]] && [value count] > 0){
        id obj = value[0];
        if(![obj isKindOfClass:[NSString class]] && ![obj isKindOfClass:[NSNumber class]]){
            [self dealClassWithDictionary:[value firstObject] WithClassName:property];
        }
        return [NSString stringWithFormat:@"@property (nonatomic, strong) NSArray *%@;\n",property];
    }else{
        return [NSString stringWithFormat:@"@property (nonatomic, strong) %@ *%@;\n",property,property];
    }
}

-(NSString *)getClassBodyContentStringByDictionary:(NSDictionary *)dictionary withClassName:(NSString *)className{
    NSMutableString *writeBodyStr = [NSMutableString new];
    
    [writeBodyStr appendFormat:@"#import \"%@.h\"\n\n",className];
    [writeBodyStr appendFormat:@"@implementation %@\n\n",className];
    
    //添加endcode方法
    [writeBodyStr appendString:@"\n"];
    [writeBodyStr appendString:[self getEncodeFunction:dictionary]];
    
    [writeBodyStr appendString:@"\n"];
    [writeBodyStr appendString:[self getDecodeFunction:dictionary]];
    
    [writeBodyStr appendString:@"@end"];
    
    return writeBodyStr;
}

-(NSString *)getEncodeFunction:(NSDictionary *)dictionary{
    NSMutableString *encodeStr = [NSMutableString new];
    [encodeStr appendString:@"-(void)encodeWithCoder:(NSCoder *)aCoder{\n"];
    
    for(NSString *key in dictionary.allKeys){
        NSString *formatString = [NSString stringWithFormat:@"  [aCoder encodeObject:_%@ forKey:@\"%@\"];\n",key,key];
        [encodeStr appendString:formatString];
    }
    
    [encodeStr appendString:@"}"];
    
    return encodeStr;
}

-(NSString *)getDecodeFunction:(NSDictionary *)dictionary{
    NSMutableString *decodeStr = [NSMutableString new];
    [decodeStr appendString:@"-(id)initWithCoder:(NSCoder *)aDecoder{\n self = [super init];\n   if(self){\n"];
    
    for(NSString *key in dictionary.allKeys){
        NSString *formatString = [NSString stringWithFormat:@"      _%@ =   [aDecoder decodeObjectForKey:@\"%@\"];\n",key,key];
        [decodeStr appendString:formatString];
    }
    
    [decodeStr appendString:@"  }\nreturn self;\n}"];
    
    return decodeStr;
}

@end
