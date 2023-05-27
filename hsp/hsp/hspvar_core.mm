//
//	HSPVARマネージャー
//	onion software/onitama 2003/4
//
//関数ポインタの使用箇所あり
//->LrI
//->Cnv

#import "hspvar_core.h"
#import "debug_message.h"
#import "hsp3struct_debug.h"
#import "hsp3struct_var.h"
#import "hspvar_label.h"
#import "strbuf.h"
#import "supio_hsp3.h"
#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <stdio.h>
#import <stdlib.h>
#import <string.h>
#import "hspvar_double.h"
#import "hspvar_int.h"
#import "hspvar_label.h"
#import "hspvar_str.h"
#import "hspvar_struct.h"
#import "utility_string.h"

@implementation ViewController (hspvar_core)

//------------------------------------------------------------
// master pointer
//------------------------------------------------------------

PVal *mem_pval;
HspVarProc *hspvarproc;
int hspvartype_max;
int hspvartype_limit;

///        変数データの実態ポインタを得る
///
///        (APTRとpvalから実態を求める)
///
PDAT *HspVarCorePtrAPTR(PVal *pv, APTR ofs) {
    pv->offset = ofs;
    PDAT *dst;
    if (strcmp(hspvarproc[(pv)->flag].vartype_name, "int") == 0) { //整数のFree
        dst = HspVarInt_GetPtr(pv);
    } else if (strcmp(hspvarproc[(pv)->flag].vartype_name, "double") == 0) { //実数のFree
        dst = HspVarDouble_GetPtr(pv);
    } else if (strcmp(hspvarproc[(pv)->flag].vartype_name, "str") == 0) { //文字列のFree
        dst = HspVarStr_GetPtr(pv);
    } else if (strcmp(hspvarproc[(pv)->flag].vartype_name, "label") == 0) { //ラベルのFree
        dst = HspVarLabel_GetPtr(pv);
    } else if (strcmp(hspvarproc[(pv)->flag].vartype_name, "struct") == 0) { // structのFree
        dst = HspVarLabel_GetPtr(pv);
    } else {
        NSString *error_str = [NSString stringWithFormat:@"%d", HSPERR_SYNTAX];
        @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
    }
    return dst; // hspvarproc[(pv)->flag].GetPtr(pv);
}

void HspVarCoreInit(void) {
    hspvarproc = (HspVarProc *) sbAlloc(sizeof(HspVarProc) * HSPVAR_FLAG_MAX);
    hspvartype_max = HSPVAR_FLAG_MAX;
    for (int i = 0; i < HSPVAR_FLAG_MAX; i++) {
        hspvarproc[i].flag = 0;
    }

    //		mpval(テンポラリ変数)を初期化します
    //		(実態の初期化は、変数使用時に行なわれます)
    PVal *pval;
    mem_pval = (PVal *) sbAlloc(sizeof(PVal) * HSPVAR_FLAG_MAX);
    for (int i = 0; i < HSPVAR_FLAG_MAX; i++) {
        pval = &mem_pval[i];
        pval->mode = HSPVAR_MODE_NONE;
        pval->flag = HSPVAR_FLAG_INT; // 仮の型
    }
}

void HspVarCoreBye(void) {
    for (int i = 0; i < hspvartype_max; i++) {
        if (mem_pval[i].mode == HSPVAR_MODE_MALLOC) {
            // HspVarCoreDispose( &mem_pval[i] );
            if (strcmp(hspvarproc[(&mem_pval[i])->flag].vartype_name, "int") == 0) { //整数のFree
                HspVarInt_Free(&mem_pval[i]);
            } else if (strcmp(hspvarproc[(&mem_pval[i])->flag].vartype_name, "double") == 0) { //実数のFree
                HspVarDouble_Free(&mem_pval[i]);
            } else if (strcmp(hspvarproc[(&mem_pval[i])->flag].vartype_name, "str") == 0) { //文字列のFree
                HspVarStr_Free(&mem_pval[i]);
            } else if (strcmp(hspvarproc[(&mem_pval[i])->flag].vartype_name, "label") == 0) { //ラベルのFree
                HspVarLabel_Free(&mem_pval[i]);
            } else if (strcmp(hspvarproc[(&mem_pval[i])->flag].vartype_name, "struct") == 0) { // structのFree
                HspVarLabel_Free(&mem_pval[i]);
            } else {
                NSString *error_str = [NSString stringWithFormat:@"%d", HSPERR_SYNTAX];
                @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
            }
        }
    }
    sbFree(mem_pval);
    sbFree(hspvarproc);
}

