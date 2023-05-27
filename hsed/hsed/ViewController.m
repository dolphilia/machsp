//
//  ViewController.m
//  hsed
//
//  Created by dolphilia on 2016/03/12.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //NSLog(@"aiueo");
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)onLaunchApplication:(id)sender {
    //NSLog(@"aaa");
    //[(MyWindow*)self.view.window launchApplication];
}

- (IBAction)onTerminateApplication:(id)sender {
    //[(MyWindow*)self.view.window terminateApplication];
}


- (IBAction)doSomething:(id)sender {
    //NSLog(@"doSomething");
    NSString *path = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    //[myWebKitView setMainFrameURL:path];


    //myTextViewから現在のカーソル位置にある単語を取得する
    NSString *curString = [myTextView getCorsorNearString];
    curString = [curString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
    //NSLog(@"%@",curString);

    ////URLをリクエスト
    //NSURL* url = [NSURL URLWithString: path];
    NSURL *fileURL = [NSURL fileURLWithPath:path]; // (2)
    NSString *filePath = [fileURL absoluteString];
    filePath = [filePath stringByAppendingString:@"?search="];
    filePath = [filePath stringByAppendingString:curString];
    //
    //NSLog(@"%@",filePath);
    if ([filePath isEqual:@""]) {

    } else {
        [myWebKitView setMainFrameURL:filePath];
    }


    //NSURLRequest* request = [NSURLRequest requestWithURL: url];
    //[[self mainFrame] loadRequest:request];
    //NSLog(@"The menu item's object is %@",[sender representedObject]);
}

@end
