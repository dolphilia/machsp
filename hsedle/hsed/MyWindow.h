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

@interface MyWindow:NSWindow {
    AppDelegate* global;
@public
    int accessNumber;
}
-(void)setAccessNumber:(int)num;
- (NSString*)replace:(NSString*)str searchStr:(NSString*)searchStr replaceStr:(NSString*)replaceStr;
- (NSString*)preg_replace:(NSString*)str patternStr:(NSString*)patternStr replaceStr:(NSString*)replaceStr;
- (BOOL)preg_match:(NSString*)str patternStr:(NSString*)patternStr;
- (NSString*)trim:(NSString*)str;
- (NSString*)append:(NSString*)str append:(NSString*)append;

@end

#endif /* MyWindow_h */
