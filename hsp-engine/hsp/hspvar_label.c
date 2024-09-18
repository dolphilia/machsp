
//
//	HSPVARコアモジュール
//	onion software/onitama 2007/1
//

#import "hspvar_label.h"
#import "strbuf.h"


//------------------------------------------------------------
// HSPVAR core interface (label)
//------------------------------------------------------------

#define hspvar_label_GetPtr(pval) ((HSPVAR_LABEL*)pval)

/// Core
void *hspvar_label_get_ptr(value_t *pval) {
    return (void *) (((HSPVAR_LABEL * )(pval->pt)) + pval->offset);
}

/// PVALポインタの変数が必要とするサイズを取得する
///
/// (sizeフィールドに設定される)
///
int hspvar_label_get_var_size(value_t *pval) {
    int size = pval->len[1];
    if (pval->len[2])
        size *= pval->len[2];
    if (pval->len[3])
        size *= pval->len[3];
    if (pval->len[4])
        size *= pval->len[4];
    size *= sizeof(HSPVAR_LABEL);
    return size;
}

/// PVALポインタの変数メモリを解放する
///
void hspvar_label_free(value_t *pval) {
    if (pval->mode == HSPVAR_MODE_MALLOC) {
        strbuf_free(pval->pt);
    }
    pval->pt = NULL;
    pval->mode = HSPVAR_MODE_NONE;
}

/// pval変数が必要とするサイズを確保する。
///
/// (pvalがすでに確保されているメモリ解放は呼び出し側が行なう)
/// (flagの設定は呼び出し側が行なう)
/// (pval2がNULLの場合は、新規データ)
/// (pval2が指定されている場合は、pval2の内容を継承して再確保)
///
void hspvar_label_alloc(value_t *pval, const value_t *pval2) {
    if (pval->len[1] < 1)
        pval->len[1] = 1; // 配列を最低1は確保する

    int size = hspvar_label_get_var_size(pval);
    pval->mode = HSPVAR_MODE_MALLOC;
    char *pt = strbuf_alloc(size);
    HSPVAR_LABEL *fv = (HSPVAR_LABEL *) pt;

    for (int i = 0; i < (int) (size / sizeof(HSPVAR_LABEL)); i++) {
        fv[i] = NULL;
    }
    if (pval2 != NULL) {
        memcpy(pt, pval->pt, pval->size);
        strbuf_free(pval->pt);
    }
    pval->pt = pt;
    pval->size = size;
}

/// Size
int hspvar_label_get_size(const void *pval) {
    return sizeof(HSPVAR_LABEL);
}

/// Using
int hspvar_label_get_using(const void *pdat) {
    // (実態のポインタが渡されます)
    return ((void *)pdat != NULL);
}

/// Set
void hspvar_label_set(value_t *pval, void *pdat, const void *in) {
    *hspvar_label_GetPtr(pdat) = *((HSPVAR_LABEL * )(in));
}

void *hspvar_label_get_block_size(value_t *pval, void *pdat, int *size) {
    *size = pval->size - (int) (((char *) pdat) - pval->pt);
    return (pdat);
}

void hspvar_label_alloc_block(value_t *pval, void *pdat, int size) {
}

//------------------------------------------------------------

void hspvar_label_init(hspvar_proc_t *p) {
    //    p->Set = hspvar_label_set;
    //    p->GetPtr = hspvar_label_get_ptr;
    //    p->GetSize = HspVarLabel_GetSize;
    //    p->GetUsing = hspvar_label_get_using;
    //    p->GetBlockSize = HspVarLabel_GetBlockSize;
    //    p->AllocBlock = hspvar_label_alloc_block;
    //    p->Alloc = hspvar_label_alloc;
    //    p->Free = hspvar_label_free;
    p->vartype_name = (char *) "label"; // タイプ名
    p->version = 0x001; // 型タイプランタイムバージョン(0x100 = 1.0)
    p->support = HSPVAR_SUPPORT_STORAGE | HSPVAR_SUPPORT_FLEXARRAY | HSPVAR_SUPPORT_VARUSE;
    // サポート状況フラグ(HSPVAR_SUPPORT_*)
    p->basesize = sizeof(HSPVAR_LABEL); // １つのデータが使用するサイズ(byte) / 可変長の時は-1
}

