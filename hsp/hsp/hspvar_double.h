//
//  hspvar_double.h
//

#ifndef hspvar_double_h
#define hspvar_double_h

#import "hsp3struct.h"

void *HspVarDouble_GetPtr(value_t *pval);
void *HspVarDouble_Cnv(const void *buffer, int flag);
int HspVarDouble_GetVarSize(value_t *pval);
void HspVarDouble_Free(value_t *pval);
void HspVarDouble_Alloc(value_t *pval, const value_t *pval2);
int HspVarDouble_GetSize(const void *pval);
void HspVarDouble_Set(value_t *pval, void *pdat, const void *in);
void HspVarDouble_AddI(void *pval, const void *val);
void HspVarDouble_SubI(void *pval, const void *val);
void HspVarDouble_MulI(void *pval, const void *val);
void HspVarDouble_DivI(void *pval, const void *val);
void HspVarDouble_ModI(void *pval, const void *val);
void HspVarDouble_EqI(void *pval, const void *val);
void HspVarDouble_NeI(void *pval, const void *val);
void HspVarDouble_GtI(void *pval, const void *val);
void HspVarDouble_LtI(void *pval, const void *val);
void HspVarDouble_GtEqI(void *pval, const void *val);
void HspVarDouble_LtEqI(void *pval, const void *val);
void *HspVarDouble_GetBlockSize(value_t *pval, void *pdat, int *size);
void HspVarDouble_AllocBlock(value_t *pval, void *pdat, int size);
void HspVarDouble_Init(hspvar_proc_t *p);

#endif /* hspvar_double_h */