/// VARTYPEを初期化する(HspVarCoreInitの後で呼ぶ)
///
/// (expandに拡張するVARTYPEの数を指定する)
///
void HspVarCoreResetVartype(int expand) {
    hspvartype_limit = hspvartype_max + expand;
    if (expand >= 0) {
        hspvarproc = (HspVarProc *) sbExpand((char *) hspvarproc, sizeof(HspVarProc) * hspvartype_limit);
        mem_pval = (PVal *) sbExpand((char *) mem_pval, sizeof(PVal) * hspvartype_limit);
    }

    // 標準の型を登録する
    HspVarCoreRegisterType(HSPVAR_FLAG_INT, (char *) "int");
    HspVarCoreRegisterType(HSPVAR_FLAG_STR, (char *) "str");
    HspVarCoreRegisterType(HSPVAR_FLAG_DOUBLE, (char *) "double");
    HspVarCoreRegisterType(HSPVAR_FLAG_STRUCT, (char *) "struct");
    HspVarCoreRegisterType(HSPVAR_FLAG_LABEL, (char *) "label"); // ラベル型(3.1)
}

int HspVarCoreAddType() {
    PVal *pval;
    if (hspvartype_max >= hspvartype_limit)
        return -1;
    int id = hspvartype_max++;
    // hspvarproc = (HspVarProc *)sbExpand( (char *)hspvarproc, sizeof(HspVarProc)
    // * hspvartype_max );
    hspvarproc[id].flag = 0;
    // mem_pval = (PVal *)sbExpand( (char *)mem_pval, sizeof(PVal) *
    // hspvartype_max );
    pval = &mem_pval[id];
    pval->mode = HSPVAR_MODE_NONE;
    pval->flag = HSPVAR_FLAG_INT; // 仮の型
    return id;
}

static void PutInvalid(void) {
    NSString *error_str = [NSString stringWithFormat:@"%d", HSPERR_UNSUPPORTED_FUNCTION];
    @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
}

void HspVarCoreRegisterType(int flag, char *vartype_name) {
    int id = flag;
    if (id < 0) {
        id = HspVarCoreAddType();
        if (id < 0) {
            return;
        }
    }

    HspVarProc *p = &hspvarproc[id];
    p->flag = p->aftertype = id;

    //void** procs;
    // procs = (void **)(&p->Cnv);
    // while(1) {
    //    *procs = (void *)(PutInvalid);
    //    if ( procs == (void **)(&p->LrI) ) //$
    //        break;
    //    procs++;
    //}

    //	初期化関数の呼び出し
    if (strcmp(vartype_name, "int") == 0) {
        HspVarInt_Init(p);
    } else if (strcmp(vartype_name, "str") == 0) {
        HspVarStr_Init(p);
    } else if (strcmp(vartype_name, "double") == 0) {
        HspVarDouble_Init(p);
    } else if (strcmp(vartype_name, "struct") == 0) {
        HspVarStruct_Init(p);
    } else if (strcmp(vartype_name, "label") == 0) {
        HspVarLabel_Init(p);
    } else {
        NSString *error_str = [NSString stringWithFormat:@"%d", HSPERR_UNKNOWN_CODE];
        @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
    }
    // func( p );
}

/*------------------------------------------------------------*/

