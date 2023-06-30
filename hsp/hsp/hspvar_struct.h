//
//  hspvar_struct.h
//  hsp
//
//  Created by 半澤 聡 on 2016/10/07.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#ifndef hspvar_struct_h
#define hspvar_struct_h

#import "ViewController.h"

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
