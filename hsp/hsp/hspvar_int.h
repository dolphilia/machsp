//
//  hspvar_int.h
//

#ifndef hspvar_int_h
#define hspvar_int_h


#include "hsp3struct.h"

void *HspVarInt_GetPtr(value_t *pval);
void *HspVarInt_Cnv(const void *buffer, int flag);
int HspVarInt_GetVarSize(value_t *pval);
void HspVarInt_Free(value_t *pval);
void HspVarInt_Alloc(value_t *pval, const value_t *pval2);
int HspVarInt_GetSize(const void *pval);
void HspVarInt_Set(value_t *pval, void *pdat, const void *in);
void HspVarInt_AddI(void *pval, const void *val);
void HspVarInt_SubI(void *pval, const void *val);
void HspVarInt_MulI(void *pval, const void *val);
void HspVarInt_DivI(void *pval, const void *val);
void HspVarInt_ModI(void *pval, const void *val);
void HspVarInt_AndI(void *pval, const void *val);
void HspVarInt_OrI(void *pval, const void *val);
void HspVarInt_XorI(void *pval, const void *val);
void HspVarInt_EqI(void *pval, const void *val);
void HspVarInt_NeI(void *pval, const void *val);
void HspVarInt_GtI(void *pval, const void *val);
void HspVarInt_LtI(void *pval, const void *val);
void HspVarInt_GtEqI(void *pval, const void *val);
void HspVarInt_LtEqI(void *pval, const void *val);
void HspVarInt_RrI(void *pval, const void *val);
void HspVarInt_LrI(void *pval, const void *val);
void *HspVarInt_GetBlockSize(value_t *pval, void *pdat, int *size);
void HspVarInt_AllocBlock(value_t *pval, void *pdat, int size);
void HspVarInt_Init(hspvar_proc_t *p);


#endif /* hspvar_int_h */
