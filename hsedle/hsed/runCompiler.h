//
//  runCompiler.h
//  documentbasededitor
//
//  Created by dolphilia on 2016/02/26.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#ifndef runCompiler_h
#define runCompiler_h

#import <stdio.h>
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface runCompiler : NSObject  {
}

//static void usage1( void );
-(void)usage1;
-(int)runCompiler:(int)argc argv:(char **)argv;

@end


#endif /* runCompiler_h */
