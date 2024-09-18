//
//  hspvar_struct.h
//

#ifndef hspvar_struct_h
#define hspvar_struct_h

#include "hsp3struct.h"

void *hspvar_struct_get_ptr(value_t *pval);
void hspvar_struct_free(value_t *pval);
void hspvar_struct_alloc(value_t *pval, const value_t *pval2);
int hspvar_struct_get_size(const void *pdat);
int hspvar_struct_get_using(const void *pdat);
void hspvar_struct_set(value_t *pval, void *pdat, const void *in);
void *hspvar_struct_get_block_size(value_t *pval, void *pdat, int *size);
void hspvar_struct_alloc_block(value_t *pval, void *pdat, int size);
void hspvar_struct_init(hspvar_proc_t *p);

#endif /* hspvar_struct_h */
