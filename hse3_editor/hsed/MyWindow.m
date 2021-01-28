//
//  MyWindow.m
//
#import <Foundation/Foundation.h>
#import "MyWindow.h"
#import "AppDelegate.h"
//#import "runCompiler.h"
@implementation MyWindow
-(void)awakeFromNib //初期化する
{
    global = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    if (global.logString == nil) {
        global.logString = @"";
    }
}
-(void)setAccessNumber:(int)num //ウィンドウ管理用の番号をセットする（外部用）
{
    accessNumber = num;
}
-(IBAction)onLaunchApplication:(id)sender //実行ボタンを押した時
{
    global = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    global.runtimeAccessNumber = accessNumber;
    global.logString = @"";
    global.isError = NO;
    //Documents/hsptmpディレクトリにテキストを出力する
    //hsptmpディレクトリを作成する
    NSString *docDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    BOOL isDirectory;
    NSFileManager* manager = [NSFileManager defaultManager];
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
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@/hsptmp/hsptmp.hsp",documentsDirectory];
    NSString *content;
    if(global.globalTexts == nil || accessNumber == -1) {
        content = @"";
    }
    else {
        content = [global.globalTexts objectAtIndex:accessNumber];
    }
    [content writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:nil];
    //コンパイルする(Documents/hsptmp/hsptmp.hsp -> start.ax)
    char * filename = (char *)[NSHomeDirectory() stringByAppendingString:@"/Documents/hsptmp/hsptmp.hsp"].UTF8String;
    char * axfilename = (char *)[[@"-o" stringByAppendingString:NSHomeDirectory()] stringByAppendingString:@"/Documents/hsptmp/start.ax"].UTF8String;
    char *argv[] = {(char*)"",axfilename,filename};
    //[self runCompiler:3 argv:argv];
    if(global.isError) {
        return;
    }
    //パス情報を保存する
    fileName = [NSString stringWithFormat:@"%@/hsptmp/path.txt",documentsDirectory];
    content = global.currentPaths[accessNumber];
    [content writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:nil];
    //hsp.appを実行する
    //ディレクトリの確認 順序：1.Applications -> 2.Home/Applications -> 3.Home -> 4.Desktop -> 5.Downloads -> ...
    NSString* path = @"";
    NSString* check_path = @"";
    BOOL isDir = NO;
    BOOL isExists = NO;
    NSFileManager *filemanager = [ NSFileManager defaultManager];
    //0.エディタと同じディレクトリ
    check_path = [[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent] stringByAppendingString:@"/hsp.app"];
    isExists = [filemanager fileExistsAtPath:check_path isDirectory:&isDir];
    if(isExists && isDir && [path isEqual:@""]) {
        path = check_path;
    }
    //1.Applications
    check_path = @"/Applications/hsp.app";
    isExists = [filemanager fileExistsAtPath:check_path isDirectory:&isDir];
    if(isExists && isDir && [path isEqual:@""]) {
        path = check_path;
    }
    //2.Home/Applications
    check_path = [NSHomeDirectory() stringByAppendingString:@"/Applications/hsp.app"];
    isExists = [filemanager fileExistsAtPath:check_path isDirectory:&isDir];
    if(isExists && isDir && [path isEqual:@""]) {
        path = check_path;
    }
    //3.Home
    check_path = [NSHomeDirectory() stringByAppendingString:@"/hsp.app"];
    isExists = [filemanager fileExistsAtPath:check_path isDirectory:&isDir];
    if(isExists && isDir && [path isEqual:@""]) {
        path = check_path;
    }
    //4.Desktop
    check_path = [NSHomeDirectory() stringByAppendingString:@"/Desktop/hsp.app"];
    isExists = [filemanager fileExistsAtPath:check_path isDirectory:&isDir];
    if(isExists && isDir && [path isEqual:@""]) {
        path = check_path;
    }
    //5.Downloads
    check_path = [NSHomeDirectory() stringByAppendingString:@"/Downloads/hsp.app"];
    isExists = [filemanager fileExistsAtPath:check_path isDirectory:&isDir];
    if(isExists && isDir && [path isEqual:@""]) {
        path = check_path;
    }
    //6.Resources
    check_path = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/hsp.app"];
    isExists = [filemanager fileExistsAtPath:check_path isDirectory:&isDir];
    if(isExists && isDir && [path isEqual:@""]) {
        path = check_path;
    }
    if(![path isEqual:@""]) {
        //多重起動を可能にする
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath:@"/usr/bin/open"];
        [task setArguments:[NSArray arrayWithObjects:(NSURL *)path, @"-n", nil]];
        [task launch];
        //他の起動方法
        //[[NSWorkspace sharedWorkspace] launchApplication:path];
    }
}
//---- 文字列操作のためのユーティリティ
-(NSString*)charAt:(NSString*)str index:(int)index //文字列の指定位置で指定された位置の文字を返す
{
    if (index>=str.length) {
        return @"";
    }
    if (index<0) return @"";
    return [str substringWithRange:NSMakeRange(index, 1)];
}
-(NSString*)substr:(NSString*)str index:(int)index length:(int)length //文字列の部分文字列を返す
{
    if (index>=str.length || index+length>=str.length) {
        return @"";
    }
    if (index<0) return @"";
    return [str substringWithRange:NSMakeRange(index, length)];
}
-(int)indexOf:(NSString*)str searchStr:(NSString*)searchStr
{
    if (str.length < searchStr.length) {
        return -1;
    }
    return (int)[str rangeOfString:searchStr].location;
}
-(int)indexOf:(NSString*)str searchStr:(NSString*)searchStr location:(int)location
{
    if (str.length < location+searchStr.length) {
        return -1;
    }
    return (int)[str rangeOfString:searchStr options:0 range:NSMakeRange(location, str.length-location)].location;
}
-(BOOL)isSpaceCharacter:(NSString*)str
{
    if ( [str isEqual:@" "] || [str isEqual:@"\t"] || [str isEqual:@"\f"] || [str isEqual:@"\n"] || [str isEqual:@"\r"] || [str isEqual:@"\v"]) {
        return YES;
    }
    else {
        return NO;
    }
}
-(BOOL)isOperatorCharacter:(NSString*)str
{
    if ( [str isEqual:@"+"] || [str isEqual:@"-"] || [str isEqual:@"*"] || [str isEqual:@"/"] || [str isEqual:@"\\"] || [str isEqual:@"="] || [str isEqual:@"&"] || [str isEqual:@"|"] || [str isEqual:@"^"] || [str isEqual:@"<"] || [str isEqual:@">"] || [str isEqual:@"!"]) {
        return YES;
    }
    else {
        return NO;
    }
}
-(NSString*)replace:(NSString*)str searchStr:(NSString*)searchStr replaceStr:(NSString*)replaceStr
{
    return [str stringByReplacingOccurrencesOfString:searchStr withString:replaceStr];
}
-(NSString*)preg_replace:(NSString*)str patternStr:(NSString*)patternStr replaceStr:(NSString*)replaceStr
{
    NSError *error = nil;
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:patternStr options:0 error:&error];
    NSString *new_str = [regexp stringByReplacingMatchesInString:str options:0 range:NSMakeRange(0, str.length) withTemplate:replaceStr];
    return new_str;
}
-(NSString*)preg_replace_lines:(NSString *)str patternStr:(NSString *)patternStr replaceStr:(NSString *)replaceStr
{
    __block NSString* tmpstr = @"";
    __block NSString* t = @"";
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
-(BOOL)preg_match:(NSString*)str patternStr:(NSString*)patternStr
{
    BOOL ret = NO;
    NSError* error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:patternStr options:0 error:&error];
    NSArray * matches = [regex matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    if ([matches isEqual:nil]) {}
    else {
        if (matches.count > 0) {
            ret = YES;
        }
    }
    return ret;
}
-(NSString*)trim:(NSString*)str
{
    return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}
-(NSString*)append:(NSString*)str append:(NSString*)append
{
    return [str stringByAppendingString:append];
}
-(NSString*)trimAllLines:(NSString*)str //すべての行をtrimする
{
    __block NSString* tmpstr = @"";
    [str enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        tmpstr = [tmpstr stringByAppendingString:[self trim:line]];
        tmpstr = [tmpstr stringByAppendingString:@"\n"];
    }];
    return tmpstr;
}
-(NSString*)deleteBlankLineAllLines:(NSString*)str //すべての行から空行を取り除く
{
    __block NSString* tmpstr = @"";
    [str enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        if ([line isEqual:@""]){}
        else {
            tmpstr = [tmpstr stringByAppendingString:line];
            tmpstr = [tmpstr stringByAppendingString:@"\n"];
        }
    }];
    return tmpstr;
}
@end
