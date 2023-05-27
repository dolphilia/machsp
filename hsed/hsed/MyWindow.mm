//
//  MyWindow.m
//  documentbasededitor
//
//  Created by dolphilia on 2016/01/31.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyWindow.h"
#import "runCompiler.h"
#import "MyScrollView.h"

@implementation MyWindow
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

- (NSString *)replace:(NSString *)str searchStr:(NSString *)searchStr replaceStr:(NSString *)replaceStr {
    return [str stringByReplacingOccurrencesOfString:searchStr withString:replaceStr];
}

- (NSString *)preg_replace:(NSString *)str patternStr:(NSString *)patternStr replaceStr:(NSString *)replaceStr {
    NSError *error = nil;
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:patternStr options:0 error:&error];
    NSString *new_str = [regexp stringByReplacingMatchesInString:str options:0 range:NSMakeRange(0, str.length) withTemplate:replaceStr];
    return new_str;
}

- (NSString *)preg_replace_lines:(NSString *)str patternStr:(NSString *)patternStr replaceStr:(NSString *)replaceStr {
    __block NSString *tmpstr = @"";
    __block NSString *t = @"";
    [str enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        t = line;
        if ([self preg_match:line patternStr:patternStr]) {
            t = [self preg_replace:line patternStr:patternStr replaceStr:replaceStr];
        }
        tmpstr = [tmpstr stringByAppendingString:t];
        tmpstr = [tmpstr stringByAppendingString:@"\n"];
    }];
    return tmpstr;
}

- (BOOL)preg_match:(NSString *)str patternStr:(NSString *)patternStr {
    BOOL ret = NO;
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:patternStr options:0 error:&error];
//    NSTextCheckingResult *match = [regex firstMatchInString:str options:0 range:NSMakeRange(0, str.length)];
//    if (match) {
//        ret = YES;
//    }
    NSArray *matches = [regex matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    if ([matches isEqual:nil]) {}
    else {
        if (matches.count > 0) {
            ret = YES;
        }
    }
    return ret;
}

- (NSString *)trim:(NSString *)str {
    return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString *)append:(NSString *)str append:(NSString *)append {
    return [str stringByAppendingString:append];
}

- (NSString *)trimAllLines:(NSString *)str {
    //すべての行をtrimする
    __block NSString *tmpstr = @"";
    [str enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        tmpstr = [tmpstr stringByAppendingString:[self trim:line]];
        tmpstr = [tmpstr stringByAppendingString:@"\n"];
    }];
    return tmpstr;
}

- (NSString *)deleteBlankLineAllLines:(NSString *)str {
    //すべての行から空行を取り除く
    __block NSString *tmpstr = @"";
    [str enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        if ([line isEqual:@""]) {}
        else {
            tmpstr = [tmpstr stringByAppendingString:line];
            tmpstr = [tmpstr stringByAppendingString:@"\n"];
        }
    }];
    return tmpstr;
}


- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {}
    return self;
}

- (void)awakeFromNib { //ウィンドウ管理用の番号を初期化する
    global = (AppDelegate *) [[NSApplication sharedApplication] delegate];
    if (global.logString == nil) {
        global.logString = @"";
    }

    accessNumber = -1;
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        while (YES) {
            usleep(100000);
            if (accessNumber == -1) {
                continue;
            }
            MyScrollView *myScrollView = (MyScrollView *) self.contentView.subviews[0].subviews[0].subviews[0].subviews[0].subviews[0];
            documentVisibleX[accessNumber] = myScrollView.contentView.documentVisibleRect.origin.x;//self.contentView.documentVisibleRect.origin.x;
            documentVisibleY[accessNumber] = myScrollView.contentView.documentVisibleRect.origin.y;//self.contentView.documentVisibleRect.origin.y;
            documentVisibleWidth[accessNumber] = myScrollView.contentView.documentVisibleRect.size.width;//self.contentView.documentVisibleRect.size.width;
            documentVisibleHeight[accessNumber] = myScrollView.contentView.documentVisibleRect.size.height;//self.contentView.documentVisibleRect.size.height;
        }
    }];
}

- (void)setAccessNumber:(int)num { //ウィンドウ管理用の番号をセットする（外部用）
    accessNumber = num;
}

- (IBAction)onButton:(id)sender {
    if ([sender state] == 0) { //トグルボタンの状態
        [[[self.contentViewController.view.subviews objectAtIndex:0].subviews objectAtIndex:1] setHidden:YES];
    } else {
        [[[self.contentViewController.view.subviews objectAtIndex:0].subviews objectAtIndex:1] setHidden:NO];
    }
}

