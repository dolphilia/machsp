
//
//	HSPVAR core module
//	onion software/onitama 2003/4
//
//=============================================================================>>>hspvar_struct
#import "hspvar_struct.h"
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
//=============================================================================<<<hspvar_struct
@implementation ViewController (hspvar_struct)
//=============================================================================>>>hspvar_struct
/*------------------------------------------------------------*/
/*
 HSPVAR core interface (struct)
 */
/*------------------------------------------------------------*/
// Core
-(PDAT*)HspVarStruct_GetPtr:(PVal*)pval {
    return (PDAT*)(((FlexValue*)(pval->pt)) + pval->offset);
}
/*
 static void *HspVarStruct_Cnv( const void *buffer, int flag )
 {
 //		リクエストされた型 -> 自分の型への変換を行なう
 //		(組み込み型にのみ対応でOK)
 //		(参照元のデータを破壊しないこと)
 //
 throw HSPERR_INVALID_TYPE;
 return buffer;
 }
 static void *HspVarStruct_CnvCustom( const void *buffer, int flag )
 {
 //		(カスタムタイプのみ)
 //		自分の型 -> リクエストされた型 への変換を行なう
 //		(組み込み型に対応させる)
 //		(参照元のデータを破壊しないこと)
 //
 throw HSPERR_INVALID_TYPE;
 return buffer;
 }
 */
-(void)HspVarStruct_Free:(PVal*)pval {
    //		PVALポインタの変数メモリを解放する
    //
    int i;
    FlexValue* fv;
    if (pval->mode == HSPVAR_MODE_MALLOC) {
        // code_delstruct_all( pval );					//
        // デストラクタがあれば呼び出す
        fv = (FlexValue*)pval->pt;
        for (i = 0; i < pval->len[1]; i++) {
            if (fv->type == FLEXVAL_TYPE_ALLOC)
                [self sbFree:fv->ptr];
            fv++;
        }
        [self sbFree:pval->pt];
    }
    pval->mode = HSPVAR_MODE_NONE;
}
-(void)HspVarStruct_Alloc:(PVal*)pval pval2:(const PVal*)pval2 {
    //		pval変数が必要とするサイズを確保する。
    //		(pvalがすでに確保されているメモリ解放は呼び出し側が行なう)
    //		(pval2がNULLの場合は、新規データ)
    //		(pval2が指定されている場合は、pval2の内容を継承して再確保)
    //
    int i, size;
    char* pt;
    FlexValue* fv;
    if (pval->len[1] < 1)
        pval->len[1] = 1; // 配列を最低1は確保する
    pval->mode = HSPVAR_MODE_MALLOC;
    size = sizeof(FlexValue) * pval->len[1];
    pt = [self sbAlloc:size];
    fv = (FlexValue*)pt;
    for (i = 0; i < pval->len[1]; i++) {
        /*
         rev 53
         BT#113: dimtypeでstruct型(モジュール型)変数が不完全な状態で作成される
         に対処。
         */
        memset(fv, 0, sizeof(FlexValue));
        fv->type = FLEXVAL_TYPE_NONE;
        fv++;
    }
    if (pval2 != NULL) {
        memcpy(pt, pval->pt, pval->size);
        [self sbFree:pval->pt];
    }
    pval->pt = pt;
    pval->size = size;
}
/*
 static void *HspVarStruct_ArrayObject( PVal *pval, int *mptype )
 {
 //		配列要素の指定 (文字列/連想配列用)
 //
 throw( HSPERR_UNSUPPORTED_FUNCTION );
 return NULL;
 }
 */
// Size
-(int)HspVarStruct_GetSize:(const PDAT*)pdat {
    //		(実態のポインタが渡されます)
    return sizeof(FlexValue);
}
// Using
-(int)HspVarStruct_GetUsing:(const PDAT*)pdat {
    //		(実態のポインタが渡されます)
    FlexValue* fv;
    fv = (FlexValue*)pdat;
    return fv->type;
}
// Set
-(void)HspVarStruct_Set:(PVal*)pval pdat:(PDAT*)pdat in:(const void*)in {
    FlexValue* fv;
    FlexValue* fv_src;
    fv = (FlexValue*)in;
    fv->type = FLEXVAL_TYPE_CLONE;
    fv_src = (FlexValue*)pdat;
    if (fv_src->type == FLEXVAL_TYPE_ALLOC) {
        [self sbFree:fv_src->ptr];
    }
    memcpy(pdat, fv, sizeof(FlexValue));
    // sbCopy( (char **)pdat, (char *)fv->ptr, fv->size );
}
/*
 // INVALID
 static void HspVarStruct_Invalid( PDAT *pval, const void *val )
 {
 throw( HSPERR_UNSUPPORTED_FUNCTION );
 }
 */
-(void*)HspVarStruct_GetBlockSize:(PVal*)pval pdat:(PDAT*)pdat size:(int*)size {
    FlexValue* fv;
    fv = (FlexValue*)pdat;
    *size = fv->size;
    return (void*)(fv->ptr);
}
-(void)HspVarStruct_AllocBlock:(PVal*)pval pdat:(PDAT*)pdat size:(int)size {
}
/*------------------------------------------------------------*/
-(void)HspVarStruct_Init:(HspVarProc*)p {
    //    p->Set = HspVarStruct_Set;
    //    p->GetPtr = HspVarStruct_GetPtr;
    //    //	p->Cnv = HspVarStruct_Cnv;
    //    //	p->CnvCustom = HspVarStruct_CnvCustom;
    //    p->GetSize = HspVarStruct_GetSize;
    //    p->GetUsing = HspVarStruct_GetUsing;
    //    p->GetBlockSize = HspVarStruct_GetBlockSize;
    //    p->AllocBlock = HspVarStruct_AllocBlock;
    //    //	p->ArrayObject = HspVarStruct_ArrayObject;
    //    p->Alloc = HspVarStruct_Alloc;
    //    p->Free = HspVarStruct_Free;
    //    /*
    //     p->AddI = HspVarStruct_Invalid;
    //     p->SubI = HspVarStruct_Invalid;
    //     p->MulI = HspVarStruct_Invalid;
    //     p->DivI = HspVarStruct_Invalid;
    //     p->ModI = HspVarStruct_Invalid;
    //
    //     p->AndI = HspVarStruct_Invalid;
    //     p->OrI  = HspVarStruct_Invalid;
    //     p->XorI = HspVarStruct_Invalid;
    //
    //     p->EqI = HspVarStruct_Invalid;
    //     p->NeI = HspVarStruct_Invalid;
    //     p->GtI = HspVarStruct_Invalid;
    //     p->LtI = HspVarStruct_Invalid;
    //     p->GtEqI = HspVarStruct_Invalid;
    //     p->LtEqI = HspVarStruct_Invalid;
    //
    //     p->RrI = HspVarStruct_Invalid;
    //     p->LrI = HspVarStruct_Invalid;
    //     */
    p->vartype_name = (char*)"struct"; // タイプ名
    p->version = 0x001; // 型タイプランタイムバージョン(0x100 = 1.0)
    p->support =
    HSPVAR_SUPPORT_STORAGE | HSPVAR_SUPPORT_FLEXARRAY | HSPVAR_SUPPORT_VARUSE;
    // サポート状況フラグ(HSPVAR_SUPPORT_*)
    p->basesize =
    sizeof(FlexValue); // １つのデータが使用するサイズ(byte) / 可変長の時は-1
}
/*------------------------------------------------------------*/
//=============================================================================<<<hspvar_struct
@end
