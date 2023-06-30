
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
void *HspVarLabel_GetPtr(value_t *pval) {
    return (void *) (((HSPVAR_LABEL * )(pval->pt)) + pval->offset);
}

/// PVALポインタの変数が必要とするサイズを取得する
///
/// (sizeフィールドに設定される)
///
int HspVarLabel_GetVarSize(value_t *pval) {
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
void HspVarLabel_Free(value_t *pval) {
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
void HspVarLabel_Alloc(value_t *pval, const value_t *pval2) {
    if (pval->len[1] < 1)
        pval->len[1] = 1; // 配列を最低1は確保する

    int size = HspVarLabel_GetVarSize(pval);
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
int HspVarLabel_GetSize(const void *pval) {
    return sizeof(HSPVAR_LABEL);
}

/// Using
int HspVarLabel_GetUsing(const void *pdat) {
    // (実態のポインタが渡されます)
    return ((void *)pdat != NULL);
}

/// Set
void HspVarLabel_Set(value_t *pval, void *pdat, const void *in) {
    *hspvar_label_GetPtr(pdat) = *((HSPVAR_LABEL * )(in));
}

void *HspVarLabel_GetBlockSize(value_t *pval, void *pdat, int *size) {
    *size = pval->size - (int) (((char *) pdat) - pval->pt);
    return (pdat);
}

void HspVarLabel_AllocBlock(value_t *pval, void *pdat, int size) {
}

//------------------------------------------------------------

void HspVarLabel_Init(hspvar_proc_t *p) {
    //    p->Set = HspVarLabel_Set;
    //    p->GetPtr = HspVarLabel_GetPtr;
    //    p->GetSize = HspVarLabel_GetSize;
    //    p->GetUsing = HspVarLabel_GetUsing;
    //    p->GetBlockSize = HspVarLabel_GetBlockSize;
    //    p->AllocBlock = HspVarLabel_AllocBlock;
    //    p->Alloc = HspVarLabel_Alloc;
    //    p->Free = HspVarLabel_Free;
    p->vartype_name = (char *) "label"; // タイプ名
    p->version = 0x001; // 型タイプランタイムバージョン(0x100 = 1.0)
    p->support = HSPVAR_SUPPORT_STORAGE | HSPVAR_SUPPORT_FLEXARRAY | HSPVAR_SUPPORT_VARUSE;
    // サポート状況フラグ(HSPVAR_SUPPORT_*)
    p->basesize = sizeof(HSPVAR_LABEL); // １つのデータが使用するサイズ(byte) / 可変長の時は-1
}

