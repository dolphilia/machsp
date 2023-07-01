
//
//	hspvar_label.cpp header
//
#ifndef __hspvar_label_h
#define __hspvar_label_h

#import "hsp3struct_var.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef unsigned short *HSPVAR_LABEL;
void hspvar_label_init(hspvar_proc_t *p);

#ifdef __cplusplus
}
#endif

void *hspvar_label_get_ptr(value_t *pval);
int hspvar_label_get_var_size(value_t *pval);
void hspvar_label_free(value_t *pval);
void hspvar_label_alloc(value_t *pval, const value_t *pval2);
int hspvar_label_get_size(const void *pval);
int hspvar_label_get_using(const void *pdat);
void hspvar_label_set(value_t *pval, void *pdat, const void *in);
void *hspvar_label_get_block_size(value_t *pval, void *pdat, int *size);
void hspvar_label_alloc_block(value_t *pval, void *pdat, int size);
void hspvar_label_init(hspvar_proc_t *p);


#endif
