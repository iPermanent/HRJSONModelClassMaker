//
//  AppDelegate.m
//  HRJSONModelClassMaker
//
//  Created by ZhangHeng on 16/1/15.
//  Copyright © 2016年 ZhangHeng. All rights reserved.
//

#import "AppDelegate.h"
#import "HRModelUtil.h"
#import "HRApiClient.h"

@interface AppDelegate ()<NSTableViewDataSource,NSTableViewDelegate>
{
    IBOutlet    NSTextField     *resultLabel;
    IBOutlet    NSTextField     *inputJsonText;
    IBOutlet    NSTextField     *className;
    
    NSString *outputPath;
    
    IBOutlet    NSTextField     *url;
    IBOutlet    NSTextField     *keyTF;
    IBOutlet    NSTextField     *valueTF;
    
    IBOutlet    NSTextField     *headerTF;
    IBOutlet    NSTextField     *headerValueTF;
    
    IBOutlet    NSPopUpButton   *requestWay;
}
@property   (weak) IBOutlet NSWindow *window;
@property   (nonatomic,weak)IBOutlet NSTableView    *table;
@property   (nonatomic,weak)IBOutlet NSTableView    *headerTable;
@property   (nonatomic,strong)NSMutableDictionary   *parameters;
@property   (nonatomic,strong)NSMutableDictionary   *headers;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    _table.dataSource = self;
    _table.delegate = self;
    
    _headerTable.dataSource = self;
    _headerTable.delegate = self;
    _parameters =   [NSMutableDictionary new];
    _headers    =   [NSMutableDictionary new];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(IBAction)selectOutputPath:(id)sender{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:NO];
    [openDlg setCanChooseDirectories:YES];
    if ( [openDlg runModal] == NSModalResponseOK){
        NSURL   *files = [[openDlg URLs] objectAtIndex:0];
        outputPath = files.path;
        resultLabel.stringValue = outputPath;
    }
}

