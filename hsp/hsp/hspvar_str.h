//
//  hspvar_str.h
//  hsp
//
//  Created by 半澤 聡 on 2016/10/07.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#ifndef hspvar_str_h
#define hspvar_str_h

#import "ViewController.h"
#import <Foundation/Foundation.h>

@interface
ViewController (hspvar_str) {
}

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

@end

#endif /* hspvar_str_h */
