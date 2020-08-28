
//
//	hsp3debug.cpp header
//
#ifndef __hsp3debug_h
#define __hsp3debug_h

#import "hsp3struct_debug.h"
#import "ViewController.h"
@interface
ViewController (hsp3debug) {
}

#ifdef FLAG_HSPDEBUG
-(char*)hspd_geterror:(HSPERROR)error;
#else
-(char*)hspd_geterror:(HSPERROR)error;
#endif

@end

#endif
