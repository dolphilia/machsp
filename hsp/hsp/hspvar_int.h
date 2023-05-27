//
//  hspvar_int.h
//  hsp
//
//  Created by 半澤 聡 on 2016/10/07.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#ifndef hspvar_int_h
#define hspvar_int_h

#import "ViewController.h"
#import <Foundation/Foundation.h>

@interface
ViewController (hspvar_int) {
}

PDAT *HspVarInt_GetPtr(PVal *pval);

void *HspVarInt_Cnv(const void *buffer, int flag);

int HspVarInt_GetVarSize(PVal *pval);

void HspVarInt_Free(PVal *pval);

void HspVarInt_Alloc(PVal *pval, const PVal *pval2);

int HspVarInt_GetSize(const PDAT *pval);

void HspVarInt_Set(PVal *pval, PDAT *pdat, const void *in);

void HspVarInt_AddI(PDAT *pval, const void *val);

void HspVarInt_SubI(PDAT *pval, const void *val);

void HspVarInt_MulI(PDAT *pval, const void *val);

void HspVarInt_DivI(PDAT *pval, const void *val);

void HspVarInt_ModI(PDAT *pval, const void *val);

void HspVarInt_AndI(PDAT *pval, const void *val);

void HspVarInt_OrI(PDAT *pval, const void *val);

void HspVarInt_XorI(PDAT *pval, const void *val);

void HspVarInt_EqI(PDAT *pval, const void *val);

void HspVarInt_NeI(PDAT *pval, const void *val);

void HspVarInt_GtI(PDAT *pval, const void *val);

void HspVarInt_LtI(PDAT *pval, const void *val);

void HspVarInt_GtEqI(PDAT *pval, const void *val);

void HspVarInt_LtEqI(PDAT *pval, const void *val);

void HspVarInt_RrI(PDAT *pval, const void *val);

void HspVarInt_LrI(PDAT *pval, const void *val);

void *HspVarInt_GetBlockSize(PVal *pval, PDAT *pdat, int *size);

void HspVarInt_AllocBlock(PVal *pval, PDAT *pdat, int size);

void HspVarInt_Init(HspVarProc *p);

@end

#endif /* hspvar_int_h */
