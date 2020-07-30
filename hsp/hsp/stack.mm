
//
//	HSP3 stack support
//	(汎用スタックマネージャー)
//	(int,double,stringなどの可変長データをpush,popできます)
//	onion software/onitama 2004/6
//

#import "stack.h"

@implementation ViewController (stack)

- (void)StackInit {
    
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
    
}

- (void)StackTerm {
    
    [self StackReset];
    free(stack_mem_stm);
    
}

- (void)StackAlloc:(StackManagerData *)stm size:(int)size {
    
    if (size <= STM_STRSIZE_DEFAULT) {
        //		stm->mode = STMMODE_SELF;
        //		stm->ptr = (char *)&(stm->ival);
        
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
            
            return;
        case HSPVAR_FLAG_DOUBLE:
            // dptr = (double *)&stm->ival;
            //*dptr = *(double *)data;
            memcpy(&stm->ival, data, sizeof(double));
            //		stm->mode = STMMODE_SELF;
            //		stm->ptr = (char *)dptr;
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
    //	if ( stack_stm_cur >= stack_stm_maxptr ) throw HSPERR_STACK_OVERFLOW;
    stm = stack_stm_cur;
    stm->type = type;
    //	stm->mode = STMMODE_SELF;
    stm->ival = val;
    iptr = (int *)stm->itemp;
    *iptr = val2;
    stack_stm_cur++;
    
}

- (void)StackPushVar:(void *)pval aptr:(int)aptr {
    
    StackManagerData *stm;
    //	if ( stack_stm_cur >= stack_stm_maxptr ) throw HSPERR_STACK_OVERFLOW;
    stm = stack_stm_cur;
    stm->type = -1;  // HSPVAR_FLAG_VAR
    //	stm->mode = STMMODE_SELF;
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
