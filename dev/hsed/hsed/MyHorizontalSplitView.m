//
//  MySplitView.m
//  documentbasededitor
//
//  Created by dolphilia on 2016/01/31.
//  Copyright © 2016年 dolphilia. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MyHorizontalSplitView.h"
@implementation MyHorizontalSplitView {
}
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        //[[[self subviews] objectAtIndex:0] ;
        //[self can]
    }
    return self;
}
-(void)awakeFromNib {
    //splitviewの下部領域を非表示にする
    //[[[self subviews] objectAtIndex:1] setHidden:YES];
    //self.dividerStyle = NSSplitViewDividerStyleThin;
    //非表示の下部領域が隠されているかどうか
    BOOL rightViewCollapsed = [self isSubviewCollapsed:[[self subviews] objectAtIndex: 1]];
    if (rightViewCollapsed) { //隠されている
    } else {//表示されている
    }
}
@end