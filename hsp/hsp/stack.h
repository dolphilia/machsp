
//
//	stack.cpp header
//

#ifndef __stack_h
#define __stack_h

#import <stdio.h>
#import <stdlib.h>
#import <string.h>
#import "debug_message.h"
#import "hsp3config.h"
#import "hsp3struct_debug.h"
#import "hsp3struct_var.h"

#define STM_MAX_DEFAULT 512
#define STM_STRSIZE_DEFAULT 64
#define STMMODE_SELF 0
#define STMMODE_ALLOC 1
#define STM_GETPTR(pp) (pp->ptr)
#define StackPeek (get_stack_stm_cur() - 1)
#define StackPeek2 (get_stack_stm_cur() - 2)
#define PeekPtr ((void *)(get_stack_stm_cur() - 1)->ptr)
#define StackGetLevel (get_stack_stm_cur() - get_stack_mem_stm())
#define StackDecLevel dec_stack_stm_cur()

#define STM_STRSIZE_DEFAULT 64

//    StackManagerData structure
//
//    Memory Data structure
//
typedef struct {
    short type;
    short mode;
    char *ptr;
    void *pval;
    int ival;
    char itemp[STM_STRSIZE_DEFAULT - 4]; // data area padding
} StackManagerData;

void StackInit();
void StackTerm();
void StackAlloc(StackManagerData *stm, int size);  // private
void StackReset();
void StackPush(int type, char *data, int size);
void StackPush2(int type, char *str);
void StackPushStr(char *str);
void StackPushTypeVal(int type, int val, int val2);
void StackPushVar(void *pval, int aptr);
void StackPushType(int type);
void StackPopFree();
void StackPushi(int val);
void StackPop();
void *StackPushSize(int type, int size);
StackManagerData *get_stack_stm_cur();
StackManagerData *get_stack_mem_stm();
void dec_stack_stm_cur();

#endif
