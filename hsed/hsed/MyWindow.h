//
//  MyWindow.h
//  documentbasededitor
//
//  Created by dolphilia on 2016/01/31.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#ifndef MyWindow_h
#define MyWindow_h

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

@interface MyWindow : NSWindow {
    AppDelegate *global;
    IBOutlet NSButton *button;
@public
    int accessNumber;
    double documentVisibleX[128];
    double documentVisibleY[128];
    double documentVisibleWidth[128];
    double documentVisibleHeight[128];
}
- (void)setAccessNumber:(int)num;

- (IBAction)onButton:(id)sender;

- (NSString *)replace:(NSString *)str searchStr:(NSString *)searchStr replaceStr:(NSString *)replaceStr;

- (NSString *)preg_replace:(NSString *)str patternStr:(NSString *)patternStr replaceStr:(NSString *)replaceStr;

- (BOOL)preg_match:(NSString *)str patternStr:(NSString *)patternStr;

- (NSString *)trim:(NSString *)str;

- (NSString *)append:(NSString *)str append:(NSString *)append;

- (NSString *)launchApplication_getPath;

- (void)terminateApplication;

@end

#endif /* MyWindow_h */
