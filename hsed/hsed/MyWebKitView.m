//
//  MyWebKitView.m
//  documentbasededitor
//
//  Created by dolphilia on 2016/02/20.
//  Copyright © 2016年 dolphilia. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MyWebKitView.h"
@implementation MyWebKitView
-(void)awakeFromNib {
    ////リソースのHTMLを表示する
    NSString* path = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    [self setMainFrameURL:path];
    ////URLを直接
//    NSString* urlString = @"https://dolphilia.github.io/?version=91";
//    [self setMainFrameURL:urlString];
    ////URLをリクエスト
    //NSURL* url = [NSURL URLWithString: urlString];
    //NSURLRequest* request = [NSURLRequest requestWithURL: url];
    //[[self mainFrame] loadRequest:request];
}
@end