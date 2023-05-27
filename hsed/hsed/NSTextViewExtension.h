//
//  NSTextViewExtension.h
//  globalvaltest
//
//  Created by dolphilia on 2016/01/29.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#ifndef NSTextViewExtension_h
#define NSTextViewExtension_h

#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>
#import <objc/objc.h>
#import "LineNumberRulerView.h"

@interface NSTextViewExtension : NSTextView {
    LineNumberRulerView *lineNumberView;
    NSUInteger LineNumberViewAssocObjKey;
}
- (void)lnv_setUpLineNumberView;

- (void)lnv_framDidChange:(NSNotification *)notification;

- (void)lnv_textDidChange:(NSNotification *)notification;

@end

#endif /* NSTextViewExtension_h */