/// 指定されたポインタからのクローンになる
///
void HspVarCoreDupPtr(PVal *pval, int flag, void *ptr, int size) {
    PDAT *buf = (PDAT *) ptr;
    HspVarProc *p = &hspvarproc[flag];

    // HspVarCoreDispose( pval );
    if (strcmp(hspvarproc[(pval)->flag].vartype_name, "int") == 0) { //整数のFree
        HspVarInt_Free(pval);
    } else if (strcmp(hspvarproc[(pval)->flag].vartype_name, "double") == 0) { //実数のFree
        HspVarDouble_Free(pval);
    } else if (strcmp(hspvarproc[(pval)->flag].vartype_name, "str") == 0) { //文字列のFree
        HspVarStr_Free(pval);
    } else if (strcmp(hspvarproc[(pval)->flag].vartype_name, "label") == 0) { //ラベルのFree
        HspVarLabel_Free(pval);
    } else if (strcmp(hspvarproc[(pval)->flag].vartype_name, "struct") == 0) { // structのFree
        HspVarLabel_Free(pval);
    } else {
        NSString *error_str = [NSString stringWithFormat:@"%d", HSPERR_SYNTAX];
        @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
    }

    pval->pt = (char *) buf;
    pval->flag = flag;
    pval->size = size;
    pval->mode = HSPVAR_MODE_CLONE;
    pval->len[0] = 1;

    if (p->basesize < 0) {
        pval->len[1] = 1;
    } else {
        pval->len[1] = size / p->basesize;
    }
    pval->len[2] = 0;
    pval->len[3] = 0;
    pval->len[4] = 0;
    pval->offset = 0;
    pval->arraycnt = 0;
    pval->support = HSPVAR_SUPPORT_STORAGE;
}

/// 指定された変数のクローンになる
///
void HspVarCoreDup(PVal *pval, PVal *arg, APTR aptr) {
    int size;
    PDAT *buf = HspVarCorePtrAPTR(arg, aptr);
    HspVarProc *p = &hspvarproc[arg->flag];

    // HspVarCoreGetBlockSize( arg, buf, &size );
    void *dst;
    if (strcmp(hspvarproc[(arg)->flag].vartype_name, "int") == 0) { //整数のGetBlockSize
        dst = HspVarInt_GetBlockSize(arg, buf, &size);
    } else if (strcmp(hspvarproc[(arg)->flag].vartype_name, "double") == 0) { //実数のGetBlockSize
        dst = HspVarDouble_GetBlockSize(arg, buf, &size);
    } else if (strcmp(hspvarproc[(arg)->flag].vartype_name, "str") == 0) { //文字列のGetBlockSize
        dst = HspVarStr_GetBlockSize(arg, buf, &size);
    } else if (strcmp(hspvarproc[(arg)->flag].vartype_name, "label") == 0) { //ラベルのGetBlockSize
        dst = HspVarLabel_GetBlockSize(arg, buf, &size);
    } else if (strcmp(hspvarproc[(arg)->flag].vartype_name, "struct") == 0) { // structのGetBlockSize
        dst = HspVarLabel_GetBlockSize(arg, buf, &size);
    } else {
        NSString *error_str = [NSString stringWithFormat:@"%d", HSPERR_SYNTAX];
        @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
    }

    HspVarCoreDupPtr(pval, arg->flag, buf, size);

}

