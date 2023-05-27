//
//  NSTextViewExtension.m
//  globalvaltest
//
//  Created by dolphilia on 2016/01/29.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSTextViewExtension.h"

@implementation NSTextViewExtension

- (void)lnv_setUpLineNumberView {
    if (self.font == nil) {
        self.font = [NSFont systemFontOfSize:16];
    }

    NSScrollView *scrollView = self.enclosingScrollView;
    if (scrollView != nil) {
        lineNumberView = [[LineNumberRulerView alloc] init:self];

        scrollView.verticalRulerView = lineNumberView;
        scrollView.hasVerticalRuler = true;
        scrollView.rulersVisible = true;
    }

    self.postsFrameChangedNotifications = true;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lnv_framDidChange:) name:NSViewFrameDidChangeNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lnv_textDidChange:) name:NSTextDidChangeNotification object:self];
}

- (void)lnv_framDidChange:(NSNotification *)notification {
    lineNumberView.needsDisplay = true;
}

- (void)lnv_textDidChange:(NSNotification *)notification {
    lineNumberView.needsDisplay = true;
}

@end