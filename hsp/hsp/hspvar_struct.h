//
//  hspvar_struct.h
//

#ifndef hspvar_struct_h
#define hspvar_struct_h

#include "hsp3struct.h"

PDAT *HspVarStruct_GetPtr(PVal *pval);
void HspVarStruct_Free(PVal *pval);
void HspVarStruct_Alloc(PVal *pval, const PVal *pval2);
int HspVarStruct_GetSize(const PDAT *pdat);
int HspVarStruct_GetUsing(const PDAT *pdat);
void HspVarStruct_Set(PVal *pval, PDAT *pdat, const void *in);
void *HspVarStruct_GetBlockSize(PVal *pval, PDAT *pdat, int *size);
void HspVarStruct_AllocBlock(PVal *pval, PDAT *pdat, int size);
void HspVarStruct_Init(HspVarProc *p);

#endif /* hspvar_struct_h */
