
//
//	HSPVAR core module
//	onion software/onitama 2003/4
//

#import "hspvar_str.h"
#import "debug_message.h"
#import "hsp3struct_debug.h"
#import "hsp3struct_var.h"
#import "strbuf.h"
#import "supio_hsp3.h"
#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <stdio.h>
#import <stdlib.h>
#import <string.h>

@implementation ViewController (hspvar_str)

//------------------------------------------------------------
// HSPVAR core interface (str)
//------------------------------------------------------------

#define hspvar_str_GetPtr(pval) ((char*)pval)

char hspvar_str_conv[400];
HspVarProc* hspvar_str_myproc;

/// 可変長バッファのポインタを得る
///
char** HspVarStr_GetFlexBufPtr(PVal* pval, int num) {
    char** pp;
    if (num == 0)
        return &(pval->pt); // ID#0は、ptがポインタとなる
    pp = (char**)(pval->master);
    return &pp[num];
}

/// Core
PDAT* HspVarStr_GetPtr(PVal* pval) {
    char** pp = HspVarStr_GetFlexBufPtr(pval, pval->offset);
    return (PDAT*)(*pp);
}

/// リクエストされた型 -> 自分の型への変換を行なう
///
/// (組み込み型にのみ対応でOK)
/// (参照元のデータを破壊しないこと)
///
void* HspVarStr_Cnv(const void* buffer, int flag) {
    switch (flag) {
        case HSPVAR_FLAG_INT:
            sprintf(hspvar_str_conv, "%d", *(int*)buffer);
            return hspvar_str_conv;
        case HSPVAR_FLAG_STR:
            break;
        case HSPVAR_FLAG_DOUBLE:
            //_gcvt( *(double *)buffer, 32, hspvar_str_conv );
            sprintf(hspvar_str_conv, "%f", *(double*)buffer);
            return hspvar_str_conv;
        default: {
            NSString* error_str = [NSString stringWithFormat:@"%d", HSPVAR_ERROR_TYPEMISS];
            @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
        }
    }
    return (void*)buffer;
}

/*
 static void *HspVarStr_CnvCustom( const void *buffer, int flag )
 {
 //		(カスタムタイプのみ)
 //		自分の型 -> リクエストされた型 への変換を行なう
 //		(組み込み型に対応させる)
 //		(参照元のデータを破壊しないこと)
 //
 return buffer;
 }
 */

/// PVALポインタの変数が必要とするサイズを取得する
///
/// (sizeフィールドに設定される)
///
int HspVarStr_GetVarSize(PVal* pval) {
    int size = pval->len[1];
    if (pval->len[2])
        size *= pval->len[2];
    if (pval->len[3])
        size *= pval->len[3];
    if (pval->len[4])
        size *= pval->len[4];
    size *= sizeof(char*);
    pval->size = size;
    return size;
}

/// PVALポインタの変数メモリを解放する
///
void HspVarStr_Free(PVal* pval) {
    char** pp;
    int size;
    if (pval->mode == HSPVAR_MODE_MALLOC) {
        size = HspVarStr_GetVarSize(pval);
        for (int i = 0; i < (int)(size / sizeof(char*)); i++) {
            pp = HspVarStr_GetFlexBufPtr(pval, i);
            sbFree(*pp);
        }
        free(pval->master);
    }
    pval->mode = HSPVAR_MODE_NONE;
}

/// pval変数が必要とするサイズを確保する。
///
/// (pvalがすでに確保されているメモリ解放は呼び出し側が行なう)
/// (pval2がNULLの場合は、新規データ。len[0]に確保バイト数が代入される)
/// (pval2が指定されている場合は、pval2の内容を継承して再確保)
///
void HspVarStr_Alloc(PVal* pval, const PVal* pval2) {
    char** pp;
    int i2, size, bsize;
    PVal oldvar;
    if (pval->len[1] < 1)
        pval->len[1] = 1; // 配列を最低1は確保する
    if (pval2 != NULL)
        oldvar = *pval2; // 拡張時は以前の情報を保存する
    
    size = HspVarStr_GetVarSize(pval);
    pval->mode = HSPVAR_MODE_MALLOC;
    pval->master = (char*)calloc(size, 1);
    if (pval->master == NULL) {
        NSString* error_str =
        [NSString stringWithFormat:@"%d", HSPERR_OUT_OF_MEMORY];
        @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
    }
    
    if (pval2 == NULL) { // 配列拡張なし
        bsize = pval->len[0];
        if (bsize < 64)
            bsize = 64;
        for (int i = 0; i < (int)(size / sizeof(char*)); i++) {
            pp = HspVarStr_GetFlexBufPtr(pval, i);
            *pp = sbAllocClear(bsize);
            sbSetOption(*pp, (void*)pp);
        }
        return;
    }
    
    i2 = oldvar.size / sizeof(char*);
    for (int i = 0; i < (int)(size / sizeof(char*)); i++) {
        pp = HspVarStr_GetFlexBufPtr(pval, i);
        if (i >= i2) {
            *pp = sbAllocClear(64); // 新規確保分
        } else {
            *pp = *HspVarStr_GetFlexBufPtr(&oldvar, i); // 確保済みバッファ
        }
        sbSetOption(*pp, (void*)pp);
    }
    free(oldvar.master);
    
}

