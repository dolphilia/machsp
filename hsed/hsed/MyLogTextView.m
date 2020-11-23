//
//  MyLogTextView.m
//  documentbasededitor
//
//  Created by dolphilia on 2016/03/03.
//  Copyright © 2016年 dolphilia. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MyLogTextView.h"
#import "AppDelegate.h"
#import "MyWindow.h"
@implementation MyLogTextView
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        global = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        if (global.logString == nil) {
            global.logString = @"";
        }
        self.string = @"aaaaa";
        NSString* str = [self string]; //現在の文字列を保持する
        NSFont* font = [NSFont fontWithName:@"Menlo Regular" size:10.0];
        NSMutableAttributedString* attrStr = [[NSMutableAttributedString alloc] initWithString:str attributes:@{NSForegroundColorAttributeName:[NSColor whiteColor]}];
        NSRange area = NSMakeRange(0, attrStr.length);
        [attrStr addAttribute:NSFontAttributeName value:font range:area];
        [self.textStorage setAttributedString:attrStr];
        self.backgroundColor = [NSColor colorWithCalibratedRed:47.0/255.0 green:47.0/255.0 blue:47.0/255.0 alpha:1.0]; //背景色を設定する
        // タイマー
        NSTimer *tm = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(onTimer:) userInfo:nil repeats:YES ];
        [tm fire];
    }
    return self;
}
-(void)onTimer:(NSTimer*)timer { 
    if ([self.string isEqual:global.logString]) {}
    else {
        self.string = global.logString;
        NSString* str = [self string]; //現在の文字列を保持する
        NSFont* font = [NSFont fontWithName:@"Menlo Regular" size:10.0];
        NSMutableAttributedString* attrStr = [[NSMutableAttributedString alloc] initWithString:str attributes:@{NSForegroundColorAttributeName:[NSColor whiteColor]}];
        NSRange area = NSMakeRange(0, attrStr.length);
        [attrStr addAttribute:NSFontAttributeName value:font range:area];
        [self.textStorage setAttributedString:attrStr];
    }
}
@end