//
//  hspvar_struct.h
//  hsp
//
//  Created by 半澤 聡 on 2016/10/07.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#ifndef hspvar_struct_h
#define hspvar_struct_h
//=============================================================================>>>hspvar_struct
#import "ViewController.h"
#import <Foundation/Foundation.h>
//=============================================================================<<<hspvar_struct

@interface
ViewController (hspvar_struct) {
}
//=============================================================================>>>hspvar_struct
PDAT* HspVarStruct_GetPtr(PVal* pval);
void HspVarStruct_Free(PVal* pval);
void HspVarStruct_Alloc(PVal* pval, const PVal* pval2);
int HspVarStruct_GetSize(const PDAT* pdat);
int HspVarStruct_GetUsing(const PDAT* pdat);
void HspVarStruct_Set(PVal* pval, PDAT* pdat, const void* in);
void* HspVarStruct_GetBlockSize(PVal* pval, PDAT* pdat, int* size);
void HspVarStruct_AllocBlock(PVal* pval, PDAT* pdat, int size);
void HspVarStruct_Init(HspVarProc* p);
//=============================================================================<<<hspvar_struct
@end

#endif /* hspvar_struct_h */
