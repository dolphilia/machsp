
//
//	HSP3スタックサポート
//
//	(汎用スタックマネージャー)
//	(int,double,stringなどの可変長データをpush,popできます)
//	onion software/onitama 2004/6
//

#import "stack.h"

// stack.mm
int stack_stm_max;
stack_manager_t *stack_mem_stm;
stack_manager_t *stack_stm_cur;
stack_manager_t *stack_stm_maxptr;

void stack_init() {
    stack_manager_t *stm;
    stack_stm_max = STM_MAX_DEFAULT;
    stack_mem_stm = (stack_manager_t *) malloc(sizeof(stack_manager_t) * stack_stm_max);
    stack_stm_maxptr = stack_mem_stm + stack_stm_max;
    stack_stm_cur = stack_mem_stm;
    stm = stack_mem_stm;
    for (int i = 0; i < stack_stm_max; i++) {
        stm->type = HSPVAR_FLAG_INT;
        stm->mode = STMMODE_SELF;
        stm->ptr = (char *) &(stm->ival);
        stm++;
    }
}

void stack_free() {
    stack_reset();
    free(stack_mem_stm);
}

void stack_alloc(stack_manager_t *stm, int size) {
    if (size <= STM_STRSIZE_DEFAULT) {
        //		stm->mode = STMMODE_SELF;
        //		stm->ptr = (char *)&(stm->ival);
        return;
    }
    stm->mode = STMMODE_ALLOC;
    stm->ptr = (char *) malloc(size);
}

void stack_reset() {
    while (1) {
        if (stack_stm_cur == stack_mem_stm) break;
        stack_pop();
    }
}

void stack_push(int type, char *data, int size) {
    stack_manager_t *stm;
    // double *dptr;
    if (stack_stm_cur >= stack_stm_maxptr) {
        fprintf(stderr, "Error: %d\n", HSPERR_STACK_OVERFLOW);
        exit(EXIT_FAILURE);
    }
    stm = stack_stm_cur;
    stm->type = type;
    switch (type) {
        case HSPVAR_FLAG_LABEL:
        case HSPVAR_FLAG_INT:
            //		stm->mode = STMMODE_SELF;
            stm->ival = *(int *) data;
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
    stack_alloc(stm, size);
    memcpy(stm->ptr, data, size);
    stack_stm_cur++;
}

void stack_push2(int type, char *str) {
    stack_push(type, str, (int)strlen(str) + 1);
}

void *stack_push_size(int type, int size) {
    stack_manager_t *stm;
    if (stack_stm_cur >= stack_stm_maxptr) {
        fprintf(stderr, "Error: %d\n", HSPERR_STACK_OVERFLOW);
        exit(EXIT_FAILURE);
    }
    stm = stack_stm_cur;
    stm->type = type;
    stack_alloc(stm, size);
    stack_stm_cur++;
    return (void *) stm->ptr;
}

void stack_push_str(char *str) {
    stack_push(HSPVAR_FLAG_STR, str, (int)strlen(str) + 1);
}

void stack_push_type_val(int type, int val, int val2) {
    stack_manager_t *stm;
    int *iptr;
    //	if ( stack_stm_cur >= stack_stm_maxptr ) throw HSPERR_STACK_OVERFLOW;
    stm = stack_stm_cur;
    stm->type = type;
    //	stm->mode = STMMODE_SELF;
    stm->ival = val;
    iptr = (int *) stm->itemp;
    *iptr = val2;
    stack_stm_cur++;
}

void stack_push_var(void *pval, int aptr) {
    stack_manager_t *stm;
    //	if ( stack_stm_cur >= stack_stm_maxptr ) throw HSPERR_STACK_OVERFLOW;
    stm = stack_stm_cur;
    stm->type = -1;  // HSPVAR_FLAG_VAR
    //	stm->mode = STMMODE_SELF;
    stm->pval = pval;
    stm->ival = aptr;
    stack_stm_cur++;
}

void stack_push_type(int type) {
    stack_push_type_val(type, 0, 0);
}

void stack_pop_free() {
    free(stack_stm_cur->ptr);
    stack_stm_cur->mode = STMMODE_SELF;
    stack_stm_cur->ptr = (char *) &(stack_stm_cur->ival);
}

//void
//stack_pop_free(StackManagerData* stack_manager_data_current)
//{
//  free(stack_manager_data_current->ptr);
//  stack_manager_data_current->mode = STMMODE_SELF;
//  stack_manager_data_current->ptr = (char*)&(stack_manager_data_current->ival);
//}

void stack_push_int(int val) {
    //	if ( stack_stm_cur >= stack_stm_maxptr ) throw HSPERR_STACK_OVERFLOW;
    stack_stm_cur->type = HSPVAR_FLAG_INT;
    stack_stm_cur->ival = val;
    stack_stm_cur++;
}

void stack_push_label(int val) {
    //	if ( stack_stm_cur >= stack_stm_maxptr ) throw HSPERR_STACK_OVERFLOW;
    stack_stm_cur->type = HSPVAR_FLAG_LABEL;
    stack_stm_cur->ival = val;
    stack_stm_cur++;
}

void stack_push_double(double val) {
    double *dptr;
    //	if ( stack_stm_cur >= stack_stm_maxptr ) throw HSPERR_STACK_OVERFLOW;
    stack_stm_cur->type = HSPVAR_FLAG_DOUBLE;
    dptr = (double *) &stack_stm_cur->ival;
    *dptr = val;
    stack_stm_cur++;
}

void stack_pop() {
    //	if ( stack_stm_cur <= stack_mem_stm ) throw HSPERR_UNKNOWN_CODE;
    stack_stm_cur--;
    if (stack_stm_cur->mode) {
        stack_pop_free();
    }
}

stack_manager_t *get_stack_stm_cur() {
    return stack_stm_cur;
}

stack_manager_t *get_stack_mem_stm() {
    return stack_mem_stm;
}

void dec_stack_stm_cur() {
    stack_stm_cur--;
}
