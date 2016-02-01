//
//  HRHistoryManager.h
//  HRJSONModelClassMaker
//
//  Created by ZhangHeng on 16/1/31.
//  Copyright © 2016年 ZhangHeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HRHistoryManager : NSObject

+(instancetype)sharedManager;


-(NSArray *)getAllURLs;

-(void)addURL:(NSString *)url;

@end
