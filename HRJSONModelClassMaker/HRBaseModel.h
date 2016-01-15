//
//  HRBaseModel.h
//  KeyboardTest
//
//  Created by ZhangHeng on 15/9/22.
//  Copyright © 2015年 ZhangHeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HRBaseModel : NSObject

-(id)initWithDictionary:(NSDictionary *)dictionary;

/*映射关系字典，{
    前方为服务器返回，后面为model定义的属性
    @"id" = @"ID"
}*/
-(NSDictionary *)mapDictionary;

@end