/// 配列を確保する
///
/// (len1〜len4は、4byte単位なので注意)
///
void HspVarCoreDim(PVal *pval, int flag, int len1, int len2, int len3, int len4) {
    HspVarProc *p = &hspvarproc[flag];

    if ((len1 < 0) || (len2 < 0) || (len3 < 0) || (len4 < 0)) {
        NSString *error_str = [NSString stringWithFormat:@"%d", HSPVAR_ERROR_ILLEGALPRM];
        @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
    }

    // HspVarCoreDispose( pval );
    if (strcmp(hspvarproc[(pval)->flag].vartype_name, "int") == 0) { //整数のFree
        HspVarInt_Free(pval);
    } else if (strcmp(hspvarproc[(pval)->flag].vartype_name, "double") == 0) { //実数のFree
        HspVarDouble_Free(pval);
    } else if (strcmp(hspvarproc[(pval)->flag].vartype_name, "str") == 0) { //文字列のFree
        HspVarStr_Free(pval);
    } else if (strcmp(hspvarproc[(pval)->flag].vartype_name, "label") == 0) { //ラベルのFree
        HspVarLabel_Free(pval);
    } else if (strcmp(hspvarproc[(pval)->flag].vartype_name, "struct") == 0) { // structのFree
        HspVarLabel_Free(pval);
    } else {
        NSString *error_str = [NSString stringWithFormat:@"%d", HSPERR_SYNTAX];
        @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
    }

    pval->flag = flag;
    pval->len[0] = 1;
    pval->offset = 0;
    pval->arraycnt = 0;
    pval->support = p->support;
    pval->len[1] = len1;
    pval->len[2] = len2;
    pval->len[3] = len3;
    pval->len[4] = len4;

    if (strcmp(p->vartype_name, "int") == 0) { //整数のAlloc
        HspVarInt_Alloc(pval, NULL);
    } else if (strcmp(p->vartype_name, "double") == 0) { //実数のAlloc
        HspVarDouble_Alloc(pval, NULL);
    } else if (strcmp(p->vartype_name, "str") == 0) { //文字列のAlloc
        HspVarStr_Alloc(pval, NULL);
    } else if (strcmp(p->vartype_name, "label") == 0) { //ラベルのAlloc
        HspVarLabel_Alloc(pval, NULL);
    } else if (strcmp(p->vartype_name, "struct") == 0) { // structのAlloc
        HspVarLabel_Alloc(pval, NULL);
    } else {
        NSString *error_str = [NSString stringWithFormat:@"%d", HSPERR_SYNTAX];
        @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
    }
}

/// 配列を確保する(可変長配列用)
///
/// (len1〜len4は、4byte単位なので注意)
///
void HspVarCoreDimFlex(PVal *pval, int flag, int len0, int len1, int len2, int len3, int len4) {
    HspVarProc *p = &hspvarproc[flag];

    if ((len1 < 0) || (len2 < 0) || (len3 < 0) || (len4 < 0)) {
        NSString *error_str = [NSString stringWithFormat:@"%d", HSPVAR_ERROR_ILLEGALPRM];
        @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
    }

    // HspVarCoreDispose( pval );
    if (strcmp(hspvarproc[(pval)->flag].vartype_name, "int") == 0) { //整数のFree
        HspVarInt_Free(pval);
    } else if (strcmp(hspvarproc[(pval)->flag].vartype_name, "double") == 0) { //実数のFree
        HspVarDouble_Free(pval);
    } else if (strcmp(hspvarproc[(pval)->flag].vartype_name, "str") == 0) { //文字列のFree
        HspVarStr_Free(pval);
    } else if (strcmp(hspvarproc[(pval)->flag].vartype_name, "label") == 0) { //ラベルのFree
        HspVarLabel_Free(pval);
    } else if (strcmp(hspvarproc[(pval)->flag].vartype_name, "struct") == 0) { // structのFree
        HspVarLabel_Free(pval);
    } else {
        NSString *error_str = [NSString stringWithFormat:@"%d", HSPERR_SYNTAX];
        @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
    }

    pval->flag = flag;
    pval->len[0] = len0;
    pval->offset = 0;
    pval->arraycnt = 0;
    pval->support = p->support;
    pval->len[1] = len1;
    pval->len[2] = len2;
    pval->len[3] = len3;
    pval->len[4] = len4;

    if (strcmp(p->vartype_name, "int") == 0) { //整数のAlloc
        HspVarInt_Alloc(pval, NULL);
    } else if (strcmp(p->vartype_name, "double") == 0) { //実数のAlloc
        HspVarDouble_Alloc(pval, NULL);
    } else if (strcmp(p->vartype_name, "str") == 0) { //文字列のAlloc
        HspVarStr_Alloc(pval, NULL);
    } else if (strcmp(p->vartype_name, "label") == 0) { //ラベルのAlloc
        HspVarLabel_Alloc(pval, NULL);
    } else if (strcmp(p->vartype_name, "struct") == 0) { // structのAlloc
        HspVarLabel_Alloc(pval, NULL);
    } else {
        NSString *error_str = [NSString stringWithFormat:@"%d", HSPERR_SYNTAX];
        @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
    }

    pval->len[0] = 1;
}

