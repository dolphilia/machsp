//
//  AppDelegate.swift
//  hsedle_swift
//
//  Created by dolphilia on 2022/05/14.
//

import Cocoa

//@main
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    // グローバル変数
    var runtimeAccessNumber: Int = 0 //実行時のアクセスナンバー
    var isError: Bool = false //エラーがあったか
    var logString: NSString = ""
    var currentPath: NSString = "" //現在のスクリプトファイルのあるパス
    var currentPaths: NSMutableArray = []
    var globalTitles: NSMutableArray = []
    var globalTexts: NSMutableArray = []
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // アプリケーションを初期化するコードをここに挿入する
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // アプリケーションを破棄するコードをここに挿入する
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

}

