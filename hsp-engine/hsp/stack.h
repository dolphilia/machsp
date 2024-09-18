
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
} stack_manager_t;

void stack_init();
void stack_free();
void stack_alloc(stack_manager_t *stm, int size);  // private
void stack_reset();
void stack_push(int type, char *data, int size);
void stack_push2(int type, char *str);
void stack_push_str(char *str);
void stack_push_type_val(int type, int val, int val2);
void stack_push_var(void *pval, int aptr);
void stack_push_type(int type);
void stack_pop_free();
void stack_push_int(int val);
void stack_pop();
void *stack_push_size(int type, int size);
stack_manager_t *get_stack_stm_cur();
stack_manager_t *get_stack_mem_stm();
void dec_stack_stm_cur();

#endif