-(IBAction)startOutputClassFile:(id)sender{
    if(!outputPath){
        resultLabel.stringValue = @"请选择输出路径!";
        return;
    }
    
    NSData *data = [inputJsonText.stringValue dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if(!json || ![json isKindOfClass:[NSDictionary class]] || [json isKindOfClass:[NSArray class]]){
        resultLabel.stringValue = @"格式有误";
    }else{
        [[HRModelUtil shareUtil] setPath:outputPath];
        [[HRModelUtil shareUtil] dealClassWithDictionary:json WithClassName:className.stringValue.length > 1?className.stringValue:@"baseModel"];
    }
}

-(IBAction)startRequest:(id)sender{
    if(url.stringValue.length < 1 || ![url.stringValue hasPrefix:@"http://"]){
        inputJsonText.stringValue = @"URL不合法，请检查！";
        return;
    }
    for(NSString *key in _headers.allKeys){
        [[[HRApiClient sharedClient] requestSerializer] setValue:_headers[key] forHTTPHeaderField:key];
    }
    NSString  *way = requestWay.selectedItem.title;
    if([way isEqualToString:@"Post"]){
        [[HRApiClient sharedClient] postPath:url.stringValue parameters:_parameters completion:^(NSURLSessionDataTask *task,    NSDictionary *aResponse, NSError *anError) {
            NSLog(@"%@",aResponse);
            if(aResponse){
                NSString *jsonString = [self jsonStringWithObject:aResponse];
                inputJsonText.stringValue = jsonString;
            }
        }];
    }else if([way isEqualToString:@"Get"]){
        [[HRApiClient sharedClient] getPath:url.stringValue parameters:_parameters completion:^(NSURLSessionDataTask *task, NSDictionary *aResponse, NSError *anError) {
            NSLog(@"%@",aResponse);
            if(aResponse){
                NSString *jsonString = [self jsonStringWithObject:aResponse];
                inputJsonText.stringValue = jsonString;
            }
        }];
    }else{
        [[HRApiClient sharedClient] uploadWithMultipartFormsparam:url.stringValue imageUrls:nil andParameters:_parameters withCompletion:^(NSURLSessionDataTask *task, NSDictionary *aResponse, NSError *anError) {
            if(aResponse){
                NSString *jsonString = [self jsonStringWithObject:aResponse];
                inputJsonText.stringValue = jsonString;
            }
        }];
    }
}

-(IBAction)addParametersOfRequest:(id)sender{
    if(keyTF.stringValue.length > 0 && valueTF.stringValue.length > 0){
        [_parameters setObject:valueTF.stringValue forKey:keyTF.stringValue];
        [_table reloadData];
    }
}

-(IBAction)addHttpHeaders:(id)sender{
    if(headerTF.stringValue.length > 0 && headerValueTF.stringValue.length > 0){
        [_headers setObject:headerValueTF.stringValue forKey:headerTF.stringValue];
        [_headerTable reloadData];
    }
}

-(NSString *) jsonStringWithObject:(id) object{
    NSError *error;
    NSData *jsondata=[NSJSONSerialization dataWithJSONObject:object
                                                     options:kNilOptions
                                                       error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsondata
                            
                                                 encoding:NSUTF8StringEncoding];
    
    return jsonString;
}

#pragma mark- tableView function
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    if(tableView == _table){
        return _parameters.allKeys.count;
    }else{
        return _headers.allKeys.count;
    }
}

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    return 40.0;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if(tableView == _table){
        if([tableColumn.identifier isEqualToString:@"AutomaticTableColumnIdentifier.0"]){
            NSTableCellView *cellView = [[NSTableCellView alloc] init];
            NSTextField *keyLabel = [[NSTextField alloc] initWithFrame:CGRectMake(10, 5, 100, 30)];
            [cellView addSubview:keyLabel];
            keyLabel.stringValue = [_parameters.allKeys objectAtIndex:row];
            return cellView;
        }else if([tableColumn.identifier isEqualToString:@"AutomaticTableColumnIdentifier.1"]){
            NSTableCellView *cellView = [[NSTableCellView alloc] init];
            NSTextField *keyLabel = [[NSTextField alloc] initWithFrame:CGRectMake(10, 5, 100, 30)];
            [cellView addSubview:keyLabel];
            keyLabel.stringValue = [_parameters objectForKey:[_parameters.allKeys objectAtIndex:row]];
            return cellView;
        }else{
            NSTableCellView *cellView = [[NSTableCellView alloc] init];
            NSButton *deleteBtn = [[NSButton alloc] initWithFrame:NSMakeRect(10, 5, 60, 30)];
            deleteBtn.layer.backgroundColor = [NSColor redColor].CGColor;
            deleteBtn.tag = row;
            [deleteBtn setTitle:@"删除"];
            [deleteBtn setAction:@selector(deleteParam:)];
            [cellView addSubview:deleteBtn];
            
            return cellView;
        }
    }else{
        if([tableColumn.identifier isEqualToString:@"AutomaticTableColumnIdentifier.0"]){
            NSTableCellView *cellView = [[NSTableCellView alloc] init];
            NSTextField *keyLabel = [[NSTextField alloc] initWithFrame:CGRectMake(10, 5, 100, 30)];
            [cellView addSubview:keyLabel];
            keyLabel.stringValue = [_headers.allKeys objectAtIndex:row];
            return cellView;
        }else if([tableColumn.identifier isEqualToString:@"AutomaticTableColumnIdentifier.1"]){
            NSTableCellView *cellView = [[NSTableCellView alloc] init];
            NSTextField *keyLabel = [[NSTextField alloc] initWithFrame:CGRectMake(10, 5, 100, 30)];
            [cellView addSubview:keyLabel];
            keyLabel.stringValue = [_headers objectForKey:[_headers.allKeys objectAtIndex:row]];
            return cellView;
        }else{
            NSTableCellView *cellView = [[NSTableCellView alloc] init];
            NSButton *deleteBtn = [[NSButton alloc] initWithFrame:NSMakeRect(10, 5, 100, 30)];
            deleteBtn.layer.backgroundColor = [NSColor redColor].CGColor;
            deleteBtn.tag = row;
            [deleteBtn setTitle:@"删除"];
            [deleteBtn setAction:@selector(deleteHeader:)];
            [cellView addSubview:deleteBtn];
            
            return cellView;
        }
    }
}

-(void)deleteHeader:(NSButton *)sender{
    NSString *key = [_headers.allKeys objectAtIndex:sender.tag];
    [_headers removeObjectForKey:key];
    [_headerTable reloadData];
}

-(void)deleteParam:(NSButton *)sender{
    NSString *key = [_parameters.allKeys objectAtIndex:sender.tag];
    [_parameters removeObjectForKey:key];
    [_table reloadData];
}

@end
