//
//  hspvar_str.h
//

#ifndef hspvar_str_h
#define hspvar_str_h

#include "hsp3struct.h"

char **hspvar_str_get_flex_buf_ptr(value_t *pval, int num);
void *hspvar_str_get_ptr(value_t *pval);
void *hspvar_str_cnv(const void *buffer, int flag);
int hspvar_str_get_var_size(value_t *pval);
void hspvar_str_free(value_t *pval);
void hspvar_str_alloc(value_t *pval, const value_t *pval2);
int hspvar_str_get_size(const void *pval);
void hspvar_str_set(value_t *pval, void *pdat, const void *in);
void hspvar_str_add_i(void *pval, const void *val);
void hspvar_str_eq_i(void *pdat, const void *val);
void hspvar_str_ne_i(void *pdat, const void *val);
void *hspvar_str_get_block_size(value_t *pval, void *pdat, int *size);
void hspvar_str_alloc_block(value_t *pval, void *pdat, int size);
void hspvar_str_init(hspvar_proc_t *p);

#endif /* hspvar_str_h */
