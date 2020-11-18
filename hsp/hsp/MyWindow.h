//
//  MyWindow.h
//  objc-calayer-example
//
//  Created by dolphilia on 2016/02/01.
//  Copyright © 2016年 dolphilia. All rights reserved.
//
#ifndef MyWindow_h
#define MyWindow_h
#import <Cocoa/Cocoa.h>
#import "MyView.h"
#include "debug_message.h"
@interface MyWindow : NSWindow <NSWindowDelegate>{
    AppDelegate* g; //"g"lobal
}
@end
#endif /* MyWindow_h */