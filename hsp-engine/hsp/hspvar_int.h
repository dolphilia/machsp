//
//  hspvar_int.h
//

#ifndef hspvar_int_h
#define hspvar_int_h


#include "hsp3struct.h"

void *hspvar_int_get_ptr(value_t *pval);
void *hspvar_int_cnv(const void *buffer, int flag);
int hspvar_int_get_var_size(value_t *pval);
void hspvar_int_free(value_t *pval);
void hspvar_int_alloc(value_t *pval, const value_t *pval2);
int hspvar_int_get_size(const void *pval);
void hspvar_int_set(value_t *pval, void *pdat, const void *in);
void hspvar_int_add_i(void *pval, const void *val);
void hspvar_int_sub_i(void *pval, const void *val);
void hspvar_int_mul_i(void *pval, const void *val);
void hspvar_int_div_i(void *pval, const void *val);
void hspvar_int_mod_i(void *pval, const void *val);
void hspvar_int_and_i(void *pval, const void *val);
void hspvar_int_or_i(void *pval, const void *val);
void hspvar_int_xor_i(void *pval, const void *val);
void hspvar_int_eq_i(void *pval, const void *val);
void hspvar_int_ne_i(void *pval, const void *val);
void hspvar_int_gt_i(void *pval, const void *val);
void hspvar_int_lt_i(void *pval, const void *val);
void hspvar_int_gt_eq_i(void *pval, const void *val);
void hspvar_int_lt_eq_i(void *pval, const void *val);
void hspvar_int_rr_i(void *pval, const void *val);
void hspvar_int_lr_i(void *pval, const void *val);
void *hspvar_int_get_block_size(value_t *pval, void *pdat, int *size);
void hspvar_int_alloc_block(value_t *pval, void *pdat, int size);
void hspvar_int_init(hspvar_proc_t *p);


#endif /* hspvar_int_h */
