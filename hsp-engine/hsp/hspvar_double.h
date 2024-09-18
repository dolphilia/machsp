//
//  hspvar_double.h
//

#ifndef hspvar_double_h
#define hspvar_double_h

#import "hsp3struct.h"

void *hspvar_double_get_ptr(value_t *pval);
void *hspvar_double_cnv(const void *buffer, int flag);
int hspvar_double_get_var_size(value_t *pval);
void hspvar_double_free(value_t *pval);
void hspvar_double_alloc(value_t *pval, const value_t *pval2);
int hspvar_double_get_size(const void *pval);
void hspvar_double_set(value_t *pval, void *pdat, const void *in);
void hspvar_double_add_i(void *pval, const void *val);
void hspvar_double_sub_i(void *pval, const void *val);
void hspvar_double_mul_i(void *pval, const void *val);
void hspvar_double_div_i(void *pval, const void *val);
void hspvar_double_mod_i(void *pval, const void *val);
void hspvar_double_eq_i(void *pval, const void *val);
void hspvar_double_ne_i(void *pval, const void *val);
void hspvar_double_gt_i(void *pval, const void *val);
void hspvar_double_lt_i(void *pval, const void *val);
void hspvar_double_gt_eq_i(void *pval, const void *val);
void hspvar_double_lt_eq_i(void *pval, const void *val);
void *hspvar_double_get_block_size(value_t *pval, void *pdat, int *size);
void hspvar_double_alloc_block(value_t *pval, void *pdat, int size);
void hspvar_double_init(hspvar_proc_t *p);

#endif /* hspvar_double_h */
