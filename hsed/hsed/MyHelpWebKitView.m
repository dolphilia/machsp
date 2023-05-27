//
//  MyHelpWebKitView.m
//  hsed
//
//  Created by dolphilia on 2016/04/13.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyHelpWebKitView.h"

@implementation MyHelpWebKitView

-(void)awakeFromNib {
    
    ////リソースのHTMLを表示する
    //NSString* path = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    //[self setMainFrameURL:path];
    
    ////URLを直接
    NSString* urlString = @"https://dolphilia.github.io/?version=99";
    [self setMainFrameURL:urlString];
    
    ////URLをリクエスト
    //NSURL* url = [NSURL URLWithString: urlString];
    //NSURLRequest* request = [NSURLRequest requestWithURL: url];
    //[[self mainFrame] loadRequest:request];
    
}

@end