- (NSString *)convertAltHSP:(NSString *)str {


    NSString *ret = str;

    //NSString *jqueryFilePath = [[NSBundle mainBundle] pathForResource:@"jquery" ofType:@"js"];
    //NSString *jqueryScript = [NSString stringWithContentsOfFile:jqueryFilePath encoding:NSUTF8StringEncoding error:NULL];


    //JavaScriptを使用する例
    //JSContext* context = [[JSContext alloc] init];
    //NSString* script = [jqueryScript stringByAppendingString:@"\nvar value = encodeURI('<name>');"];
    //[context evaluateScript:script];
    //JSValue* value = [context objectForKeyedSubscript:@"value"];
    //NSLog(@"%@",value.toString);

//    int index = [self indexOf:str searchStr:@"repeat" location:0];
//    if(index != -1) { //repeatが存在したら
//        int i=0;
//        while(1) {
//            if([[self charAt:str index:index+i] isEqual:@"\n"]) {
//                break;
//            }
//            else if([[self charAt:str index:index+i] isEqual:@"{"]) {
//                break;
//            }
//            i++;
//            if ((int)str.length < i+index) { //ソースコードの終端だったら
//                break;
//            }
//        }
//    }
    __block BOOL isClass = NO;
    __block BOOL isFunction = NO;
    __block BOOL isModuleLine = NO;
    __block BOOL isFunctionLine = NO;
    __block BOOL isIfLine = NO;
    __block int ifCount = 0;
    __block NSString *tmpstr = @"";
    __block NSString *t = @"";

    //すべての行に対する処理
    ret = [self trimAllLines:ret]; //すべての行をtrimする
    ret = [self deleteBlankLineAllLines:ret]; //すべての行から空行を取り除く

    // class xxx
    //
    // {
    // を、 class xxx { に
    //
    isClass = NO;
    isFunction = NO;
    ifCount = 0;
    tmpstr = @"";
    t = @"";
    [ret enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        t = line;
        if ([self preg_match:line patternStr:@"^class\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\s*[^\{]*\\s*$"]) {
            isClass = YES;
            t = [self preg_replace:line patternStr:@"^class\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\s*[^\{]*\\s*$" replaceStr:@"class $1 {"];
        } else if ([self preg_match:line patternStr:@"^func\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\s*\\((.*)\\)\\s*[^\\{]*\\s*$"]) {
            isFunction = YES;
            t = [self preg_replace:line patternStr:@"^func\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\s*\\((.*)\\)\\s*[^\\{]*\\s*$" replaceStr:@"func $1($2) {"];
        } else if ([self preg_match:line patternStr:@"^func\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_,]+)\\s*([^\\(\\)\\{]*)\\s*[^\\{]*\\s*$"]) {
            isFunction = YES;
            t = [self preg_replace:line patternStr:@"^func\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_,]+)\\s*([^\\(\\)\\{]*)\\s*[^\\{]*\\s*$" replaceStr:@"func $1 $2 {"];
        } else if ([self preg_match:line patternStr:@"^init\\s*\\((.*)\\)\\s*[^\\{]*\\s*$"]) {
            isFunction = YES;
            t = [self preg_replace:line patternStr:@"^init\\s*\\((.*)\\)\\s*[^\\{]*\\s*$" replaceStr:@"init($1) {"];
        } else if ([self preg_match:line patternStr:@"^init\\s+(.*)\\s*[^\\{]*\\s*$"]) {
            isFunction = YES;
            t = [self preg_replace:line patternStr:@"^init\\s+(.*)\\s*[^\\{]*\\s*$" replaceStr:@"init $1 {"];
        } else if ([self preg_match:line patternStr:@"^deinit\\s*[^\\{]*\\s*$"]) {
            isFunction = YES;
            t = [self preg_replace:line patternStr:@"^deinit\\s*[^\\{]*\\s*$" replaceStr:@"deinit {"];
        } else if ([self preg_match:line patternStr:@"^if\\s*([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_, \\t]*[^\\{\\:]+)$"]) {
            ifCount++;
            t = [self preg_replace:line patternStr:@"^if\\s*([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_, \\t]*[^\\{\\:]+)$" replaceStr:@"if $1 {"];
        } else if ([self preg_match:line patternStr:@"^else\\s*$"]) {
            ifCount++;
            t = [self preg_replace:line patternStr:@"^else\\s*$" replaceStr:@"else {"];
        } else if ([self preg_match:line patternStr:@"^\\s*\\{\\s*$"]) {
            if (isClass) {
                isClass = NO;
                t = @"";
            } else if (isFunction) {
                isFunction = NO;
                t = @"";
            } else if (ifCount > 0) {
                ifCount--;
                t = @"";
            }
        }
        tmpstr = [tmpstr stringByAppendingString:t];
        tmpstr = [tmpstr stringByAppendingString:@"\n"];
    }];
    ret = tmpstr;

    ret = [self trimAllLines:ret]; //すべての行をtrimする
    ret = [self deleteBlankLineAllLines:ret]; //すべての行から空行を取り除く

    //class xxx { を、 class xxx {{{
    //func xxx {  ->  func xxx {{
    isClass = NO;
    isFunction = NO;
    isModuleLine = NO;
    isFunctionLine = NO;
    isIfLine = NO;
    ifCount = 0;
    tmpstr = @"";
    t = @"";
    [ret enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        t = line;
        if ([self preg_match:line patternStr:@"^class\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\s*\\{$"]) {
            isClass = YES;
            t = [self preg_replace:line patternStr:@"^class\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\s*\\{$" replaceStr:@"class $1 {{{"];
        } else if ([self preg_match:line patternStr:@"^func\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\s*\\((.*)\\)\\s*\\{$"]) {
            isFunction = YES;
            t = [self preg_replace:line patternStr:@"^func\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\s*\\((.*)\\)\\s*\\{$" replaceStr:@"func $1($2) {{"];
        } else if ([self preg_match:line patternStr:@"^func\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_,]+)\\s*([^\\(\\)]*)\\s*\\{$"]) {
            isFunction = YES;
            t = [self preg_replace:line patternStr:@"^func\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_,]+)\\s*([^\\(\\)]*)\\s*\\{$" replaceStr:@"func $1 $2 {{"];
        } else if ([self preg_match:line patternStr:@"^init\\s*\\((.*)\\)\\s*\\{$"]) {
            isFunction = YES;
            t = [self preg_replace:line patternStr:@"^init\\s*\\((.*)\\)\\s*\\{$" replaceStr:@"init($1) {{"];
        } else if ([self preg_match:line patternStr:@"^init\\s+(.*)\\s*\\{$"]) { //^init\\s+(.*)\\s*\\{$
            isFunction = YES;
            t = [self preg_replace:line patternStr:@"^init\\s+(.*)\\s*\\{$" replaceStr:@"init $1 {{"];
            NSLog(@"%@", t);
        } else if ([self preg_match:line patternStr:@"^deinit\\s*\\{$"]) {
            isFunction = YES;
            t = [self preg_replace:line patternStr:@"^deinit\\s*\\{$" replaceStr:@"deinit {{"];
        } else if ([self preg_match:line patternStr:@"if\\s+.+\\{$"] || [self preg_match:line patternStr:@"else\\s+\\{$"]) {
            ifCount++;
        } else if ([self preg_match:line patternStr:@"^\\}$"]) {
            if (ifCount > 0) {
                ifCount--;
            } else if (isFunction) {
                isFunction = NO;
                t = @"}}";
            } else if (isClass) {
                isClass = NO;
                t = @"}}}";
            }
        }
        tmpstr = [tmpstr stringByAppendingString:t];
        tmpstr = [tmpstr stringByAppendingString:@"\n"];
    }];
    ret = tmpstr;

    //日本語の変数名や関数名の末尾に_をつける
    ret = [self preg_replace:ret patternStr:@"([\\@\\(\\[\\!<>\\^\\|\\*\\t\\f\\r\\n \\.,:;=\\+\\-\\%\\&\\\\])([ぁ-んァ-ヶー一-龠０-９]+)" replaceStr:@"$1_$2_"];


    //クラス変数、ローカル変数

    //class xxx {{{ \n var a \n var b \n var c -> class xxx a,b,c
    NSMutableString *mutableStr = [NSMutableString stringWithString:ret];
    NSError *error = nil;
    NSString *pattern = @"\\{\\{\\{\\s*((var\\s+[ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+\\s*)+)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    NSArray *matches = [regex matchesInString:ret options:0 range:NSMakeRange(0, ret.length)];
    [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult *match, NSUInteger idx, BOOL *stop) {
        NSString *rangeStr = [self substr:ret index:(int) match.range.location length:(int) match.range.length];
        NSString *tmpstr = rangeStr;
        tmpstr = [self preg_replace:tmpstr patternStr:@"\\{\\{\\{\\s*((var\\s+[ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+\\s*)+)" replaceStr:@"$1"];//var a \n var b \n var c
        tmpstr = [self preg_replace:tmpstr patternStr:@"([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\nvar\\s+" replaceStr:@"$1,"];//var a,b,c
        tmpstr = [self preg_replace:tmpstr patternStr:@"^\\s*var\\s+(.*)" replaceStr:@"$1"]; //行頭のvarを除く
        [mutableStr replaceCharactersInRange:match.range withString:tmpstr];
    }];
    ret = [NSString stringWithString:mutableStr];

    //コンストラクタ（関数）のローカル変数 パラメーターあり
    mutableStr = [NSMutableString stringWithString:ret];
    pattern = @"(init)\\s*\\(\\s*([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_].*)\\)\\s*\\{\\{\\s*((var\\s+[ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+\\s*)+)";
    regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    matches = [regex matchesInString:ret options:0 range:NSMakeRange(0, ret.length)];
    [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult *match, NSUInteger idx, BOOL *stop) {
        //NSLog(@"%d-%d",(int)[match rangeAtIndex:0].location,(int)[match rangeAtIndex:0].length); //マッチ全体
        //NSLog(@"%d-%d",(int)[match rangeAtIndex:1].location,(int)[match rangeAtIndex:1].length); //init
        //NSLog(@"%d-%d",(int)[match rangeAtIndex:2].location,(int)[match rangeAtIndex:2].length); //a
        //NSLog(@"%d-%d",(int)[match rangeAtIndex:3].location,(int)[match rangeAtIndex:3].length); //var a ~ var c
        NSString *tmpstr1 = [self substr:ret index:(int) [match rangeAtIndex:1].location length:(int) [match rangeAtIndex:1].length];
        NSString *tmpstr2 = [self substr:ret index:(int) [match rangeAtIndex:2].location length:(int) [match rangeAtIndex:2].length];
        NSString *tmpstr3 = [self substr:ret index:(int) [match rangeAtIndex:3].location length:(int) [match rangeAtIndex:3].length];
        tmpstr3 = [self preg_replace:tmpstr3 patternStr:@"((var\\s+[ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+\\s*)+)" replaceStr:@"$1"];
        tmpstr3 = [self preg_replace:tmpstr3 patternStr:@"([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\nvar\\s+" replaceStr:@"$1, local "]; //var a,b,c
        tmpstr3 = [self preg_replace:tmpstr3 patternStr:@"^\\s*var\\s+(.*)" replaceStr:@"local $1"]; //行頭のvarを除く
        tmpstr3 = [self preg_replace:tmpstr3 patternStr:@"^(.*)\\n*" replaceStr:@"$1"]; //行末の改行を除く
        tmpstr3 = [NSString stringWithFormat:@"%@(%@,%@) {{\n", tmpstr1, tmpstr2, tmpstr3];
        [mutableStr replaceCharactersInRange:match.range withString:tmpstr3];
    }];
    ret = [NSString stringWithString:mutableStr];

    //コンストラクタ（関数）のローカル変数 パラメーターなし
    mutableStr = [NSMutableString stringWithString:ret];
    pattern = @"(init)\\s*\\(\\s*\\)\\s*\\{\\{\\s*((var\\s+[ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+\\s*)+)";
    regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    matches = [regex matchesInString:ret options:0 range:NSMakeRange(0, ret.length)];
    [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult *match, NSUInteger idx, BOOL *stop) {
        NSString *tmpstr1 = [self substr:ret index:(int) [match rangeAtIndex:1].location length:(int) [match rangeAtIndex:1].length];
        NSString *tmpstr2 = [self substr:ret index:(int) [match rangeAtIndex:2].location length:(int) [match rangeAtIndex:2].length];
        //NSString* tmpstr3 = [self substr:ret index:(int)[match rangeAtIndex:3].location length:(int)[match rangeAtIndex:3].length];
        tmpstr2 = [self preg_replace:tmpstr2 patternStr:@"((var\\s+[ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+\\s*)+)" replaceStr:@"$1"];
        tmpstr2 = [self preg_replace:tmpstr2 patternStr:@"([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\nvar\\s+" replaceStr:@"$1, local "]; //var a,b,c
        tmpstr2 = [self preg_replace:tmpstr2 patternStr:@"^\\s*var\\s+(.*)" replaceStr:@"local $1"]; //行頭のvarを除く
        tmpstr2 = [self preg_replace:tmpstr2 patternStr:@"^(.*)\\n*" replaceStr:@"$1"]; //行末の改行を除く
        tmpstr2 = [NSString stringWithFormat:@"%@(%@) {{\n", tmpstr1, tmpstr2];
        [mutableStr replaceCharactersInRange:match.range withString:tmpstr2];
    }];
    ret = [NSString stringWithString:mutableStr];

    //コンストラクタ（関数）のローカル変数 パラメーターあり
    mutableStr = [NSMutableString stringWithString:ret];
    pattern = @"(init)\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_].*)\\{\\{\\s*((var\\s+[ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+\\s*)+)";
    regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    matches = [regex matchesInString:ret options:0 range:NSMakeRange(0, ret.length)];
    [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult *match, NSUInteger idx, BOOL *stop) {
        NSString *tmpstr1 = [self substr:ret index:(int) [match rangeAtIndex:1].location length:(int) [match rangeAtIndex:1].length];
        NSString *tmpstr2 = [self substr:ret index:(int) [match rangeAtIndex:2].location length:(int) [match rangeAtIndex:2].length];
        NSString *tmpstr3 = [self substr:ret index:(int) [match rangeAtIndex:3].location length:(int) [match rangeAtIndex:3].length];
        tmpstr3 = [self preg_replace:tmpstr3 patternStr:@"((var\\s+[ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+\\s*)+)" replaceStr:@"$1"];
        tmpstr3 = [self preg_replace:tmpstr3 patternStr:@"([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\nvar\\s+" replaceStr:@"$1, local "]; //var a,b,c
        tmpstr3 = [self preg_replace:tmpstr3 patternStr:@"^\\s*var\\s+(.*)" replaceStr:@"local $1"]; //行頭のvarを除く
        tmpstr3 = [self preg_replace:tmpstr3 patternStr:@"^(.*)\\n*" replaceStr:@"$1"]; //行末の改行を除く
        tmpstr3 = [NSString stringWithFormat:@"%@ %@,%@ {{\n", tmpstr1, tmpstr2, tmpstr3];
        [mutableStr replaceCharactersInRange:match.range withString:tmpstr3];
    }];
    ret = [NSString stringWithString:mutableStr];

    //関数のローカル変数 パラメーターあり
    mutableStr = [NSMutableString stringWithString:ret];
    pattern = @"func\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\s*\\(\\s*([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_].*)\\)\\s*\\{\\{\\s*((var\\s+[ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+\\s*)+)";
    regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    matches = [regex matchesInString:ret options:0 range:NSMakeRange(0, ret.length)];
    [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult *match, NSUInteger idx, BOOL *stop) {
        NSString *tmpstr1 = [self substr:ret index:(int) [match rangeAtIndex:1].location length:(int) [match rangeAtIndex:1].length];
        NSString *tmpstr2 = [self substr:ret index:(int) [match rangeAtIndex:2].location length:(int) [match rangeAtIndex:2].length];
        NSString *tmpstr3 = [self substr:ret index:(int) [match rangeAtIndex:3].location length:(int) [match rangeAtIndex:3].length];
        tmpstr3 = [self preg_replace:tmpstr3 patternStr:@"((var\\s+[ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+\\s*)+)" replaceStr:@"$1"];
        tmpstr3 = [self preg_replace:tmpstr3 patternStr:@"([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\nvar\\s+" replaceStr:@"$1, local "]; //var a,b,c
        tmpstr3 = [self preg_replace:tmpstr3 patternStr:@"^\\s*var\\s+(.*)" replaceStr:@"local $1"]; //行頭のvarを除く
        tmpstr3 = [self preg_replace:tmpstr3 patternStr:@"^(.*)\\n*" replaceStr:@"$1"]; //行末の改行を除く
        tmpstr3 = [NSString stringWithFormat:@"func %@(%@,%@) {{\n", tmpstr1, tmpstr2, tmpstr3];
        [mutableStr replaceCharactersInRange:match.range withString:tmpstr3];
    }];
    ret = [NSString stringWithString:mutableStr];

    //関数のローカル変数 パラメーターなし
    mutableStr = [NSMutableString stringWithString:ret];
    pattern = @"func\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\s*\\(\\s*\\)\\s*\\{\\{\\s*((var\\s+[ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+\\s*)+)";
    regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    matches = [regex matchesInString:ret options:0 range:NSMakeRange(0, ret.length)];
    [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult *match, NSUInteger idx, BOOL *stop) {
        NSString *tmpstr1 = [self substr:ret index:(int) [match rangeAtIndex:1].location length:(int) [match rangeAtIndex:1].length];
        NSString *tmpstr2 = [self substr:ret index:(int) [match rangeAtIndex:2].location length:(int) [match rangeAtIndex:2].length];
        //NSString* tmpstr3 = [self substr:ret index:(int)[match rangeAtIndex:3].location length:(int)[match rangeAtIndex:3].length];
        tmpstr2 = [self preg_replace:tmpstr2 patternStr:@"((var\\s+[ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+\\s*)+)" replaceStr:@"$1"];
        tmpstr2 = [self preg_replace:tmpstr2 patternStr:@"([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\nvar\\s+" replaceStr:@"$1, local "]; //var a,b,c
        tmpstr2 = [self preg_replace:tmpstr2 patternStr:@"^\\s*var\\s+(.*)" replaceStr:@"local $1"]; //行頭のvarを除く
        tmpstr2 = [self preg_replace:tmpstr2 patternStr:@"^(.*)\\n*" replaceStr:@"$1"]; //行末の改行を除く
        tmpstr2 = [NSString stringWithFormat:@"func %@(%@) {{\n", tmpstr1, tmpstr2];
        [mutableStr replaceCharactersInRange:match.range withString:tmpstr2];

    }];
    ret = [NSString stringWithString:mutableStr];

    //命令のローカル変数 パラメーターあり
    mutableStr = [NSMutableString stringWithString:ret];
    pattern = @"func\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_].*)\\{\\{\\s*((var\\s+[ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+\\s*)+)";
    regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    matches = [regex matchesInString:ret options:0 range:NSMakeRange(0, ret.length)];
    [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult *match, NSUInteger idx, BOOL *stop) {
        NSString *tmpstr1 = [self substr:ret index:(int) [match rangeAtIndex:1].location length:(int) [match rangeAtIndex:1].length];
        NSString *tmpstr2 = [self substr:ret index:(int) [match rangeAtIndex:2].location length:(int) [match rangeAtIndex:2].length];
        NSString *tmpstr3 = [self substr:ret index:(int) [match rangeAtIndex:3].location length:(int) [match rangeAtIndex:3].length];
        tmpstr3 = [self preg_replace:tmpstr3 patternStr:@"((var\\s+[ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+\\s*)+)" replaceStr:@"$1"];
        tmpstr3 = [self preg_replace:tmpstr3 patternStr:@"([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\nvar\\s+" replaceStr:@"$1, local "]; //var a,b,c
        tmpstr3 = [self preg_replace:tmpstr3 patternStr:@"^\\s*var\\s+(.*)" replaceStr:@"local $1"]; //行頭のvarを除く
        tmpstr3 = [self preg_replace:tmpstr3 patternStr:@"^(.*)\\n*" replaceStr:@"$1"]; //行末の改行を除く
        tmpstr3 = [NSString stringWithFormat:@"func %@ %@,%@ {{\n", tmpstr1, tmpstr2, tmpstr3];
        [mutableStr replaceCharactersInRange:match.range withString:tmpstr3];
    }];
    ret = [NSString stringWithString:mutableStr];

    //命令のローカル変数 パラメーターなし
    mutableStr = [NSMutableString stringWithString:ret];
    pattern = @"\\{\\{\\s*((var\\s+[ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+\\s*)+)";
    regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    matches = [regex matchesInString:ret options:0 range:NSMakeRange(0, ret.length)];
    [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult *match, NSUInteger idx, BOOL *stop) {
        NSString *tmpstr = [self substr:ret index:(int) match.range.location length:(int) match.range.length];
        //NSString* tmpstr2 = [self substr:ret index:(int)[match rangeAtIndex:2].location length:(int)[match rangeAtIndex:2].length];
        //NSString* tmpstr3 = [self substr:ret index:(int)[match rangeAtIndex:3].location length:(int)[match rangeAtIndex:3].length];
        tmpstr = [self preg_replace:tmpstr patternStr:@"\\{\\{\\s*((var\\s+[ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+\\s*)+)" replaceStr:@"$1"];
        tmpstr = [self preg_replace:tmpstr patternStr:@"([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\nvar\\s+" replaceStr:@"$1, local "]; //var a,b,c
        tmpstr = [self preg_replace:tmpstr patternStr:@"^\\s*var\\s+(.*)" replaceStr:@"local $1"]; //行頭のvarを除く
        tmpstr = [self preg_replace:tmpstr patternStr:@"^(.*)\\n*" replaceStr:@"$1"]; //行末の改行を除く
        tmpstr = [NSString stringWithFormat:@"%@ {{\n", tmpstr];
        [mutableStr replaceCharactersInRange:match.range withString:tmpstr];

    }];
    ret = [NSString stringWithString:mutableStr];

    //class クラス名_ {{{\nvar 変数_1,変数_2,... -> #module クラス名_ 変数_1,変数_2,変数_3
    ret = [self preg_replace:ret patternStr:@"class\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\s+(.+)" replaceStr:@"#module $1 $2"];

    //else if
    ret = [self preg_replace:ret patternStr:@"(\\}\\s*)else\\s+if" replaceStr:@"$1else : if"];


    //import文
    ret = [self preg_replace_lines:ret patternStr:@"^import\\s+(.+)" replaceStr:@"#include \"$1\\.as\""];

    //module modfunc modcfunc modinit modterm
    ret = [self preg_replace_lines:ret patternStr:@"^class\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\s*\\{\\{\\{" replaceStr:@"#module $1"];
    ret = [self preg_replace_lines:ret patternStr:@"^\\}\\}\\}" replaceStr:@"#global"];
    ret = [self preg_replace_lines:ret patternStr:@"^func\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\s*\\((.*)\\)\\s*\\{\\{" replaceStr:@"#modcfunc $1 $2"];
    ret = [self preg_replace_lines:ret patternStr:@"^func\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_,]+)\\s*(.*)\\{\\{" replaceStr:@"#modfunc $1 $2"];
    ret = [self preg_replace_lines:ret patternStr:@"^init\\s*\\((.*)\\)\\s*\\{\\{" replaceStr:@"#modinit $1"];
    ret = [self preg_replace_lines:ret patternStr:@"^init\\s+(.*)\\s*\\{\\{" replaceStr:@"#modinit $1"];
    ret = [self preg_replace_lines:ret patternStr:@"^deinit\\s*\\{\\{" replaceStr:@"#modterm"];

    //#module xxx {{{ 修正用
    ret = [self preg_replace_lines:ret patternStr:@"^#module\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\s*\\{\\{\\{" replaceStr:@"#module $1"];

    //newmod delmod
    ret = [self preg_replace_lines:ret patternStr:@"^([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_\\[\\]]+)\\s*=\\s*push\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\(\\)" replaceStr:@"newmod $1,$2"];
    ret = [self preg_replace_lines:ret patternStr:@"^([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_\\[\\]]+)\\s*=\\s*add\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\(\\)" replaceStr:@"newmod $1,$2"];
    ret = [self preg_replace_lines:ret patternStr:@"^([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_\\[\\]]+)\\s*=\\s*new\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\(\\)" replaceStr:@"newmod $1,$2"];
    ret = [self preg_replace_lines:ret patternStr:@"^([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_\\[\\]]+)\\s*=\\s*push\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\((.+)\\)" replaceStr:@"newmod $1,$2,$3"];
    ret = [self preg_replace_lines:ret patternStr:@"^([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_\\[\\]]+)\\s*=\\s*add\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\((.+)\\)" replaceStr:@"newmod $1,$2,$3"];
    ret = [self preg_replace_lines:ret patternStr:@"^([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_\\[\\]]+)\\s*=\\s*new\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\((.+)\\)" replaceStr:@"newmod $1,$2,$3"];
    ret = [self preg_replace_lines:ret patternStr:@"^([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_\\[\\]]+)\\s*=\\s*([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+).new\\s*\\((.+)\\)" replaceStr:@"newmod $1,$2,$3"];
    ret = [self preg_replace_lines:ret patternStr:@"^([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_\\[\\]]*)\\.delete$" replaceStr:@"delmod $1"];
    ret = [self preg_replace_lines:ret patternStr:@"^([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_\\[\\]]*)\\.delete()$" replaceStr:@"delmod $1"];

    //each 命令
    ret = [self preg_replace_lines:ret patternStr:@"^each\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+),\\s*([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)" replaceStr:@"foreach $1\n$2 = $1.cnt"];

    //x.x x[x]
    ret = [self preg_replace_lines:ret patternStr:@"^([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\.([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\(\\s*\\)" replaceStr:@"$2 $1"];
    ret = [self preg_replace_lines:ret patternStr:@"([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\[(.+)\\]\\.([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\((.+)\\)" replaceStr:@"$3($1.$2,$4)"];
    ret = [self preg_replace_lines:ret patternStr:@"^([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\[(.+)\\]\\.([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\s+(.+)$" replaceStr:@"$3 $1.$2,$4"];

    //for
    ret = [self preg_replace_lines:ret patternStr:@"^for\\s([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+\\s*=.+);\\s*(.+);\\s*(.+)" replaceStr:@"$1\nrepeat\nif $2 {\n}\nelse {\nbreak\n}\nif cnt>0 {\n$3\n}"];

    // loop {{{{{
    //     ...
    // }}}}}
    if ([self preg_match:ret patternStr:@"loop[ \t]\\{\\{\\{\\{\\{"]) {
        ret = [self preg_replace:ret patternStr:@"(loop[ \t])\\{\\{\\{\\{\\{" replaceStr:@"repeat"];
    }
    if ([self preg_match:ret patternStr:@"\\}\\}\\}\\}\\}"]) {
        ret = [self preg_replace:ret patternStr:@"\\}\\}\\}\\}\\}" replaceStr:@"loop"];
    }

    // repeat xxx {{{{
    //     ...
    // }}}}
    if ([self preg_match:ret patternStr:@"repeat[ \t].*\\{\\{\\{\\{"]) {
        ret = [self preg_replace:ret patternStr:@"(repeat[ \t].*)\\{\\{\\{\\{" replaceStr:@"$1"];
    }
    if ([self preg_match:ret patternStr:@"\\}\\}\\}\\}"]) {
        ret = [self preg_replace:ret patternStr:@"\\}\\}\\}\\}" replaceStr:@"loop"];
    }

    //グローバル空間からモジュール空間へのアクセスを禁止する
    //インスタンスからのメソッド呼び出しを許可する
    //インスタンス同士のメソッド衝突は回避できない
    __block NSString *module_name = @"";
    //isClass = NO;
    __block BOOL inFunction = NO;
    tmpstr = @"";
    t = @"";
    [ret enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        t = line;
        if ([self preg_match:line patternStr:@"^#module\\s*([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\s*.*"]) {
            module_name = [self preg_replace:line patternStr:@"^#module\\s*([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\s*.*" replaceStr:@"$1"];
        } else if ([self preg_match:line patternStr:@"^#global\\s*.*"]) {
            module_name = @"";
            inFunction = NO;
        } else if ([self preg_match:line patternStr:@"^#deffunc\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)(.*)"]) {
            inFunction = YES;
            if ([module_name isEqualToString:@""]) {}
            else {
                NSString *repstr = [NSString stringWithFormat:@"#define global $1_global_ _$1@%@\n#define $1 _$1@%@\n#deffunc local _$1$2", module_name, module_name];
                t = [self preg_replace:line patternStr:@"^#deffunc\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)(.*)" replaceStr:repstr];
            }
        } else if ([self preg_match:line patternStr:@"^#defcfunc\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)(.*)"]) {
            inFunction = YES;
            if ([module_name isEqualToString:@""]) {}
            else {
                NSString *repstr = [NSString stringWithFormat:@"#define global $1_global_ _$1@%@\n#define $1 _$1@%@\n#deffunc local _$1$2", module_name, module_name];
                t = [self preg_replace:line patternStr:@"^#defcfunc\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)(.*)" replaceStr:repstr];
            }
        } else if ([self preg_match:line patternStr:@"^#modfunc\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)(.*)"]) {
            inFunction = YES;
            if ([module_name isEqualToString:@""]) {
                NSString *repstr = [NSString stringWithFormat:@"goto *@f\n#deffunc $1$2"];
                t = [self preg_replace:line patternStr:@"^#modfunc\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)(.*)" replaceStr:repstr];
            }
//            else {
//                NSString* repstr = [NSString stringWithFormat:@"#define global $1_global_ _$1@%@\n#define $1 _$1@%@\n#modfunc local _$1$2",module_name,module_name];
//                t = [self preg_replace:line patternStr:@"^#modfunc\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)(.*)" replaceStr:repstr];
//            }
        } else if ([self preg_match:line patternStr:@"^#modcfunc\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)(.*)"]) {
            inFunction = YES;
            if ([module_name isEqualToString:@""]) {
                NSString *repstr = [NSString stringWithFormat:@"goto *@f\n#defcfunc $1$2"];
                t = [self preg_replace:line patternStr:@"^#modcfunc\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)(.*)" replaceStr:repstr];
            }
//            else {
//                NSString* repstr = [NSString stringWithFormat:@"#define global $1_global_ _$1@%@\n#define $1 _$1@%@\n#modcfunc local _$1$2",module_name,module_name];
//                t = [self preg_replace:line patternStr:@"^#modcfunc\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)(.*)" replaceStr:repstr];
//            }
        } else if ([self preg_match:line patternStr:@"^\\}\\}"]) {
            inFunction = NO;
            t = [self preg_replace:line patternStr:@"^\\}\\}" replaceStr:@"return\n*@"];
        } else if ([self preg_match:line patternStr:@"^global\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)"]) {
            //グローバル変数
            if ([module_name isEqual:@""] && inFunction == NO) {
                t = [self preg_replace:line patternStr:@"^global\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)" replaceStr:@"#define global $1 $1@hsp"];
            }
        } else if ([self preg_match:line patternStr:@"^var\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\s*\\=([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_ \\t\\=\\.\\\"\\(\\)\\[\\]]+)"]) {
            //グローバル変数の宣言、代入あり
            if ([module_name isEqual:@""] && inFunction == NO) {
                t = [self preg_replace:line patternStr:@"^var\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\s*\\=([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_ \\t\\=\\.\\\"\\(\\)\\[\\]]+)" replaceStr:@"#define global $1 $1@hsp\n$1 =$2"];
            }
        } else if ([self preg_match:line patternStr:@"^var\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)"]) {
            //グローバル変数の宣言、代入なし
            if ([module_name isEqual:@""] && inFunction == NO) {
                t = [self preg_replace:line patternStr:@"^var\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)" replaceStr:@"#define global $1 $1@hsp"];
            }
        }

        tmpstr = [tmpstr stringByAppendingString:t];
        tmpstr = [tmpstr stringByAppendingString:@"\n"];
    }];
    ret = tmpstr;

    //#module xxx 修正用
    ret = [self preg_replace_lines:ret patternStr:@"^#module\\s+([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)$" replaceStr:@"#module $1　  __module__   "];

    //インスタンスメソッド
