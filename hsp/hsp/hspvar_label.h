
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
void HspVarLabel_Init(hspvar_proc_t *p);

#ifdef __cplusplus
}
#endif

void *HspVarLabel_GetPtr(value_t *pval);

int HspVarLabel_GetVarSize(value_t *pval);

void HspVarLabel_Free(value_t *pval);

void HspVarLabel_Alloc(value_t *pval, const value_t *pval2);

int HspVarLabel_GetSize(const void *pval);

int HspVarLabel_GetUsing(const void *pdat);

void HspVarLabel_Set(value_t *pval, void *pdat, const void *in);

void *HspVarLabel_GetBlockSize(value_t *pval, void *pdat, int *size);

void HspVarLabel_AllocBlock(value_t *pval, void *pdat, int size);

void HspVarLabel_Init(hspvar_proc_t *p);


#endif
