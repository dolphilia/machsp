//
//  MyTextView.m
//  nstextview-fontcolor-test
//
//  Created by dolphilia on 2016/01/25.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyTextView.h"

@implementation MyTextView

//文字列操作のためのユーティリティ
- (NSString *)charAt:(NSString *)str index:(int)index { //文字列の指定位置で指定された位置の文字を返す
    if (index >= str.length) {
        return @"";
    }
    if (index < 0) return @"";
    return [str substringWithRange:NSMakeRange(index, 1)];
}

- (NSString *)substr:(NSString *)str index:(int)index length:(int)length { //文字列の部分文字列を返す
    if (index >= str.length || index + length >= str.length) {
        return @"";
    }
    if (index < 0) return @"";
    return [str substringWithRange:NSMakeRange(index, length)];
}

- (NSString *)substrext:(NSString *)str index:(int)index length:(int)length { //文字列の部分文字列を返す（字数制限が若干緩め）
    if (index > str.length || index + length > str.length) {
        return @"";
    }
    if (index < 0) return @"";
    return [str substringWithRange:NSMakeRange(index, length)];
}

- (int)indexOf:(NSString *)str searchStr:(NSString *)searchStr {
    if (str.length < searchStr.length) {
        return -1;
    }
    return (int) [str rangeOfString:searchStr].location;
}

- (int)indexOf:(NSString *)str searchStr:(NSString *)searchStr location:(int)location {
    if (str.length < location + searchStr.length) {
        return -1;
    }
    return (int) [str rangeOfString:searchStr options:0 range:NSMakeRange(location, str.length - location)].location;
}

- (BOOL)isSpaceCharacter:(NSString *)str {
    if ([str isEqual:@" "] || [str isEqual:@"\t"] || [str isEqual:@"\f"] || [str isEqual:@"\n"] || [str isEqual:@"\r"] || [str isEqual:@"\v"]) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isOperatorCharacter:(NSString *)str {
    if ([str isEqual:@"+"] || [str isEqual:@"-"] || [str isEqual:@"*"] || [str isEqual:@"/"] || [str isEqual:@"\\"] || [str isEqual:@"="] || [str isEqual:@"&"] || [str isEqual:@"|"] || [str isEqual:@"^"] || [str isEqual:@"<"] || [str isEqual:@">"] || [str isEqual:@"!"]) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isSpaceOrOperatorCharacter:(NSString *)str {
    if ([self isSpaceCharacter:str]) {
        return YES;
    } else {
        if ([self isOperatorCharacter:str]) {
            return YES;
        } else {
            return NO;
        }
    }
}

- (int)getEditorLineCount {
    return editorLineCount;
}

- (int)getEditorTextCount {
    return editorTextCount;
}

- (int)getEditorTextIndex {
    return editorTextIndex;
}

- (int)getEditorSelectedTextCount {
    return editorSelectedTextCount;
}

- (NSString *)getCorsorNearString { //現在のカーソル位置付近の文字列を取得する
    NSString *corsorNearString = @"";

    NSInteger cursorPosition = [self selectedRange].location; //カーソル位置を取得して保持する
    NSString *str = [self string]; //現在の文字列を保持する

    BOOL isBackChar = NO;//手前の文字は存在するか
    int index = (int) (str.length - (str.length - cursorPosition));
    if (index <= 0) { //手前の文字が存在しないなら
        isBackChar = NO;
    } else {
        isBackChar = YES;
    }

    NSString *tmpChar = @"";
    int minusIndex = 0;
    for (int i = (int) cursorPosition - 1; i >= 0; i--) {
        tmpChar = [self charAt:str index:i];
        if ([self isSpaceOrOperatorCharacter:tmpChar]) { //
            //minusIndex++;
            break;
        } else {
            minusIndex++;
        }
    }
    int plusIndex = 0;
    for (int i = (int) cursorPosition; i <= str.length; i++) {
        tmpChar = [self charAt:str index:i];
        if ([self isSpaceOrOperatorCharacter:tmpChar] || i >= str.length) { // ||
            //plusIndex++;
            break;
        } else {
            plusIndex++;
        }
    }
    if (plusIndex == -1) {
        plusIndex = 0;
    }

    corsorNearString = [self substrext:str index:(int) cursorPosition - minusIndex length:plusIndex + minusIndex];

    return corsorNearString;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    global = (AppDelegate *) [[NSApplication sharedApplication] delegate];
//    if (global.globalString == nil) {
//        global.globalString = @"";
//        global.globalString = [self string];
//    }
    if (global.selectedFontSizeString == nil) {
        global.selectedFontSizeString = @"11";
    }
    accessNumber = 0;
    if (self) {
        isOperationChangeColor = NO;
        myWindow = ((MyWindow *) self.window);
        myScrollView = ((MyScrollView *) ((MyWindow *) self.window).contentView.subviews[0].subviews[0].subviews[0].subviews[0].subviews[0]);
        timerCount = 0;

//        self.backgroundColor = [NSColor colorWithCalibratedRed:47.0/255.0 green:47.0/255.0 blue:47.0/255.0 alpha:1.0]; //背景色を設定する
//        self.insertionPointColor = [NSColor whiteColor]; //カーソルバーの色を設定
//        self.selectedTextAttributes = @{NSBackgroundColorAttributeName: [NSColor colorWithCalibratedRed:67.0/255.0 green:65.0/255.0 blue:70.0/255.0 alpha:1.0]}; //選択中の背景色の設定
//        self.linkTextAttributes = @{NSForegroundColorAttributeName: [NSColor colorWithCalibratedRed:178.0/255.0 green:237.0/255.0 blue:93.0/255.0 alpha:1.0]}; //リンクの文字色の設定

        // タイマー
        NSTimer *tm = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self
                                                     selector:@selector(onTimer:) userInfo:nil repeats:YES];
        [tm fire];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:NSTextDidChangeNotification object:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectionDidChange:) name:NSTextViewDidChangeSelectionNotification object:self];

        //NSTimer *tm2 = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(onTimer2:) userInfo:nil repeats:YES ];
        //[tm2 fire];
    }
    return self;
}

- (void)onTimer2:(NSTimer *)timer {
    //NSLog(@"%d",(int)[self selectedRange].location);
    //現在の表示範囲を得る
    documentRect = ((MyScrollView *) ((MyWindow *) self.window).contentView.subviews[0].subviews[0].subviews[0].subviews[0].subviews[0]).contentView.documentVisibleRect;

    if (documentVisibleY != documentRect.origin.y) {
        documentVisibleX = documentRect.origin.x;
        documentVisibleY = documentRect.origin.y;
        documentVisibleWidth = documentRect.size.width;
        documentVisibleHeight = documentRect.size.height;
        if (isOperationChangeColor == NO) {
            if ([global.selectedColorThemeString isEqual:@"hsed3le"]) {
                //isOperationChangeColor = YES;
                //[self resetTextColor];
                //isOperationChangeColor = NO;
            } else {
                isOperationChangeColor = YES;
                [self updateTextColor];
                isOperationChangeColor = NO;
            }
        }
    } else {
        documentVisibleX = documentRect.origin.x;
        documentVisibleY = documentRect.origin.y;
        documentVisibleWidth = documentRect.size.width;
        documentVisibleHeight = documentRect.size.height;
    }
}

