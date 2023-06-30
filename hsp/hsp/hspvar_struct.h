//
//  hspvar_struct.h
//

#ifndef hspvar_struct_h
#define hspvar_struct_h

#include "hsp3struct.h"

void *HspVarStruct_GetPtr(value_t *pval);
void HspVarStruct_Free(value_t *pval);
void HspVarStruct_Alloc(value_t *pval, const value_t *pval2);
int HspVarStruct_GetSize(const void *pdat);
int HspVarStruct_GetUsing(const void *pdat);
void HspVarStruct_Set(value_t *pval, void *pdat, const void *in);
void *HspVarStruct_GetBlockSize(value_t *pval, void *pdat, int *size);
void HspVarStruct_AllocBlock(value_t *pval, void *pdat, int size);
void HspVarStruct_Init(hspvar_proc_t *p);

#endif /* hspvar_struct_h */
