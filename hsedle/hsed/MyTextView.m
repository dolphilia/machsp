//
//  MyTextView.m
//  nstextview-fontcolor-test
//
//  Created by dolphilia on 2016/01/25.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyTextView.h"
#import "objc_utility_string.h"

@implementation MyTextView

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    global = (AppDelegate *) [[NSApplication sharedApplication] delegate];

    accessNumber = 0;
    if (self) {
        myWindow = ((MyWindow *) self.window);
        timerCount = 0;

        // タイマー
        NSTimer *tm = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
        [tm fire];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:NSTextDidChangeNotification object:self];
    }
    return self;
}

- (void)awakeFromNib {
    self.textContainerInset = NSMakeSize(4, 4);//テキストの位置を微調整する
    self.automaticQuoteSubstitutionEnabled = NO; //自動でクオートを変換する機能をオフにする
    self.enabledTextCheckingTypes = 0; //文字列のチェックをオフにする
}

- (void)onTimer:(NSTimer *)timer {
    timerCount++;
    accessNumber = [self.window.title intValue] - 1;
    if (timerCount > 50) { //0.5秒何も読み込まれなかったら
        [self window].title = [global.globalTitles objectAtIndex:[self.window.title intValue] - 1];
        [timer invalidate];
    }
    if (0 < [self.window.title intValue]) { //ウィンドウタイトルに数値が入っている
        if (global.globalTexts == nil) {
        } else {
            if (global.globalTexts.count < [self.window.title intValue]) {
            } else {
                if ([[global.globalTexts objectAtIndex:[self.window.title intValue] - 1] isEqual:@"__NULL__=0"]) {
                } else {
                    self.string = [global.globalTexts objectAtIndex:[self.window.title intValue] - 1];
                    [self setNeedsDisplay:YES];
                    [self window].title = [global.globalTitles objectAtIndex:[self.window.title intValue] - 1];
                    [timer invalidate];
                }
            }
        }
    }
    [((MyWindow *) [self window]) setAccessNumber:accessNumber];
}

- (void)textDidChange:(NSNotification *)notification {
    NSInteger cursorPosition = [self selectedRange].location; //カーソル位置を取得して保持する
    if ([self.string isEqual:[global.globalTexts objectAtIndex:accessNumber]]) {
    } else {
        [global.globalTexts replaceObjectAtIndex:accessNumber withObject:self.string];
    }

    //グローバル変数を設定
    //通常の行数をカウント（コメントと文字列）
    __block int lineCount = 0;
    [self.string enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        lineCount++;
    }];

    [self setSelectedRange:NSMakeRange(cursorPosition, 0)];//カーソルバーの位置を元に戻す
}

- (void)insertNewline:(id)sender {
    //自動でタブを挿入する処理
    NSInteger cursorPosition = [self selectedRange].location; //カーソル位置を取得して保持する
    NSString *str = [self string]; //現在の文字列を保持する
    //現在のカーソル位置から遡って、最初の改行あるいは最初の文字を見つける
    //最初の改行あるいは文字列の頭から続く文字がタブだった場合、タブの個数分タブを挿入する
    int index = (int) (str.length - (str.length - cursorPosition));
    if (index <= 0) { //手前の文字が存在しないなら
        [super insertNewline:sender]; //行を挿入する
        return;
    }
    NSString *back_char = [objc_utility_string charAt:str index:index - 1];//[str substringWithRange:NSMakeRange(index-1, 1)]; //１つ前の文字
    BOOL breakFlag = NO;
    for (int i = 0; i < index; i++) {
        if ([[objc_utility_string charAt:str index:index - i - 1] isEqual:@"\n"]) { //最初の行以外
            [super insertNewline:sender]; //行を挿入する
            if ([back_char isEqual:@"{"]) {
                [super insertTab:sender];
            } else if ([[objc_utility_string charAt:str index:index - i] isEqual:@"*"]) { //行頭がアスタリスクだったら
                [super insertTab:sender];
                breakFlag = YES;
                break;
            }
            for (int n = 0; n < i; n++) {
                if ([[objc_utility_string charAt:str index:index - i + n] isEqual:@"\t"]) {
                    [super insertTab:sender];
                } else {
                    breakFlag = YES;
                    break;
                }
            }
            breakFlag = YES;
            break;
        } else if (i == index - 1) { //最初の行
            [super insertNewline:sender]; //行を挿入する
            if ([back_char isEqual:@"{"]) {
                [super insertTab:sender];
            } else if ([[objc_utility_string charAt:str index:0] isEqual:@"*"]) { //行頭がアスタリスクだったら
                [super insertTab:sender];
                breakFlag = YES;
                break;
            }
            for (int n = 0; n < index; n++) {
                if ([[objc_utility_string charAt:str index:n] isEqual:@"\t"]) {
                    [super insertTab:sender];
                } else {
                    breakFlag = YES;
                    break;
                }
            }
            breakFlag = YES;
            break;
        } else {
        }
        if (breakFlag) {
            break;
        }
    }
    return;
}

@end
