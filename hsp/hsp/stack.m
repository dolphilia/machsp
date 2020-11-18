
//
//	HSP3 stack support
//	(汎用スタックマネージャー)
//	(int,double,stringなどの可変長データをpush,popできます)
//	onion software/onitama 2004/6
//
#import "stack.h"
@implementation ViewController (stack)
- (void)StackInit {
    StackManagerData *stm;
    stack_stm_max = STM_MAX_DEFAULT;
    stack_mem_stm =
    (StackManagerData *)malloc(sizeof(StackManagerData) * stack_stm_max);
    stack_stm_maxptr = stack_mem_stm + stack_stm_max;
    stack_stm_cur = stack_mem_stm;
    stm = stack_mem_stm;
    for (int i = 0; i < stack_stm_max; i++) {
        stm->type = HSPVAR_FLAG_INT;
        stm->mode = STMMODE_SELF;
        stm->ptr = (char *)&(stm->ival);
        stm++;
    }
}
- (void)StackTerm {
    [self StackReset];
    free(stack_mem_stm);
}
- (void)StackAlloc:(StackManagerData *)stm size:(int)size {
    if (size <= STM_STRSIZE_DEFAULT) {
        return;
    }
    stm->mode = STMMODE_ALLOC;
    stm->ptr = (char *)malloc(size);
}
- (void)StackReset {
    while (1) {
        if (stack_stm_cur == stack_mem_stm) break;
        [self StackPop];
    }
}
- (void)StackPush:(int)type data:(char *)data size:(int)size {
    StackManagerData *stm;
    if (stack_stm_cur >= stack_stm_maxptr) {
        NSString *error_str =
        [NSString stringWithFormat:@"%d", HSPERR_STACK_OVERFLOW];
        @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
    }
    stm = stack_stm_cur;
    stm->type = type;
    switch (type) {
        case HSPVAR_FLAG_LABEL:
        case HSPVAR_FLAG_INT:
            stm->ival = *(int *)data;
            stack_stm_cur++;
            return;
        case HSPVAR_FLAG_DOUBLE:
            memcpy(&stm->ival, data, sizeof(double));
            stack_stm_cur++;
            return;
        default:
            break;
    }
    [self StackAlloc:stm size:size];
    memcpy(stm->ptr, data, size);
    stack_stm_cur++;
}
- (void)StackPush:(int)type str:(char *)str {
    [self StackPush:type data:str size:(int)strlen(str) + 1];
}
- (void *)StackPushSize:(int)type size:(int)size {
    StackManagerData *stm;
    if (stack_stm_cur >= stack_stm_maxptr) {
        NSString *error_str =
        [NSString stringWithFormat:@"%d", HSPERR_STACK_OVERFLOW];
        @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
    }
    stm = stack_stm_cur;
    stm->type = type;
    [self StackAlloc:stm size:size];
    stack_stm_cur++;
    return (void *)stm->ptr;
}
- (void)StackPushStr:(char *)str {
    [self StackPush:HSPVAR_FLAG_STR data:str size:(int)strlen(str) + 1];
}
- (void)StackPushTypeVal:(int)type val:(int)val val2:(int)val2 {
    StackManagerData *stm;
    int *iptr;
    stm = stack_stm_cur;
    stm->type = type;
    stm->ival = val;
    iptr = (int *)stm->itemp;
    *iptr = val2;
    stack_stm_cur++;
}
- (void)StackPushVar:(void *)pval aptr:(int)aptr {
    StackManagerData *stm;
    stm = stack_stm_cur;
    stm->type = -1;  // HSPVAR_FLAG_VAR
    stm->pval = pval;
    stm->ival = aptr;
    stack_stm_cur++;
}
- (void)StackPushType:(int)type {
    [self StackPushTypeVal:type val:0 val2:0];
}
- (void)StackPopFree {
    free(stack_stm_cur->ptr);
    stack_stm_cur->mode = STMMODE_SELF;
    stack_stm_cur->ptr = (char *)&(stack_stm_cur->ival);
}
- (void)StackPushi:(int)val {
    stack_stm_cur->type = HSPVAR_FLAG_INT;
    stack_stm_cur->ival = val;
    stack_stm_cur++;
}
- (void)StackPushl:(int)val {
    stack_stm_cur->type = HSPVAR_FLAG_LABEL;
    stack_stm_cur->ival = val;
    stack_stm_cur++;
}
- (void)StackPushd:(double)val {
    double *dptr;
    stack_stm_cur->type = HSPVAR_FLAG_DOUBLE;
    dptr = (double *)&stack_stm_cur->ival;
    *dptr = val;
    stack_stm_cur++;
}
- (void)StackPop {
    stack_stm_cur--;
    if (stack_stm_cur->mode) {
        [self StackPopFree];
    }
}
@end
