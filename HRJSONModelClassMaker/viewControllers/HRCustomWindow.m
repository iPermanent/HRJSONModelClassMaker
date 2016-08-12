//
//  HRCustomWindow.m
//  HRJSONModelClassMaker
//
//  Created by vhall on 16/8/11.
//  Copyright © 2016年 ZhangHeng. All rights reserved.
//

#import "HRCustomWindow.h"
#import "HRListItem.h"
#import <Masonry/Masonry.h>
#import "HRData.h"

@interface HRCustomWindow()<NSOutlineViewDelegate,NSOutlineViewDataSource>
{
    IBOutlet NSOutlineView   *structView;
}
@property(nonatomic,strong)NSArray  *models;
@end

@implementation HRCustomWindow

-(void)awakeFromNib{
    [super awakeFromNib];

    _dataDic = [[HRData shareData] dataDic];
    self.models = [self getAllItems:_dataDic];
    
//    structView = [[NSOutlineView alloc] init];
    [self.contentView addSubview:structView];
    [structView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    structView.dataSource = self;
    structView.delegate = self;
}

-(void)setModels:(NSArray *)models{
    _models = models;
    [structView reloadData];
}

#pragma mark NSLineOutView function
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item{
    if(item == nil)
        return [_models objectAtIndex:index];
    return [[(HRListItem *)item childNodes] objectAtIndex:index];
}

-(NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item{
    return item == nil ? _models.count : [[(HRListItem *)item childNodes] count];
}

-(BOOL) outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item{
    return [(HRListItem*)item childNodes].count > 1;
}

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item{
    return 20;
}

-(id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)theColumn byItem:(id)item{
    NSString    *index = [[[theColumn identifier] componentsSeparatedByString:@"."] lastObject];
    int row = [index intValue];
    
    switch (row) {
        case 0:
            return [item nodeName];
            break;
        case 1:
            return [item typeName];
            break;
        case 2:
            return [item className];
            break;
        default:
            break;
    }
    
    return nil;
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item{
    NSTableCellView *cellView = [outlineView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
    NSString    *index = [[[tableColumn identifier] componentsSeparatedByString:@"."] lastObject];
    int row = [index intValue];
    
    switch (row) {
        case 0:
            cellView.textField.stringValue = [item nodeName];
            break;
        case 1:
            cellView.textField.stringValue = [item typeName];
            break;
        case 2:
            cellView.textField.stringValue = [item className];
            break;
        default:
            break;
    }
    
    
    return cellView;
}

-(NSArray *)getAllItems:(NSDictionary *)dictionary{
    NSMutableArray  *items = @[].mutableCopy;
    for(NSString *key in [dictionary allKeys]){
        id obj = dictionary[key];
        HRListItem *item = [HRListItem new];
        item.nodeName = key;
        item.typeName = [self getDataTypeName:obj];
        item.className = key;
        if([obj isKindOfClass:[NSNumber class]]){
            item.type = propertyTypeAssign;
            item.numberType = [HRTool getNumberType:(NSNumber *)obj];
        }else{
            item.type = propertyTypeStrong;
        }
        
        if([obj isKindOfClass:[NSDictionary class]]){
            [self configItem:item WithDictionary:obj];
        }else if([obj isKindOfClass:[NSArray class]]){
            [self configItem:item WithArray:obj];
        }
        
        [items addObject:item];
    }
    
    return items;
}

-(NSString *)getDataTypeName:(id)object{
    if([object isKindOfClass:[NSNumber class]]){
        return [HRTool getNumberTypeString:(NSNumber *)object];
    }else{
        if([object isKindOfClass:[NSString class]]){
            return @"NSString";
        }else if([object isKindOfClass:[NSArray class]]){
            return @"NSArray";
        }else{
            return @"NSDictionary";
        }
    }
    return @"";
}

-(void)configItem:(HRListItem*)item WithArray:(NSArray *)array{
    [self configItem:item WithDictionary:array[0]];
}

-(void)configItem:(HRListItem*)item WithDictionary:(NSDictionary *)dic{
    item.childNodes = [self getAllItems:dic];
}

@end
