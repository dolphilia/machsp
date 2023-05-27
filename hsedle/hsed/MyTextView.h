//
//  MyTextView.h
//  nstextview-fontcolor-test
//
//  Created by dolphilia on 2016/01/25.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#ifndef MyTextView_h
#define MyTextView_h

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"
#import "MyWindow.h"

@interface MyTextView : NSTextView <NSTextViewDelegate> {
    AppDelegate *global;
    MyWindow *myWindow;
@public
    int accessNumber;
    int timerCount;
}

@end

#endif /* MyTextView_h */
