//
//  MyScrollView.m
//  nstextview-fontcolor-test
//
//  Created by dolphilia on 2016/01/25.
//  Copyright © 2016年 dolphilia. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MyScrollView.h"
#import "MyTextView.h"
@implementation MyScrollView
- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    global = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    if (self) {
        //マルチスレッドで随時、コンテンツの表示位置を格納
        //[[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        //    while (YES) {
                //global.documentVisibleX = self.contentView.documentVisibleRect.origin.x;
                //global.documentVisibleY = self.contentView.documentVisibleRect.origin.y;
                //global.documentVisibleWidth = self.contentView.documentVisibleRect.size.width;
                //global.documentVisibleHeight = self.contentView.documentVisibleRect.size.height;
                //NSLog(@"%f",self.contentView.documentVisibleRect.origin.y);
                //printf("%f\n",self.subviews[0].subviews[0].frame.size.height);
                //printf("%f\n",self.contentView.frame.height);
        //        usleep(10000);
        //    }
        //}];
        [_contentView setPostsBoundsChangedNotifications:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(boundsDidChange:) name:NSViewBoundsDidChangeNotification object:_contentView];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrool1:) name:NSScrollViewWillStartLiveMagnifyNotification object:_contentView];
//        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrool2:) name:NSScrollViewDidEndLiveMagnifyNotification object:_contentView];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrool3:) name:NSScrollViewWillStartLiveScrollNotification object:_contentView];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrool4:) name:NSScrollViewDidLiveScrollNotification object:_contentView];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrool5:) name:NSScrollViewDidEndLiveScrollNotification object:_contentView];
    }
    return self;
}
//-(void)scrool1:(NSNotification *)notification {NSLog(@"1");}
//-(void)scrool2:(NSNotification *)notification {NSLog(@"2");}
//-(void)scrool3:(NSNotification *)notification {NSLog(@"3");}
//-(void)scrool4:(NSNotification *)notification {NSLog(@"4");}
//-(void)scrool5:(NSNotification *)notification {NSLog(@"5");}
-(void)boundsDidChange:(NSNotification *)notification { //スクロールした時
//    MyTextView* myTextView = self.subviews[0].subviews[2];
//    if (myTextView->isOperationChangeColor == NO) {
//        if ([global.selectedColorThemeString isEqual:@"hsed3le"]) {
//            [myTextView resetTextColor];
//        }
//        else {
//            [myTextView updateTextColor];
//        }
//    }
}
- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //NSLog(@"init frame");
    }
    return self;
}
@end