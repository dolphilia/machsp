//
//	HSPVARマネージャー
//	onion software/onitama 2003/4
//
//関数ポインタの使用箇所あり
//->LrI
//->Cnv

#import "hspvar_core.h"
#import "hspvar_label.h"
#import "strbuf.h"
#import "hspvar_double.h"
#import "hspvar_int.h"
#import "hspvar_str.h"
#import "hspvar_struct.h"

//------------------------------------------------------------
// master pointer
//------------------------------------------------------------

value_t *mem_pval;
hspvar_proc_t *hspvarproc;
int hspvartype_max;
int hspvartype_limit;

///        変数データの実態ポインタを得る
///
///        (APTRとpvalから実態を求める)
///
void *HspVarCorePtrAPTR(value_t *pv, int ofs) {
    pv->offset = ofs;
    void *dst;
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
        fprintf(stderr, "Error: %d\n", HSPERR_SYNTAX);
        exit(EXIT_FAILURE);
    }
    return dst; // hspvarproc[(pv)->flag].GetPtr(pv);
}

void hspvar_core_init(void) {
    hspvarproc = (hspvar_proc_t *) strbuf_alloc(sizeof(hspvar_proc_t) * HSPVAR_FLAG_MAX);
    hspvartype_max = HSPVAR_FLAG_MAX;
    for (int i = 0; i < HSPVAR_FLAG_MAX; i++) {
        hspvarproc[i].flag = 0;
    }

    //		mpval(テンポラリ変数)を初期化します
    //		(実態の初期化は、変数使用時に行なわれます)
    value_t *pval;
    mem_pval = (value_t *) strbuf_alloc(sizeof(value_t) * HSPVAR_FLAG_MAX);
    for (int i = 0; i < HSPVAR_FLAG_MAX; i++) {
        pval = &mem_pval[i];
        pval->mode = HSPVAR_MODE_NONE;
        pval->flag = HSPVAR_FLAG_INT; // 仮の型
    }
}

void hspvar_core_bye(void) {
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
                fprintf(stderr, "Error: %d\n", HSPERR_SYNTAX);
                exit(EXIT_FAILURE);
            }
        }
    }
    strbuf_free(mem_pval);
    strbuf_free(hspvarproc);
}

/// VARTYPEを初期化する(HspVarCoreInitの後で呼ぶ)
///
/// (expandに拡張するVARTYPEの数を指定する)
///
void hspvar_core_reset_var_type(int expand) {
    hspvartype_limit = hspvartype_max + expand;
    if (expand >= 0) {
        hspvarproc = (hspvar_proc_t *) strbuf_expand((char *) hspvarproc, sizeof(hspvar_proc_t) * hspvartype_limit);
        mem_pval = (value_t *) strbuf_expand((char *) mem_pval, sizeof(value_t) * hspvartype_limit);
    }

    // 標準の型を登録する
    hspvar_core_register_type(HSPVAR_FLAG_INT, (char *) "int");
    hspvar_core_register_type(HSPVAR_FLAG_STR, (char *) "str");
    hspvar_core_register_type(HSPVAR_FLAG_DOUBLE, (char *) "double");
    hspvar_core_register_type(HSPVAR_FLAG_STRUCT, (char *) "struct");
    hspvar_core_register_type(HSPVAR_FLAG_LABEL, (char *) "label"); // ラベル型(3.1)
}

int hspvar_core_add_type() {
    value_t *pval;
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
    fprintf(stderr, "Error: %d\n", HSPERR_UNSUPPORTED_FUNCTION);
    exit(EXIT_FAILURE);
}

void hspvar_core_register_type(int flag, char *vartype_name) {
    int id = flag;
    if (id < 0) {
        id = hspvar_core_add_type();
        if (id < 0) {
            return;
        }
    }

    hspvar_proc_t *p = &hspvarproc[id];
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
        fprintf(stderr, "Error: %d\n", HSPERR_UNKNOWN_CODE);
        exit(EXIT_FAILURE);
    }
    // func( p );
}

/*------------------------------------------------------------*/

/// 指定されたポインタからのクローンになる
///
void HspVarCoreDupPtr(value_t *pval, int flag, void *ptr, int size) {
    void *buf = (void *) ptr;
    hspvar_proc_t *p = &hspvarproc[flag];

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
        fprintf(stderr, "Error: %d\n", HSPERR_SYNTAX);
        exit(EXIT_FAILURE);
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
void HspVarCoreDup(value_t *pval, value_t *arg, int aptr) {
    int size;
    void *buf = HspVarCorePtrAPTR(arg, aptr);
    hspvar_proc_t *p = &hspvarproc[arg->flag];

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
        fprintf(stderr, "Error: %d\n", HSPERR_SYNTAX);
        exit(EXIT_FAILURE);
    }

    HspVarCoreDupPtr(pval, arg->flag, buf, size);

}