//    ret = [self preg_replace_lines:ret patternStr:@"([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_\\[\\]]+)\\.([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\(()\\)" replaceStr:@"$2_global_($1)"];
//    ret = [self preg_replace_lines:ret patternStr:@"([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_\\[\\]]+)\\.([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\((.+)\\)" replaceStr:@"$2_global_($1,$3)"];
//    ret = [self preg_replace_lines:ret patternStr:@"^([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_\\[\\]]*)\\.([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\s+(.+)$" replaceStr:@"$2_global_ $1,$3"]; //a.name 0 -> name a,0,0,0
//    ret = [self preg_replace_lines:ret patternStr:@"^([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_\\[\\]]*)\\.([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)$" replaceStr:@"$2_global_ $1"]; //a.name -> name a

    //this.xxx -> self.xxx
    ret = [self preg_replace_lines:ret patternStr:@"(self)\\.([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\(()\\)" replaceStr:@"$2(thismod)"];
    ret = [self preg_replace_lines:ret patternStr:@"(self)\\.([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\((.+)\\)" replaceStr:@"$2(thismod,$3)"];
    ret = [self preg_replace_lines:ret patternStr:@"^(self)\\.([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\s+(.+)$" replaceStr:@"$2 thismod,$3"]; //a.name 0 -> name a,0,0,0
    ret = [self preg_replace_lines:ret patternStr:@"^(self)\\.([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)$" replaceStr:@"$2 thismod"]; //a.name -> name a

    //修正
    ret = [self preg_replace_lines:ret patternStr:@"([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_\\[\\]]+)\\.([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\(()\\)" replaceStr:@"$2($1)"];
    ret = [self preg_replace_lines:ret patternStr:@"([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_\\[\\]]+)\\.([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\((.+)\\)" replaceStr:@"$2($1,$3)"];
    ret = [self preg_replace_lines:ret patternStr:@"^([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_\\[\\]]*)\\.([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\s+(.+)$" replaceStr:@"$2 $1,$3"]; //a.name 0 -> name a,0,0,0
    ret = [self preg_replace_lines:ret patternStr:@"^([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_\\[\\]]*)\\.([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)$" replaceStr:@"$2 $1"]; //a.name -> name a



    //配列（５次元まで）
    ret = [self preg_replace_lines:ret patternStr:@"([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\[\\s*([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\]\\[\\s*([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\]\\[\\s*([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\]\\[\\s*([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\]" replaceStr:@"$1.$2.$3.$4.$5"];
    ret = [self preg_replace_lines:ret patternStr:@"([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\[\\s*([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\]\\[\\s*([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\]\\[\\s*([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\]" replaceStr:@"$1.$2.$3.$4"];
    ret = [self preg_replace_lines:ret patternStr:@"([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\[\\s*([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\]\\[\\s*([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\]" replaceStr:@"$1.$2.$3"];
    ret = [self preg_replace_lines:ret patternStr:@"([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\[\\s*([ぁ-んァ-ヶーa-zA-Z0-9一-龠０-９_]+)\\]" replaceStr:@"$1.$2"];



    //ret = [self preg_replace_lines:ret patternStr:@"" replaceStr:@""];

    /*
    //置き換え
    [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult* match, NSUInteger idx, BOOL *stop) {
        [workString replaceCharactersInRange:match.range withString:string];
    }];
    //削除
    [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult* match, NSUInteger idx, BOOL *stop) {
        [workString deleteCharactersInRange:match.range];
    }];
     */
    //ログ出力用
    __block NSString *log = @"\n変換後のコード:\n";
    __block int cnt = 1;
    [ret enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        t = [[NSString stringWithFormat:@"%d ", cnt] stringByAppendingString:line];
        log = [log stringByAppendingString:t];
        log = [log stringByAppendingString:@"\n"];
        cnt++;
    }];
    log = [log stringByAppendingString:@"\n"];
    global.logString = [global.logString stringByAppendingString:log];
    //NSLog(@"%@",ret);
    //global.logString = [@property (nonatomic, readwrite) NSString *logString;
    //NSLog(@"\n置換後のコード：\n%@",ret);
    return ret;
}

