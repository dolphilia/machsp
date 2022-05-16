//
//  Document.swift
//  hsedle_swift
//
//  Created by dolphilia on 2022/05/14.
//

import Cocoa
import Foundation

class Document: NSPersistentDocument {
    let global: AppDelegate = NSApplication.shared.delegate as! AppDelegate
    var accessNumber: Int = 0
    var title: NSString = ""
    //var aController: NSWindowController? = nil

    override init() {
        super.init()
        // サブクラス固有の初期化をここに追加する
    }

    override class var autosavesInPlace: Bool {
        return true
    }

    override func makeWindowControllers() {
        // ドキュメントウィンドウを含むストーリーボードを返す
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
        self.addWindowController(windowController)
        
        //
        title = windowController.window!.title as NSString
        global.globalTitles.add(title)
        
        windowController.window!.title = String(format:"%lu", global.globalTitles.count)
        
        title = windowController.window!.title as NSString
        accessNumber = Int(title as String)! - 1;
        
        if (self.fileURL?.absoluteURL == nil) {
            global.currentPaths.add("")
        } else {
            var path : NSString = self.fileURL!.deletingLastPathComponent().absoluteString as NSString
            path = substr(path, 5, path.length - 5)
            global.currentPaths.add(path)
        }
        
        let myTimer = Timer.scheduledTimer(timeInterval:5, target:self, selector:#selector(self.interval_func), userInfo:nil, repeats:true)
        myTimer.fire()
    }
    
    @objc private func interval_func() {
        if self.fileURL?.absoluteString != nil {
            var path: NSString = self.fileURL!.deletingLastPathComponent().absoluteString as NSString
            path = self.substr(path, 5, path.length - 5)
            let cur_path : String = global.currentPaths[accessNumber] as! String
            if cur_path == path as String {
            } else {
                global.currentPaths.replaceObject(at: accessNumber, with: path)
            }
        }
    }
    
    /// 文字列の部分文字列を返す
    ///
    func substr(_ in_str: NSString, _ index: Int, _ length: Int) -> NSString {
        let str: String = in_str as String
        if index > str.count || index + length > str.count {
            return ""
        }
        if index < 0 {
            return ""
        }
        return String(str[str.index(str.startIndex, offsetBy: index) ..< str.index(str.startIndex, offsetBy: index + length)]) as NSString
    }
    
    /// ファイルを保存する
    ///
    override func data(ofType typeName: String) throws -> Data {
        //NSAttributedString
        //let keys:[String] = [NSPlainTextDocumentType,NSDocumentTypeDocumentAttribute]
        //let dic : NSDictionary = NSDictionary.dictionaryWithValues(forKeys: [""]) as NSDictionary
        //NSDictionary * dic;
        //dic = [NSDictionary dictionaryWithObjectsAndKeys:NSPlainTextDocumentType, NSDocumentTypeDocumentAttribute,nil];
        let str : NSString = global.globalTexts.object(at:accessNumber) as! NSString
        let data = str.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: true)!
        return data;
    }
    
    
    /// ファイルを開く
    ///
    override func read(from data: Data, ofType typeName: String) throws {
        let attr:NSDictionary;
        //NSError *error = nil;
        let zNSAttributedStringObj:NSAttributedString = NSAttributedString(data: data, documentAttributes:attr)
    }
    - (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
        if (outError != NULL) {
        }
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys: NSPlainTextDocumentType, NSDocumentTypeDocumentAttribute, nil];
        NSDictionary *attr;
        NSError *error = nil;
        NSAttributedString * zNSAttributedStringObj = [[NSAttributedString alloc]initWithData:data options:dic documentAttributes:&attr error:&error];
        if (error != NULL) {
            NSLog(@"Error readFromData: %@",[error localizedDescription]);
            return NO;
        }
        
        [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
            while(YES) {
                if ([self->title isEqual:@"Window"]) {
                }
                else {
                    [self->global.globalTexts replaceObjectAtIndex:[self->title intValue]-1 withObject:[zNSAttributedStringObj string]];
                    break;
                }
                usleep(100000);
            }
        }];

        return YES;
    }
    
}