/// 配列を拡張する
///
void HspVarCoreReDim(PVal *pval, int lenid, int len) {
    HspVarProc *p = &hspvarproc[pval->flag];
    pval->len[lenid] = len;
    if (strcmp(p->vartype_name, "int") == 0) { //整数のAlloc
        HspVarInt_Alloc(pval, pval);
    } else if (strcmp(p->vartype_name, "double") == 0) { //実数のAlloc
        HspVarDouble_Alloc(pval, pval);
    } else if (strcmp(p->vartype_name, "str") == 0) { //文字列のAlloc
        HspVarStr_Alloc(pval, pval);
    } else if (strcmp(p->vartype_name, "label") == 0) { //ラベルのAlloc
        HspVarLabel_Alloc(pval, pval);
    } else if (strcmp(p->vartype_name, "struct") == 0) { // structのAlloc
        HspVarLabel_Alloc(pval, pval);
    } else {
        NSString *error_str = [NSString stringWithFormat:@"%d", HSPERR_SYNTAX];
        @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
    }
}

/// 指定タイプの変数を最小メモリで初期化する
///
void HspVarCoreClear(PVal *pval, int flag) {
    HspVarCoreDim(pval, flag, 1, 0, 0, 0); // 最小サイズのメモリを確保
}

/// 指定タイプの変数を最小メモリで初期化する(テンポラリ用)
///
void HspVarCoreClearTemp(PVal *pval, int flag) {
    HspVarCoreDim(pval, flag, 1, 0, 0, 0); // 最小サイズのメモリを確保
    pval->support |= HSPVAR_SUPPORT_TEMPVAR;
}

/// 指定されたtypeフラグに変換された値のポインタを得る
///
void *HspVarCoreCnvPtr(PVal *pval, int flag) {
    PDAT *dst;
    if (pval->flag == flag) {
        if (strcmp(hspvarproc[flag].vartype_name, "int") == 0) { //整数のFree
            dst = HspVarInt_GetPtr(pval);
        } else if (strcmp(hspvarproc[flag].vartype_name, "double") == 0) { //実数のFree
            dst = HspVarDouble_GetPtr(pval);
        } else if (strcmp(hspvarproc[flag].vartype_name, "str") == 0) { //文字列のFree
            dst = HspVarStr_GetPtr(pval);
        } else if (strcmp(hspvarproc[flag].vartype_name, "label") == 0) { //ラベルのFree
            dst = HspVarLabel_GetPtr(pval);
        } else if (strcmp(hspvarproc[flag].vartype_name, "struct") == 0) { // structのFree
            dst = HspVarLabel_GetPtr(pval);
        } else {
            NSString *error_str = [NSString stringWithFormat:@"%d", HSPERR_SYNTAX];
            @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
        }
        return (void *) dst; // hspvarproc[ flag ].GetPtr( pval );
    }
    // 型変換をする
    void *buf;

    // buf = hspvarproc[ pval->flag ].GetPtr( pval );
    if (strcmp(hspvarproc[pval->flag].vartype_name, "int") == 0) { //整数のFree
        dst = HspVarInt_GetPtr(pval);
    } else if (strcmp(hspvarproc[pval->flag].vartype_name, "double") == 0) { //実数のFree
        dst = HspVarDouble_GetPtr(pval);
    } else if (strcmp(hspvarproc[pval->flag].vartype_name, "str") == 0) { //文字列のFree
        dst = HspVarStr_GetPtr(pval);
    } else if (strcmp(hspvarproc[pval->flag].vartype_name, "label") == 0) { //ラベルのFree
        dst = HspVarLabel_GetPtr(pval);
    } else if (strcmp(hspvarproc[pval->flag].vartype_name, "struct") == 0) { // structのFree
        dst = HspVarLabel_GetPtr(pval);
    } else {
        NSString *error_str = [NSString stringWithFormat:@"%d", HSPERR_SYNTAX];
        @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
    }

    buf = (void *) dst;

    if (pval->flag >= HSPVAR_FLAG_USERDEF) {
        //$使用できるCnvCustom関数は存在しない
        return NULL; //( hspvarproc[ pval->flag ].CnvCustom( buf, flag ) );
    }

    if (strcmp(hspvarproc[flag].vartype_name, "int") == 0) { //整数のCnv
        buf = HspVarInt_Cnv(buf, pval->flag);
    } else if (strcmp(hspvarproc[flag].vartype_name, "double") == 0) { //実数のCnv
        buf = HspVarDouble_Cnv(buf, pval->flag);
    } else if (strcmp(hspvarproc[flag].vartype_name, "str") == 0) { //文字列のCnv
        buf = HspVarStr_Cnv(buf, pval->flag);
    } else {
        NSString *error_str = [NSString stringWithFormat:@"%d", HSPERR_SYNTAX];
        @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
    }
    return (void *) dst; //( hspvarproc[flag].Cnv( buf, pval->flag ) );
}