/*
 static void *HspVarStr_ArrayObject( PVal *pval, int *arg )
 {
 //		配列要素の指定 (文字列/連想配列用)
 //		( Reset後に次元数だけ連続で呼ばれます )
 //
 throw HSPERR_UNSUPPORTED_FUNCTION;
 }
 */

/// Size
int HspVarStr_GetSize(const PDAT* pval) {
    return (int)(strlen((char*)pval) + 1);
}

/// Set
void HspVarStr_Set(PVal* pval, PDAT* pdat, const void* in) {
    char** pp;
    if (pval->mode == HSPVAR_MODE_CLONE) {
        strncpy((char*)pdat, (char*)in, pval->size);
        return;
    }
    pp = (char**)sbGetOption((char*)pdat);
    sbStrCopy(pp, (char*)in);
    // strcpy( hspvar_str_GetPtr(pval), (char *)in );
}

/// Add
void HspVarStr_AddI(PDAT* pval, const void* val) {
    char** pp = (char**)sbGetOption((char*)pval);
    sbStrAdd(pp, (char*)val);
    // strcat( hspvar_str_GetPtr(pval), (char *)val );
    hspvar_str_myproc->aftertype = HSPVAR_FLAG_STR;
}

/// Eq
void HspVarStr_EqI(PDAT* pdat, const void* val) {
    if (strcmp((char*)pdat, (char*)val)) {
        *(int*)pdat = 0;
    } else {
        *(int*)pdat = 1;
    }
    hspvar_str_myproc->aftertype = HSPVAR_FLAG_INT;
}

/// Ne
void HspVarStr_NeI(PDAT* pdat, const void* val) {
    int i = strcmp((char*)pdat, (char*)val);
    *(int*)pdat = i;
    hspvar_str_myproc->aftertype = HSPVAR_FLAG_INT;
}

/*
 // INVALID
 static void HspVarStr_Invalid( PDAT *pval, const void *val )
 {
 throw( HSPERR_UNSUPPORTED_FUNCTION );
 }
 */

void* HspVarStr_GetBlockSize(PVal* pval, PDAT* pdat, int* size) {
    STRINF* inf;
    if (pval->mode == HSPVAR_MODE_CLONE) {
        *size = pval->size;
        return pdat;
    }
    inf = sbGetSTRINF((char*)pdat);
    *size = inf->size;
    return pdat;
}

void HspVarStr_AllocBlock(PVal* pval, PDAT* pdat, int size) {
    char** pp;
    if (pval->mode == HSPVAR_MODE_CLONE)
        return;
    pp = (char**)sbGetOption((char*)pdat);
    *pp = sbExpand(*pp, size);
}

//------------------------------------------------------------

void HspVarStr_Init(HspVarProc* p) {
    hspvar_str_myproc = p;
    
    //    p->Set = HspVarStr_Set;
    //    p->Cnv = HspVarStr_Cnv;
    //    p->GetPtr = HspVarStr_GetPtr;
    //    //	p->CnvCustom = HspVarStr_CnvCustom;
    //    p->GetSize = HspVarStr_GetSize;
    //    p->GetBlockSize = HspVarStr_GetBlockSize;
    //    p->AllocBlock = HspVarStr_AllocBlock;
    //
    //    //	p->ArrayObject = HspVarStr_ArrayObject;
    //    p->Alloc = HspVarStr_Alloc;
    //    p->Free = HspVarStr_Free;
    //
    //    p->AddI = HspVarStr_AddI;
    //    //	p->SubI = HspVarStr_Invalid;
    //    //	p->MulI = HspVarStr_Invalid;
    //    //	p->DivI = HspVarStr_Invalid;
    //    //	p->ModI = HspVarStr_Invalid;
    //
    //    //	p->AndI = HspVarStr_Invalid;
    //    //	p->OrI  = HspVarStr_Invalid;
    //    //	p->XorI = HspVarStr_Invalid;
    //
    //    p->EqI = HspVarStr_EqI;
    //    p->NeI = HspVarStr_NeI;
    //    //	p->GtI = HspVarStr_Invalid;
    //    //	p->LtI = HspVarStr_Invalid;
    //    //	p->GtEqI = HspVarStr_Invalid;
    //    //	p->LtEqI = HspVarStr_Invalid;
    //
    //    //	p->RrI = HspVarStr_Invalid;
    //    //	p->LrI = HspVarStr_Invalid;
    
    p->vartype_name = (char*)"str"; // タイプ名
    p->version = 0x001; // 型タイプランタイムバージョン(0x100 = 1.0)
    p->support = HSPVAR_SUPPORT_FLEXSTORAGE | HSPVAR_SUPPORT_FLEXARRAY;
    // サポート状況フラグ(HSPVAR_SUPPORT_*)
    p->basesize = -1; // １つのデータが使用するサイズ(byte) / 可変長の時は-1
}

@end
