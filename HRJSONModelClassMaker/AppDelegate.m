//
//  AppDelegate.m
//  HRJSONModelClassMaker
//
//  Created by ZhangHeng on 16/1/15.
//  Copyright © 2016年 ZhangHeng. All rights reserved.
//

#import "AppDelegate.h"
#import "HRModelUtil.h"

@interface AppDelegate ()<NSTableViewDataSource,NSTableViewDelegate>
{
    IBOutlet    NSTextField     *resultLabel;
    IBOutlet    NSTextField     *inputJsonText;
    IBOutlet    NSTextField     *className;
    
    NSString *outputPath;
}
@property (weak) IBOutlet NSWindow *window;
@property (nonatomic,strong)NSMutableDictionary *parameters;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    _parameters = [NSMutableDictionary new];
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
    
    NSLog(@"%@",inputJsonText.stringValue);
    NSData *data = [inputJsonText.stringValue dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if(!json || ![json isKindOfClass:[NSDictionary class]] || [json isKindOfClass:[NSArray class]]){
        resultLabel.stringValue = @"格式有误";
    }else{
        [[HRModelUtil shareUtil] setPath:outputPath];
        [[HRModelUtil shareUtil] dealClassWithDictionary:json WithClassName:className.stringValue.length > 1?className.stringValue:@"baseModel"];
    }
}

#pragma mark- tableView function
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return 4;
    return _parameters.allKeys.count;
}

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    return 40.0;
}

@end
