//
//  Document.m
//  hsed
//
//  Created by dolphilia on 2016/03/12.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#import "Document.h"

@interface Document ()

@end

@implementation Document

- (NSString *)substr:(NSString *)str index:(int)index length:(int)length { //文字列の部分文字列を返す
    if (index > str.length || index + length > str.length) {
        return @"";
    }
    if (index < 0) return @"";
    return [str substringWithRange:NSMakeRange(index, length)];
}

- (instancetype)init {
    self = [super init];
    accessNumber = 0;
    if (self) {
        // Add your subclass-specific initialization here.

        aController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"Document Window Controller"];
        title = @"Window";
        global = (AppDelegate *) [[NSApplication sharedApplication] delegate];
        global.runtimeAccessNumber = 0;
        if (global.currentPaths == nil) {
            global.currentPaths = [[NSMutableArray alloc] initWithCapacity:0];
        }
        if (global.logString == nil) {
            global.logString = @"";
        }
        if (global.logStrings == nil) {
            global.logStrings = [[NSMutableArray alloc] initWithCapacity:0];
        }
        if (global.globalTitles == nil) {
            global.globalTitles = [[NSMutableArray alloc] initWithCapacity:0];
        }
        if (global.globalTexts == nil) {
            global.globalTexts = [[NSMutableArray alloc] initWithCapacity:0];
        }
        [global.globalTexts addObject:@"__NULL__=0"];
    }
    return self;
}

- (void)windowControllerDidLoadNib:(NSWindowController *)_aController {
    [super windowControllerDidLoadNib:_aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.

}

+ (BOOL)autosavesInPlace {
    return YES;
}

- (void)makeWindowControllers {
    [self addWindowController:aController];

    title = [aController window].title;
    [global.globalTitles addObject:title];

    [global.logStrings addObject:@""];//ログメッセージよう

    [aController window].title = [NSString stringWithFormat:@"%lu", (unsigned long) global.globalTitles.count];
    title = [aController window].title;
    accessNumber = [title intValue] - 1;

    if ([self.fileURL absoluteString] == nil) {
        [global.currentPaths addObject:@""];
    } else {
        NSString *path = [[self.fileURL absoluteString] stringByDeletingLastPathComponent];
        path = [self substr:path index:5 length:(int) path.length - 5];
        [global.currentPaths addObject:path];
    }
    // タイマー
    NSTimer *tm = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self
                                                 selector:@selector(onTimer:) userInfo:nil repeats:YES];
    [tm fire];
}

- (void)onTimer:(NSTimer *)timer {
    if ([self.fileURL absoluteString] != nil) {
        NSString *path = [[self.fileURL absoluteString] stringByDeletingLastPathComponent];
        path = [self substr:path index:5 length:(int) path.length - 5];
        if ([global.currentPaths[accessNumber] isEqual:path]) {}
        else {
            [global.currentPaths replaceObjectAtIndex:accessNumber withObject:path];
        }
    }
}

- (NSDocument *)duplicateAndReturnError:(NSError *_Nullable __autoreleasing *)outError {
    return self;
}

- (void)duplicateDocument:(id)sender {
}

- (void)duplicateDocumentWithDelegate:(id)delegate didDuplicateSelector:(SEL)didDuplicateSelector contextInfo:(void *)contextInfo {
}

- (void)lockDocument:(id)sender {
}

- (void)lockDocumentWithCompletionHandler:(void (^)(BOOL))completionHandler {
}

- (void)lockWithCompletionHandler:(void (^)(NSError *_Nullable))completionHandler {
}

//-(void)autosaveDocumentWithDelegate:(id)delegate didAutosaveSelector:(SEL)didAutosaveSelector contextInfo:(void *)contextInfo {
//    //ファイルを自動保存する
//}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    //ファイルを保存する

    //    if (outError != NULL) {
    //    }

    NSDictionary *dic;
    //if ([typeName compare:@"public.plain-text"] == NSOrderedSame || [typeName compare:@"com.hsp-source"] == NSOrderedSame ) {
    dic = [NSDictionary dictionaryWithObjectsAndKeys:NSPlainTextDocumentType, NSDocumentTypeDocumentAttribute, nil];
    //} else {
    //    NSLog(@"ERROR: dataOfType pTypeName=%@",typeName);
    //    *outError = [NSError errorWithDomain:NSOSStatusErrorDomain
    //                                     code:unimpErr
    //                                 userInfo:NULL];
    //    return NULL;
    //}


    NSString *str = [global.globalTexts objectAtIndex:accessNumber];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];

    return data;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    //ファイルを開く

    //[]
    //NSLog(@"%@",self.fileURL);

    if (outError != NULL) {
    }

    //    if ([typeName compare:@"public.plain-text"] != NSOrderedSame || [typeName compare:@"com.hsp-source"] != NSOrderedSame) {
    //        NSLog(@"エラーが発生しました:%@",typeName);
    //        return NO;
    //    }

    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
            NSPlainTextDocumentType,
            NSDocumentTypeDocumentAttribute,
                    nil];
    NSDictionary *attr;
    NSError *error = nil;
    NSAttributedString *zNSAttributedStringObj =
            [[NSAttributedString alloc] initWithData:data
                                             options:dic
                                  documentAttributes:&attr
                                               error:&error];
    if (error != NULL) {
        NSLog(@"Error readFromData: %@", [error localizedDescription]);
        return NO;
    }

    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        while (YES) {
            if ([title isEqual:@"Window"]) {
            } else {
                [global.globalTexts replaceObjectAtIndex:[title intValue] - 1 withObject:[zNSAttributedStringObj string]];
                break;
            }
            usleep(100000);
        }
    }];

    return YES;
}

@end
