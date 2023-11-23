//
// runCompiler.h
//

#ifndef runCompiler_h
#define runCompiler_h

#include <stdio.h>
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "MyWindow.h"
#import "c_wrapper.h"

@interface MyWindow (run) {
}

static void usage1(void);

- (int)runCompiler:(int)argc argv:(char **)argv;

@end

#endif /* runCompiler_h */