- (IBAction)onLaunchApplication:(id)sender { //実行ボタンを押した時
    //[self launchApplication];
}

- (IBAction)onLaunchApplicationNSTask:(id)sender {
    NSString *path = [self launchApplication_getPath];
    if (![path isEqual:@""]) {
        //多重起動を可能にする
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath:@"/usr/bin/open"];
        [task setArguments:[NSArray arrayWithObjects:(NSURL *) path, @"-n", nil]];
        [task launch];
        //NSLog(@"NSTaskで実行");
    }
}

- (IBAction)onLaunchApplicationNSWorkspace:(id)sender {
    NSString *path = [self launchApplication_getPath];
    if (![path isEqual:@""]) {
        //他の起動方法
        [[NSWorkspace sharedWorkspace] launchApplication:path];
        //NSLog(@"NSWorkspaceで実行");
    }
}

- (IBAction)onLaunchApplicationAppleScript:(id)sender {
    NSString *path = [self launchApplication_getPath];
    if (![path isEqual:@""]) {
        //AppleScriptを使用する方法
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *applescript_content = @"tell application \"";
        applescript_content = [applescript_content stringByAppendingString:path];
        applescript_content = [applescript_content stringByAppendingString:@"\"\n\tactivate\nend tell"];
        NSString *applescript_path = [NSString stringWithFormat:@"%@/hsptmp/applescript.scpt", documentsDirectory];
        [applescript_content writeToFile:applescript_path atomically:YES encoding:NSUTF8StringEncoding error:nil];
        NSURL *applescript_url = [NSURL fileURLWithPath:applescript_path];
        NSDictionary *errors = [NSDictionary dictionary];
        NSAppleScript *appleScript = [[NSAppleScript alloc] initWithContentsOfURL:(NSURL *) applescript_url error:&errors];
        [appleScript executeAndReturnError:nil];
        //NSLog(@"AppleScriptで実行");
    }
}

