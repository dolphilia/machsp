//
//  hspvar_str.h
//

#ifndef hspvar_str_h
#define hspvar_str_h

#include "hsp3struct.h"

char **HspVarStr_GetFlexBufPtr(PVal *pval, int num);
PDAT *HspVarStr_GetPtr(PVal *pval);
void *HspVarStr_Cnv(const void *buffer, int flag);
int HspVarStr_GetVarSize(PVal *pval);
void HspVarStr_Free(PVal *pval);
void HspVarStr_Alloc(PVal *pval, const PVal *pval2);
int HspVarStr_GetSize(const PDAT *pval);
void HspVarStr_Set(PVal *pval, PDAT *pdat, const void *in);
void HspVarStr_AddI(PDAT *pval, const void *val);
void HspVarStr_EqI(PDAT *pdat, const void *val);
void HspVarStr_NeI(PDAT *pdat, const void *val);
void *HspVarStr_GetBlockSize(PVal *pval, PDAT *pdat, int *size);
void HspVarStr_AllocBlock(PVal *pval, PDAT *pdat, int size);
void HspVarStr_Init(HspVarProc *p);

#endif /* hspvar_str_h */
