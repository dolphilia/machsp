//
//  runCompiler.h
//  documentbasededitor
//
//  Created by dolphilia on 2016/02/26.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#ifndef runCompiler_h
#define runCompiler_h

#include <stdio.h>
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "MyWindow.h"

@interface MyWindow (run)

static void usage1(void);

- (int)runCompiler:(int)argc argv:(char **)argv;

- (void)testCompiler;

@end


#endif /* runCompiler_h */
