
//
//	hspvar_label.cpp header
//
#ifndef __hspvar_label_h
#define __hspvar_label_h
//=============================================================================>>>hspvar_label
#import "hsp3struct_var.h"
#import "ViewController.h"
//=============================================================================<<<hspvar_label
@interface
ViewController (hspvar_label) {
}
//=============================================================================>>>hspvar_label
#ifdef __cplusplus
extern "C" {
#endif
    
    typedef unsigned short* HSPVAR_LABEL;
    void HspVarLabel_Init(HspVarProc* p);
    
#ifdef __cplusplus
}
#endif

PDAT* HspVarLabel_GetPtr(PVal* pval);
int HspVarLabel_GetVarSize(PVal* pval);
void HspVarLabel_Free(PVal* pval);
void HspVarLabel_Alloc(PVal* pval, const PVal* pval2);
int HspVarLabel_GetSize(const PDAT* pval);
int HspVarLabel_GetUsing(const PDAT* pdat);
void HspVarLabel_Set(PVal* pval, PDAT* pdat, const void* in);
void* HspVarLabel_GetBlockSize(PVal* pval, PDAT* pdat, int* size);
void HspVarLabel_AllocBlock(PVal* pval, PDAT* pdat, int size);
void HspVarLabel_Init(HspVarProc* p);
//=============================================================================<<<hspvar_label
@end
#endif
