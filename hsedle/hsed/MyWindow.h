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
@public
    int accessNumber;
}
- (void)setAccessNumber:(int)num;


@end

#endif /* MyWindow_h */
