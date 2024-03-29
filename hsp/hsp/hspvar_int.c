//
//	HSPVARコアモジュール
//	onion software/onitama 2003/4

#import "hspvar_int.h"
#import "strbuf.h"
#import "supio_hsp3.h"

//------------------------------------------------------------
// HSPVAR core interface (int)
//------------------------------------------------------------

#define hspvar_int_GetPtr(pval) ((int*)pval)
int hspvar_int_conv;

/// Core
void *hspvar_int_get_ptr(value_t *pval) {
    return (void *) (((int *) (pval->pt)) + pval->offset);
}

/// リクエストされた型 -> 自分の型への変換を行なう
///
/// (組み込み型にのみ対応でOK)
/// (参照元のデータを破壊しないこと)
///
void *hspvar_int_cnv(const void *buffer, int flag) {
    switch (flag) {
        case HSPVAR_FLAG_STR:
            if (*(char *) buffer == '$') { // 16->10進数
                hspvar_int_conv = htoi((char *) buffer);
            } else {
                hspvar_int_conv = atoi((char *) buffer);
            }
            return &hspvar_int_conv;
        case HSPVAR_FLAG_INT:
            break;
        case HSPVAR_FLAG_DOUBLE:
            hspvar_int_conv = (int) (*(double *) buffer);
            return &hspvar_int_conv;
        default: {
            fprintf(stderr, "Error: %d\n", HSPVAR_ERROR_TYPEMISS);
            exit(EXIT_FAILURE);
        }
    }
    return (void *) buffer;
}

/*
 static void *HspVarInt_CnvCustom( const void *buffer, int flag )
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
int hspvar_int_get_var_size(value_t *pval) {
    int size = pval->len[1];
    if (pval->len[2])
        size *= pval->len[2];
    if (pval->len[3])
        size *= pval->len[3];
    if (pval->len[4])
        size *= pval->len[4];
    size *= sizeof(int);
    return size;
}

/// PVALポインタの変数メモリを解放する
///
void hspvar_int_free(value_t *pval) {
    if (pval->mode == HSPVAR_MODE_MALLOC) {
        strbuf_free(pval->pt);
    }
    pval->pt = NULL;
    pval->mode = HSPVAR_MODE_NONE;
}

/// pval変数が必要とするサイズを確保する。
///
/// (pvalがすでに確保されているメモリ解放は呼び出し側が行なう)
/// (pval2がNULLの場合は、新規データ)
/// (pval2が指定されている場合は、pval2の内容を継承して再確保)
///
void hspvar_int_alloc(value_t *pval, const value_t *pval2) {
    if (pval->len[1] < 1)
        pval->len[1] = 1; // 配列を最低1は確保する

    int size = hspvar_int_get_var_size(pval);
    pval->mode = HSPVAR_MODE_MALLOC;
    char *pt = strbuf_alloc(size);
    int *fv = (int *) pt;

    for (int i = 0; i < (int) (size / sizeof(int)); i++) {
        fv[i] = 0;
    }
    if (pval2 != NULL) {
        memcpy(pt, pval->pt, pval->size);
        strbuf_free(pval->pt);
    }
    pval->pt = pt;
    pval->size = size;
}

/*
 static void *HspVarInt_ArrayObject( PVal *pval, int *mptype )
 {
 //		配列要素の指定 (文字列/連想配列用)
 //
 throw HSPERR_UNSUPPORTED_FUNCTION;
 return NULL;
 }
 */

/// Size
int hspvar_int_get_size(const void *pval) {
    return sizeof(int);
}

/// Set
void hspvar_int_set(value_t *pval, void *pdat, const void *in) {
    *hspvar_int_GetPtr(pdat) = *((int *) (in));
}

/// Add
void hspvar_int_add_i(void *pval, const void *val) {
    *hspvar_int_GetPtr(pval) += *((int *) (val));
}

/// Sub
void hspvar_int_sub_i(void *pval, const void *val) {
    *hspvar_int_GetPtr(pval) -= *((int *) (val));
}

/// Mul
void hspvar_int_mul_i(void *pval, const void *val) {
    *hspvar_int_GetPtr(pval) *= *((int *) (val));
}

/// Div
void hspvar_int_div_i(void *pval, const void *val) {
    int p = *((int *) (val));
    if (p == 0) {
        fprintf(stderr, "Error: %d\n", HSPVAR_ERROR_DIVZERO);
        exit(EXIT_FAILURE);
    }
    *hspvar_int_GetPtr(pval) /= p;
}