- (void)onTimer:(NSTimer *)timer {
    timerCount++;
    accessNumber = [self.window.title intValue] - 1;
    if (timerCount > 50) {//0.5秒何も読み込まれなかったら
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
                    if ([global.selectedColorThemeString isEqual:@"hsed3le"]) {
                        //isOperationChangeColor = YES;
                        //[self resetTextColor];
                        //isOperationChangeColor = NO;
                    } else {
                        isOperationChangeColor = YES;
                        [self updateTextColor];
                        isOperationChangeColor = NO;
                    }
                    [self setNeedsDisplay:YES];
                    [self window].title = [global.globalTitles objectAtIndex:[self.window.title intValue] - 1];
                    [timer invalidate];
                }
            }
        }
    }
    [((MyWindow *) [self window]) setAccessNumber:accessNumber];
    //((MyWindow *)[self window])->accessNumber = accessNumber;
}

- (void)selectionDidChange:(NSNotification *)notification {
    // NSLog(@"didchange");
    __block int lineCount = 0;
    [self.string enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        lineCount++;
    }];

    editorLineCount = lineCount;
    editorTextCount = (int) self.string.length;
    editorTextIndex = (int) self.selectedRange.location;
    editorSelectedTextCount = (int) self.selectedRange.length;
}

- (void)textDidChange:(NSNotification *)notification {
    //NSLog(@"change");
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
    editorLineCount = lineCount;
    editorTextCount = (int) self.string.length;

//    if (isOperationChangeColor == NO) {
//        if ([global.selectedColorThemeString isEqual:@"hsed3le"]) {
//            isOperationChangeColor = YES;
//            [self resetTextColor];
//            isOperationChangeColor = NO;
//        }
//        else {
//            isOperationChangeColor = YES;
//            [self updateTextColor];
//            isOperationChangeColor = NO;
//        }
//    }
    [self setSelectedRange:NSMakeRange(cursorPosition, 0)];//カーソルバーの位置を元に戻す
}

- (void)awakeFromNib {
    [self lnv_setUpLineNumberView];
    self.textContainerInset = NSMakeSize(4, 4);//テキストの位置を微調整する
    self.automaticQuoteSubstitutionEnabled = NO; //自動でクオートを変換する機能をオフにする
    self.enabledTextCheckingTypes = 0; //文字列のチェックをオフにする
    if (isOperationChangeColor == NO) {
        if ([global.selectedColorThemeString isEqual:@"hsed3le"]) {
            //isOperationChangeColor = YES;
            //[self resetTextColor];
            //isOperationChangeColor = NO;
        } else {
            isOperationChangeColor = YES;
            [self updateTextColor];
            isOperationChangeColor = NO;
        }
    }
}

