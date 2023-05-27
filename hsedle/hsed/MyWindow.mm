//
//  MyWindow.m
//  documentbasededitor
//
//  Created by dolphilia on 2016/01/31.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyWindow.h"
#import "AppDelegate.h"
#import "runCompiler.h"

@implementation MyWindow

//初期化する
-(void)awakeFromNib {
    global = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    if (global.logString == nil) {
        global.logString = @"";
    }
}

//ウィンドウ管理用の番号をセットする（外部用）
-(void)setAccessNumber:(int)num {
    accessNumber = num;
}

//実行ボタンを押した時
-(IBAction)onLaunchApplication:(id)sender {
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
        [manager createDirectoryAtPath:yoyoDir withIntermediateDirectories:NO attributes:nil error:&error];
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
    [self runCompiler:3 argv:argv];
    
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

@end
