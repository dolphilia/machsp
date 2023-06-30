
//
//	HSPVARコアモジュール
//	onion software/onitama 2003/4
//

#import "hspvar_double.h"
#import "strbuf.h"

//------------------------------------------------------------
// HSPVAR core interface (double)
//------------------------------------------------------------

#define hspvar_double_GetPtr(pval) ((double*)pval)

double hspvar_double_conv;
short *hspvar_double_aftertype;

/// Core
///
void *HspVarDouble_GetPtr(value_t *pval) {
    return (void *) (((double *) (pval->pt)) + pval->offset);
}

/// リクエストされた型 -> 自分の型への変換を行なう
///
/// (組み込み型にのみ対応でOK)
/// (参照元のデータを破壊しないこと)
///
void *HspVarDouble_Cnv(const void *buffer, int flag) {
    switch (flag) {
        case HSPVAR_FLAG_STR:
            hspvar_double_conv = (double) atof((char *) buffer);
            return &hspvar_double_conv;
        case HSPVAR_FLAG_INT:
            hspvar_double_conv = (double) (*(int *) buffer);
            return &hspvar_double_conv;
        case HSPVAR_FLAG_DOUBLE:
            break;
        default: {
            fprintf(stderr, "Error: %d\n", HSPVAR_ERROR_TYPEMISS);
            exit(EXIT_FAILURE);
        }
    }
    return (void *) buffer;
}

/*
 static void *HspVarDouble_CnvCustom( const void *buffer, int flag )
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
int HspVarDouble_GetVarSize(value_t *pval) {
    int size = pval->len[1];
    if (pval->len[2])
        size *= pval->len[2];
    if (pval->len[3])
        size *= pval->len[3];
    if (pval->len[4])
        size *= pval->len[4];
    size *= sizeof(double);
    return size;
}

/// PVALポインタの変数メモリを解放する
///
void HspVarDouble_Free(value_t *pval) {
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
void HspVarDouble_Alloc(value_t *pval, const value_t *pval2) {
    if (pval->len[1] < 1)
        pval->len[1] = 1; // 配列を最低1は確保する

    int size = HspVarDouble_GetVarSize(pval);
    pval->mode = HSPVAR_MODE_MALLOC;
    char *pt = strbuf_alloc(size);
    double *fv = (double *) pt;

    for (int i = 0; i < (int) (size / sizeof(double)); i++) {
        fv[i] = 0.0;
    }
    if (pval2 != NULL) {
        memcpy(pt, pval->pt, pval->size);
        strbuf_free(pval->pt);
    }
    pval->pt = pt;
    pval->size = size;
}

/*
 static void *HspVarDouble_ArrayObject( PVal *pval, int *mptype )
 {
 //		配列要素の指定 (文字列/連想配列用)
 //
 throw HSPERR_UNSUPPORTED_FUNCTION;
 return NULL;
 }
 */

/// Size
int HspVarDouble_GetSize(const void *pval) {
    return sizeof(double);
}

/// Set
void HspVarDouble_Set(value_t *pval, void *pdat, const void *in) {
    //*hspvar_double_GetPtr(pdat) = *((double *)(in));
    memcpy(pdat, in, sizeof(double));
}

/// Add
void HspVarDouble_AddI(void *pval, const void *val) {
    *hspvar_double_GetPtr(pval) += *((double *) (val));
    *hspvar_double_aftertype = HSPVAR_FLAG_DOUBLE;
}

/// Sub
void HspVarDouble_SubI(void *pval, const void *val) {
    *hspvar_double_GetPtr(pval) -= *((double *) (val));
    *hspvar_double_aftertype = HSPVAR_FLAG_DOUBLE;
}

/// Mul
void HspVarDouble_MulI(void *pval, const void *val) {
    *hspvar_double_GetPtr(pval) *= *((double *) (val));
    *hspvar_double_aftertype = HSPVAR_FLAG_DOUBLE;
}

/// Div
void HspVarDouble_DivI(void *pval, const void *val) {
    double p = *((double *) (val));
    if (p == 0.0) {
        fprintf(stderr, "Error: %d\n", HSPVAR_ERROR_DIVZERO);
        exit(EXIT_FAILURE);
    }
    *hspvar_double_GetPtr(pval) /= p;
    *hspvar_double_aftertype = HSPVAR_FLAG_DOUBLE;
}

