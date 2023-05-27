//
//  AppDelegate.m
//  hsed
//
//  Created by dolphilia on 2016/03/12.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application

//    //---- macOS Sierra対策
//    NSOperatingSystemVersion version = [[NSProcessInfo processInfo] operatingSystemVersion];
//    BOOL isDir = NO;
//    BOOL isExists = NO;
//    NSString *docDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
//    NSFileManager *filemanager = [NSFileManager defaultManager];
//    NSString* path = [docDir stringByAppendingString:@"/hsptmp/is_run.txt"];
//    isExists = [filemanager fileExistsAtPath:path isDirectory:&isDir];
//    if((int)version.majorVersion <= 10 &&
//       (int)version.minorVersion <= 12 &&
//       isExists == NO) //is_run.txtがDocuments/hsptmpに存在しない
//    {
//        NSAlert *alert = [[NSAlert alloc] init];
//        [alert setMessageText:@"macOS Sierra以降をお使いの皆さまへ"];
//        [alert setInformativeText:@"当アプリケーションはmacOS Sierraに対応していません。\nターミナル上で、\n\n$ sudo spctl --master-disable\n\nを実行してGatekeeperをオフにした上で、システム環境設定 > セキュリティとプライバシー > すべてのアプリケーションを許可 にチェックを入れることで使用可能になりますが、セキュリティの危険を伴いますので自己責任でお願いします。"];
//        [alert addButtonWithTitle:@"OK"];
//        [alert runModal];
//        //Documents/hsptmpディレクトリにテキストを出力する
//        //hsptmpディレクトリを作成する
//        BOOL isDirectory;
//        NSFileManager* manager = [NSFileManager defaultManager];
//        NSString *yoyoDir = [docDir stringByAppendingPathComponent:@"hsptmp"];
//        if (![manager fileExistsAtPath:yoyoDir isDirectory:&isDirectory] || !isDirectory) {
//            NSError *error = nil;
//            [manager createDirectoryAtPath:yoyoDir
//               withIntermediateDirectories:NO
//                                attributes:nil
//                                     error:&error];
//            if (error) {
//                NSLog(@"Error creating directory path: %@", [error localizedDescription]);
//            }
//        }
//        //テキストを出力する
//        NSArray *paths = NSSearchPathForDirectoriesInDomains
//        (NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentsDirectory = [paths objectAtIndex:0];
//        NSString *fileName = [NSString stringWithFormat:@"%@/hsptmp/is_run.txt",documentsDirectory];
//        NSString *content = @"";
//        [content writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:nil];
//    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