#if 0
//        変数データの実態ポインタを得る
//        (APTRとpvalから実態を求める)
//
PDAT * HspVarCorePtrAPTR( PVal *pv, APTR ofs ) {
    pv->offset=ofs;
    PDAT* dst;
    if(strcmp(hspvarproc[(pv)->flag].vartype_name, "int") == 0) { //整数のGetPtr
        dst = HspVarInt_GetPtr(pv);
    }
    else if(strcmp(hspvarproc[(pv)->flag].vartype_name, "double") == 0) { //実数のGetPtr
        dst = HspVarDouble_GetPtr(pv);
    }
    else if(strcmp(hspvarproc[(pv)->flag].vartype_name, "str") == 0) { //文字列のGetPtr
        dst = HspVarStr_GetPtr(pv);
    }
    else if(strcmp(hspvarproc[(pv)->flag].vartype_name, "label") == 0) { //ラベルのGetPtr
        dst = HspVarLabel_GetPtr(pv);
    }
    else if(strcmp(hspvarproc[(pv)->flag].vartype_name, "struct") == 0) { //structのGetPtr
        dst = HspVarLabel_GetPtr(pv);
    }
    else {
        NSString *error_str = [NSString stringWithFormat:@"%d", HSPERR_SYNTAX];
        @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
    }

    return dst;//[(pv)->flag].GetPtr(pv);
}
#endif

HspVarProc *HspVarCoreSeekProc(const char *name) {
    HspVarProc *p;
    for (int i = 0; i < hspvartype_max; i++) {
        p = &hspvarproc[i];
        if (p->flag) {
            if (strcmp(p->vartype_name, name) == 0) {
                return p;
            }
        }
    }
    return NULL;
}

/// 配列要素の指定 (index)
///
/// ( Reset後に次元数だけ連続で呼ばれます )
///
void HspVarCoreArray(PVal *pval, int offset) {
    if (pval->arraycnt >= 5) {
        NSString *error_str = [NSString stringWithFormat:@"%d", HSPVAR_ERROR_ARRAYOVER];
        @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
    }
    if (pval->arraycnt == 0) {
        pval->arraymul = 1; // 最初の値
    } else {
        pval->arraymul *= pval->len[pval->arraycnt];
    }
    pval->arraycnt++;
    if (offset < 0) {
        NSString *error_str = [NSString stringWithFormat:@"%d", HSPVAR_ERROR_ARRAYOVER];
        @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
    }
    if (offset >= (pval->len[pval->arraycnt])) {
        NSString *error_str = [NSString stringWithFormat:@"%d", HSPVAR_ERROR_ARRAYOVER];
        @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
    }
    pval->offset += offset * pval->arraymul;
}

@end