- (NSString *)launchApplication_getPath {
    global = (AppDelegate *) [[NSApplication sharedApplication] delegate];
    global.runtimeAccessNumber = accessNumber;
    global.logString = @"";
    global.isError = NO;

    //NSLog(@"%@",NSHomeDirectory());

    //Documents/hsptmpディレクトリにテキストを出力する
    //hsptmpディレクトリを作成する
    NSString *docDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    BOOL isDirectory;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *yoyoDir = [docDir stringByAppendingPathComponent:@"hsptmp"];
    if (![manager fileExistsAtPath:yoyoDir isDirectory:&isDirectory] || !isDirectory) {
        NSError *error = nil;
        [manager createDirectoryAtPath:yoyoDir
           withIntermediateDirectories:NO
                            attributes:nil
                                 error:&error];
        if (error) {
            NSLog(@"Error creating directory path: %@", [error localizedDescription]);
        }
    }

    //テキストを出力する
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@/hsptmp/hsptmp.hsp", documentsDirectory];
    NSString *content;
    if (global.globalTexts == nil || accessNumber == -1) {
        content = @"";
    } else {
        content = [global.globalTexts objectAtIndex:accessNumber];
    }

    if ([global.selectedSyntaxString isEqual:@"AltHSP"]) {
        content = [self convertAltHSP:content];
    }

    [content writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:nil];

    //コンパイルする(Documents/hsptmp/hsptmp.hsp -> start.ax)
    char *filename = (char *) [NSHomeDirectory() stringByAppendingString:@"/Documents/hsptmp/hsptmp.hsp"].UTF8String;
    char *axfilename = (char *) [[@"-o" stringByAppendingString:NSHomeDirectory()] stringByAppendingString:@"/Documents/hsptmp/start.ax"].UTF8String;
    char *argv[] = {(char *) "", axfilename, filename};
    [self runCompiler:3 argv:argv];

    if (global.isError) {
        return @"";
    }

    //パス情報を保存する
    fileName = [NSString stringWithFormat:@"%@/hsptmp/path.txt", documentsDirectory];
    content = global.currentPaths[accessNumber];
    [content writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:nil];

    //hsp.appを実行する
    //ディレクトリの確認 順序：1.Applications -> 2.Home/Applications -> 3.Home -> 4.Desktop -> 5.Downloads -> ...
    NSString *path = @"";
    NSString *check_path = @"";

    BOOL isDir = NO;
    BOOL isExists = NO;
    NSFileManager *filemanager = [NSFileManager defaultManager];

    //0.エディタと同じディレクトリ
    check_path = [[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent] stringByAppendingString:@"/hsp.app"];
    isExists = [filemanager fileExistsAtPath:check_path isDirectory:&isDir];
    if (isExists && isDir && [path isEqual:@""]) {
        path = check_path;
    }

    //1.Applications
    check_path = @"/Applications/hsp.app";
    isExists = [filemanager fileExistsAtPath:check_path isDirectory:&isDir];
    if (isExists && isDir && [path isEqual:@""]) {
        path = check_path;
    }

    //2.Home/Applications
    check_path = [NSHomeDirectory() stringByAppendingString:@"/Applications/hsp.app"];
    isExists = [filemanager fileExistsAtPath:check_path isDirectory:&isDir];
    if (isExists && isDir && [path isEqual:@""]) {
        path = check_path;
    }

    //3.Home
    check_path = [NSHomeDirectory() stringByAppendingString:@"/hsp.app"];
    isExists = [filemanager fileExistsAtPath:check_path isDirectory:&isDir];
    if (isExists && isDir && [path isEqual:@""]) {
        path = check_path;
    }

    //4.Desktop
    check_path = [NSHomeDirectory() stringByAppendingString:@"/Desktop/hsp.app"];
    isExists = [filemanager fileExistsAtPath:check_path isDirectory:&isDir];
    if (isExists && isDir && [path isEqual:@""]) {
        path = check_path;
    }

    //5.Downloads
    check_path = [NSHomeDirectory() stringByAppendingString:@"/Downloads/hsp.app"];
    isExists = [filemanager fileExistsAtPath:check_path isDirectory:&isDir];
    if (isExists && isDir && [path isEqual:@""]) {
        path = check_path;
    }

    //6.Resources
    check_path = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/hsp.app"];
    isExists = [filemanager fileExistsAtPath:check_path isDirectory:&isDir];
    if (isExists && isDir && [path isEqual:@""]) {
        path = check_path;
    }

    return path;
}

