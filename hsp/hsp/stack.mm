
//
//	HSP3 stack support
//	(汎用スタックマネージャー)
//	(int,double,stringなどの可変長データをpush,popできます)
//	onion software/onitama 2004/6
//

#import "stack.h"

@implementation ViewController (stack)

- (void)StackInit {
    DEBUG_IN;
    int i;
    StackManagerData *stm;
    
    stack_stm_max = STM_MAX_DEFAULT;
    stack_mem_stm =
    (StackManagerData *)malloc(sizeof(StackManagerData) * stack_stm_max);
    stack_stm_maxptr = stack_mem_stm + stack_stm_max;
    stack_stm_cur = stack_mem_stm;
    stm = stack_mem_stm;
    for (i = 0; i < stack_stm_max; i++) {
        stm->type = HSPVAR_FLAG_INT;
        stm->mode = STMMODE_SELF;
        stm->ptr = (char *)&(stm->ival);
        stm++;
    }
    DEBUG_OUT;
}

- (void)StackTerm {
    DEBUG_IN;
    [self StackReset];
    free(stack_mem_stm);
    DEBUG_OUT;
}

- (void)StackAlloc:(StackManagerData *)stm size:(int)size {
    DEBUG_IN;
    if (size <= STM_STRSIZE_DEFAULT) {
        //		stm->mode = STMMODE_SELF;
        //		stm->ptr = (char *)&(stm->ival);
        DEBUG_OUT;
        return;
    }
    stm->mode = STMMODE_ALLOC;
    stm->ptr = (char *)malloc(size);
    DEBUG_OUT;
}

- (void)StackReset {
    DEBUG_IN;
    while (1) {
        if (stack_stm_cur == stack_mem_stm) break;
        [self StackPop];
    }
    DEBUG_OUT;
}

- (void)StackPush:(int)type data:(char *)data size:(int)size {
    DEBUG_IN;
    StackManagerData *stm;
    // double *dptr;
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
            //		stm->mode = STMMODE_SELF;
            stm->ival = *(int *)data;
            //		stm->ptr = (char *)&(stm->ival);
            stack_stm_cur++;
            DEBUG_OUT;
            return;
        case HSPVAR_FLAG_DOUBLE:
            // dptr = (double *)&stm->ival;
            //*dptr = *(double *)data;
            memcpy(&stm->ival, data, sizeof(double));
            //		stm->mode = STMMODE_SELF;
            //		stm->ptr = (char *)dptr;
            stack_stm_cur++;
            DEBUG_OUT;
            return;
        default:
            break;
    }
    [self StackAlloc:stm size:size];
    memcpy(stm->ptr, data, size);
    stack_stm_cur++;
    DEBUG_OUT;
}

- (void)StackPush:(int)type str:(char *)str {
    DEBUG_IN;
    [self StackPush:type data:str size:(int)strlen(str) + 1];
    DEBUG_OUT;
}

- (void *)StackPushSize:(int)type size:(int)size {
    DEBUG_IN;
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
    DEBUG_OUT;
}

- (void)StackPushStr:(char *)str {
    DEBUG_IN;
    [self StackPush:HSPVAR_FLAG_STR data:str size:(int)strlen(str) + 1];
    DEBUG_OUT;
}

- (void)StackPushTypeVal:(int)type val:(int)val val2:(int)val2 {
    DEBUG_IN;
    StackManagerData *stm;
    int *iptr;
    //	if ( stack_stm_cur >= stack_stm_maxptr ) throw HSPERR_STACK_OVERFLOW;
    stm = stack_stm_cur;
    stm->type = type;
    //	stm->mode = STMMODE_SELF;
    stm->ival = val;
    iptr = (int *)stm->itemp;
    *iptr = val2;
    stack_stm_cur++;
    DEBUG_OUT;
}

- (void)StackPushVar:(void *)pval aptr:(int)aptr {
    DEBUG_IN;
    StackManagerData *stm;
    //	if ( stack_stm_cur >= stack_stm_maxptr ) throw HSPERR_STACK_OVERFLOW;
    stm = stack_stm_cur;
    stm->type = -1;  // HSPVAR_FLAG_VAR
    //	stm->mode = STMMODE_SELF;
    stm->pval = pval;
    stm->ival = aptr;
    stack_stm_cur++;
    DEBUG_OUT;
}

- (void)StackPushType:(int)type {
    DEBUG_IN;
    [self StackPushTypeVal:type val:0 val2:0];
    DEBUG_OUT;
}

- (void)StackPopFree {
    DEBUG_IN;
    free(stack_stm_cur->ptr);
    stack_stm_cur->mode = STMMODE_SELF;
    stack_stm_cur->ptr = (char *)&(stack_stm_cur->ival);
    DEBUG_OUT;
}

//void
//stack_pop_free(StackManagerData* stack_manager_data_current)
//{
//  free(stack_manager_data_current->ptr);
//  stack_manager_data_current->mode = STMMODE_SELF;
//  stack_manager_data_current->ptr = (char*)&(stack_manager_data_current->ival);
//}

- (void)StackPushi:(int)val {
    //	if ( stack_stm_cur >= stack_stm_maxptr ) throw HSPERR_STACK_OVERFLOW;
    stack_stm_cur->type = HSPVAR_FLAG_INT;
    stack_stm_cur->ival = val;
    stack_stm_cur++;
}

- (void)StackPushl:(int)val {
    //	if ( stack_stm_cur >= stack_stm_maxptr ) throw HSPERR_STACK_OVERFLOW;
    stack_stm_cur->type = HSPVAR_FLAG_LABEL;
    stack_stm_cur->ival = val;
    stack_stm_cur++;
}

- (void)StackPushd:(double)val {
    double *dptr;
    //	if ( stack_stm_cur >= stack_stm_maxptr ) throw HSPERR_STACK_OVERFLOW;
    stack_stm_cur->type = HSPVAR_FLAG_DOUBLE;
    dptr = (double *)&stack_stm_cur->ival;
    *dptr = val;
    stack_stm_cur++;
}

- (void)StackPop {
    //	if ( stack_stm_cur <= stack_mem_stm ) throw HSPERR_UNKNOWN_CODE;
    stack_stm_cur--;
    if (stack_stm_cur->mode) {
        [self StackPopFree];
    }
}

@end
