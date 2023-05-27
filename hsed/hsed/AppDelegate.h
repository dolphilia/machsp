//
//  AppDelegate.h
//  hsed
//
//  Created by dolphilia on 2016/03/12.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {

}

// グローバル変数
@property(readwrite, nonatomic) double documentVisibleX;
@property(readwrite, nonatomic) double documentVisibleY;
@property(readwrite, nonatomic) double documentVisibleWidth;
@property(readwrite, nonatomic) double documentVisibleHeight;

@property(nonatomic, readwrite) NSString *logString;
@property(nonatomic, readwrite) NSMutableArray *logStrings;
@property(nonatomic, readwrite) int runtimeAccessNumber; //実行時のアクセスナンバー
@property(nonatomic, readwrite) BOOL isError; //エラーがあったか

@property(nonatomic, readwrite) NSString *currentPath; //現在のスクリプトファイルのあるパス
@property(nonatomic, readwrite) NSMutableArray *currentPaths;

@property(nonatomic, readwrite) NSString *globalString;
@property(strong, nonatomic) NSMutableDictionary *globalDictionary;
@property(nonatomic, readwrite) NSMutableArray *globalTitles;
@property(nonatomic, readwrite) NSMutableArray *globalTexts;

@property(nonatomic, readwrite) NSString *selectedSyntaxString; //PopUpButton 構文の選択内容
@property(nonatomic, readwrite) NSString *selectedColorThemeString; //PopUpButton カラーテーマの選択内容
@property(nonatomic, readwrite) NSString *selectedFontSizeString; //PopUpButton 文字サイズの選択内容


//エディタ関連
@property(nonatomic, readwrite) int editorLineCount;
@property(nonatomic, readwrite) int editorTextCount;
//@property (nonatomic, readwrite) int editorLineIndex;
@property(nonatomic, readwrite) int editorSelectedTextCount;
@property(nonatomic, readwrite) int editorTextIndex;

@end