- (IBAction)onTerminateApplication:(id)sender { //停止ボタンを押した時
    //AppleScriptを使用する方法
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString *documentsDirectory = [paths objectAtIndex:0];
    //NSString *applescript_content = @"tell application \"hsp\"";
    //applescript_content = [applescript_content stringByAppendingString:@"\n\tquit\nend tell"];
    //NSString* applescript_path = [NSString stringWithFormat:@"%@/hsptmp/applescript.scpt",documentsDirectory];
    //[applescript_content writeToFile:applescript_path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    //NSURL* applescript_url = [NSURL fileURLWithPath:applescript_path];
    //NSDictionary* errors = [NSDictionary dictionary];
    //NSAppleScript* appleScript = [[NSAppleScript alloc] initWithContentsOfURL:(NSURL *)applescript_url error:&errors];
    //[appleScript executeAndReturnError:nil];

    //他の終了方法
    [self terminateApplication];
}

- (void)terminateApplication {
    [self terminateApplicationWithBundleID:@"com.dolphilia.hsp"];
}

- (BOOL)terminateApplicationWithBundleID:(NSString *)bundleID //アプリケーションを終了する
{
    // For OS X >= 10.6 NSWorkspace has the nifty runningApplications-method.
    if ([[NSWorkspace sharedWorkspace] respondsToSelector:@selector(runningApplications)])
        for (NSRunningApplication *app in [[NSWorkspace sharedWorkspace] runningApplications])
            if ([bundleID isEqualToString:[app bundleIdentifier]])
                return [app terminate];

    // If that didn‘t work then try using the apple event method, also works for OS X < 10.6.

    AppleEvent event = {typeNull, nil};
    const char *bundleIDString = [bundleID UTF8String];

    OSStatus result = AEBuildAppleEvent(kCoreEventClass, kAEQuitApplication, typeApplicationBundleID, bundleIDString, strlen(bundleIDString), kAutoGenerateReturnID, kAnyTransactionID, &event, NULL, "");

    if (result == noErr) {
        result = AESendMessage(&event, NULL, kAEAlwaysInteract | kAENoReply, kAEDefaultTimeout);
        AEDisposeDesc(&event);
    }
    return result == noErr;
}
@end
