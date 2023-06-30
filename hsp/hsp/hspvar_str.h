//
//  hspvar_str.h
//

#ifndef hspvar_str_h
#define hspvar_str_h

#include "hsp3struct.h"

char **HspVarStr_GetFlexBufPtr(value_t *pval, int num);
void *HspVarStr_GetPtr(value_t *pval);
void *HspVarStr_Cnv(const void *buffer, int flag);
int HspVarStr_GetVarSize(value_t *pval);
void HspVarStr_Free(value_t *pval);
void HspVarStr_Alloc(value_t *pval, const value_t *pval2);
int HspVarStr_GetSize(const void *pval);
void HspVarStr_Set(value_t *pval, void *pdat, const void *in);
void HspVarStr_AddI(void *pval, const void *val);
void HspVarStr_EqI(void *pdat, const void *val);
void HspVarStr_NeI(void *pdat, const void *val);
void *HspVarStr_GetBlockSize(value_t *pval, void *pdat, int *size);
void HspVarStr_AllocBlock(value_t *pval, void *pdat, int size);
void HspVarStr_Init(hspvar_proc_t *p);

#endif /* hspvar_str_h */
