//
//  hspvar_str.h
//
#ifndef hspvar_str_h
#define hspvar_str_h
#import "ViewController.h"
#import <Foundation/Foundation.h>
@interface
ViewController (hspvar_str) {
}
-(char**) HspVarStr_GetFlexBufPtr:(PVal*)pval num:(int)num;
-(PDAT*) HspVarStr_GetPtr:(PVal*)pval;
-(void*) HspVarStr_Cnv:(const void*)buffer flag:(int)flag;
-(int) HspVarStr_GetVarSize:(PVal*)pval;
-(void) HspVarStr_Free:(PVal*)pval;
-(void) HspVarStr_Alloc:(PVal*)pval pval2:(const PVal*)pval2;
-(int) HspVarStr_GetSize:(const PDAT*)pval;
-(void) HspVarStr_Set:(PVal*)pval pdat:(PDAT*)pdat in:(const void*)in;
-(void) HspVarStr_AddI:(PDAT*)pval val:(const void*)val;
-(void) HspVarStr_EqI:(PDAT*)pdat val:(const void*)val;
-(void) HspVarStr_NeI:(PDAT*)pdat val:(const void*)val;
-(void*) HspVarStr_GetBlockSize:(PVal*)pval pdat:(PDAT*)pdat size:(int*)size;
-(void) HspVarStr_AllocBlock:(PVal*)pval pdat:(PDAT*)pdat size:(int)size;
-(void) HspVarStr_Init:(HspVarProc*)p;
@end
#endif /* hspvar_str_h */
