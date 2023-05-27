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
#import "NSTextViewExtension.h"
#import "MyWindow.h"
#import "MyScrollView.h"

@interface MyTextView : NSTextViewExtension <NSTextViewDelegate> {
    AppDelegate *global;
    MyWindow *myWindow;
    MyScrollView *myScrollView;
@public
    int accessNumber;
    int timerCount;
    int editorLineCount;
    int editorTextCount;
    int editorTextIndex;
    int editorSelectedTextCount;
    BOOL isOperationChangeColor; //色設定を開始した
    //
    NSRect documentRect;
    double documentVisibleX;
    double documentVisibleY;
    double documentVisibleWidth;
    double documentVisibleHeight;
}
- (int)getEditorLineCount;

- (int)getEditorTextCount;

- (int)getEditorTextIndex;

- (int)getEditorSelectedTextCount;

- (NSString *)getCorsorNearString;

- (void)resetTextColor;

- (void)updateTextColor;
@end

#endif /* MyTextView_h */
