
//
//	HSPVAR core module
//	onion software/onitama 2007/1
//
//=============================================================================>>>hspvar_label
#import "hspvar_label.h"
#import "debug_message.h"
#import "hsp3struct_debug.h"
#import "hsp3struct_var.h"
#import "strbuf.h"
#import "supio_hsp3.h"
#import <stdio.h>
#import <stdlib.h>
#import <string.h>
//=============================================================================<<<hspvar_label
@implementation ViewController (hspvar_label)
//=============================================================================>>>hspvar_label
/*------------------------------------------------------------*/
/*
 HSPVAR core interface (label)
 */
/*------------------------------------------------------------*/

#define hspvar_label_GetPtr(pval) ((HSPVAR_LABEL*)pval)

// Core
PDAT*
HspVarLabel_GetPtr(PVal* pval)
{
    DEBUG_IN;
    DEBUG_OUT;
    return (PDAT*)(((HSPVAR_LABEL*)(pval->pt)) + pval->offset);
}

int
HspVarLabel_GetVarSize(PVal* pval)
{
    DEBUG_IN;
    //		PVALポインタの変数が必要とするサイズを取得する
    //		(sizeフィールドに設定される)
    //
    int size;
    size = pval->len[1];
    if (pval->len[2])
        size *= pval->len[2];
    if (pval->len[3])
        size *= pval->len[3];
    if (pval->len[4])
        size *= pval->len[4];
    size *= sizeof(HSPVAR_LABEL);
    DEBUG_OUT;
    return size;
}

void
HspVarLabel_Free(PVal* pval)
{
    DEBUG_IN;
    //		PVALポインタの変数メモリを解放する
    //
    if (pval->mode == HSPVAR_MODE_MALLOC) {
        sbFree(pval->pt);
    }
    pval->pt = NULL;
    pval->mode = HSPVAR_MODE_NONE;
    DEBUG_OUT;
}

void
HspVarLabel_Alloc(PVal* pval, const PVal* pval2)
{
    DEBUG_IN;
    //		pval変数が必要とするサイズを確保する。
    //		(pvalがすでに確保されているメモリ解放は呼び出し側が行なう)
    //		(flagの設定は呼び出し側が行なう)
    //		(pval2がNULLの場合は、新規データ)
    //		(pval2が指定されている場合は、pval2の内容を継承して再確保)
    //
    int i, size;
    char* pt;
    HSPVAR_LABEL* fv;
    if (pval->len[1] < 1)
        pval->len[1] = 1; // 配列を最低1は確保する
    size = HspVarLabel_GetVarSize(pval);
    pval->mode = HSPVAR_MODE_MALLOC;
    pt = sbAlloc(size);
    fv = (HSPVAR_LABEL*)pt;
    for (i = 0; i < (int)(size / sizeof(HSPVAR_LABEL)); i++) {
        fv[i] = NULL;
    }
    if (pval2 != NULL) {
        memcpy(pt, pval->pt, pval->size);
        sbFree(pval->pt);
    }
    pval->pt = pt;
    pval->size = size;
    DEBUG_OUT;
}

// Size
int
HspVarLabel_GetSize(const PDAT* pval)
{
    DEBUG_IN;
    DEBUG_OUT;
    return sizeof(HSPVAR_LABEL);
}

// Using
int
HspVarLabel_GetUsing(const PDAT* pdat)
{
    //		(実態のポインタが渡されます)
    DEBUG_IN;
    DEBUG_OUT;
    return (*pdat != NULL);
}

// Set
void
HspVarLabel_Set(PVal* pval, PDAT* pdat, const void* in)
{
    DEBUG_IN;
    *hspvar_label_GetPtr(pdat) = *((HSPVAR_LABEL*)(in));
    DEBUG_OUT;
}

void*
HspVarLabel_GetBlockSize(PVal* pval, PDAT* pdat, int* size)
{
    DEBUG_IN;
    *size = pval->size - (int)(((char*)pdat) - pval->pt);
    DEBUG_OUT;
    return (pdat);
}

void
HspVarLabel_AllocBlock(PVal* pval, PDAT* pdat, int size)
{
    DEBUG_IN;
    DEBUG_OUT;
}

/*------------------------------------------------------------*/

void
HspVarLabel_Init(HspVarProc* p)
{
    DEBUG_IN;
    //    p->Set = HspVarLabel_Set;
    //    p->GetPtr = HspVarLabel_GetPtr;
    //    p->GetSize = HspVarLabel_GetSize;
    //    p->GetUsing = HspVarLabel_GetUsing;
    //    p->GetBlockSize = HspVarLabel_GetBlockSize;
    //    p->AllocBlock = HspVarLabel_AllocBlock;
    //    p->Alloc = HspVarLabel_Alloc;
    //    p->Free = HspVarLabel_Free;
    
    p->vartype_name = (char*)"label"; // タイプ名
    p->version = 0x001; // 型タイプランタイムバージョン(0x100 = 1.0)
    p->support =
    HSPVAR_SUPPORT_STORAGE | HSPVAR_SUPPORT_FLEXARRAY | HSPVAR_SUPPORT_VARUSE;
    // サポート状況フラグ(HSPVAR_SUPPORT_*)
    p->basesize =
    sizeof(HSPVAR_LABEL); // １つのデータが使用するサイズ(byte) / 可変長の時は-1
    DEBUG_OUT;
}

/*------------------------------------------------------------*/
//=============================================================================<<<hspvar_label
@end
