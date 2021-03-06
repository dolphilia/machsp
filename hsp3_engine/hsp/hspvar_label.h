//
//	hspvar_label.cpp header
//
#ifndef __hspvar_label_h
#define __hspvar_label_h
#import "hsp3struct_var.h"
#import "ViewController.h"
@interface
ViewController (hspvar_label) {
}
typedef unsigned short* HSPVAR_LABEL;
-(PDAT*)HspVarLabel_GetPtr:(PVal*)pval;
-(int)HspVarLabel_GetVarSize:(PVal*)pval;
-(void)HspVarLabel_Free:(PVal*)pval;
-(void)HspVarLabel_Alloc:(PVal*)pval pval2:(const PVal*)pval2;
-(int)HspVarLabel_GetSize:(const PDAT*)pval;
-(int)HspVarLabel_GetUsing:(const PDAT*)pdat;
-(void)HspVarLabel_Set:(PVal*)pval pdat:(PDAT*)pdat in:(const void*)in;
-(void*)HspVarLabel_GetBlockSize:(PVal*)pval pdat:(PDAT*)pdat size:(int*)size;
-(void)HspVarLabel_AllocBlock:(PVal*)pval pdat:(PDAT*)pdat size:(int)size;
-(void)HspVarLabel_Init:(HspVarProc*)p;
@end
#endif
