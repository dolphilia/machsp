//
//	HSPVARコアモジュール
//	onion software/onitama 2003/4

#import "hspvar_int.h"
#import "strbuf.h"
#import "supio_hsp3.h"

@implementation ViewController (hspvar_int)

//------------------------------------------------------------
// HSPVAR core interface (int)
//------------------------------------------------------------

#define hspvar_int_GetPtr(pval) ((int*)pval)
int hspvar_int_conv;

/// Core
PDAT *HspVarInt_GetPtr(PVal *pval) {
    return (PDAT *) (((int *) (pval->pt)) + pval->offset);
}

/// リクエストされた型 -> 自分の型への変換を行なう
///
/// (組み込み型にのみ対応でOK)
/// (参照元のデータを破壊しないこと)
///
void *HspVarInt_Cnv(const void *buffer, int flag) {
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
            NSString *error_str = [NSString stringWithFormat:@"%d", HSPVAR_ERROR_TYPEMISS];
            @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
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
int HspVarInt_GetVarSize(PVal *pval) {
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
void HspVarInt_Free(PVal *pval) {
    if (pval->mode == HSPVAR_MODE_MALLOC) {
        sbFree(pval->pt);
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
void HspVarInt_Alloc(PVal *pval, const PVal *pval2) {
    if (pval->len[1] < 1)
        pval->len[1] = 1; // 配列を最低1は確保する

    int size = HspVarInt_GetVarSize(pval);
    pval->mode = HSPVAR_MODE_MALLOC;
    char *pt = sbAlloc(size);
    int *fv = (int *) pt;

    for (int i = 0; i < (int) (size / sizeof(int)); i++) {
        fv[i] = 0;
    }
    if (pval2 != NULL) {
        memcpy(pt, pval->pt, pval->size);
        sbFree(pval->pt);
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
int HspVarInt_GetSize(const PDAT *pval) {
    return sizeof(int);
}

/// Set
void HspVarInt_Set(PVal *pval, PDAT *pdat, const void *in) {
    *hspvar_int_GetPtr(pdat) = *((int *) (in));
}

/// Add
void HspVarInt_AddI(PDAT *pval, const void *val) {
    *hspvar_int_GetPtr(pval) += *((int *) (val));
}

/// Sub
void HspVarInt_SubI(PDAT *pval, const void *val) {
    *hspvar_int_GetPtr(pval) -= *((int *) (val));
}

/// Mul
void HspVarInt_MulI(PDAT *pval, const void *val) {
    *hspvar_int_GetPtr(pval) *= *((int *) (val));
}

/// Div
void HspVarInt_DivI(PDAT *pval, const void *val) {
    int p = *((int *) (val));
    if (p == 0) {
        NSString *error_str = [NSString stringWithFormat:@"%d", HSPVAR_ERROR_DIVZERO];
        @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
    }
    *hspvar_int_GetPtr(pval) /= p;
}

/// Mod
void HspVarInt_ModI(PDAT *pval, const void *val) {
    int p = *((int *) (val));
    if (p == 0) {
        NSString *error_str = [NSString stringWithFormat:@"%d", HSPVAR_ERROR_DIVZERO];
        @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
    }
    *hspvar_int_GetPtr(pval) %= p;
}

/// And
void HspVarInt_AndI(PDAT *pval, const void *val) {
    *hspvar_int_GetPtr(pval) &= *((int *) (val));
}

/// Or
void HspVarInt_OrI(PDAT *pval, const void *val) {
    *hspvar_int_GetPtr(pval) |= *((int *) (val));
}

/// Xor
void HspVarInt_XorI(PDAT *pval, const void *val) {
    *hspvar_int_GetPtr(pval) ^= *((int *) (val));
}

/// Eq
void HspVarInt_EqI(PDAT *pval, const void *val) {
    *hspvar_int_GetPtr(pval) = (*hspvar_int_GetPtr(pval) == *((int *) (val)));
}

/// Ne
void HspVarInt_NeI(PDAT *pval, const void *val) {
    *hspvar_int_GetPtr(pval) = (*hspvar_int_GetPtr(pval) != *((int *) (val)));
}

/// Gt
void HspVarInt_GtI(PDAT *pval, const void *val) {
    *hspvar_int_GetPtr(pval) = (*hspvar_int_GetPtr(pval) > *((int *) (val)));
}

/// Lt
void HspVarInt_LtI(PDAT *pval, const void *val) {
    *hspvar_int_GetPtr(pval) = (*hspvar_int_GetPtr(pval) < *((int *) (val)));
}

/// GtEq
void HspVarInt_GtEqI(PDAT *pval, const void *val) {
    *hspvar_int_GetPtr(pval) = (*hspvar_int_GetPtr(pval) >= *((int *) (val)));
}

/// LtEq
void HspVarInt_LtEqI(PDAT *pval, const void *val) {
    *hspvar_int_GetPtr(pval) = (*hspvar_int_GetPtr(pval) <= *((int *) (val)));
}

/// Rr
void HspVarInt_RrI(PDAT *pval, const void *val) {
    *hspvar_int_GetPtr(pval) >>= *((int *) (val));
}

/// Lr
void HspVarInt_LrI(PDAT *pval, const void *val) {
    *hspvar_int_GetPtr(pval) <<= *((int *) (val));
}

void *HspVarInt_GetBlockSize(PVal *pval, PDAT *pdat, int *size) {
    *size = pval->size - (int) (((char *) pdat) - pval->pt);
    return (pdat);
}

void HspVarInt_AllocBlock(PVal *pval, PDAT *pdat, int size) {
}

//------------------------------------------------------------

void HspVarInt_Init(HspVarProc *p) {
    //    p->Set = HspVarInt_Set;
    //    p->Cnv = HspVarInt_Cnv;
    //    p->GetPtr = HspVarInt_GetPtr;
    //    //	p->CnvCustom = HspVarInt_CnvCustom;
    //    p->GetSize = HspVarInt_GetSize;
    //    p->GetBlockSize = HspVarInt_GetBlockSize;
    //    p->AllocBlock = HspVarInt_AllocBlock;
    //
    //    //	p->ArrayObject = HspVarInt_ArrayObject;
    //    p->Alloc = HspVarInt_Alloc;
    //    p->Free = HspVarInt_Free;
    //
    //    p->AddI = HspVarInt_AddI;
    //    p->SubI = HspVarInt_SubI;
    //    p->MulI = HspVarInt_MulI;
    //    p->DivI = HspVarInt_DivI;
    //    p->ModI = HspVarInt_ModI;
    //
    //    p->AndI = HspVarInt_AndI;
    //    p->OrI  = HspVarInt_OrI;
    //    p->XorI = HspVarInt_XorI;
    //
    //    p->EqI = HspVarInt_EqI;
    //    p->NeI = HspVarInt_NeI;
    //    p->GtI = HspVarInt_GtI;
    //    p->LtI = HspVarInt_LtI;
    //    p->GtEqI = HspVarInt_GtEqI;
    //    p->LtEqI = HspVarInt_LtEqI;
    //
    //    p->RrI = HspVarInt_RrI;
    //    p->LrI = HspVarInt_LrI;

    // サポート状況フラグ(HSPVAR_SUPPORT_*)
    p->vartype_name = (char *) "int"; // タイプ名
    p->version = 0x001; // 型タイプランタイムバージョン(0x100 = 1.0)
    p->support = HSPVAR_SUPPORT_STORAGE | HSPVAR_SUPPORT_FLEXARRAY;
    p->basesize = sizeof(int); // １つのデータが使用するサイズ(byte) / 可変長の時は-1
}

@end
