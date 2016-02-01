//
//  HRHistoryManager.m
//  HRJSONModelClassMaker
//
//  Created by ZhangHeng on 16/1/31.
//  Copyright © 2016年 ZhangHeng. All rights reserved.
//

#import "HRHistoryManager.h"

@interface HRHistoryManager()

@property(nonatomic,strong)NSMutableArray *histories;
@end

static HRHistoryManager *_sharedManager = nil;

@implementation HRHistoryManager

+(instancetype)sharedManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[HRHistoryManager alloc] init];
    });
    
    return _sharedManager;
}

-(id)init{
    self = [super init];
    if(self){
        NSArray *histories = [NSKeyedUnarchiver unarchiveObjectWithFile:[self itemArchiveExamPath]];
        if(!histories){
            _histories = [NSMutableArray new];
        }else{
            _histories = [histories mutableCopy];
        }
    }
    return self;
}

-(NSArray *)getAllURLs{
    return _histories;
}

-(void)addURL:(NSString *)url{
    if(![_histories containsObject:url]){
        [_histories addObject:url];
        [self saveHistories];
    }
}

-(void)saveHistories{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSKeyedArchiver archiveRootObject:_histories toFile:[self itemArchiveExamPath]];
    });
}

-(NSString *)itemArchiveExamPath{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories firstObject];
    return [documentDirectory stringByAppendingPathComponent:@"histories.archive"];
}

@end
