//
//  hspvar_int.h
//  hsp
//
//  Created by 半澤 聡 on 2016/10/07.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#ifndef hspvar_int_h
#define hspvar_int_h

//=============================================================================>>>hspvar_int
#import "ViewController.h"
#import <Foundation/Foundation.h>
//=============================================================================<<<hspvar_int

@interface
ViewController (hspvar_int) {
}
//=============================================================================>>>hspvar_int
-(PDAT*)HspVarInt_GetPtr:(PVal*)pval;
-(void*)HspVarInt_Cnv:(const void*)buffer flag:(int)flag;
-(int)HspVarInt_GetVarSize:(PVal*)pval;
-(void)HspVarInt_Free:(PVal*)pval;
-(void)HspVarInt_Alloc:(PVal*)pval pval2:(const PVal*)pval2;
-(int)HspVarInt_GetSize:(const PDAT*)pval;
-(void)HspVarInt_Set:(PVal*)pval pdat:(PDAT*)pdat in:(const void*)in;
-(void)HspVarInt_AddI:(PDAT*)pval val:(const void*)val;
-(void)HspVarInt_SubI:(PDAT*)pval val:(const void*)val;
-(void)HspVarInt_MulI:(PDAT*)pval val:(const void*)val;
-(void)HspVarInt_DivI:(PDAT*)pval val:(const void*)val;
-(void)HspVarInt_ModI:(PDAT*)pval val:(const void*)val;
-(void)HspVarInt_AndI:(PDAT*)pval val:(const void*)val;
-(void)HspVarInt_OrI:(PDAT*)pval val:(const void*)val;
-(void)HspVarInt_XorI:(PDAT*)pval val:(const void*)val;
-(void)HspVarInt_EqI:(PDAT*)pval val:(const void*)val;
-(void)HspVarInt_NeI:(PDAT*)pval val:(const void*)val;
-(void)HspVarInt_GtI:(PDAT*)pval val:(const void*)val;
-(void)HspVarInt_LtI:(PDAT*)pval val:(const void*)val;
-(void)HspVarInt_GtEqI:(PDAT*)pval val:(const void*)val;
-(void)HspVarInt_LtEqI:(PDAT*)pval val:(const void*)val;
-(void)HspVarInt_RrI:(PDAT*)pval val:(const void*)val;
-(void)HspVarInt_LrI:(PDAT*)pval val:(const void*)val;
-(void*)HspVarInt_GetBlockSize:(PVal*)pval pdat:(PDAT*)pdat size:(int*)size;
-(void)HspVarInt_AllocBlock:(PVal*)pval pdat:(PDAT*)pdat size:(int)size;
-(void)HspVarInt_Init:(HspVarProc*)p;
//=============================================================================<<<hspvar_int
@end

#endif /* hspvar_int_h */
