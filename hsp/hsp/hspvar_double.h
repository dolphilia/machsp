//
//  hspvar_double.h
//

#ifndef hspvar_double_h
#define hspvar_double_h

#import "hsp3struct.h"

PDAT *HspVarDouble_GetPtr(PVal *pval);
void *HspVarDouble_Cnv(const void *buffer, int flag);
int HspVarDouble_GetVarSize(PVal *pval);
void HspVarDouble_Free(PVal *pval);
void HspVarDouble_Alloc(PVal *pval, const PVal *pval2);
int HspVarDouble_GetSize(const PDAT *pval);
void HspVarDouble_Set(PVal *pval, PDAT *pdat, const void *in);
void HspVarDouble_AddI(PDAT *pval, const void *val);
void HspVarDouble_SubI(PDAT *pval, const void *val);
void HspVarDouble_MulI(PDAT *pval, const void *val);
void HspVarDouble_DivI(PDAT *pval, const void *val);
void HspVarDouble_ModI(PDAT *pval, const void *val);
void HspVarDouble_EqI(PDAT *pval, const void *val);
void HspVarDouble_NeI(PDAT *pval, const void *val);
void HspVarDouble_GtI(PDAT *pval, const void *val);
void HspVarDouble_LtI(PDAT *pval, const void *val);
void HspVarDouble_GtEqI(PDAT *pval, const void *val);
void HspVarDouble_LtEqI(PDAT *pval, const void *val);
void *HspVarDouble_GetBlockSize(PVal *pval, PDAT *pdat, int *size);
void HspVarDouble_AllocBlock(PVal *pval, PDAT *pdat, int size);
void HspVarDouble_Init(HspVarProc *p);

#endif /* hspvar_double_h */
