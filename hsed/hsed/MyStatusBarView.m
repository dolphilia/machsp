//
//  MyStatusBarView.m
//  documentbasededitor
//
//  Created by dolphilia on 2016/02/20.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyStatusBarView.h"

@implementation MyStatusBarView

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {}
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor colorWithDeviceWhite:0.7 alpha:1] set];
    NSFrameRect(NSMakeRect(self.frame.origin.x, self.frame.origin.y + self.frame.size.height - 1, self.frame.size.width, 1));
}

@end