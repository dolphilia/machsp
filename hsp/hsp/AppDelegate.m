//
//  AppDelegate.m
//  hsp
//
//  Created by 半澤 聡 on 2016/09/12.
//  Copyright © 2016年 dolphilia. All rights reserved.
//
#import "AppDelegate.h"
@interface
AppDelegate ()
@end
@implementation AppDelegate
- (void)applicationDidFinishLaunching:(NSNotification*)aNotification
{
    // Insert code here to initialize your application
    //メニューバーを初期化する
    id menubar = [NSMenu new];
    id rootmenu = [NSMenuItem new];
    [menubar addItem:rootmenu];
    id appmenu = [NSMenu new];
    id quitmenu = [[NSMenuItem alloc] initWithTitle:@"Quit"
                                             action:@selector(terminate:)
                                      keyEquivalent:@"q"];
    [appmenu addItem:quitmenu];
    [rootmenu setSubmenu:appmenu];
    [NSApp setMainMenu:menubar];
}
- (void)applicationWillTerminate:(NSNotification*)aNotification
{
    // Insert code here to tear down your application
}
- (void)windowWillClose:(NSNotification*)aNotification
{
    [NSApp terminate:self];
}
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:
(NSApplication*)theApplication
{
    return YES;
}
@end
