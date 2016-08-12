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
#import "HRHistoryManager.h"
#import "HRImageDealView.h"
#import "HRCustomModelVC.h"
#import "HRData.h"

@interface AppDelegate ()<NSTableViewDataSource,NSTableViewDelegate,NSMenuDelegate,NSComboBoxDataSource,NSComboBoxDelegate,NSTextFieldDelegate>
{
    IBOutlet    NSTextField     *resultLabel;
    IBOutlet    NSTextView     *inputJsonText;
    IBOutlet    NSTextField     *className;
    IBOutlet    NSTextField     *baseClassName;
    
    NSString *outputPath;
    
    IBOutlet    NSComboBox     *url;
    IBOutlet    NSTextField     *keyTF;
    IBOutlet    NSTextField     *valueTF;
    
    IBOutlet    NSTextField     *headerTF;
    IBOutlet    NSTextField     *headerValueTF;
    
    IBOutlet    NSPopUpButton   *requestWay;
    
    IBOutlet    NSButton    *selectFileButton;
    IBOutlet    NSTextField *filePath;
    
    //stored json string that not formated
    NSString    *realJsonString;
}
@property   (weak) IBOutlet NSWindow *window;
@property   (nonatomic,weak)IBOutlet    NSTableView     *table;
@property   (nonatomic,weak)IBOutlet    NSTableView     *headerTable;
@property   (nonatomic,weak)IBOutlet    NSTableView     *filesTable;
@property   (nonatomic,strong)NSMutableDictionary   *parameters;
@property   (nonatomic,strong)NSMutableDictionary   *headers;
@property   (nonatomic,strong)NSMutableArray        *paths;

@property   (nonatomic,weak)IBOutlet NSScrollView    *tableBase;

@property   (nonatomic,strong)NSWindowController    *myCustomWindow;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    _table.dataSource = self;
    _table.delegate = self;
    
    _headerTable.dataSource = self;
    _headerTable.delegate = self;
    
    _filesTable.dataSource = self;
    _filesTable.delegate = self;
    
    _parameters =   [NSMutableDictionary new];
    _headers    =   [NSMutableDictionary new];
    _paths      =   [NSMutableArray new];
    
    filePath.editable = NO;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *way = [defaults objectForKey:@"requestWay"];
    if(way){
        [requestWay selectItemAtIndex:way.intValue];
    }
    
    [requestWay setAction:@selector(requestWayChanged:)];
    [self requestWayChanged:requestWay];
    
    url.dataSource = self;
    url.delegate = self;
}

-(void)requestWayChanged:(NSPopUpButton *)requestButton{
    if(![requestWay.selectedItem.title isEqualToString:@"Get"]){
        selectFileButton.hidden = NO;
        if([requestWay.selectedItem.title isEqualToString:@"Post"]){
            filePath.hidden = NO;
            [_tableBase setHidden:YES];
        }else{
            filePath.stringValue = @"";
            filePath.hidden = YES;
            [_tableBase setHidden:NO];
        }
    }else{
        selectFileButton.hidden = YES;
        filePath.hidden = YES;
        [_tableBase setHidden:YES];
    }
    
    if(![requestWay.selectedItem.title isEqualToString:@"Multipart Post"]){
        [_paths removeAllObjects];
    }
    
    NSString *index = [NSString stringWithFormat:@"%ld",[requestWay indexOfSelectedItem]];
    [[NSUserDefaults standardUserDefaults] setObject:index forKey:@"requestWay"];
}

-(IBAction)selectUploadFilePath:(id)sender{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:YES];
    [openDlg setCanChooseDirectories:NO];
    if ( [openDlg runModal] == NSModalResponseOK){
        NSURL   *files = [[openDlg URLs] objectAtIndex:0];
        if([requestWay.selectedItem.title isEqualToString:@"Post"])
            filePath.stringValue = files.path;
        else{
            if(![_paths containsObject:files.path]){
                [_paths addObject:files.path];
                [_filesTable reloadData];
            }
        }
    }
}

