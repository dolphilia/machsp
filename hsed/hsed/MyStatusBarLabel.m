//
//  MyStatusBarLabel.m
//  documentbasededitor
//
//  Created by dolphilia on 2016/02/18.
//  Copyright © 2016年 dolphilia. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MyStatusBarLabel.h"
#import "MyWindow.h"
#import "MyScrollView.h"
#import "MyTextView.h"
@implementation MyStatusBarLabel
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        global = (AppDelegate *)[[NSApplication sharedApplication] delegate]; //グローバル変数にアクセスできるようにする
        //ラベルの内容を初期化
        self.stringValue = @"行数:0　文字数:0　位置:0　行:0";
        // タイマー
        NSTimer *tm = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self
                                                     selector:@selector(onTimer:) userInfo:nil repeats:YES ];
        [tm fire];
    }
    return self;
}
-(void)onTimer:(NSTimer*)timer {
    //ウィンドウが開いた状態でない場合は戻る
    if (3 > ((MyScrollView *)((MyWindow *)self.window).contentView.subviews[0].subviews[0].subviews[0].subviews[0].subviews[0]).subviews[0].subviews.count) {
        return;
    }
    MyTextView* myTextView = (MyTextView *)(((MyScrollView *)((MyWindow *)self.window).contentView.subviews[0].subviews[0].subviews[0].subviews[0].subviews[0]).subviews[0].subviews[2]);
    int editorLineCount = [myTextView getEditorLineCount];
    int editorTextCount = [myTextView getEditorTextCount];
    int editorTextIndex = [myTextView getEditorTextIndex];
    int editorSelectedTextCount = [myTextView getEditorSelectedTextCount];
    if (editorSelectedTextCount==0) {
        self.stringValue = [NSString stringWithFormat:@"行数:%d 文字数:%d 位置:%d",editorLineCount,editorTextCount,editorTextIndex];
    }
    else {
        self.stringValue = [NSString stringWithFormat:@"行数:%d 文字数:%d(%d) 位置:%d",editorLineCount,editorTextCount,editorSelectedTextCount,editorTextIndex];
    }
}
@end