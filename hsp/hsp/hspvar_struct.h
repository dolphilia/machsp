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
#import <Foundation/Foundation.h>

@interface
ViewController (hspvar_struct) {
}
-(PDAT*)HspVarStruct_GetPtr:(PVal*)pval;
-(void)HspVarStruct_Free:(PVal*)pval;
-(void)HspVarStruct_Alloc:(PVal*)pval pval2:(const PVal*)pval2;
-(int)HspVarStruct_GetSize:(const PDAT*)pdat;
-(int)HspVarStruct_GetUsing:(const PDAT*)pdat;
-(void)HspVarStruct_Set:(PVal*)pval pdat:(PDAT*)pdat in:(const void*)in;
-(void*)HspVarStruct_GetBlockSize:(PVal*)pval pdat:(PDAT*)pdat size:(int*)size;
-(void)HspVarStruct_AllocBlock:(PVal*)pval pdat:(PDAT*)pdat size:(int)size;
-(void)HspVarStruct_Init:(HspVarProc*)p;
@end

#endif /* hspvar_struct_h */
