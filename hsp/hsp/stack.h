//
//	stack.cpp header
//
#ifndef __stack_h
#define __stack_h
#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <stdio.h>
#import <stdlib.h>
#import <string.h>
#import "ViewController.h"
#import "debug_message.h"
#import "hsp3config.h"
#import "hsp3struct_debug.h"
#import "hsp3struct_var.h"
#define STM_MAX_DEFAULT 512
#define STM_STRSIZE_DEFAULT 64
#define STMMODE_SELF 0
#define STMMODE_ALLOC 1
#define STM_GETPTR(pp) (pp->ptr)
#define StackPeek (stack_stm_cur - 1)
#define StackPeek2 (stack_stm_cur - 2)
#define PeekPtr ((void *)(stack_stm_cur - 1)->ptr)
#define StackGetLevel (stack_stm_cur - stack_mem_stm)
#define StackDecLevel stack_stm_cur--
@interface ViewController (stack) {
}
- (void)StackInit;
- (void)StackTerm;
- (void)StackAlloc:(StackManagerData *)stm size:(int)size;  // private
- (void)StackReset;
- (void)StackPush:(int)type data:(char *)data size:(int)size;
- (void)StackPush:(int)type str:(char *)str;
- (void)StackPushStr:(char *)str;
- (void)StackPushTypeVal:(int)type val:(int)val val2:(int)val2;
- (void)StackPushVar:(void *)pval aptr:(int)aptr;
- (void)StackPushType:(int)type;
- (void)StackPopFree;
- (void)StackPushi:(int)val;
- (void)StackPop;
- (void *)StackPushSize:(int)type size:(int)size;
@end
#endif