- (void)insertNewline:(id)sender {
    //NSLog(@"insert");
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
    NSString *back_char = [self charAt:str index:index - 1];//[str substringWithRange:NSMakeRange(index-1, 1)]; //１つ前の文字
    BOOL breakFlag = NO;
    for (int i = 0; i < index; i++) {
        if ([[self charAt:str index:index - i - 1] isEqual:@"\n"]) { //最初の行以外
            [super insertNewline:sender]; //行を挿入する
            if ([back_char isEqual:@"{"]) {
                [super insertTab:sender];
            } else if ([[self charAt:str index:index - i] isEqual:@"*"]) { //行頭がアスタリスクだったら
                [super insertTab:sender];
                breakFlag = YES;
                break;
            }
            for (int n = 0; n < i; n++) {
                if ([[self charAt:str index:index - i + n] isEqual:@"\t"]) {
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
            } else if ([[self charAt:str index:0] isEqual:@"*"]) { //行頭がアスタリスクだったら
                [super insertTab:sender];
                breakFlag = YES;
                break;
            }
            for (int n = 0; n < index; n++) {
                if ([[self charAt:str index:n] isEqual:@"\t"]) {
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

- (void)insertText:(id)aString replacementRange:(NSRange)replacementRange {
    [super insertText:aString replacementRange:replacementRange];

    //スペースキーが挿入された場合は色分けしない
    NSInteger cursorPosition = [self selectedRange].location; //カーソル位置を取得して保持する
    NSString *str = [self string]; //現在の文字列を保持する
    int index = (int) (str.length - (str.length - cursorPosition));
    if ([[self charAt:str index:index - 1] isEqual:@" "]) { //手前の文字がスペースなら
        return;
    }

    if (isOperationChangeColor == NO) {
        if ([global.selectedColorThemeString isEqual:@"hsed3le"]) {
            isOperationChangeColor = YES;
            [self resetTextColor];
            isOperationChangeColor = NO;
        } else {
            isOperationChangeColor = YES;
            [self updateTextColor];
            isOperationChangeColor = NO;
        }
    }
}

- (void)insertParagraphSeparator:(id)sender {
    [super insertParagraphSeparator:sender];
    //NSLog(@"aaa");
}

- (void)deleteBackward:(id)sender { //Backspace時のイベントを設定する
    [super deleteBackward:sender];
    //NSLog(@"back");
    if ([global.selectedColorThemeString isEqual:@"hsed3le"]) {
        //isOperationChangeColor = YES;
        //[self resetTextColor];
        //isOperationChangeColor = NO;
    } else {
        isOperationChangeColor = YES;
        [self updateTextColor];
        isOperationChangeColor = NO;
    }
}

- (void)deleteForward:(id)sender { //Deleteキーを押した時のイベントを設定する
    //NSLog(@"delete");
    [super deleteForward:sender];
    if ([global.selectedColorThemeString isEqual:@"hsed3le"]) {
        //isOperationChangeColor = YES;
        //[self resetTextColor];
        //isOperationChangeColor = NO;
    } else {
        isOperationChangeColor = YES;
        [self updateTextColor];
        isOperationChangeColor = NO;
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}


- (NSAttributedString *)getAttrStringWithColor:(NSString *)text red:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue { //文字色付きのテキストを返す
    NSFont *font = [NSFont fontWithName:@"Menlo Regular" size:[global.selectedFontSizeString floatValue]];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]
            initWithString:text
                attributes:@{NSForegroundColorAttributeName: [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:1.0]}];
    NSRange area = NSMakeRange(0, attrStr.length);
    [attrStr addAttribute:NSFontAttributeName value:font range:area];
    return attrStr;
}

- (void)resetTextColor { //テキスト属性を初期化する
    NSInteger cursorPosition = [self selectedRange].location; //カーソル位置を取得して保持する
    NSString *str = [self string]; //現在の文字列を保持する
    NSFont *font = [NSFont fontWithName:@"Menlo Regular" size:[global.selectedFontSizeString floatValue]];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str attributes:@{NSForegroundColorAttributeName: [NSColor whiteColor]}];
    NSRange area = NSMakeRange(0, attrStr.length);
    [attrStr addAttribute:NSFontAttributeName value:font range:area];
    [self.textStorage setAttributedString:attrStr];
    [self setSelectedRange:NSMakeRange(cursorPosition, 0)];//カーソルバーの位置を元に戻す
}

- (void)updateTextColor { //テキストの内容を調べて適切に色分けする
    NSInteger cursorPosition = [self selectedRange].location; //カーソル位置を取得して保持する
    //printf("reset\n");
    [self resetTextColor]; //テキストの全体を一旦リセット
    //printf("change start\n");

    //全体に対する処理
    NSString *str = self.string;
    int size = (int) str.length;

    /*
     myWindow = (MyWindow *)self.window;
     myScrollView = (MyScrollView *)myWindow.contentView.subviews[0].subviews[0].subviews[0].subviews[0].subviews[0];
     */

    //NSLog(@"%f",((MyScrollView *)((MyWindow *)self.window).contentView.subviews[0].subviews[0].subviews[0].subviews[0].subviews[0]).contentView.documentVisibleRect.size.height);

    //現在の表示範囲を得る
    documentRect = ((MyScrollView *) ((MyWindow *) self.window).contentView.subviews[0].subviews[0].subviews[0].subviews[0].subviews[0]).contentView.documentVisibleRect;

    documentVisibleX = documentRect.origin.x;
    documentVisibleY = documentRect.origin.y;
    documentVisibleWidth = documentRect.size.width;
    documentVisibleHeight = documentRect.size.height;

    //printf("??? %f ???",documentVisibleHeight);

    //実際に表示している文字のはじめと最後を求める
    __block int firstGlyphRange = 0;
    __block int endGlyphRange = 0;
    __block int blockCounter = 0;
    [self.layoutManager
            enumerateLineFragmentsForGlyphRange:[self.layoutManager glyphRangeForTextContainer:self.textContainer]
                                     usingBlock:^(CGRect rect, CGRect usedRect, NSTextContainer *textContainer, NSRange glyphRange, BOOL *stop) {
                                         if (documentVisibleHeight == 0.0) {//テキストビューのサイズが格納されていない
                                             *stop = 0;
                                         } else if (documentVisibleY > rect.origin.y + rect.size.height) {}//範囲外（上部側）
                                         else if (documentVisibleY + documentVisibleHeight < rect.origin.y) {}//範囲外（下部側）
                                         else {
                                             //範囲内
                                             if (blockCounter == 0) {
                                                 firstGlyphRange = (int) glyphRange.location;
                                             } else {
                                             }
                                             endGlyphRange = (int) glyphRange.location + (int) glyphRange.length;
                                         }
                                         blockCounter++;
                                     }];

    //ラベルの色分け
    __block int lineCnt = 0;
    [self.string enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        if (firstGlyphRange <= lineCnt && endGlyphRange >= lineCnt) {
            if ([[self charAt:line index:0] isEqual:@"*"]) { //行頭が*だったら
                int labelCnt = 0;
                NSString *labelStr = line;
                for (int i = 0; i < line.length; i++) {
                    if ([self isSpaceCharacter:[self charAt:line index:i]]) {
                        labelStr = [self substr:line index:0 length:labelCnt];
                        break;
                    }
                    labelCnt++;
                }
                NSRange range = NSMakeRange(lineCnt, labelCnt);

                //NSLog(@"%@",labelStr);
                [self.textStorage replaceCharactersInRange:range withAttributedString:[self getAttrStringWithColor:labelStr red:110.0 / 255.0 green:156.0 / 255.0 blue:190.0 / 255.0]];
            }
        }
        lineCnt += line.length + 1;
    }];

    //printf("c:%d\n",blockCounter);
    //printf("f:%d\n",firstGlyphRange);
    //printf("e:%d\n",endGlyphRange);
    //printf("y:%f h:%f\n",documentVisibleY,documentVisibleHeight);

    //実際に表示されている行数（右端の改行を含む）
    NSRange allGlyphs = [self.layoutManager glyphRangeForTextContainer:self.textContainer];
    [self.layoutManager
            enumerateLineFragmentsForGlyphRange:allGlyphs
                                     usingBlock:^(CGRect rect, CGRect usedRect, NSTextContainer *textContainer, NSRange glyphRange, BOOL *stop) {
                                         if (documentVisibleHeight == 0.0) { //テキストビューのサイズが格納されていない
                                             //printf("未初期化\n");
                                             *stop = 0; //繰り返しを終了する
                                         } else if (documentVisibleY > rect.origin.y + rect.size.height) {}//範囲外（上部側）
                                         else if (documentVisibleY + documentVisibleHeight < rect.origin.y) {} //範囲外（下部側）
                                         else {
                                             //範囲内
                                             //表示されている箇所だけ色分けするようにする

                                             //命令
                                             NSString *keyword_command[] = {@"goto", @"gosub", @"return", @"break", @"repeat", @"loop", @"continue", @"wait", @"await", @"dim", @"sdim", @"foreach", @"dimtype", @"dup", @"dupptr", @"end", @"stop", @"newmod", @"delmod", @"mref", @"run", @"exgoto", @"on", @"mcall", @"assert", @"logmes", @"newlab", @"resume", @"yield", @"onexit", @"onerror", @"onkey", @"onclick", @"oncmd", @"exist", @"delete", @"mkdir", @"chdir", @"dirlist", @"bload", @"bsave", @"bcopy", @"memfile", @"if", @"else", @"poke", @"wpoke", @"lpoke", @"getstr", @"chdpm", @"memexpand", @"memcpy", @"memset", @"notesel", @"noteadd", @"notedel", @"noteload", @"notesave", @"randomize", @"noteunsel", @"noteget", @"split", @"strrep", @"setease", @"sortval", @"sortstr", @"sortnote", @"sortget", @"button", @"chgdisp", @"exec", @"dialog", @"mmload", @"mmplay", @"mmstop", @"mci", @"pset", @"pget", @"syscolor", @"mes", @"print", @"title", @"pos", @"circle", @"cls", @"font", @"sysfont", @"objsize", @"picload", @"color", @"palcolor", @"palette", @"redraw", @"width", @"gsel", @"gcopy", @"gzoom", @"gmode", @"bmpsave", @"hsvcolor", @"getkey", @"listbox", @"chkbox", @"combox", @"input", @"mesbox", @"buffer", @"screen", @"bgscr", @"mouse", @"objsel", @"groll", @"line", @"clrobj", @"boxf", @"objprm", @"objmode", @"stick", @"grect", @"grotate", @"gsquare", @"gradf", @"objimage", @"objskip", @"objenable", @"celload", @"celdiv", @"celput", @"gfilter", @"setreq", @"getreq", @"mmvol", @"mmpan", @"mmstat", @"mtlist", @"mtinfo", @"devinfo", @"devinfoi", @"devprm", @"devcontrol", @"httpload", @"httpinfo", @"gmulcolor", @"setcls", @"celputm", @"newcom", @"querycom", @"delcom", @"cnvstow", @"comres", @"axobj", @"winobj", @"sendmsg", @"comevent", @"comevarg", @"sarrayconv", @"callfunc", @"cnvwtos", @"comevdisp", @"libptr", @"system", @"hspstat", @"hspver", @"stat", @"cnt", @"err", @"strsize", @"looplev", @"sublev", @"iparam", @"wparam", @"lparam", @"refstr", @"refdval", @"int", @"rnd", @"strlen", @"length", @"length2", @"length3", @"length4", @"vartype", @"gettime", @"peek", @"wpeek", @"lpeek", @"varptr", @"varuse", @"noteinfo", @"instr", @"abs", @"limit", @"getease", @"notefind", @"str", @"strmid", @"strf", @"getpath", @"strtrim", @"sin", @"cos", @"tan", @"atan", @"sqrt", @"double", @"absf", @"expf", @"logf", @"limitf", @"powf", @"geteasef", @"mousex", @"mousey", @"mousew", @"hwnd", @"hinstance", @"hdc", @"ginfo", @"objinfo", @"dirinfo", @"sysinfo", @"thismod", @"setcam"};
                                             int keyword_command_count = 223;
                                             CGFloat red = 178.0 / 255.0;
                                             CGFloat green = 237.0 / 255.0;
                                             CGFloat blue = 93.0 / 255.0;
                                             NSString *str = [self.string substringWithRange:glyphRange];
                                             int index = 0;
                                             int size = (int) str.length;
                                             for (int i = 0; i < keyword_command_count; i++) {
                                                 index = 0;
                                                 for (int m = 0; m < size; m++) {
                                                     index = [self indexOf:str searchStr:keyword_command[i] location:index];//(str, keyword_func[i],index);
                                                     if (index == -1) {
                                                         break;
                                                     } else {
                                                         if (index == 0 && index + keyword_command[i].length == size) { //行頭と行末 "^mes$"
                                                             NSRange range = NSMakeRange(index + (int) glyphRange.location, (int) keyword_command[i].length);
                                                             [self.textStorage replaceCharactersInRange:range withAttributedString:[self getAttrStringWithColor:keyword_command[i] red:red green:green blue:blue]];
                                                         } else if ([self isSpaceCharacter:[self charAt:str index:index - 1]] && index + keyword_command[i].length == size) { //空白と行末 " mes$"
                                                             NSRange range = NSMakeRange(index + (int) glyphRange.location, (int) keyword_command[i].length);
                                                             [self.textStorage replaceCharactersInRange:range withAttributedString:[self getAttrStringWithColor:keyword_command[i] red:red green:green blue:blue]];
                                                         } else if ([self isSpaceCharacter:[self charAt:str index:index - 1]] && [self isSpaceCharacter:[self charAt:str index:index + (int) keyword_command[i].length]]) { //空白と空白 " mes "
                                                             NSRange range = NSMakeRange(index + (int) glyphRange.location, (int) keyword_command[i].length);
                                                             [self.textStorage replaceCharactersInRange:range withAttributedString:[self getAttrStringWithColor:keyword_command[i] red:red green:green blue:blue]];
                                                         } else if ([[self charAt:str index:index - 1] isEqual:@":"] && index + keyword_command[i].length == size) { //セミコロンと行末 ":mes$"
                                                             NSRange range = NSMakeRange(index + (int) glyphRange.location, (int) keyword_command[i].length);
                                                             [self.textStorage replaceCharactersInRange:range withAttributedString:[self getAttrStringWithColor:keyword_command[i] red:red green:green blue:blue]];
                                                         } else if ([[self charAt:str index:index - 1] isEqual:@":"] && [self isSpaceCharacter:[self charAt:str index:index + (int) keyword_command[i].length]]) { //セミコロンと空白 ":mes "
                                                             NSRange range = NSMakeRange(index + (int) glyphRange.location, (int) keyword_command[i].length);
                                                             [self.textStorage replaceCharactersInRange:range withAttributedString:[self getAttrStringWithColor:keyword_command[i] red:red green:green blue:blue]];
                                                         } else if (index == 0 && [self isSpaceCharacter:[self charAt:str index:index + (int) keyword_command[i].length]]) { //行頭と空白 "^mes "
                                                             NSRange range = NSMakeRange(index + (int) glyphRange.location, (int) keyword_command[i].length);
                                                             [self.textStorage replaceCharactersInRange:range withAttributedString:[self getAttrStringWithColor:keyword_command[i] red:red green:green blue:blue]];
                                                         } else if (index + keyword_command[i].length == size) { //行末のみ "...mes$"
                                                         }
                                                         index += keyword_command[i].length;
                                                     }
                                                 }
                                             }

                                             //関数
                                             NSString *keyword_func[] = {@"comevdisp", @"lpeek", @"peek", @"wpeek", @"abs", @"absf", @"atan", @"callfunc", @"cos", @"dirinfo", @"double", @"expf", @"gettime", @"ginfo", @"int", @"length", @"length2", @"length3", @"length4", @"libptr", @"limit", @"limitf", @"logf", @"objinfo", @"powf", @"rnd", @"sin", @"sqrt", @"str", @"strlen", @"sysinfo", @"tan", @"varptr", @"vartype", @"varuse", @"cnvwtos", @"getpath", @"instr", @"noteinfo", @"strf", @"strmid", @"strtrim"};
                                             int keyword_func_count = 42;
                                             red = 178.0 / 255.0;
                                             green = 237.0 / 255.0;
                                             blue = 93.0 / 255.0;
                                             for (int i = 0; i < keyword_func_count; i++) {
                                                 index = 0;
                                                 for (int m = 0; m < size; m++) {
                                                     index = [self indexOf:str searchStr:keyword_func[i] location:index];//(str, keyword_func[i],index);
                                                     if (index == -1) {
                                                         break;
                                                     } else {
                                                         if (index == 0 && index + keyword_func[i].length == size) { //行頭と行末 "^mes$"
                                                             NSRange range = NSMakeRange(index + (int) glyphRange.location, (int) keyword_func[i].length);
                                                             [self.textStorage replaceCharactersInRange:range withAttributedString:[self getAttrStringWithColor:keyword_func[i] red:red green:green blue:blue]];
                                                         } else if ([self isSpaceCharacter:[self charAt:str index:index - 1]] && index + keyword_func[i].length == size) { //空白と行末 " mes$"
                                                             NSRange range = NSMakeRange(index + (int) glyphRange.location, (int) keyword_func[i].length);
                                                             [self.textStorage replaceCharactersInRange:range withAttributedString:[self getAttrStringWithColor:keyword_func[i] red:red green:green blue:blue]];
                                                         } else if ([self isSpaceCharacter:[self charAt:str index:index - 1]] && [self isSpaceCharacter:[self charAt:str index:index + (int) keyword_func[i].length]]) { //空白と空白 " mes "
                                                             NSRange range = NSMakeRange(index + (int) glyphRange.location, (int) keyword_func[i].length);
                                                             [self.textStorage replaceCharactersInRange:range withAttributedString:[self getAttrStringWithColor:keyword_func[i] red:red green:green blue:blue]];
                                                         } else if ([self isSpaceCharacter:[self charAt:str index:index - 1]] && [[self charAt:str index:index + (int) keyword_func[i].length] isEqualToString:@"("]) { //空白と括弧 " mes("
                                                             NSRange range = NSMakeRange(index + (int) glyphRange.location, (int) keyword_func[i].length);
                                                             [self.textStorage replaceCharactersInRange:range withAttributedString:[self getAttrStringWithColor:keyword_func[i] red:red green:green blue:blue]];
                                                         } else if ([self isOperatorCharacter:[self charAt:str index:index - 1]] && [[self charAt:str index:index + (int) keyword_func[i].length] isEqualToString:@"("]) { //演算子と括弧 "+mes("
                                                             NSRange range = NSMakeRange(index + (int) glyphRange.location, (int) keyword_func[i].length);
                                                             [self.textStorage replaceCharactersInRange:range withAttributedString:[self getAttrStringWithColor:keyword_func[i] red:red green:green blue:blue]];
                                                         } else if ([[self charAt:str index:index - 1] isEqual:@","] && [[self charAt:str index:index + (int) keyword_func[i].length] isEqualToString:@"("]) { //カンマと括弧 ",mes("
                                                             NSRange range = NSMakeRange(index + (int) glyphRange.location, (int) keyword_func[i].length);
                                                             [self.textStorage replaceCharactersInRange:range withAttributedString:[self getAttrStringWithColor:keyword_func[i] red:red green:green blue:blue]];
                                                         } else if ([[self charAt:str index:index - 1] isEqual:@"("] && [[self charAt:str index:index + (int) keyword_func[i].length] isEqualToString:@"("]) { //括弧と括弧 "(mes("
                                                             NSRange range = NSMakeRange(index + (int) glyphRange.location, (int) keyword_func[i].length);
                                                             [self.textStorage replaceCharactersInRange:range withAttributedString:[self getAttrStringWithColor:keyword_func[i] red:red green:green blue:blue]];
                                                         } else if ([self isOperatorCharacter:[self charAt:str index:index - 1]] && [self isSpaceCharacter:[self charAt:str index:index + (int) keyword_func[i].length]]) { //演算子と空白 "+mes "
                                                             NSRange range = NSMakeRange(index + (int) glyphRange.location, (int) keyword_func[i].length);
                                                             [self.textStorage replaceCharactersInRange:range withAttributedString:[self getAttrStringWithColor:keyword_func[i] red:red green:green blue:blue]];
                                                         } else if ([[self charAt:str index:index - 1] isEqual:@","] && [self isSpaceCharacter:[self charAt:str index:index + (int) keyword_func[i].length]]) { //カンマと空白 ",mes "
                                                             NSRange range = NSMakeRange(index + (int) glyphRange.location, (int) keyword_func[i].length);
                                                             [self.textStorage replaceCharactersInRange:range withAttributedString:[self getAttrStringWithColor:keyword_func[i] red:red green:green blue:blue]];
                                                         } else if (index == 0 && [self isSpaceCharacter:[self charAt:str index:index + (int) keyword_func[i].length]]) { //行頭と空白 "^mes "
                                                             NSRange range = NSMakeRange(index + (int) glyphRange.location, (int) keyword_func[i].length);
                                                             [self.textStorage replaceCharactersInRange:range withAttributedString:[self getAttrStringWithColor:keyword_func[i] red:red green:green blue:blue]];
                                                         } else if (index + keyword_func[i].length == size) { //行末のみ "...mes$"
                                                         }
                                                         index += keyword_func[i].length;
                                                     }
                                                 }
                                             }

                                             //プリプロセッサ
                                             NSString *keyword_preprocessor[] = {@"#addition", @"#cmd", @"#comfunc", @"#const", @"#deffunc", @"#defcfunc", @"#define", @"#else", @"#endif", @"#enum", @"#epack", @"#func", @"#cfunc", @"#global", @"#if", @"#ifdef", @"#ifndef", @"#include", @"#modfunc", @"#modcfunc", @"#modinit", @"#modterm", @"#module", @"#pack", @"#packopt", @"#regcmd", @"#runtime", @"#undef", @"#usecom", @"#uselib", @"#cmpopt", @"#defint", @"#defdouble", @"#defnone", @"#bootopt"};
                                             int keyword_preprocesser_count = 35;
                                             red = 194.0 / 255.0;
                                             green = 154.0 / 255.0;
                                             blue = 122.0 / 255.0;
                                             for (int i = 0; i < keyword_preprocesser_count; i++) {
                                                 index = 0;
                                                 for (int m = 0; m < size; m++) {
                                                     index = [self indexOf:str searchStr:keyword_preprocessor[i] location:index];//(str, keyword_func[i],index);
                                                     if (index == -1) {
                                                         break;
                                                     } else {
                                                         if (index == 0 && index + keyword_preprocessor[i].length == size) { //行頭と行末 "^mes$"
                                                             NSRange range = NSMakeRange(index + (int) glyphRange.location, (int) keyword_preprocessor[i].length);
                                                             [self.textStorage replaceCharactersInRange:range withAttributedString:[self getAttrStringWithColor:keyword_preprocessor[i] red:red green:green blue:blue]];
                                                         } else if ([self isSpaceCharacter:[self charAt:str index:index - 1]] && index + keyword_preprocessor[i].length == size) { //空白と行末 " mes$"
                                                             NSRange range = NSMakeRange(index + (int) glyphRange.location, (int) keyword_preprocessor[i].length);
                                                             [self.textStorage replaceCharactersInRange:range withAttributedString:[self getAttrStringWithColor:keyword_preprocessor[i] red:red green:green blue:blue]];
                                                         } else if ([self isSpaceCharacter:[self charAt:str index:index - 1]] && [self isSpaceCharacter:[self charAt:str index:index + (int) keyword_preprocessor[i].length]]) { //空白と空白 " mes "
                                                             NSRange range = NSMakeRange(index + (int) glyphRange.location, (int) keyword_preprocessor[i].length);
                                                             [self.textStorage replaceCharactersInRange:range withAttributedString:[self getAttrStringWithColor:keyword_preprocessor[i] red:red green:green blue:blue]];
                                                         } else if (index == 0 && [self isSpaceCharacter:[self charAt:str index:index + (int) keyword_preprocessor[i].length]]) { //行頭と空白 "^mes "
                                                             NSRange range = NSMakeRange(index + (int) glyphRange.location, (int) keyword_preprocessor[i].length);
                                                             [self.textStorage replaceCharactersInRange:range withAttributedString:[self getAttrStringWithColor:keyword_preprocessor[i] red:red green:green blue:blue]];
                                                         } else if (index + keyword_preprocessor[i].length == size) { //行末のみ "...mes$"
                                                         }
                                                         index += keyword_preprocessor[i].length;
                                                     }
                                                 }
                                             }

                                             //マクロ
                                             NSString *keyword_macro[] = {@"__hspver__", @"__hsp30__", @"__date__", @"__time__", @"__line__", @"__file__", @"_debug", @"__hspdef__", @"and", @"or", @"xor", @"not", @"screen_normal", @"screen_palette", @"screen_hide", @"screen_fixedsize", @"screen_tool", @"screen_frame", @"gmode_gdi", @"gmode_mem", @"gmode_rgb0", @"gmode_alpha", @"gmode_rgb0alpha", @"gmode_add", @"gmode_sub", @"gmode_pixela", @"ginfo_mx", @"ginfo_my", @"ginfo_act", @"ginfo_sel", @"ginfo_wx1", @"ginfo_wy1", @"ginfo_wx2", @"ginfo_wy2", @"ginfo_vx", @"ginfo_vy", @"ginfo_sizex", @"ginfo_sizey", @"ginfo_winx", @"ginfo_winy", @"ginfo_mesx", @"ginfo_mesy", @"ginfo_r", @"ginfo_g", @"ginfo_b", @"ginfo_paluse", @"ginfo_dispx", @"ginfo_dispy", @"ginfo_cx", @"ginfo_cy", @"ginfo_intid", @"ginfo_newid", @"ginfo_sx", @"ginfo_sy", @"objinfo_mode", @"objinfo_bmscr", @"objinfo_hwnd", @"notemax", @"notesize", @"dir_cur", @"dir_exe", @"dir_win", @"dir_sys", @"dir_cmdline", @"dir_desktop", @"dir_mydoc", @"dir_tv", @"font_normal", @"font_bold", @"font_italic", @"font_underline", @"font_strikeout", @"font_antialias", @"objmode_normal", @"objmode_guifont", @"objmode_usefont", @"gsquare_grad", @"msgothic", @"msmincho", @"do", @"until", @"while", @"wend", @"for", @"next", @"_break", @"_continue", @"switch", @"case", @"default", @"swbreak", @"swend", @"ddim", @"ldim", @"alloc", @"m_pi", @"rad2deg", @"deg2rad", @"ease_linear", @"ease_quad_in", @"ease_quad_out", @"ease_quad_inout", @"ease_cubic_in", @"ease_cubic_out", @"ease_cubic_inout", @"ease_quartic_in", @"ease_quartic_out", @"ease_quartic_inout", @"ease_bounce_in", @"ease_bounce_out", @"ease_bounce_inout", @"ease_shake_in", @"ease_shake_out", @"ease_shake_inout", @"ease_loop", @"notefind_match", @"notefind_first", @"notefind_instr"};
                                             int keyword_macro_count = 118;
                                             //232, 191, 106
                                             red = 232.0 / 255.0;
                                             green = 191.0 / 255.0;
                                             blue = 106.0 / 255.0;
                                             for (int i = 0; i < keyword_macro_count; i++) {
                                                 index = 0;
                                                 for (int m = 0; m < size; m++) {
                                                     index = [self indexOf:str searchStr:keyword_macro[i] location:index];//(str, keyword_macro[i],index);
                                                     if (index == -1) {
                                                         break;
                                                     } else {
                                                         if (index == 0 && index + keyword_macro[i].length == size) { //行頭と行末 "^mes$"
                                                             NSRange range = NSMakeRange(index + (int) glyphRange.location, (int) keyword_macro[i].length);
                                                             [self.textStorage replaceCharactersInRange:range withAttributedString:[self getAttrStringWithColor:keyword_macro[i] red:red green:green blue:blue]];
                                                         } else if ([self isSpaceCharacter:[self charAt:str index:index - 1]] && index + keyword_macro[i].length == size) { //空白と行末 " mes$"
                                                             NSRange range = NSMakeRange(index + (int) glyphRange.location, (int) keyword_macro[i].length);
                                                             [self.textStorage replaceCharactersInRange:range withAttributedString:[self getAttrStringWithColor:keyword_macro[i] red:red green:green blue:blue]];
                                                         } else if ([self isSpaceCharacter:[self charAt:str index:index - 1]] && [self isSpaceCharacter:[self charAt:str index:index + (int) keyword_macro[i].length]]) { //空白と空白 " mes "
                                                             NSRange range = NSMakeRange(index + (int) glyphRange.location, (int) keyword_macro[i].length);
                                                             [self.textStorage replaceCharactersInRange:range withAttributedString:[self getAttrStringWithColor:keyword_macro[i] red:red green:green blue:blue]];
                                                         } else if (index == 0 && [self isSpaceCharacter:[self charAt:str index:index + (int) keyword_macro[i].length]]) { //行頭と空白 "^mes "
                                                             NSRange range = NSMakeRange(index + (int) glyphRange.location, (int) keyword_macro[i].length);
                                                             [self.textStorage replaceCharactersInRange:range withAttributedString:[self getAttrStringWithColor:keyword_macro[i] red:red green:green blue:blue]];
                                                         } else if (index + keyword_macro[i].length == size) { //行末のみ "...mes$"
                                                         }
                                                         index += keyword_macro[i].length;
                                                     }
                                                 }
                                             }

                                         }
                                     }
    ];

    //通常の行数をカウント（コメントと文字列）
    __block NSUInteger lineCount = 0;
    __block NSUInteger lineLength = 0;
    [self.string enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        int stringIndex = 0;
        int stringEndIndex = 0;
        int commentIndex = 0;
        int semicolonIndex = 0;

        if (endGlyphRange < lineLength) {
            *stop = YES;
        } else if (firstGlyphRange > lineLength && lineLength != 0) {
        } else {
            stringIndex = [self indexOf:line searchStr:@"\"" location:0]; //文字列の開始
            commentIndex = [self indexOf:line searchStr:@"//" location:0]; //コメント
            semicolonIndex = [self indexOf:line searchStr:@";" location:0]; //セミコロンのコメント

            for (int i = 0; i < line.length; i++) {

                if (stringIndex != -1) {
                    stringEndIndex = [self indexOf:line searchStr:@"\"" location:stringIndex + 1];

                    NSString *colorSpaceName = [[[self.textStorage fontAttributesInRange:NSMakeRange(stringIndex + lineLength, 1)] objectForKey:@"NSColor"] colorSpaceName];
                    if ([colorSpaceName isEqual:@"NSCalibratedWhiteColorSpace"]) { //カラースペースをチェックする（グレースケール／RGBカラー）
                        int w = (int) ([[[self.textStorage fontAttributesInRange:NSMakeRange(stringIndex + lineLength, 1)] objectForKey:@"NSColor"] whiteComponent] * 100.0);
                        if (w == 54) {
                            break;
                        }
                    } else {
                        int r = (int) ([[[self.textStorage fontAttributesInRange:NSMakeRange(stringIndex + lineLength, 1)] objectForKey:@"NSColor"] redComponent] * 100.0);
                        int g = (int) ([[[self.textStorage fontAttributesInRange:NSMakeRange(stringIndex + lineLength, 1)] objectForKey:@"NSColor"] greenComponent] * 100.0);
                        int b = (int) ([[[self.textStorage fontAttributesInRange:NSMakeRange(stringIndex + lineLength, 1)] objectForKey:@"NSColor"] blueComponent] * 100.0);
                        if (r == 54 && g == 54 && b == 54) {
                            break;
                        }
                    }

                    if (stringEndIndex != -1) {
                        NSRange fromRange = NSMakeRange(stringIndex, stringEndIndex - stringIndex + 1);
                        NSRange range = NSMakeRange(stringIndex + lineLength, stringEndIndex - stringIndex + 1);
                        [self.textStorage replaceCharactersInRange:range withAttributedString:[self getAttrStringWithColor:[line substringWithRange:fromRange] red:0.71 green:0.49 blue:0.85]];

                        stringIndex = [self indexOf:line searchStr:@"\"" location:stringEndIndex + 1];
                    } else {
                        if (commentIndex == -1 && semicolonIndex == -1) {
                            break;
                        }
                    }
                } else {
                    if (commentIndex == -1 && semicolonIndex == -1) {
                        break;
                    }
                }

                if (commentIndex != -1) {
                    //すでに文字列としての色が設定されている場合：
                    NSString *colorSpaceName = [[[self.textStorage fontAttributesInRange:NSMakeRange(commentIndex + lineLength, 1)] objectForKey:@"NSColor"] colorSpaceName];
                    if ([colorSpaceName isEqual:@"NSCalibratedWhiteColorSpace"]) { //カラースペースをチェックする（グレースケール／RGBカラー）
                        int w = (int) ([[[self.textStorage fontAttributesInRange:NSMakeRange(commentIndex + lineLength, 1)] objectForKey:@"NSColor"] whiteComponent] * 100.0);
                        if (w == 54) {
                            break;
                        }

                        NSRange fromRange = NSMakeRange(commentIndex, line.length - commentIndex);
                        NSRange range = NSMakeRange(commentIndex + lineLength, line.length - commentIndex);
                        [self.textStorage replaceCharactersInRange:range withAttributedString:[self getAttrStringWithColor:[line substringWithRange:fromRange] red:0.54 green:0.54 blue:0.54]];
                        if (stringIndex == -1 && semicolonIndex == -1) {
                            break;
                        }
                    } else {
                        int r = (int) ([[[self.textStorage fontAttributesInRange:NSMakeRange(commentIndex + lineLength, 1)] objectForKey:@"NSColor"] redComponent] * 100.0);
                        int g = (int) ([[[self.textStorage fontAttributesInRange:NSMakeRange(commentIndex + lineLength, 1)] objectForKey:@"NSColor"] greenComponent] * 100.0);
                        int b = (int) ([[[self.textStorage fontAttributesInRange:NSMakeRange(commentIndex + lineLength, 1)] objectForKey:@"NSColor"] blueComponent] * 100.0);
                        if (r == 54 && g == 54 && b == 54) {
                            break;
                        }
                        if (r != 71 && g != 49 && b != 85) {
                            NSRange fromRange = NSMakeRange(commentIndex, line.length - commentIndex);
                            NSRange range = NSMakeRange(commentIndex + lineLength, line.length - commentIndex);
                            [self.textStorage replaceCharactersInRange:range withAttributedString:[self getAttrStringWithColor:[line substringWithRange:fromRange] red:0.54 green:0.54 blue:0.54]];
                            if (stringIndex == -1 && semicolonIndex == -1) {
                                break;
                            }
                        } else {
                            commentIndex = [self indexOf:line searchStr:@"//" location:commentIndex + 2];
                        }
                    }
                } else {
                    if (stringIndex == -1 && semicolonIndex == -1) {
                        break;
                    }
                }

                if (semicolonIndex != -1) {
                    //すでに文字列としての色が設定されている場合：
                    NSString *colorSpaceName = [[[self.textStorage fontAttributesInRange:NSMakeRange(semicolonIndex + lineLength, 1)] objectForKey:@"NSColor"] colorSpaceName];
                    if ([colorSpaceName isEqual:@"NSCalibratedWhiteColorSpace"]) { //カラースペースをチェックする（グレースケール／RGBカラー）
                        int w = (int) ([[[self.textStorage fontAttributesInRange:NSMakeRange(semicolonIndex + lineLength, 1)] objectForKey:@"NSColor"] whiteComponent] * 100.0);
                        if (w == 54) {
                            break;
                        }

                        NSRange fromRange = NSMakeRange(semicolonIndex, line.length - semicolonIndex);
                        NSRange range = NSMakeRange(semicolonIndex + lineLength, line.length - semicolonIndex);
                        [self.textStorage replaceCharactersInRange:range withAttributedString:[self getAttrStringWithColor:[line substringWithRange:fromRange] red:0.54 green:0.54 blue:0.54]];
                        if (stringIndex == -1 && commentIndex == -1) {
                            break;
                        }
                    } else {
                        int r = (int) ([[[self.textStorage fontAttributesInRange:NSMakeRange(semicolonIndex + lineLength, 1)] objectForKey:@"NSColor"] redComponent] * 100.0);
                        int g = (int) ([[[self.textStorage fontAttributesInRange:NSMakeRange(semicolonIndex + lineLength, 1)] objectForKey:@"NSColor"] greenComponent] * 100.0);
                        int b = (int) ([[[self.textStorage fontAttributesInRange:NSMakeRange(semicolonIndex + lineLength, 1)] objectForKey:@"NSColor"] blueComponent] * 100.0);
                        if (r == 54 && g == 54 && b == 54) {
                            break;
                        }
                        if (r != 71 && g != 49 && b != 85) {
                            NSRange fromRange = NSMakeRange(semicolonIndex, line.length - semicolonIndex);
                            NSRange range = NSMakeRange(semicolonIndex + lineLength, line.length - semicolonIndex);
                            [self.textStorage replaceCharactersInRange:range withAttributedString:[self getAttrStringWithColor:[line substringWithRange:fromRange] red:0.54 green:0.54 blue:0.54]];
                            if (stringIndex == -1 && commentIndex == -1) {
                                break;
                            }
                        } else {
                            semicolonIndex = [self indexOf:line searchStr:@";" location:semicolonIndex + 1];
                        }
                    }
                } else {
                    if (stringIndex == -1 && commentIndex == -1) {
                        break;
                    }
                }

                if (stringIndex == -1 && commentIndex == -1 && semicolonIndex == -1) {
                    break;
                }
            }
        }

        lineCount++;
        lineLength += line.length + 1;
    }];

    //複数行の文字列／コメント
    //表示範囲内にかぶる場合にのみ色付けする
    int index_string = 0;
    int end_string = 0;
    BOOL flag_string = YES; //複数行文字列がある可能性
    int index_comment = 0;
    int end_comment = 0;
    BOOL flag_comment = YES;
    for (int m = 0; m < size; m++) {
        if (flag_string) {
            index_string = [self indexOf:str searchStr:@"{\"" location:index_string];
        }
        if (flag_comment) {
            index_comment = [self indexOf:str searchStr:@"/*" location:index_comment];
        }
        if (index_string == -1 && index_comment == -1) { //複数行の文字列／コメント両方がなかった時
            break;
        } else if (index_string == -1) { //複数行の文字列だけがなかった時（複数行のコメントだけがある）
            flag_string = NO; //複数行文字列がある可能性がなくなった
            end_comment = [self indexOf:str searchStr:@"*/" location:index_comment];
            if (end_comment == -1) {
                break;
            }
            NSRange range = NSMakeRange(index_comment, end_comment - index_comment + 2);
            if (range.location + range.length < firstGlyphRange || range.location > endGlyphRange) {}//表示範囲外だったら
            else {
                [self.textStorage replaceCharactersInRange:range withAttributedString:[self getAttrStringWithColor:[str substringWithRange:range] red:0.54 green:0.54 blue:0.54]];
            }
            index_comment += end_comment - index_comment + 2;
            continue;
        } else if (index_comment == -1) { //複数行のコメントがだけがなかった時（複数行の文字列だけがある）
            flag_comment = NO; //複数行文字列がある可能性がなくなった
            end_string = [self indexOf:str searchStr:@"\"}" location:index_string];
            if (end_string == -1) {
                break;
            }
            NSRange range = NSMakeRange(index_string, end_string - index_string + 2);
            if (range.location + range.length < firstGlyphRange || range.location > endGlyphRange) {}//表示範囲外だったら
            else {
                [self.textStorage replaceCharactersInRange:range withAttributedString:[self getAttrStringWithColor:[str substringWithRange:range] red:180 / 255.0 green:156.0 / 255.0 blue:218.0 / 255.0]];
            }
            index_string += end_string - index_string + 2;
            continue;
        }
        //文字列とコメント、両方が存在する
        end_string = [self indexOf:str searchStr:@"\"}" location:index_string + 2];
        end_comment = [self indexOf:str searchStr:@"*/" location:index_comment + 2];
        if (end_string == -1 && end_comment == -1) { //複数行の文字列／コメント両方の終わりがなかった時
            break;
        } else if (end_string == -1) { //複数行の文字列だけがなかった時（複数行のコメントだけがある
            flag_string = NO; //複数行文字列がある可能性がなくなった
            NSRange range = NSMakeRange(index_comment, end_comment - index_comment + 2);
            if (range.location + range.length < firstGlyphRange || range.location > endGlyphRange) {}//表示範囲外だったら
            else {
                [self.textStorage replaceCharactersInRange:range withAttributedString:[self getAttrStringWithColor:[str substringWithRange:range] red:0.54 green:0.54 blue:0.54]];
            }
            index_comment += end_comment - index_comment + 2;
            continue;
        } else if (end_comment == -1) { //複数行のコメントがだけがなかった時（複数行の文字列だけがある）
            flag_comment = NO; //複数行文字列がある可能性がなくなった
            NSRange range = NSMakeRange(index_string, end_string - index_string + 2);
            if (range.location + range.length < firstGlyphRange || range.location > endGlyphRange) {}//表示範囲外だったら
            else {
                [self.textStorage replaceCharactersInRange:range withAttributedString:[self getAttrStringWithColor:[str substringWithRange:range] red:180 / 255.0 green:156.0 / 255.0 blue:218.0 / 255.0]];
            }
            index_string += end_string - index_string + 2;
            continue;
        }
        //文字列とコメント、両方が存在し、かつ始まりと終わりがある
        if (index_string < index_comment) { //始まりの小さい方を優先する
            if (end_string > index_comment) {
                NSRange range = NSMakeRange(index_string, end_string - index_string + 2);
                if (range.location + range.length < firstGlyphRange || range.location > endGlyphRange) {}//表示範囲外だったら
                else {
                    [self.textStorage replaceCharactersInRange:range withAttributedString:[self getAttrStringWithColor:[str substringWithRange:range] red:180 / 255.0 green:156.0 / 255.0 blue:218.0 / 255.0]];
                }
                index_string += end_string - index_string + 2;
                index_comment = end_string;
            } else {
                NSRange range = NSMakeRange(index_string, end_string - index_string + 2);
                [self.textStorage replaceCharactersInRange:range withAttributedString:[self getAttrStringWithColor:[str substringWithRange:range] red:180 / 255.0 green:156.0 / 255.0 blue:218.0 / 255.0]];
                index_string += end_string - index_string + 2;
            }
            continue;
        } else {
            if (end_comment > index_string) {
                NSRange range = NSMakeRange(index_comment, end_comment - index_comment + 2);
                if (range.location + range.length < firstGlyphRange || range.location > endGlyphRange) {}//表示範囲外だったら
                else {
                    [self.textStorage replaceCharactersInRange:range withAttributedString:[self getAttrStringWithColor:[str substringWithRange:range] red:0.54 green:0.54 blue:0.54]];
                }
                index_comment += end_comment - index_comment + 2;
                index_string = end_comment;
            } else {
                NSRange range = NSMakeRange(index_comment, end_comment - index_comment + 2);
                if (range.location + range.length < firstGlyphRange || range.location > endGlyphRange) {}//表示範囲外だったら
                else {
                    [self.textStorage replaceCharactersInRange:range withAttributedString:[self getAttrStringWithColor:[str substringWithRange:range] red:0.54 green:0.54 blue:0.54]];
                }
                index_comment += end_comment - index_comment + 2;
            }
            continue;
        }
    }

    [self setSelectedRange:NSMakeRange(cursorPosition, 0)];//カーソルバーの位置を元に戻す
}

@end