/// 配列を確保する
///
/// (len1〜len4は、4byte単位なので注意)
///
void HspVarCoreDim(value_t *pval, int flag, int len1, int len2, int len3, int len4) {
    hspvar_proc_t *p = &hspvarproc[flag];

    if ((len1 < 0) || (len2 < 0) || (len3 < 0) || (len4 < 0)) {
        fprintf(stderr, "Error: %d\n", HSPVAR_ERROR_ILLEGALPRM);
        exit(EXIT_FAILURE);
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
        fprintf(stderr, "Error: %d\n", HSPERR_SYNTAX);
        exit(EXIT_FAILURE);
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
        fprintf(stderr, "Error: %d\n", HSPERR_SYNTAX);
        exit(EXIT_FAILURE);
    }
}

/// 配列を確保する(可変長配列用)
///
/// (len1〜len4は、4byte単位なので注意)
///
void HspVarCoreDimFlex(value_t *pval, int flag, int len0, int len1, int len2, int len3, int len4) {
    hspvar_proc_t *p = &hspvarproc[flag];

    if ((len1 < 0) || (len2 < 0) || (len3 < 0) || (len4 < 0)) {
        fprintf(stderr, "Error: %d\n", HSPVAR_ERROR_ILLEGALPRM);
        exit(EXIT_FAILURE);
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
        fprintf(stderr, "Error: %d\n", HSPERR_SYNTAX);
        exit(EXIT_FAILURE);
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
        fprintf(stderr, "Error: %d\n", HSPERR_SYNTAX);
        exit(EXIT_FAILURE);
    }

    pval->len[0] = 1;
}

/// 配列を拡張する
///
void HspVarCoreReDim(value_t *pval, int lenid, int len) {
    hspvar_proc_t *p = &hspvarproc[pval->flag];
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
        fprintf(stderr, "Error: %d\n", HSPERR_SYNTAX);
        exit(EXIT_FAILURE);
    }
}

/// 指定タイプの変数を最小メモリで初期化する
///
void HspVarCoreClear(value_t *pval, int flag) {
    HspVarCoreDim(pval, flag, 1, 0, 0, 0); // 最小サイズのメモリを確保
}

/// 指定タイプの変数を最小メモリで初期化する(テンポラリ用)
///
void HspVarCoreClearTemp(value_t *pval, int flag) {
    HspVarCoreDim(pval, flag, 1, 0, 0, 0); // 最小サイズのメモリを確保
    pval->support |= HSPVAR_SUPPORT_TEMPVAR;
}

/// 指定されたtypeフラグに変換された値のポインタを得る
///
void *HspVarCoreCnvPtr(value_t *pval, int flag) {
    void *dst;
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
            fprintf(stderr, "Error: %d\n", HSPERR_SYNTAX);
            exit(EXIT_FAILURE);
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
        fprintf(stderr, "Error: %d\n", HSPERR_SYNTAX);
        exit(EXIT_FAILURE);
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
        fprintf(stderr, "Error: %d\n", HSPERR_SYNTAX);
        exit(EXIT_FAILURE);
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
        fprintf(stderr, "Error: %d\n", HSPERR_SYNTAX);
        exit(EXIT_FAILURE);
    }

    return dst;//[(pv)->flag].GetPtr(pv);
}
#endif

hspvar_proc_t *hspvar_core_seek_proc(const char *name) {
    hspvar_proc_t *p;
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
void HspVarCoreArray(value_t *pval, int offset) {
    if (pval->arraycnt >= 5) {
        fprintf(stderr, "Error: %d\n", HSPVAR_ERROR_ARRAYOVER);
        exit(EXIT_FAILURE);
    }
    if (pval->arraycnt == 0) {
        pval->arraymul = 1; // 最初の値
    } else {
        pval->arraymul *= pval->len[pval->arraycnt];
    }
    pval->arraycnt++;
    if (offset < 0) {
        fprintf(stderr, "Error: %d\n", HSPVAR_ERROR_ARRAYOVER);
        exit(EXIT_FAILURE);
    }
    if (offset >= (pval->len[pval->arraycnt])) {
        fprintf(stderr, "Error: %d\n", HSPVAR_ERROR_ARRAYOVER);
        exit(EXIT_FAILURE);
    }
    pval->offset += offset * pval->arraymul;
}