-(BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag{
    [_window makeKeyAndOrderFront:self];
    return YES;
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
        if([requestWay.selectedItem.title isEqualToString:@"Post"]){
            
        }else{
            [_paths addObject:outputPath];
            [_filesTable reloadData];
        }
        
        resultLabel.stringValue = outputPath;
    }
}

-(IBAction)startOutputClassFile:(id)sender{
    if(!outputPath){
        resultLabel.stringValue = @"请选择输出路径!";
        return;
    }
    
    NSData *data = [realJsonString dataUsingEncoding:NSUTF8StringEncoding];
    if(!data || data.length == 0){
        data = [inputJsonText.string dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if(!json || ![json isKindOfClass:[NSDictionary class]] || [json isKindOfClass:[NSArray class]]){
        resultLabel.stringValue = @"格式有误";
    }else{
        [[HRModelUtil shareUtil] setPath:outputPath];
        if(baseClassName.stringValue.length > 0)
            [[HRModelUtil shareUtil] setBaseClassName:baseClassName.stringValue];
        [[HRModelUtil shareUtil] dealClassWithDictionary:json WithClassName:className.stringValue.length > 1?className.stringValue:@"baseModel"];
        
        resultLabel.stringValue = @"处理完成";
        
        [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:outputPath]];
    }
}

-(IBAction)startCustomOutput:(id)sender{
    NSData *data = [realJsonString dataUsingEncoding:NSUTF8StringEncoding];
    if(!data || data.length == 0){
        data = [inputJsonText.string dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if(!json || ![json isKindOfClass:[NSDictionary class]] || [json isKindOfClass:[NSArray class]]){
        resultLabel.stringValue = @"格式有误";
        return;
    }
    [[HRData shareData] setDataDic:json];
    HRCustomModelVC *custVC = [[HRCustomModelVC alloc] initWithWindowNibName:@"HRCustomWindow"];
//    NSScreen * screen = [NSScreen deepestScreen];
//    [custVC.window setFrameOrigin:NSMakePoint(20, screen.visibleFrame.size.height - screen.visibleFrame.origin.y - screen.visibleFrame.size.height * 0.8 + 15)];
//    [custVC.window setContentSize:NSMakeSize(screen.visibleFrame.size.width * 0.8, screen.visibleFrame.size.height * 0.8)];
    [custVC showWindow:nil];
    [custVC.window makeKeyAndOrderFront:self];
    _myCustomWindow = custVC;
}

-(IBAction)startRequest:(id)sender{
    if(url.stringValue.length < 1 || ((![url.stringValue hasPrefix:@"http://"]) && (![url.stringValue hasPrefix:@"https://"]))){
        inputJsonText.string = @"URL不合法，请检查！";
        return;
    }
    NSButton *startBtn = sender;
    
    [[HRHistoryManager sharedManager] addURL:url.stringValue];
    
    for(NSString *key in _headers.allKeys){
        [[[HRApiClient sharedClient] requestSerializer] setValue:_headers[key] forHTTPHeaderField:key];
    }
    NSString  *way = requestWay.selectedItem.title;
    if([way isEqualToString:@"Post"]){
        startBtn.enabled = NO;
        //如果有文件需要上传的
        if(filePath.stringValue.length > 0){
            [[HRApiClient sharedClient] postPathForUpload:url.stringValue andParameters:_parameters andData:[NSData dataWithContentsOfFile:filePath.stringValue] withName:@"file" completion:^(NSURLSessionDataTask *task, NSDictionary *aResponse, NSError *anError) {
                startBtn.enabled = YES;
                if(aResponse){
                    realJsonString = [self jsonStringWithObject:aResponse];
                    if([self formatStringWithDictionary:aResponse])
                        inputJsonText.string = [self formatStringWithDictionary:(NSDictionary *)aResponse];
                    else
                        inputJsonText.string = realJsonString;
                }else{
                    inputJsonText.string = anError.description;
                }
            } andProgress:^(long long sent, long long expectSend) {
                inputJsonText.string = [NSString stringWithFormat:@"%lld data sent of %lld total data need sent",sent,expectSend];
            }];
        }else{
            //没有文件上传直接调post接口
            [[HRApiClient sharedClient] postPath:url.stringValue parameters:_parameters completion:^(NSURLSessionDataTask *task,    NSDictionary *aResponse, NSError *anError) {
                if(aResponse){
                    realJsonString = [self jsonStringWithObject:aResponse];
                    if([self formatStringWithDictionary:aResponse])
                        inputJsonText.string = [self formatStringWithDictionary:(NSDictionary *)aResponse];
                    else
                        inputJsonText.string = realJsonString;
                }else{
                    inputJsonText.string = anError.description;
                }
                startBtn.enabled = YES;
            }];
        }
    }else if([way isEqualToString:@"Get"]){
        startBtn.enabled = NO;
        [[HRApiClient sharedClient] getPath:url.stringValue parameters:_parameters completion:^(NSURLSessionDataTask *task, NSDictionary *aResponse, NSError *anError) {
            if(aResponse){
                realJsonString = [self jsonStringWithObject:aResponse];
                if([self formatStringWithDictionary:aResponse])
                    inputJsonText.string = [self formatStringWithDictionary:(NSDictionary *)aResponse];
                else
                    inputJsonText.string = realJsonString;
            }else{
                inputJsonText.string = anError.description;
            }
            startBtn.enabled = YES;
        }];
    }else{
        startBtn.enabled = NO;
        [[HRApiClient sharedClient] uploadWithMultipartFormsparam:url.stringValue imageUrls:_paths andParameters:_parameters withCompletion:^(NSURLSessionDataTask *task, NSDictionary *aResponse, NSError *anError) {
            if(aResponse){
                realJsonString = [self jsonStringWithObject:aResponse];
                if([self formatStringWithDictionary:aResponse])
                    inputJsonText.string = [self formatStringWithDictionary:(NSDictionary *)aResponse];
                else
                    inputJsonText.string = realJsonString;
            }else{
                inputJsonText.string = anError.description;
            }
            startBtn.enabled = YES;
        }];
    }
}

-(IBAction)addParametersOfRequest:(id)sender{
    if(keyTF.stringValue.length > 0 && valueTF.stringValue.length > 0){
        [_parameters setObject:valueTF.stringValue forKey:keyTF.stringValue];
        valueTF.stringValue = @"";
        keyTF.stringValue = @"";
        [_table reloadData];
    }
}

-(IBAction)addHttpHeaders:(id)sender{
    if(headerTF.stringValue.length > 0 && headerValueTF.stringValue.length > 0){
        [_headers setObject:headerValueTF.stringValue forKey:headerTF.stringValue];
        headerTF.stringValue = @"";
        headerValueTF.stringValue = @"";
        [_headerTable reloadData];
    }
}

#pragma combonBox dataSource
-(NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox{
    return [[HRHistoryManager sharedManager] getAllURLs].count;
}

-(id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index{
    return [[[HRHistoryManager sharedManager] getAllURLs] objectAtIndex:index];
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

-(NSString *)formatStringWithDictionary:(NSDictionary *)dictionary{
    NSString *unicode = [dictionary description];
    
    return [NSString stringWithCString:[unicode cStringUsingEncoding:NSUTF8StringEncoding] encoding:NSNonLossyASCIIStringEncoding];
}

- (void)controlTextDidChange:(NSNotification *)notification {
    NSTextField *textField = [notification object];
    if(textField == url || textField == className || textField == baseClassName)
        return;
    NSLog(@"controlTextDidChange: stringValue == %@", [textField stringValue]);
    //headerCell
    if(textField.tag > 200){
        NSInteger index = textField.tag - 200;
        [_headers setObject:textField.stringValue forKey:_headers.allKeys[index]];
    }else{
        //valueCell
        NSInteger index = textField.tag - 100;
        [_parameters setObject:textField.stringValue forKey:_parameters.allKeys[index]];
    }
}

#pragma mark- tableView function
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    if(tableView == _table){
        return _parameters.allKeys.count;
    }else if(tableView == _headerTable){
        return _headers.allKeys.count;
    }else{
        return _paths.count;
    }
}

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    return 30.0;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if(tableView == _table){
        if([tableColumn.identifier isEqualToString:@"AutomaticTableColumnIdentifier.0"]){
            NSTableCellView *cellView = [[NSTableCellView alloc] init];
            NSTextField *keyLabel = [self getShowLabel];
            keyLabel.editable = NO;
            [cellView addSubview:keyLabel];
            keyLabel.stringValue = [_parameters.allKeys objectAtIndex:row];
            return cellView;
        }else if([tableColumn.identifier isEqualToString:@"AutomaticTableColumnIdentifier.1"]){
            NSTableCellView *cellView = [[NSTableCellView alloc] init];
            NSTextField *valueLabel = [self getShowLabel];
            valueLabel.tag = 100+row;
            [cellView addSubview:valueLabel];
            valueLabel.stringValue = [_parameters objectForKey:[_parameters.allKeys objectAtIndex:row]];
            return cellView;
        }else{
            NSTableCellView *cellView = [[NSTableCellView alloc] init];
            NSButton *deleteBtn = [[NSButton alloc] initWithFrame:NSMakeRect(10, 0, 60, 30)];
            deleteBtn.layer.backgroundColor = [NSColor redColor].CGColor;
            deleteBtn.tag = row;
            [deleteBtn setTitle:@"删除"];
            [deleteBtn setAction:@selector(deleteParam:)];
            [cellView addSubview:deleteBtn];
            
            return cellView;
        }
    }else if(tableView == _headerTable){
        if([tableColumn.identifier isEqualToString:@"AutomaticTableColumnIdentifier.0"]){
            NSTableCellView *cellView = [[NSTableCellView alloc] init];
            NSTextField *keyLabel = [self getShowLabel];
            keyLabel.editable = NO;
            [cellView addSubview:keyLabel];
            keyLabel.stringValue = [_headers.allKeys objectAtIndex:row];
            return cellView;
        }else if([tableColumn.identifier isEqualToString:@"AutomaticTableColumnIdentifier.1"]){
            NSTableCellView *cellView = [[NSTableCellView alloc] init];
            NSTextField *valueLabel = [self getShowLabel];
            [cellView addSubview:valueLabel];
            valueLabel.tag = 200 + row;
            valueLabel.stringValue = [_headers objectForKey:[_headers.allKeys objectAtIndex:row]];
            return cellView;
        }else{
            NSTableCellView *cellView = [[NSTableCellView alloc] init];
            NSButton *deleteBtn = [[NSButton alloc] initWithFrame:NSMakeRect(10, 0, 60, 30)];
            deleteBtn.layer.backgroundColor = [NSColor redColor].CGColor;
            deleteBtn.tag = row;
            [deleteBtn setTitle:@"删除"];
            [deleteBtn setAction:@selector(deleteHeader:)];
            [cellView addSubview:deleteBtn];
            
            return cellView;
        }
    }else{
        if([tableColumn.identifier isEqualToString:@"AutomaticTableColumnIdentifier.0"]){
            NSTableCellView *cellView = [[NSTableCellView alloc] init];
            NSTextField *keyLabel = [[NSTextField alloc] initWithFrame:CGRectMake(10, 0, 140, 30)];
            keyLabel.alignment = NSTextAlignmentCenter;
            [cellView addSubview:keyLabel];
            keyLabel.stringValue = [[_paths objectAtIndex:row] lastPathComponent];
            return cellView;
        }else{
            NSTableCellView *cellView = [[NSTableCellView alloc] init];
            NSButton *deleteBtn = [[NSButton alloc] initWithFrame:NSMakeRect(10, 0, 50, 30)];
            deleteBtn.layer.backgroundColor = [NSColor redColor].CGColor;
            deleteBtn.tag = row;
            [deleteBtn setTitle:@"删除"];
            [deleteBtn setAction:@selector(deleteUploadPath:)];
            [cellView addSubview:deleteBtn];
            return cellView;
        }
    }
}

-(void)deleteUploadPath:(NSButton *)deleteButton{
    [_paths removeObjectAtIndex:deleteButton.tag];
    [_filesTable reloadData];
}

-(NSTextField *)getShowLabel{
    NSTextField *keyLabel = [[NSTextField alloc] initWithFrame:CGRectMake(10, 0, 100, 30)];
    keyLabel.alignment = NSTextAlignmentCenter;
    keyLabel.delegate = self;
    
    return keyLabel;
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
