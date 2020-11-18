//
//  MyWindow.h
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
