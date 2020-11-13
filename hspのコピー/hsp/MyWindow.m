//
//  MyWindow.m
//  objc-calayer-example
//
//  Created by dolphilia on 2016/02/01.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyWindow.h"

@implementation MyWindow

-(instancetype)initWithContentRect:(NSRect)contentRect
                         styleMask:(NSWindowStyleMask)style
                           backing:(NSBackingStoreType)bufferingType
                             defer:(BOOL)flag
{
    
    self = [super initWithContentRect:contentRect styleMask:style backing:bufferingType defer:flag];
    if(self) {
        g = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        g.backing_scale_factor = self.backingScaleFactor;
    }
    
    return self;
}

-(void)windowDidChangeBackingProperties:(NSNotification *)notification
{
    
    //解像度の変更を検知
    g.backing_scale_factor = self.backingScaleFactor;
    
}

@end
