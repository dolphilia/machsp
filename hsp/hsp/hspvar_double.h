//
//  hspvar_double.h
//  hsp
//
//  Created by 半澤 聡 on 2016/10/07.
//  Copyright © 2016年 dolphilia. All rights reserved.
//
#ifndef hspvar_double_h
#define hspvar_double_h
#import "ViewController.h"
#import <Foundation/Foundation.h>
@interface
ViewController (hspvar_double) {
}
-(PDAT*)HspVarDouble_GetPtr:(PVal*)pval;
-(void*)HspVarDouble_Cnv:(const void*)buffer flag:(int)flag;
-(int)HspVarDouble_GetVarSize:(PVal*)pval;
-(void)HspVarDouble_Free:(PVal*)pval;
-(void)HspVarDouble_Alloc:(PVal*)pval pval2:(const PVal*)pval2;
-(int)HspVarDouble_GetSize:(const PDAT*)pval;
-(void)HspVarDouble_Set:(PVal*)pval pdat:(PDAT*)pdat in:(const void*)in;
-(void)HspVarDouble_AddI:(PDAT*)pval val:(const void*)val;
-(void)HspVarDouble_SubI:(PDAT*)pval val:(const void*)val;
-(void)HspVarDouble_MulI:(PDAT*)pval val:(const void*)val;
-(void)HspVarDouble_DivI:(PDAT*)pval val:(const void*)val;
-(void)HspVarDouble_ModI:(PDAT*)pval val:(const void*)val;
-(void)HspVarDouble_EqI:(PDAT*)pval val:(const void*)val;
-(void)HspVarDouble_NeI:(PDAT*)pval val:(const void*)val;
-(void)HspVarDouble_GtI:(PDAT*)pval val:(const void*)val;
-(void)HspVarDouble_LtI:(PDAT*)pval val:(const void*)val;
-(void)HspVarDouble_GtEqI:(PDAT*)pval val:(const void*)val;
-(void)HspVarDouble_LtEqI:(PDAT*)pval val:(const void*)val;
-(void*)HspVarDouble_GetBlockSize:(PVal*)pval pdat:(PDAT*)pdat size:(int*)size;
-(void)HspVarDouble_AllocBlock:(PVal*)pval pdat:(PDAT*)pdat size:(int)size;
-(void)HspVarDouble_Init:(HspVarProc*)p;
@end
#endif /* hspvar_double_h */
