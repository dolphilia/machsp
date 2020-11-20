//
//  AppDelegate.h
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
}

// グローバル変数
@property (nonatomic, readwrite) int runtimeAccessNumber; //実行時のアクセスナンバー
@property (nonatomic, readwrite) BOOL isError; //エラーがあったか
@property (nonatomic, readwrite) NSString *logString;
@property (nonatomic, readwrite) NSString *currentPath; //現在のスクリプトファイルのあるパス
@property (nonatomic, readwrite) NSMutableArray *currentPaths;
@property (nonatomic, readwrite) NSMutableArray *globalTitles;
@property (nonatomic, readwrite) NSMutableArray *globalTexts;

@end

