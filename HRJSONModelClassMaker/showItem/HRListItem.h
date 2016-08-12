//
//  HRListItem.h
//  HRJSONModelClassMaker
//
//  Created by vhall on 16/8/11.
//  Copyright © 2016年 ZhangHeng. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HRTool.h"

typedef NS_ENUM(NSInteger,propertyType){
    propertyTypeWeak = 0,
    propertyTypeStrong,
    propertyTypeCopy,
    propertyTypeAssign
};

@interface HRListItem : NSObject

@property(nonatomic,copy)NSString *nodeName;
@property(nonatomic,strong)NSArray  *childNodes;
@property(nonatomic,assign)BOOL     shouldIgnore;
@property(nonatomic,copy)NSString *typeName;
@property(nonatomic,assign)BOOL     userAtomic;
@property(nonatomic,copy)NSString *className;
@property(nonatomic,assign)propertyType      type;
//注释
@property(nonatomic,copy)NSString *comment;
//值类型，仅供NSNumber型使用
@property(nonatomic,assign)numberType numberType;

//可选属性类型，strong weak等
@property(nonatomic,strong)NSArray  *avalibleTypes;

@end