/// Mod
void hspvar_int_mod_i(void *pval, const void *val) {
    int p = *((int *) (val));
    if (p == 0) {
        fprintf(stderr, "Error: %d\n", HSPVAR_ERROR_DIVZERO);
        exit(EXIT_FAILURE);
    }
    *hspvar_int_GetPtr(pval) %= p;
}

/// And
void hspvar_int_and_i(void *pval, const void *val) {
    *hspvar_int_GetPtr(pval) &= *((int *) (val));
}

/// Or
void hspvar_int_or_i(void *pval, const void *val) {
    *hspvar_int_GetPtr(pval) |= *((int *) (val));
}

/// Xor
void hspvar_int_xor_i(void *pval, const void *val) {
    *hspvar_int_GetPtr(pval) ^= *((int *) (val));
}

/// Eq
void hspvar_int_eq_i(void *pval, const void *val) {
    *hspvar_int_GetPtr(pval) = (*hspvar_int_GetPtr(pval) == *((int *) (val)));
}

/// Ne
void hspvar_int_ne_i(void *pval, const void *val) {
    *hspvar_int_GetPtr(pval) = (*hspvar_int_GetPtr(pval) != *((int *) (val)));
}

/// Gt
void hspvar_int_gt_i(void *pval, const void *val) {
    *hspvar_int_GetPtr(pval) = (*hspvar_int_GetPtr(pval) > *((int *) (val)));
}

/// Lt
void hspvar_int_lt_i(void *pval, const void *val) {
    *hspvar_int_GetPtr(pval) = (*hspvar_int_GetPtr(pval) < *((int *) (val)));
}

/// GtEq
void hspvar_int_gt_eq_i(void *pval, const void *val) {
    *hspvar_int_GetPtr(pval) = (*hspvar_int_GetPtr(pval) >= *((int *) (val)));
}

/// LtEq
void hspvar_int_lt_eq_i(void *pval, const void *val) {
    *hspvar_int_GetPtr(pval) = (*hspvar_int_GetPtr(pval) <= *((int *) (val)));
}

/// Rr
void hspvar_int_rr_i(void *pval, const void *val) {
    *hspvar_int_GetPtr(pval) >>= *((int *) (val));
}

/// Lr
void hspvar_int_lr_i(void *pval, const void *val) {
    *hspvar_int_GetPtr(pval) <<= *((int *) (val));
}

void *hspvar_int_get_block_size(value_t *pval, void *pdat, int *size) {
    *size = pval->size - (int) (((char *) pdat) - pval->pt);
    return (pdat);
}

void hspvar_int_alloc_block(value_t *pval, void *pdat, int size) {
}

//------------------------------------------------------------

void hspvar_int_init(hspvar_proc_t *p) {
    //    p->Set = hspvar_int_set;
    //    p->Cnv = hspvar_int_cnv;
    //    p->GetPtr = hspvar_int_get_ptr;
    //    //	p->CnvCustom = HspVarInt_CnvCustom;
    //    p->GetSize = hspvar_int_get_size;
    //    p->GetBlockSize = hspvar_int_get_block_size;
    //    p->AllocBlock = hspvar_int_alloc_block;
    //
    //    //	p->ArrayObject = HspVarInt_ArrayObject;
    //    p->Alloc = hspvar_int_alloc;
    //    p->Free = hspvar_int_free;
    //
    //    p->AddI = hspvar_int_add_i;
    //    p->SubI = hspvar_int_sub_i;
    //    p->MulI = hspvar_int_mul_i;
    //    p->DivI = hspvar_int_div_i;
    //    p->ModI = hspvar_int_mod_i;
    //
    //    p->AndI = hspvar_int_and_i;
    //    p->OrI  = hspvar_int_or_i;
    //    p->XorI = hspvar_int_xor_i;
    //
    //    p->EqI = hspvar_int_eq_i;
    //    p->NeI = hspvar_int_ne_i;
    //    p->GtI = hspvar_int_gt_i;
    //    p->LtI = hspvar_int_lt_i;
    //    p->GtEqI = hspvar_int_gt_eq_i;
    //    p->LtEqI = hspvar_int_lt_eq_i;
    //
    //    p->RrI = hspvar_int_rr_i;
    //    p->LrI = hspvar_int_lr_i;

    // サポート状況フラグ(HSPVAR_SUPPORT_*)
    p->vartype_name = (char *) "int"; // タイプ名
    p->version = 0x001; // 型タイプランタイムバージョン(0x100 = 1.0)
    p->support = HSPVAR_SUPPORT_STORAGE | HSPVAR_SUPPORT_FLEXARRAY;
    p->basesize = sizeof(int); // １つのデータが使用するサイズ(byte) / 可変長の時は-1
}