/// Mod
void HspVarDouble_ModI(void *pval, const void *val) {
    double p = *((double *) (val));
    if (p == 0.0) {
        fprintf(stderr, "Error: %d\n", HSPVAR_ERROR_DIVZERO);
        exit(EXIT_FAILURE);
    }
    double dval = *hspvar_double_GetPtr(pval);
    *hspvar_double_GetPtr(pval) = fmod(dval, p);
    *hspvar_double_aftertype = HSPVAR_FLAG_DOUBLE;
}

/// Eq
void HspVarDouble_EqI(void *pval, const void *val) {
    *((int *) pval) = (*hspvar_double_GetPtr(pval) == *((double *) (val)));
    *hspvar_double_aftertype = HSPVAR_FLAG_INT;
}

/// Ne
void HspVarDouble_NeI(void *pval, const void *val) {
    *((int *) pval) = (*hspvar_double_GetPtr(pval) != *((double *) (val)));
    *hspvar_double_aftertype = HSPVAR_FLAG_INT;
}

/// Gt
void HspVarDouble_GtI(void *pval, const void *val) {
    *((int *) pval) = (*hspvar_double_GetPtr(pval) > *((double *) (val)));
    *hspvar_double_aftertype = HSPVAR_FLAG_INT;
}

/// Lt
void HspVarDouble_LtI(void *pval, const void *val) {
    *((int *) pval) = (*hspvar_double_GetPtr(pval) < *((double *) (val)));
    *hspvar_double_aftertype = HSPVAR_FLAG_INT;
}

/// GtEq
void HspVarDouble_GtEqI(void *pval, const void *val) {
    *((int *) pval) = (*hspvar_double_GetPtr(pval) >= *((double *) (val)));
    *hspvar_double_aftertype = HSPVAR_FLAG_INT;
}

/// LtEq
void HspVarDouble_LtEqI(void *pval, const void *val) {
    *((int *) pval) = (*hspvar_double_GetPtr(pval) <= *((double *) (val)));
    *hspvar_double_aftertype = HSPVAR_FLAG_INT;
}

/*
 // INVALID
 static void HspVarDouble_Invalid( PDAT *pval, const void *val )
 {
 throw( HSPVAR_ERROR_INVALID );
 }
 */

void *HspVarDouble_GetBlockSize(value_t *pval, void *pdat, int *size) {
    *size = pval->size - (int) (((char *) pdat) - pval->pt);
    return (pdat);
}

void HspVarDouble_AllocBlock(value_t *pval, void *pdat, int size) {
}

//------------------------------------------------------------

void HspVarDouble_Init(hspvar_proc_t *p) {
    hspvar_double_aftertype = &p->aftertype;

    //    p->Set = HspVarDouble_Set;
    //    p->Cnv = HspVarDouble_Cnv;
    //    p->GetPtr = HspVarDouble_GetPtr;
    //    //	p->CnvCustom = HspVarDouble_CnvCustom;
    //    p->GetSize = HspVarDouble_GetSize;
    //    p->GetBlockSize = HspVarDouble_GetBlockSize;
    //    p->AllocBlock = HspVarDouble_AllocBlock;
    //
    //    //	p->ArrayObject = HspVarDouble_ArrayObject;
    //    p->Alloc = HspVarDouble_Alloc;
    //    p->Free = HspVarDouble_Free;
    //
    //    p->AddI = HspVarDouble_AddI;
    //    p->SubI = HspVarDouble_SubI;
    //    p->MulI = HspVarDouble_MulI;
    //    p->DivI = HspVarDouble_DivI;
    //    p->ModI = HspVarDouble_ModI;
    //
    //    //	p->AndI = HspVarDouble_Invalid;
    //    //	p->OrI  = HspVarDouble_Invalid;
    //    //	p->XorI = HspVarDouble_Invalid;
    //
    //    p->EqI = HspVarDouble_EqI;
    //    p->NeI = HspVarDouble_NeI;
    //    p->GtI = HspVarDouble_GtI;
    //    p->LtI = HspVarDouble_LtI;
    //    p->GtEqI = HspVarDouble_GtEqI;
    //    p->LtEqI = HspVarDouble_LtEqI;

    //	p->RrI = HspVarDouble_Invalid;
    //	p->LrI = HspVarDouble_Invalid;

    p->vartype_name = (char *) "double"; // タイプ名
    p->version = 0x001; // 型タイプランタイムバージョン(0x100 = 1.0)
    p->support = HSPVAR_SUPPORT_STORAGE | HSPVAR_SUPPORT_FLEXARRAY;
    // サポート状況フラグ(HSPVAR_SUPPORT_*)
    p->basesize = sizeof(double); // １つのデータが使用するサイズ(byte) / 可変長の時は-1
}
