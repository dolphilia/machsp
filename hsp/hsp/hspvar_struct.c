
//
//	HSPVARコアモジュール
//	onion software/onitama 2003/4
//

#import "hspvar_struct.h"
#import "strbuf.h"

//------------------------------------------------------------
// HSPVAR core interface (struct)
//------------------------------------------------------------

/// Core
void *hspvar_struct_get_ptr(value_t *pval) {
    return (void *) (((flex_value_t *)(pval->pt)) + pval->offset);
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

/// PVALポインタの変数メモリを解放する
///
void hspvar_struct_free(value_t *pval) {
    if (pval->mode == HSPVAR_MODE_MALLOC) {
        // code_delstruct_all( pval );
        // デストラクタがあれば呼び出す
        flex_value_t *fv = (flex_value_t *) pval->pt;
        for (int i = 0; i < pval->len[1]; i++) {
            if (fv->type == FLEXVAL_TYPE_ALLOC)
                strbuf_free(fv->ptr);
            fv++;
        }
        strbuf_free(pval->pt);
    }
    pval->mode = HSPVAR_MODE_NONE;
}

/// pval変数が必要とするサイズを確保する。
///
/// (pvalがすでに確保されているメモリ解放は呼び出し側が行なう)
/// (pval2がNULLの場合は、新規データ)
/// (pval2が指定されている場合は、pval2の内容を継承して再確保)
///
void hspvar_struct_alloc(value_t *pval, const value_t *pval2) {
    if (pval->len[1] < 1)
        pval->len[1] = 1; // 配列を最低1は確保する
    pval->mode = HSPVAR_MODE_MALLOC;

    int size = sizeof(flex_value_t) * pval->len[1];
    char *pt = strbuf_alloc(size);
    flex_value_t *fv = (flex_value_t *) pt;

    for (int i = 0; i < pval->len[1]; i++) {
        memset(fv, 0, sizeof(flex_value_t));
        fv->type = FLEXVAL_TYPE_NONE;
        fv++;
    }
    if (pval2 != NULL) {
        memcpy(pt, pval->pt, pval->size);
        strbuf_free(pval->pt);
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

/// Size
int hspvar_struct_get_size(const void *pdat) {
    return sizeof(flex_value_t); // 実態のポインタが渡されます
}

/// Using
int hspvar_struct_get_using(const void *pdat) {
    flex_value_t *fv = (flex_value_t *) pdat; // 実態のポインタが渡されます
    return fv->type;
}

/// Set
void hspvar_struct_set(value_t *pval, void *pdat, const void *in) {
    flex_value_t *fv = (flex_value_t *) in;
    flex_value_t *fv_src = (flex_value_t *) pdat;
    fv->type = FLEXVAL_TYPE_CLONE;
    if (fv_src->type == FLEXVAL_TYPE_ALLOC) {
        strbuf_free(fv_src->ptr);
    }
    memcpy(pdat, fv, sizeof(flex_value_t));
    // sbCopy( (char **)pdat, (char *)fv->ptr, fv->size );
}

/*
 // INVALID
 static void HspVarStruct_Invalid( PDAT *pval, const void *val )
 {
 throw( HSPERR_UNSUPPORTED_FUNCTION );
 }
 */

void *hspvar_struct_get_block_size(value_t *pval, void *pdat, int *size) {
    flex_value_t *fv = (flex_value_t *) pdat;
    *size = fv->size;
    return (void *) (fv->ptr);
}

void hspvar_struct_alloc_block(value_t *pval, void *pdat, int size) {
}

//------------------------------------------------------------

void hspvar_struct_init(hspvar_proc_t *p) {

    //    p->Set = hspvar_struct_set;
    //    p->GetPtr = hspvar_struct_get_ptr;
    //    //	p->Cnv = HspVarStruct_Cnv;
    //    //	p->CnvCustom = HspVarStruct_CnvCustom;
    //    p->GetSize = hspvar_struct_get_size;
    //    p->GetUsing = hspvar_struct_get_using;
    //    p->GetBlockSize = hspvar_struct_get_block_size;
    //    p->AllocBlock = hspvar_struct_alloc_block;
    //    //	p->ArrayObject = HspVarStruct_ArrayObject;
    //    p->Alloc = hspvar_struct_alloc;
    //    p->Free = hspvar_struct_free;
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
    p->vartype_name = (char *) "struct"; // タイプ名
    p->version = 0x001; // 型タイプランタイムバージョン(0x100 = 1.0)
    p->support =
            HSPVAR_SUPPORT_STORAGE | HSPVAR_SUPPORT_FLEXARRAY | HSPVAR_SUPPORT_VARUSE;
    // サポート状況フラグ(HSPVAR_SUPPORT_*)
    p->basesize = sizeof(flex_value_t); // １つのデータが使用するサイズ(byte) / 可変長の時は-1
}
