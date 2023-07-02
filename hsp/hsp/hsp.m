//
//  hsp.mm
//

#import "hsp.h"
#import "hspvar_double.h"
#import "hspvar_int.h"
#import "hspvar_label.h"
#import "hspvar_str.h"

#define strp(dsptr) &hsp_hspctx->mem_mds[dsptr]
#define GetTypeInfoPtr(hsp_type_tmp) (&hsp_hsp3tinfo[hsp_type_tmp])
//有符号型と無符号型の比較に対処
#define ETRLOOP ((int)0x80000000)
#define GETLOP(num) (&(hspctx->mem_loop[num]))

@implementation ViewController (hsp)

int get_u32(unsigned short *mcs) {
    return (mcs[1] << 16) | (mcs[0]);
}

/// Get 1 command block
///
/// (ver3.0以降用)
///
- (void)code_next {
    hsp_mcsbak = hsp_mcs;
    hsp_csvalue = *hsp_mcs++;
    hsp_exflg = hsp_csvalue & (EXFLG_1 | EXFLG_2);
    hsp_type_tmp = hsp_csvalue & CSTYPE;
    if (hsp_csvalue & EXFLG_3) { // 32bit val code
        hsp_val_tmp = get_u32(hsp_mcs);
        hsp_mcs += 2;
        return;
    }
    hsp_val_tmp = (int) (*hsp_mcs++); // 16bit val code
}

//void code_next( void ) {
//    __[self code_next];
//}

/// エラー例外を発生させる
///
- (void)code_puterror:(HSPERROR)error {
    if (error == HSPERR_NONE) {
        hsp_hspctx->runmode = RUNMODE_END;
        return;
    }
    @throw [self make_nsexception:error];
}

- (int)code_getexflg {
    return hsp_exflg;
}

/// Caluculate parameter args (valiant)
///
- (void)calcprm:(hspvar_proc_t *)proc pval:(void *)pval exp:(int)exp ptr:(void *)ptr {
    switch (exp) {
        case CALCCODE_ADD: {
            if (strcmp(proc->vartype_name, "int") == 0) {  //整数の足し算
                hspvar_int_add_i(pval, ptr);
            } else if (strcmp(proc->vartype_name, "double") == 0) {  //実数の足し算
                hspvar_double_add_i(pval, ptr);
            } else if (strcmp(proc->vartype_name, "str") == 0) {  //文字列の足し算
                hspvar_str_add_i(pval, ptr);
            } else {
                @throw [self make_nsexception:HSPERR_SYNTAX];
            }
            break;
        }
        case CALCCODE_SUB: {
            if (strcmp(proc->vartype_name, "int") == 0) {  //整数の引き算
                hspvar_int_sub_i(pval, ptr);
            } else if (strcmp(proc->vartype_name, "double") == 0) {  //実数の引き算
                hspvar_double_sub_i(pval, ptr);
            } else {
                @throw [self make_nsexception:HSPERR_SYNTAX];
            }
            break;
        }
        case CALCCODE_MUL: {
            if (strcmp(proc->vartype_name, "int") == 0) {  //整数の掛け算
                hspvar_int_mul_i(pval, ptr);
            } else if (strcmp(proc->vartype_name, "double") == 0) {  //実数の掛け算
                hspvar_double_mul_i(pval, ptr);
            } else {
                @throw [self make_nsexception:HSPERR_SYNTAX];
            }
            break;
        }
        case CALCCODE_DIV: {
            if (strcmp(proc->vartype_name, "int") == 0) {  //整数の割り算
                hspvar_int_div_i(pval, ptr);
            } else if (strcmp(proc->vartype_name, "double") == 0) {  //実数の割り算
                hspvar_double_div_i(pval, ptr);
            } else {
                @throw [self make_nsexception:HSPERR_SYNTAX];
            }
            break;
        }
        case CALCCODE_MOD:  // '%'
        {
            if (strcmp(proc->vartype_name, "int") == 0) {  //整数のMOD
                hspvar_int_mod_i(pval, ptr);
            } else if (strcmp(proc->vartype_name, "double") == 0) {  //実数のMOD
                hspvar_double_mod_i(pval, ptr);
            } else {
                @throw [self make_nsexception:HSPERR_SYNTAX];
            }
            break;
        }
        case CALCCODE_AND: {
            if (strcmp(proc->vartype_name, "int") == 0) {  //整数のAND
                hspvar_int_and_i(pval, ptr);
            } else {
                @throw [self make_nsexception:HSPERR_SYNTAX];
            }
            break;
        }
        case CALCCODE_OR: {
            if (strcmp(proc->vartype_name, "int") == 0) {  //整数のOR
                hspvar_int_or_i(pval, ptr);
            } else {
                @throw [self make_nsexception:HSPERR_SYNTAX];
            }
            break;
        }
        case CALCCODE_XOR: {
            if (strcmp(proc->vartype_name, "int") == 0) {  //整数のXOR
                hspvar_int_xor_i(pval, ptr);
            } else {
                @throw [self make_nsexception:HSPERR_SYNTAX];
            }
            break;
        }
        case CALCCODE_EQ: {
            if (strcmp(proc->vartype_name, "int") == 0) {  //整数の=
                hspvar_int_eq_i(pval, ptr);
            } else if (strcmp(proc->vartype_name, "double") == 0) {  //実数の=
                hspvar_double_eq_i(pval, ptr);
            } else if (strcmp(proc->vartype_name, "str") == 0) {  //文字列の=
                hspvar_str_eq_i(pval, ptr);
            } else {
                @throw [self make_nsexception:HSPERR_SYNTAX];
            }
            break;
        }
        case CALCCODE_NE: {
            if (strcmp(proc->vartype_name, "int") == 0) {  //整数の!=
                hspvar_int_ne_i(pval, ptr);
            } else if (strcmp(proc->vartype_name, "double") == 0) {  //実数の!=
                hspvar_double_ne_i(pval, ptr);
            } else if (strcmp(proc->vartype_name, "str") == 0) {  //文字列の!=
                hspvar_str_ne_i(pval, ptr);
            } else {
                @throw [self make_nsexception:HSPERR_SYNTAX];
            }
            break;
        }
        case CALCCODE_GT: {
            if (strcmp(proc->vartype_name, "int") == 0) {  //整数の>
                hspvar_int_gt_i(pval, ptr);
            } else if (strcmp(proc->vartype_name, "double") == 0) {  //実数の>
                hspvar_double_gt_i(pval, ptr);
            } else {
                @throw [self make_nsexception:HSPERR_SYNTAX];
            }
            break;
        }
        case CALCCODE_LT: {
            if (strcmp(proc->vartype_name, "int") == 0) {  //整数の<
                hspvar_int_lt_i(pval, ptr);
            } else if (strcmp(proc->vartype_name, "double") == 0) {  //実数の<
                hspvar_double_lt_i(pval, ptr);
            } else {
                @throw [self make_nsexception:HSPERR_SYNTAX];
            }
            break;
        }
        case CALCCODE_GTEQ:  // '>='
        {
            if (strcmp(proc->vartype_name, "int") == 0) {  //整数の>=
                hspvar_int_gt_eq_i(pval, ptr);
            } else if (strcmp(proc->vartype_name, "double") == 0) {  //実数の>=
                hspvar_double_gt_eq_i(pval, ptr);
            } else {
                @throw [self make_nsexception:HSPERR_SYNTAX];
            }
            break;
        }
        case CALCCODE_LTEQ:  // '<='
        {
            if (strcmp(proc->vartype_name, "int") == 0) {  //整数の<=
                hspvar_int_lt_eq_i(pval, ptr);
            } else if (strcmp(proc->vartype_name, "double") == 0) {  //実数の<=
                hspvar_double_lt_eq_i(pval, ptr);
            } else {
                @throw [self make_nsexception:HSPERR_SYNTAX];
            }
            break;
        }
        case CALCCODE_RR:  // '>>'
        {
            if (strcmp(proc->vartype_name, "int") == 0) {  //整数の>>
                hspvar_int_rr_i(pval, ptr);
            } else {
                @throw [self make_nsexception:HSPERR_SYNTAX];
            }
            break;
        }
        case CALCCODE_LR:  // '<<'
        {
            if (strcmp(proc->vartype_name, "int") == 0) {  //整数の<<
                hspvar_int_lr_i(pval, ptr);
            } else {
                @throw [self make_nsexception:HSPERR_SYNTAX];
            }
            break;
        }
        case '(': {
            @throw [self make_nsexception:HSPERR_INVALID_ARRAY];
        }
        default: {
            @throw [self make_nsexception:HSPVAR_ERROR_INVALID];
        }
    }

}

/// Caluculate parameter args (int)
///
- (void)calcprmf:(int *)mval exp:(int)exp p:(int)p {
    switch (exp) {
        case CALCCODE_ADD:
            *mval += p;
            break;
        case CALCCODE_SUB:
            *mval -= p;
            break;
        case CALCCODE_MUL:
            *mval *= p;
            break;
        case CALCCODE_DIV: {
            if (p == 0) {
                @throw [self make_nsexception:HSPVAR_ERROR_DIVZERO];
            }
            *mval /= p;
            break;
        }
        case CALCCODE_MOD:  // '%'
        {
            if (p == 0) {
                @throw [self make_nsexception:HSPVAR_ERROR_DIVZERO];
            }
            *mval %= p;
            break;
        }
        case CALCCODE_AND:
            *mval &= p;
            break;
        case CALCCODE_OR:
            *mval |= p;
            break;
        case CALCCODE_XOR:
            *mval ^= p;
            break;
        case CALCCODE_EQ:
            *mval = (*mval == p);
            break;
        case CALCCODE_NE:
            *mval = (*mval != p);
            break;
        case CALCCODE_GT:
            *mval = (*mval > p);
            break;
        case CALCCODE_LT:
            *mval = (*mval < p);
            break;
        case CALCCODE_GTEQ:  // '>='
            *mval = (*mval >= p);
            break;
        case CALCCODE_LTEQ:  // '<='
            *mval = (*mval <= p);
            break;

        case CALCCODE_RR:  // '>>'
            *mval >>= p;
            break;
        case CALCCODE_LR:  // '<<'
            *mval <<= p;
            break;
        case '(': {
            @throw [self make_nsexception:HSPERR_INVALID_ARRAY];
        }
        default: {
            @throw [self make_nsexception:HSPVAR_ERROR_INVALID];
        }
    }
}

/// スタックから引数を２つPOPしたものを演算する
///
- (void)code_calcop:(int)op {
    hspvar_proc_t *varproc;
    stack_manager_t *stm1 = StackPeek2;
    stack_manager_t *stm2 = StackPeek;
    char *ptr;
    int tflag = stm1->type;
    int basesize;

    // stm1 = stm2-1;

    // if ( tflag > HSP3_FUNC_MAX ) throw HSPERR_UNKNOWN_CODE;
    // alert_format( "(%d) %d %d %d",tflag, stm1->ival, op, stm2->ival );

    if (tflag == HSPVAR_FLAG_INT) {
        if (stm2->type == HSPVAR_FLAG_INT) {  // HSPVAR_FLAG_INT のみ高速化
            [self calcprmf:&stm1->ival exp:op p:stm2->ival];  // 高速化された演算(intのみ)
            StackDecLevel;               // stack->Pop() の代わり(高速に)
            stm2->ival = stm1->ival;  // １段目スタックの値を入れ替える
            return;
        }
    }

    mpval = HspVarCoreGetPVal(tflag);
    varproc = HspVarCoreGetProc(tflag);

    if (mpval->mode == HSPVAR_MODE_NONE) {  // 型に合わせたテンポラリ変数を初期化
        if (varproc->flag == 0) {
            @throw [self make_nsexception:HSPERR_TYPE_INITALIZATION_FAILED];
        }
        hspvar_core_clear_tmp(mpval, tflag);  // 最小サイズのメモリを確保
    }

    // テンポラリ変数に初期値を設定
    if (strcmp(varproc->vartype_name, "int") == 0) {  //整数のSet
        hspvar_int_set(mpval, (void *) mpval->pt, STM_GETPTR(stm1));
    } else if (strcmp(varproc->vartype_name, "double") == 0) {  //実数のSet
        hspvar_double_set(mpval, (void *) mpval->pt, STM_GETPTR(stm1));
    } else if (strcmp(varproc->vartype_name, "str") == 0) {  //文字列のSet
        hspvar_str_set(mpval, (void *) mpval->pt, STM_GETPTR(stm1));
    } else if (strcmp(varproc->vartype_name, "label") == 0) {  //ラベルのSet
        hspvar_label_set(mpval, (void *) mpval->pt, STM_GETPTR(stm1));
    } else if (strcmp(varproc->vartype_name, "struct") == 0) {  // structのSet
        hspvar_label_set(mpval, (void *) mpval->pt, STM_GETPTR(stm1));
    } else {
        @throw [self make_nsexception:HSPERR_SYNTAX];
    }

    ptr = STM_GETPTR(stm2);
    if (tflag != stm2->type) {  // 型が一致しない場合は変換
        if (stm2->type >= HSPVAR_FLAG_USERDEF) {
            //$使用できるCnvCustom関数は存在しない
            // ptr = (char *)HspVarCoreGetProc(stm2->type)->CnvCustom( ptr, tflag );
        } else {
            if (strcmp(varproc->vartype_name, "int") == 0) {  //整数のCnv
                ptr = (char *) hspvar_int_cnv(ptr, stm2->type);
            } else if (strcmp(varproc->vartype_name, "double") == 0) {  //実数のCnv
                ptr = (char *) hspvar_double_cnv(ptr, stm2->type);
            } else if (strcmp(varproc->vartype_name, "str") == 0) {  //文字列のCnv
                ptr = (char *) hspvar_str_cnv(ptr, stm2->type);
            } else {
                @throw [self make_nsexception:HSPERR_SYNTAX];
            }
        }
    }
    [self calcprm:varproc pval:(void *) mpval->pt exp:op ptr:ptr];  // 計算を行なう
    stack_pop();
    stack_pop();

    if (varproc->aftertype != tflag) {  // 演算後に型が変わる場合
        tflag = varproc->aftertype;
        varproc = HspVarCoreGetProc(tflag);
    }
    basesize = varproc->basesize;
    if (basesize < 0) {
        if (strcmp(varproc->vartype_name, "int") == 0) {  //整数のGetSize
            basesize = hspvar_int_get_size((void *) mpval->pt);
        } else if (strcmp(varproc->vartype_name, "double") == 0) {  //実数のGetSize
            basesize = hspvar_double_get_size((void *) mpval->pt);
        } else if (strcmp(varproc->vartype_name, "str") == 0) {  //文字列のGetSize
            basesize = hspvar_str_get_size((void *) mpval->pt);
        } else if (strcmp(varproc->vartype_name, "label") == 0) {  //ラベルのGetSize
            basesize = hspvar_label_get_size((void *) mpval->pt);
        } else if (strcmp(varproc->vartype_name, "struct") == 0) {  // structのGetSize
            basesize = hspvar_label_get_size((void *) mpval->pt);
        } else {
            @throw [self make_nsexception:HSPERR_SYNTAX];
        }
    }
    stack_push(tflag, mpval->pt, basesize);
}

/// Check PVal Array information
///
/// (配列要素(int)の取り出し)
///
- (void)code_checkarray:(value_t *)pval {
    int chk;
    int i;
    value_t temp;
    HspVarCoreReset(pval);  // 配列ポインタをリセットする

    if (hsp_type_tmp == TYPE_MARK) {
        if (hsp_val_tmp == '(') {
            [self code_next];
            //			整数値のみサポート
            while (1) {
                HspVarCoreCopyArrayInfo(&temp, pval);  // 状態を保存
                chk = [self code_get];  // パラメーターを取り出す
                if (chk <= PARAM_END) {
                    @throw [self make_nsexception:HSPERR_BAD_ARRAY_EXPRESSION];
                }
                if (mpval->flag != HSPVAR_FLAG_INT) {
                    @throw [self make_nsexception:HSPERR_TYPE_MISMATCH];
                }
                HspVarCoreCopyArrayInfo(pval, &temp);  // 状態を復帰
                i = *(int *) (mpval->pt);
                hspvar_core_array(pval, i);  // 配列要素指定(整数)
                if (chk == PARAM_SPLIT) break;
            }
            [self code_next];  // ')'を読み飛ばす
            return;
        }
    }
}

/// 配列要素の指定 (index)
///
/// ( Reset後に次元数だけ連続で呼ばれます )
///
- (void)code_arrayint2:(value_t *)pval offset:(int)offset {
    if (pval->arraycnt >= 5) {
        @throw [self make_nsexception:HSPVAR_ERROR_ARRAYOVER];
    }
    if (pval->arraycnt == 0) {
        pval->arraymul = 1;  // 最初の値
    } else {
        pval->arraymul *= pval->len[pval->arraycnt];
    }
    pval->arraycnt++;
    if (offset < 0) {
        @throw [self make_nsexception:HSPVAR_ERROR_ARRAYOVER];
    }
    if (offset >= (pval->len[pval->arraycnt])) {
        if ((pval->arraycnt >= 4) || (pval->len[pval->arraycnt + 1] == 0)) {
            if (pval->support & HSPVAR_SUPPORT_FLEXARRAY) {
                hspvar_core_re_dim(pval, pval->arraycnt, offset + 1);  // 配列を拡張する
                pval->offset += offset * pval->arraymul;
                return;
            }
        }
        @throw [self make_nsexception:HSPVAR_ERROR_ARRAYOVER];
    }
    pval->offset += offset * pval->arraymul;
}

/// Check PVal Array information
///
/// (配列要素(int)の取り出し)(配列の拡張に対応)
///
- (void)code_checkarray2:(value_t *)pval {
    int chk, i;
    value_t temp;
    HspVarCoreReset(pval);  // 配列ポインタをリセットする

    if (hsp_type_tmp == TYPE_MARK) {
        if (hsp_val_tmp == '(') {
            [self code_next];
            // 整数値のみサポート
            while (1) {
                HspVarCoreCopyArrayInfo(&temp, pval);  // 状態を保存
                chk = [self code_get];  // パラメーターを取り出す
                if (chk <= PARAM_END) {
                    @throw [self make_nsexception:HSPERR_BAD_ARRAY_EXPRESSION];
                }
                if (mpval->flag != HSPVAR_FLAG_INT) {
                    @throw [self make_nsexception:HSPERR_TYPE_MISMATCH];
                }
                HspVarCoreCopyArrayInfo(pval, &temp);  // 状態を復帰
                i = *(int *) (mpval->pt);
                [self code_arrayint2:pval offset:i];
                if (chk == PARAM_SPLIT) break;
            }
            [self code_next];  // ')'を読み飛ばす
            return;
        }
    }
}

/// Check PVal Array object information
///
/// ( 配列要素(オブジェクト)の取り出し )
/// ( 返値 : 汎用データのポインタ )
/// ( mptype : 汎用データのタイプを返す )
///
- (char *)code_checkarray_obj:(value_t *)pval mptype:(int *)mptype {
    char *ptr;
    hspvar_proc_t *varproc;
    /*
     flex_value_t *fv;
     if ( pval->support & HSPVAR_SUPPORT_STRUCTACCEPT ) {			//
     構造体受け付け
     code_checkarray( pval );
     if ( pval->support & HSPVAR_SUPPORT_CLONE ) {				//
     クローンのチェック
     fv = (flex_value_t *)HspVarCorePtr( pval );
     *mptype = fv->clonetype;
     return (fv->ptr);
     }
     if (( type != TYPE_STRUCT )||( hsp_exflg )) {
     *mptype = MPTYPE_VAR;
     return HspVarCorePtr( pval );
     }
     varproc = HspVarCoreGetProc( pval->flag );
     ptr = varproc->ArrayObject( pval, mptype );
     return ptr;
     }
     
     if ( pval->support & HSPVAR_SUPPORT_CLONE ) {				//
     クローンのチェック
     fv = (flex_value_t *)HspVarCorePtr( pval );
     *mptype = fv->clonetype;
     return (fv->ptr);
     }
     */

    *mptype = pval->flag;
    HspVarCoreReset(pval);  // 配列ポインタをリセットする

    if (hsp_type_tmp == TYPE_MARK) {
        if (hsp_val_tmp == '(') {  // 配列がある場合
            [self code_next];
            //			if ( pval->support & HSPVAR_SUPPORT_ARRAYOBJ ) {
            varproc = HspVarCoreGetProc(pval->flag);
            //＄使用できるArrayObjectReadは存在しない
            // ptr = (char *)varproc->ArrayObjectRead( pval, mptype );
            [self code_next];  // ')'を読み飛ばす
            return ptr;
            //			}
            //			code_checkarray( pval );
        }
    }

    void *dst;
    if (strcmp(hspvar_proc[(pval)->flag].vartype_name, "int") == 0) {  //整数のGetPtr
        dst = hspvar_int_get_ptr(pval);
    } else if (strcmp(hspvar_proc[(pval)->flag].vartype_name, "double") == 0) {  //実数のGetPtr
        dst = hspvar_double_get_ptr(pval);
    } else if (strcmp(hspvar_proc[(pval)->flag].vartype_name, "str") == 0) {  //文字列のGetPtr
        dst = hspvar_str_get_ptr(pval);
    } else if (strcmp(hspvar_proc[(pval)->flag].vartype_name, "label") == 0) {  //ラベルのGetPtr
        dst = hspvar_label_get_ptr(pval);
    } else if (strcmp(hspvar_proc[(pval)->flag].vartype_name, "struct") == 0) {  // structのGetPtr
        dst = hspvar_label_get_ptr(pval);
    } else {
        @throw [self make_nsexception:HSPERR_SYNTAX];
    }

    return (char *) dst;  //(char *)HspVarCorePtr( pval );
}

/*
 static char *code_get_varsub( PVal *pval, int *restype )
 {
 //		pvalの実体を検索する(HSPVAR_SUPPORT_ARRAYOBJ時のみ)
 //		( 返値が実体ポインタとなる )
 //
 char *ptr;
 ptr = (char *)code_checkarray_obj( pval, restype );
 return code_get_proxyvar( ptr, restype );
 }
 */

/// マルチパラメーターの変数を処理する
///
- (char *)code_get_proxyvar:(char *)ptr mptype:(int *)mptype {
    multi_param_var_data_t *var;
    value_t *getv_pval;
    switch (*mptype) {  // マルチパラメーターを取得
        case MPTYPE_SINGLEVAR:
            var = (multi_param_var_data_t *) ptr;
            getv_pval = var->pval;
            getv_pval->offset = var->aptr;
            if (hsp_type_tmp == TYPE_MARK) {
                if (hsp_val_tmp == '(') {
                    @throw [self make_nsexception:HSPERR_INVALID_ARRAY];
                }
            }
            // HspVarCoreReset( getv_pval );
            break;
        case MPTYPE_LOCALSTRING:
            *mptype = MPTYPE_STRING;
            return *(char **) ptr;
        case MPTYPE_LABEL:
            *mptype = HSPVAR_FLAG_LABEL;
            return ptr;
        case MPTYPE_ARRAYVAR:
            var = (multi_param_var_data_t *) ptr;
            getv_pval = var->pval;
            if (getv_pval->support & HSPVAR_SUPPORT_MISCTYPE) {
                return [self code_checkarray_obj:getv_pval mptype:mptype];
            } else {
                [self code_checkarray:getv_pval];
            }
            break;
        case MPTYPE_LOCALVAR:
            getv_pval = (value_t *) ptr;
            if (getv_pval->support & HSPVAR_SUPPORT_MISCTYPE) {
                return [self code_checkarray_obj:getv_pval mptype:mptype];
            } else {
                [self code_checkarray:getv_pval];
            }
            break;
        default:
            return ptr;
    }
    *mptype = getv_pval->flag;

    void *dst;
    if (strcmp(hspvar_proc[(getv_pval)->flag].vartype_name, "int") == 0) {  //整数のFree
        dst = hspvar_int_get_ptr(getv_pval);
    } else if (strcmp(hspvar_proc[(getv_pval)->flag].vartype_name, "double") == 0) {  //実数のFree
        dst = hspvar_double_get_ptr(getv_pval);
    } else if (strcmp(hspvar_proc[(getv_pval)->flag].vartype_name, "str") == 0) {  //文字列のFree
        dst = hspvar_str_get_ptr(getv_pval);
    } else if (strcmp(hspvar_proc[(getv_pval)->flag].vartype_name, "label") == 0) {  //ラベルのFree
        dst = hspvar_label_get_ptr(getv_pval);
    } else if (strcmp(hspvar_proc[(getv_pval)->flag].vartype_name, "struct") == 0) {  // structのFree
        dst = hspvar_label_get_ptr(getv_pval);
    } else {
        @throw [self make_nsexception:HSPERR_SYNTAX];
    }

    return (char *) dst;  // HspVarCorePtr( getv_pval );
}

/// Check PVal Array object information
///
/// ( 配列要素(オブジェクト)の取り出し・変数指定時 )
/// ( 変数の内容を参照する場合にはcode_checkarray_objを使用します )
///
- (void)code_checkarray_obj2:(value_t *)pval {
    hspvar_proc_t *varproc;
    HspVarCoreReset(pval);  // 配列ポインタをリセットする

    hsp_arrayobj_flag = 0;
    if (hsp_type_tmp == TYPE_MARK) {
        if (hsp_val_tmp == '(') {  // 配列がある場合
            [self code_next];
            varproc = HspVarCoreGetProc(pval->flag);
            //$使用できるArryObjectは存在しない
            // varproc->ArrayObject( pval );
            hsp_arrayobj_flag = 1;
            [self code_next];  // ')'を読み飛ばす
        }
    }
}

/// parameter analysis
///
/// result:
/// 0=ok(PARAM_OK)
/// -1=end(PARAM_END)
/// -2=default(PARAM_DEFAULT)
/// (エラー発生時は例外が発生します)
///
- (int)code_get {
    stack_manager_t *stm;
    value_t *argpv;
    hspvar_proc_t *varproc;
    hsp_type_info_t *info;
    multi_param_module_var_data_t *var;
    flex_value_t *fv;
    char *out;
    struct_param_t *prm;
    char *ptr = NULL;
    int tflag = 0;
    int basesize;
    int tmpval;
    int stack_def;
    int resval;

    if (hsp_exflg & EXFLG_1) return PARAM_END;  // パラメーター終端
    if (hsp_exflg & EXFLG_2) {  // パラメーター区切り(デフォルト時)
        hsp_exflg ^= EXFLG_2;
        return PARAM_DEFAULT;
    }
    if (hsp_type_tmp == TYPE_MARK) {
        if (hsp_val_tmp == 63) {  // パラメーター省略時('?')
            [self code_next];
            hsp_exflg &= ~EXFLG_2;
            return PARAM_DEFAULT;
        }
        if (hsp_val_tmp == ')') {  // 関数内のパラメーター省略時
            hsp_exflg &= ~EXFLG_2;
            return PARAM_ENDSPLIT;
        }
    }

    if (hsp_csvalue & EXFLG_0) {  // 単一の項目(高速化)
        switch (hsp_type_tmp) {
            case TYPE_INUM:
                mpval = hsp_mpval_int;
                *(int *) mpval->pt = hsp_val_tmp;
                break;
            case TYPE_DNUM:
            case TYPE_STRING: {
                varproc = HspVarCoreGetProc(hsp_type_tmp);
                mpval = HspVarCoreGetPVal(hsp_type_tmp);
                if (mpval->mode ==
                        HSPVAR_MODE_NONE) {  // 型に合わせたテンポラリ変数を初期化
                    if (varproc->flag == 0) {
                        @throw [self make_nsexception:HSPERR_TYPE_INITALIZATION_FAILED];
                    }
                    hspvar_core_clear_tmp(mpval, hsp_type_tmp);  // 最小サイズのメモリを確保
                }

                // テンポラリ変数に初期値を設定
                if (strcmp(varproc->vartype_name, "int") == 0) {  //整数のSet
                    hspvar_int_set(mpval, (void *) (mpval->pt), &abc_hspctx.mem_mds[hsp_val_tmp]);
                } else if (strcmp(varproc->vartype_name, "double") == 0) {  //実数のSet
                    hspvar_double_set(mpval, (void *) (mpval->pt), &abc_hspctx.mem_mds[hsp_val_tmp]);
                } else if (strcmp(varproc->vartype_name, "str") == 0) {  //文字列のSet
                    hspvar_str_set(mpval, (void *) (mpval->pt), &abc_hspctx.mem_mds[hsp_val_tmp]);
                } else if (strcmp(varproc->vartype_name, "label") == 0) {  //ラベルのSet
                    hspvar_label_set(mpval, (void *) (mpval->pt), &abc_hspctx.mem_mds[hsp_val_tmp]);
                } else if (strcmp(varproc->vartype_name, "struct") == 0) {  // structのSet
                    hspvar_label_set(mpval, (void *) (mpval->pt), &abc_hspctx.mem_mds[hsp_val_tmp]);
                } else {
                    @throw [self make_nsexception:HSPERR_SYNTAX];
                }
                break;
            }
            default: {
                @throw [self make_nsexception:HSPERR_UNKNOWN_CODE];
            }
        }
        [self code_next];
        hsp_exflg &= ~EXFLG_2;
        return 0;
    }

    resval = 0;
    stack_def = (int) StackGetLevel;  // スタックのレベルを取得

    while (1) {
        switch (hsp_type_tmp) {
            case TYPE_MARK:
                if (hsp_val_tmp == ')') {  // 引数の終了マーク
                    if (stack_def == StackGetLevel) {
                        @throw [self make_nsexception:HSPERR_WRONG_EXPRESSION];
                    }
                    resval = PARAM_SPLIT;
                    hsp_exflg |= EXFLG_2;
                    break;
                }
                [self code_calcop:hsp_val_tmp];
                [self code_next];
                break;
            case TYPE_VAR:
                argpv = &abc_hspctx.mem_var[hsp_val_tmp];
                [self code_next];
                tflag = argpv->flag;
                if (argpv->support & HSPVAR_SUPPORT_MISCTYPE) {
                    ptr = (char *) [self code_checkarray_obj:argpv mptype:&tflag];
                } else {
                    [self code_checkarray:argpv];
                    void *dst;
                    if (strcmp(hspvar_proc[(argpv)->flag].vartype_name, "int") == 0) {  //整数のFree
                        dst = hspvar_int_get_ptr(argpv);
                    } else if (strcmp(hspvar_proc[(argpv)->flag].vartype_name, "double") == 0) {  //実数のFree
                        dst = hspvar_double_get_ptr(argpv);
                    } else if (strcmp(hspvar_proc[(argpv)->flag].vartype_name, "str") == 0) {  //文字列のFree
                        dst = hspvar_str_get_ptr(argpv);
                    } else if (strcmp(hspvar_proc[(argpv)->flag].vartype_name, "label") == 0) {  //ラベルのFree
                        dst = hspvar_label_get_ptr(argpv);
                    } else if (strcmp(hspvar_proc[(argpv)->flag].vartype_name, "struct") == 0) {  // structのFree
                        dst = hspvar_label_get_ptr(argpv);
                    } else {
                        @throw [self make_nsexception:HSPERR_SYNTAX];
                    }
                    ptr = (char *) dst;  // HspVarCorePtr( argpv );
                }
                varproc = HspVarCoreGetProc(tflag);
                basesize = varproc->basesize;
                if (basesize < 0) {
                    if (strcmp(varproc->vartype_name, "int") == 0) {  //整数のGetSize
                        basesize = hspvar_int_get_size((void *) ptr);
                    } else if (strcmp(varproc->vartype_name, "double") == 0) {  //実数のGetSize
                        basesize = hspvar_double_get_size((void *) ptr);
                    } else if (strcmp(varproc->vartype_name, "str") == 0) {  //文字列のGetSize
                        basesize = hspvar_str_get_size((void *) ptr);
                    } else if (strcmp(varproc->vartype_name, "label") == 0) {  //ラベルのGetSize
                        basesize = hspvar_label_get_size((void *) ptr);
                    } else if (strcmp(varproc->vartype_name, "struct") == 0) {  // structのGetSize
                        basesize = hspvar_label_get_size((void *) ptr);
                    } else {
                        @throw [self make_nsexception:HSPERR_SYNTAX];
                    }
                }
                stack_push(tflag, ptr, basesize);
                break;
            case TYPE_INUM:
                stack_push_int(hsp_val_tmp);
                [self code_next];
                break;
            case TYPE_STRING:
                stack_push2(hsp_type_tmp, &abc_hspctx.mem_mds[hsp_val_tmp]);
                [self code_next];
                break;
            case TYPE_DNUM:
                stack_push(hsp_type_tmp, &abc_hspctx.mem_mds[hsp_val_tmp], sizeof(double));
                [self code_next];
                break;
            case TYPE_STRUCT:
                prm = &abc_hspctx.mem_minfo[hsp_val_tmp];
                [self code_next];
                out = ((char *) abc_hspctx.prmstack);
                if (out == NULL) {
                    @throw [self make_nsexception:HSPERR_INVALID_PARAMETER];
                }
                if (prm->subid != STRUCTPRM_SUBID_STACK) {
                    var = (multi_param_module_var_data_t *) out;
                    if ((var->magic != MODVAR_MAGICCODE) || (var->subid != prm->subid) || (var->pval->flag != TYPE_STRUCT)) {
                        @throw [self make_nsexception:HSPERR_INVALID_STRUCT_SOURCE];
                    }
                    fv = (flex_value_t *) hspvar_core_ptr_offset(var->pval, var->aptr);
                    if (fv->type == FLEXVAL_TYPE_NONE) {
                        @throw [self make_nsexception:HSPERR_INVALID_STRUCT_SOURCE];
                    }
                    out = (char *) fv->ptr;
                }
                out += prm->offset;
                tflag = prm->mptype;
                ptr = (char *) [self code_get_proxyvar:out mptype:&tflag];
                varproc = HspVarCoreGetProc(tflag);
                basesize = varproc->basesize;
                if (basesize < 0) {
                    if (strcmp(varproc->vartype_name, "int") == 0) {  //整数のGetSize
                        basesize = hspvar_int_get_size((void *) ptr);
                    } else if (strcmp(varproc->vartype_name, "double") == 0) {  //実数のGetSize
                        basesize = hspvar_double_get_size((void *) ptr);
                    } else if (strcmp(varproc->vartype_name, "str") == 0) {  //文字列のGetSize
                        basesize = hspvar_str_get_size((void *) ptr);
                    } else if (strcmp(varproc->vartype_name, "label") == 0) {  //ラベルのGetSize
                        basesize = hspvar_label_get_size((void *) ptr);
                    } else if (strcmp(varproc->vartype_name, "struct") == 0) {  // structのGetSize
                        basesize = hspvar_label_get_size((void *) ptr);
                    } else {
                        @throw [self make_nsexception:HSPERR_SYNTAX];
                    }
                }
                stack_push(tflag, ptr, basesize);
                break;
            case TYPE_LABEL: {
                unsigned short *tmpval =
                        abc_hspctx.mem_mcs + abc_hspctx.mem_ot[hsp_val_tmp];
                stack_push(HSPVAR_FLAG_LABEL, (char *) &tmpval, sizeof(unsigned short *));
                [self code_next];
                break;
            }
            default:
                //		リダイレクト(reffunc)使用チェック
                //

                info = GetTypeInfoPtr(hsp_type_tmp);
                if (info->reffuncNumber == -1) {
                    @throw [self make_nsexception:HSPERR_INVALID_PARAMETER];
                }
                tmpval = hsp_val_tmp;
                [self code_next];

                switch (info->reffuncNumber) {
                    case 0:
                        ptr = (char *) [self reffunc_sysvar:&tflag arg:tmpval];
                        break;
                    case 1:
                        ptr = (char *) [self reffunc_custom:&tflag arg:tmpval];
                        break;
                    case 2:
                        // ptr = (char *)reffunc_dllcmd(&tflag, tmpval);
                        break;
                    case 3:
                        // ptr = (char *)reffunc_ctrlfunc(&tflag, tmpval);
                        break;
                    case 4:

                        ptr = (char *) [self reffunc_function:&tflag arg:tmpval];
                        break;
                    case 5:
                        ptr = (char *) [self reffunc_intfunc:&tflag arg:tmpval];
                        break;
                    default:

                        break;
                }
                // ptr = (char *)info->reffunc( &tflag, tmpval );	//
                // タイプごとの関数振り分け
                if (strcmp(HspVarCoreGetProc(tflag)->vartype_name, "int") == 0) {  //整数のGetSize
                    basesize = hspvar_int_get_size((void *) ptr);
                } else if (strcmp(HspVarCoreGetProc(tflag)->vartype_name, "double") == 0) {  //実数のGetSize
                    basesize = hspvar_double_get_size((void *) ptr);
                } else if (strcmp(HspVarCoreGetProc(tflag)->vartype_name, "str") == 0) {  //文字列のGetSize
                    basesize = hspvar_str_get_size((void *) ptr);
                } else if (strcmp(HspVarCoreGetProc(tflag)->vartype_name, "label") == 0) {  //ラベルのGetSize
                    basesize = hspvar_label_get_size((void *) ptr);
                } else if (strcmp(HspVarCoreGetProc(tflag)->vartype_name, "struct") == 0) {  // structのGetSize
                    basesize = hspvar_label_get_size((void *) ptr);
                } else {
                    @throw [self make_nsexception:HSPERR_SYNTAX];
                }
                stack_push(tflag, ptr, basesize);
                break;
        }

        if (hsp_exflg) {  // パラメーター終端チェック
            hsp_exflg &= ~EXFLG_2;
            break;
        }
    }

    stm = StackPeek;
    tflag = stm->type;

    if (tflag == HSPVAR_FLAG_INT) {  // int型の場合は直接値を設定する(高速化)
        mpval = hsp_mpval_int;
        *(int *) mpval->pt = stm->ival;
    } else {
        varproc = HspVarCoreGetProc(tflag);
        mpval = HspVarCoreGetPVal(tflag);

        if (mpval->mode ==
                HSPVAR_MODE_NONE) {  // 型に合わせたテンポラリ変数を初期化
            if (varproc->flag == 0) {
                @throw [self make_nsexception:HSPERR_TYPE_INITALIZATION_FAILED];
            }
            hspvar_core_clear_tmp(mpval, tflag);  // 最小サイズのメモリを確保
        }

        // テンポラリ変数に初期値を設定
        if (strcmp(varproc->vartype_name, "int") == 0) {  //整数のSet
            hspvar_int_set(mpval, (void *) (mpval->pt), STM_GETPTR(stm));
        } else if (strcmp(varproc->vartype_name, "double") == 0) {  //実数のSet
            hspvar_double_set(mpval, (void *) (mpval->pt), STM_GETPTR(stm));
        } else if (strcmp(varproc->vartype_name, "str") == 0) {  //文字列のSet
            hspvar_str_set(mpval, (void *) (mpval->pt), STM_GETPTR(stm));
        } else if (strcmp(varproc->vartype_name, "label") == 0) {  //ラベルのSet
            hspvar_label_set(mpval, (void *) (mpval->pt), STM_GETPTR(stm));
        } else if (strcmp(varproc->vartype_name, "struct") == 0) {  // structのSet
            hspvar_label_set(mpval, (void *) (mpval->pt), STM_GETPTR(stm));
        } else {
            @throw [self make_nsexception:HSPERR_SYNTAX];
        }
    }

    stack_pop();
    if (stack_def != StackGetLevel) {  // スタックが正常に復帰していない
        @throw [self make_nsexception:HSPERR_STACK_OVERFLOW];
    }

    return resval;
}

/// 文字列パラメーターを取得
///
- (char *)code_gets {
    int chk = [self code_get];
    if (chk <= PARAM_END) {
        @throw [self make_nsexception:HSPERR_NO_DEFAULT];
    }
    if (mpval->flag != HSPVAR_FLAG_STR) {
        @throw [self make_nsexception:HSPERR_TYPE_MISMATCH];
    }
    return (mpval->pt);
}

/// 文字列パラメーターを取得(デフォルト値あり)
///
- (char *)code_getds:(const char *)defval {
    int chk = [self code_get];
    if (chk <= PARAM_END) {
        return (char *) defval;
    }
    if (mpval->flag != HSPVAR_FLAG_STR) {
        @throw [self make_nsexception:HSPERR_TYPE_MISMATCH];
    }
    return (mpval->pt);
}

/// 文字列パラメーターを取得(デフォルト値あり・数値も可)
///
- (char *)code_getdsi:(const char *)defval {
    int chk = [self code_get];
    char *ptr;
    if (chk <= PARAM_END) {
        return (char *) defval;
    }
    ptr = mpval->pt;
    if (mpval->flag != HSPVAR_FLAG_STR) {  // 型が一致しない場合は変換
        // ptr = (char *)HspVarCoreCnv( mpval->flag, HSPVAR_FLAG_STR, ptr );
        ptr = (char *) hspvar_core_cnv_ptr(mpval, HSPVAR_FLAG_STR);
    }
    return ptr;
}

/// 数値パラメーターを取得
///
- (int)code_geti {
    int chk = [self code_get];
    if (chk <= PARAM_END) {
        @throw [self make_nsexception:HSPERR_NO_DEFAULT];
    }
    if (mpval->flag != HSPVAR_FLAG_INT) {
        if (mpval->flag != HSPVAR_FLAG_DOUBLE) {
            @throw [self make_nsexception:HSPERR_TYPE_MISMATCH];
        }
        return (int) (*(double *) (mpval->pt));  // doubleの時はintに変換
    }
    return *(int *) (mpval->pt);
}

/// 数値パラメーターを取得(デフォルト値あり)
///
- (int)code_getdi:(const int)defval {
    int chk = [self code_get];
    if (chk <= PARAM_END) {
        return defval;
    }
    if (mpval->flag != HSPVAR_FLAG_INT) {
        if (mpval->flag != HSPVAR_FLAG_DOUBLE) {
            @throw [self make_nsexception:HSPERR_TYPE_MISMATCH];
        }
        return (int) (*(double *) (mpval->pt));  // doubleの時はintに変換
    }
    return *(int *) (mpval->pt);
}

/// 数値(double)パラメーターを取得
///
- (double)code_getd {
    int chk = [self code_get];
    if (chk <= PARAM_END) {
        @throw [self make_nsexception:HSPERR_NO_DEFAULT];
    }
    if (mpval->flag != HSPVAR_FLAG_DOUBLE) {
        if (mpval->flag != HSPVAR_FLAG_INT) {
            @throw [self make_nsexception:HSPERR_TYPE_MISMATCH];
        }
        return (double) (*(int *) (mpval->pt));  // intの時はdoubleに変換
    }
    return *(double *) (mpval->pt);
}

/// 数値(double)パラメーターを取得(デフォルト値あり)
///
- (double)code_getdd:(const double)defval {
    int chk = [self code_get];
    if (chk <= PARAM_END) {
        return defval;
    }
    if (mpval->flag != HSPVAR_FLAG_DOUBLE) {
        if (mpval->flag != HSPVAR_FLAG_INT) {
            @throw [self make_nsexception:HSPERR_TYPE_MISMATCH];
        }
        return (double) (*(int *) (mpval->pt));  // intの時はdoubleに変換
    }
    return *(double *) (mpval->pt);
}

/// pvalの実体を検索する(マルチパラメーターの場合があるため)
///
/// ( 返値が新しいPValポインタとなる )
///
- (int)code_getv_sub:(value_t **)pval {
    value_t *getv_pval;
    //	MPVarData *var;
    int mptype = MPTYPE_VAR;
    getv_pval = *pval;
    if (getv_pval->support & HSPVAR_SUPPORT_MISCTYPE) {  // 連想配列などの検索
        [self code_checkarray_obj2:getv_pval];
        return HspVarCoreGetAPTR(getv_pval);
    }
    [self code_checkarray2:*pval];  // 通常の配列検索(拡張あり)
    return HspVarCoreGetAPTR(getv_pval);
}

/*
 static APTR code_getv_sub2( PVal **pval )
 {
 //		pvalの実体を検索する(マルチパラメーターの場合があるため)
 //		( 返値が新しいPValポインタとなる )
 //
 PVal *getv_pval;
 MPVarData *var;
 int mptype;
 
 mptype = MPTYPE_VAR;
 getv_pval = *pval;
 if ( getv_pval->support & HSPVAR_SUPPORT_MISCTYPE ) {		//
 連想配列などの検索
 var = (MPVarData *)code_checkarray_obj( getv_pval, &mptype );
 return code_getv_proxy( pval, var, mptype );
 }
 code_checkarray2( *pval );
 // 通常の配列検索
 return HspVarCoreGetAPTR( getv_pval );
 }
 */

- (int)code_getv_proxy:(value_t **)pval var:(multi_param_var_data_t *)var mptype:(int)mptype {
    value_t *getv_pval;
    int aptr;
    switch (mptype) {  // マルチパラメーターを取得
        case MPTYPE_VAR:
            return HspVarCoreGetAPTR(*pval);
        case MPTYPE_SINGLEVAR:
            getv_pval = var->pval;
            aptr = var->aptr;
            if (hsp_type_tmp == TYPE_MARK) {
                if (hsp_val_tmp == '(') {
                    @throw [self make_nsexception:HSPERR_INVALID_ARRAY];
                }
            }
            break;
        case MPTYPE_ARRAYVAR:
            getv_pval = var->pval;
            aptr = [self code_getv_sub:&getv_pval];
            break;
        case MPTYPE_LOCALVAR:
            getv_pval = (value_t *) var;
            aptr = [self code_getv_sub:&getv_pval];
            break;
        default: {
            @throw [self make_nsexception:HSPERR_VARIABLE_REQUIRED];
        }
    }
    *pval = getv_pval;
    return aptr;
}

/// 置き換えパラメーターを変数の代わりに取得
///
/// static inline
- (int)code_getva_struct:(value_t **)pval {
    multi_param_module_var_data_t *var;
    flex_value_t *fv;
    struct_param_t *prm;
    int aptr;
    char *out;
    int i = hsp_val_tmp;

    [self code_next];
    out = ((char *) abc_hspctx.prmstack);
    if (out == NULL) {
        @throw [self make_nsexception:HSPERR_INVALID_PARAMETER];
    }

    if (i == STRUCTCODE_THISMOD) {  // thismod
        var = (multi_param_module_var_data_t *) out;
        if (var->magic != MODVAR_MAGICCODE) {
            @throw [self make_nsexception:HSPERR_INVALID_STRUCT_SOURCE];
        }
        *pval = var->pval;
        hsp_exflg &= EXFLG_1;
        return var->aptr;
    }

    prm = &abc_hspctx.mem_minfo[i];
    if (prm->subid != STRUCTPRM_SUBID_STACK) {
        var = (multi_param_module_var_data_t *) out;
        if ((var->magic != MODVAR_MAGICCODE) || (var->subid != prm->subid) ||
                (var->pval->flag != TYPE_STRUCT)) {
            @throw [self make_nsexception:HSPERR_INVALID_STRUCT_SOURCE];
        }
        fv = (flex_value_t *) hspvar_core_ptr_offset(var->pval, var->aptr);
        if (fv->type == FLEXVAL_TYPE_NONE) {
            @throw [self make_nsexception:HSPERR_INVALID_STRUCT_SOURCE];
        }
        out = (char *) fv->ptr;
    }
    out += prm->offset;
    aptr = [self code_getv_proxy:pval var:(multi_param_var_data_t *) out mptype:prm->mptype];
    hsp_exflg &= EXFLG_1;  // for 2nd prm_get
    return aptr;
}

/// 変数パラメーターを取得(pval+int)
///
- (int)code_getva:(value_t **)pval {
    value_t *getv_pval;
    int aptr;
    if (hsp_exflg) { // パラメーターなし(デフォルト時)
        @throw [self make_nsexception:HSPERR_VARIABLE_REQUIRED];
    }

    if (hsp_type_tmp == TYPE_STRUCT) {  // 置き換えパラメーター時
        return [self code_getva_struct:pval];
    }
    if (hsp_type_tmp != TYPE_VAR) {
        @throw [self make_nsexception:HSPERR_VARIABLE_REQUIRED];
    }

    getv_pval = &abc_hspctx.mem_var[hsp_val_tmp];
    [self code_next];

    aptr = [self code_getv_sub:&getv_pval];

    hsp_exflg &= EXFLG_1;  // for 2nd prm_get
    *pval = getv_pval;

    return aptr;
}

/// 変数パラメーターを取得(PVal)
///
- (value_t *)code_getpval {
    value_t *getv_pval;
    int aptr;
    aptr = [self code_getva:&getv_pval];
    if (aptr != 0) {
        @throw [self make_nsexception:HSPERR_BAD_ARRAY_EXPRESSION];
    }
    return getv_pval;
}

/// ラベルパラメーターを取得
///
- (unsigned short *)code_getlb {
    if (hsp_type_tmp != TYPE_LABEL) {
        int chk = [self code_get];
        unsigned short *p;
        if (chk <= PARAM_END) {
            @throw [self make_nsexception:HSPERR_LABEL_REQUIRED];
        }
        if (mpval->flag != HSPVAR_FLAG_LABEL) {
            @throw [self make_nsexception:HSPERR_LABEL_REQUIRED];
        }
        p = *(unsigned short **) mpval->pt;
        if (p == NULL) {  // ラベル型変数の初期値はエラーに
            @throw [self make_nsexception:HSPERR_LABEL_REQUIRED];
        }
        hsp_mcs = hsp_mcsbak;
        return p;
    }
    return (unsigned short *) (abc_hspctx.mem_mcs + (abc_hspctx.mem_ot[hsp_val_tmp]));
}

- (unsigned short *)code_getlb2 {
    unsigned short *s;
    s = [self code_getlb];
    [self code_next];
    hsp_exflg &= ~EXFLG_2;
    return s;
}

/// 構造体パラメーターを取得
///
- (struct_param_t *)code_getstprm {
    struct_param_t *prm;
    if (hsp_type_tmp != TYPE_STRUCT) {
        @throw [self make_nsexception:HSPERR_STRUCT_REQUIRED];
    }
    prm = &hsp_hspctx->mem_minfo[hsp_val_tmp];
    [self code_next];
    hsp_exflg &= ~EXFLG_2;
    return prm;
}

/// 構造体パラメーターを取得
///
- (struct_data_t *)code_getstruct {
    struct_data_t *st;
    struct_param_t *prm;
    prm = [self code_getstprm];
    if (prm->mptype != MPTYPE_STRUCTTAG) {
        @throw [self make_nsexception:HSPERR_STRUCT_REQUIRED];
    }
    st = &hsp_hspctx->mem_finfo[prm->subid];
    return st;
}

/// COM構造体パラメーターを取得
///
- (struct_data_t *)code_getcomst {
    struct_data_t *st;
    if (hsp_type_tmp != TYPE_DLLCTRL) {
        @throw [self make_nsexception:HSPERR_TYPE_MISMATCH];
    }
    hsp_val_tmp -= TYPE_OFFSET_COMOBJ;
    if (hsp_val_tmp < 0) {
        @throw [self make_nsexception:HSPERR_TYPE_MISMATCH];
    }
    st = &hsp_hspctx->mem_finfo[hsp_val_tmp];
    [self code_next];
    hsp_exflg &= ~EXFLG_2;
    return st;
}

/*
 void code_setv( PVal *pval, PDAT *dat, int type, void *ptr )
 {
 //		変数にパラメーターを指定する
 //
 PDAT *p;
 HspVarProc *proc;
 
 p = dat;
 proc = HspVarCoreGetProc( type );
 if ( pval->flag != type ) {
 HspVarCoreReset( pval );
 p = HspVarCorePtr( pval );					//
 要素0のPDATポインタを取得
 if ( p != dat ) throw HSPERR_INVALID_ARRAYSTORE;
 hspvar_core_clear( pval, type );				//
 最小サイズのメモリを確保
 p = proc->GetPtr( pval );					//
 PDATポインタを取得
 }
 proc->Set( p, ptr );
 }
 */

/// 変数にパラメーターを指定する
///
- (void)code_setva:(value_t *)pval aptr:(int)aptr type:(int)type ptr:(const void *)ptr {
    hspvar_proc_t *proc;
    pval->offset = aptr;
    proc = HspVarCoreGetProc(type);
    if (pval->flag != type) {
        if (aptr != 0) {
            @throw [self make_nsexception:HSPERR_INVALID_ARRAYSTORE];
        }
        hspvar_core_clear(pval, type);  // 最小サイズのメモリを確保
    }

    void *dst;
    if (strcmp(proc->vartype_name, "int") == 0) {  //整数のGetPtr
        dst = hspvar_int_get_ptr(pval);
    } else if (strcmp(proc->vartype_name, "double") == 0) {  //実数のGetPtr
        dst = hspvar_double_get_ptr(pval);
    } else if (strcmp(proc->vartype_name, "str") == 0) {  //文字列のGetPtr
        dst = hspvar_str_get_ptr(pval);
    } else if (strcmp(proc->vartype_name, "label") == 0) {  //ラベルのGetPtr
        dst = hspvar_label_get_ptr(pval);
    } else if (strcmp(proc->vartype_name, "struct") == 0) {  // structのGetPtr
        dst = hspvar_label_get_ptr(pval);
    } else {
        @throw [self make_nsexception:HSPERR_SYNTAX];
    }

    if (strcmp(proc->vartype_name, "int") == 0) {  //整数のSet
        hspvar_int_set(pval, dst, ptr);
    } else if (strcmp(proc->vartype_name, "double") == 0) {  //実数のSet
        hspvar_double_set(pval, dst, ptr);
    } else if (strcmp(proc->vartype_name, "str") == 0) {  //文字列のSet
        hspvar_str_set(pval, dst, ptr);
    } else if (strcmp(proc->vartype_name, "label") == 0) {  //ラベルのSet
        hspvar_label_set(pval, dst, ptr);
    } else if (strcmp(proc->vartype_name, "struct") == 0) {  // structのSet
        hspvar_label_set(pval, dst, ptr);
    } else {
        @throw [self make_nsexception:HSPERR_SYNTAX];
    }
}

/// 変数ポインタを得る
///
- (char *)code_getvptr:(value_t **)pval size:(int *)size {
    int aptr;
    aptr = [self code_getva:pval];

    void *dst;
    if (strcmp(hspvar_proc[(*pval)->flag].vartype_name, "int") == 0) {  //整数のGetBlockSize
        dst = hspvar_int_get_block_size(*pval, hspvar_core_ptr_offset(*pval, aptr), size);
    } else if (strcmp(hspvar_proc[(*pval)->flag].vartype_name, "double") == 0) {  //実数のGetBlockSize
        dst = hspvar_double_get_block_size(*pval, hspvar_core_ptr_offset(*pval, aptr), size);
    } else if (strcmp(hspvar_proc[(*pval)->flag].vartype_name, "str") == 0) {  //文字列のGetBlockSize
        dst = hspvar_str_get_block_size(*pval, hspvar_core_ptr_offset(*pval, aptr), size);
    } else if (strcmp(hspvar_proc[(*pval)->flag].vartype_name, "label") == 0) {  //ラベルのGetBlockSize
        dst = hspvar_label_get_block_size(*pval, hspvar_core_ptr_offset(*pval, aptr), size);
    } else if (strcmp(hspvar_proc[(*pval)->flag].vartype_name, "struct") == 0) {  // structのGetBlockSize
        dst = hspvar_label_get_block_size(*pval, hspvar_core_ptr_offset(*pval, aptr), size);
    } else {
        @throw [self make_nsexception:HSPERR_SYNTAX];
    }
    return (char *) dst;
    // HspVarCoreGetBlockSize( *pval, HspVarCorePtrAPTR( *pval,aptr ), size );
}

//------------------------------------------------------------
// call-return process function
//------------------------------------------------------------

/// custom command stack delete
///
- (void)customstack_delete:(struct_data_t *)st stackptr:(char *)stackptr {
    char *out;
    char *ss;
    struct_param_t *prm;
    prm = &hsp_hspctx->mem_minfo[st->prmindex];
    for (int i = 0; i < st->prmmax; i++) {  // パラメーターを取得
        if (prm->mptype == MPTYPE_LOCALSTRING) {
            out = stackptr + prm->offset;
            ss = *(char **) out;
            strbuf_free(ss);
        } else if (prm->mptype == MPTYPE_LOCALVAR) {
            // HspVarCoreDispose( (PVal *)(stackptr + prm->offset) );
            if (strcmp(hspvar_proc[((value_t *) (stackptr + prm->offset))->flag].vartype_name, "int") == 0) {  //整数のFree
                hspvar_int_free((value_t *) (stackptr + prm->offset));
            } else if (strcmp(hspvar_proc[((value_t *) (stackptr + prm->offset))->flag].vartype_name, "double") == 0) {  //実数のFree
                hspvar_double_free((value_t *) (stackptr + prm->offset));
            } else if (strcmp(hspvar_proc[((value_t *) (stackptr + prm->offset))->flag].vartype_name, "str") == 0) {  //文字列のFree
                hspvar_str_free((value_t *) (stackptr + prm->offset));
            } else if (strcmp(hspvar_proc[((value_t *) (stackptr + prm->offset))->flag].vartype_name, "label") == 0) {  //ラベルのFree
                hspvar_label_free((value_t *) (stackptr + prm->offset));
            } else if (strcmp(hspvar_proc[((value_t *) (stackptr + prm->offset))->flag].vartype_name, "struct") == 0) {  // structのFree
                hspvar_label_free((value_t *) (stackptr + prm->offset));
            } else {
                @throw [self make_nsexception:HSPERR_SYNTAX];
            }
        }
        prm++;
    }
}

/// return execute
///
- (void)cmdfunc_return {
    stack_manager_t *stm;
    hsp_subroutine_t *r;

    if (StackGetLevel == 0) {
        @throw [self make_nsexception:HSPERR_RETURN_WITHOUT_GOSUB];
    }

    stm = StackPeek;
    r = (hsp_subroutine_t *) STM_GETPTR(stm);

    if (stm->type == TYPE_EX_CUSTOMFUNC) {
        [self customstack_delete:r->param stackptr:(char *) (r + 1)];  // カスタム命令のローカルメモリを解放
    }

    hsp_mcs = r->mcsret;
    hsp_hspctx->prmstack = r->old_stack;  // 以前のスタックに戻す
    hsp_hspctx->sublev--;
    [self code_next];
    stack_pop();
}

/// gosub execute
///
- (int)cmdfunc_gosub:(unsigned short *)subr {
    hsp_subroutine_t r;
    r.mcsret = hsp_mcs;
    r.stack_level = abc_hspctx.sublev++;
    r.old_stack = abc_hspctx.prmstack;
    r.param = NULL;
    stack_push(TYPE_EX_SUBROUTINE, (char *)&r, sizeof(hsp_subroutine_t));

    hsp_mcs = subr;
    [self code_next];

    //		gosub内で呼び出しを完結させる
    //
    while (1) {
#ifdef FLAG_HSPDEBUG
        if (hsp_dbgmode) [self code_dbgtrace];  // トレースモード時の処理
#endif
        // NSLog(@"A:GetTypeInfoPtr( hsp_type_tmp )->cmdfunc( val )");
        int result = 0;  //結果
        switch (GetTypeInfoPtr(hsp_type_tmp)->cmdfuncNumber) {
            case 0:
                result = [self cmdfunc_var:hsp_val_tmp];
                break;
            case 1:
                result = [self cmdfunc_prog:hsp_val_tmp];
                break;
            case 2:
                result = [self cmdfunc_ifcmd:hsp_val_tmp];
                break;
            case 3:
                result = [self cmdfunc_custom:hsp_val_tmp];
                break;
            case 4:
                result = [self cmdfunc_default:hsp_val_tmp];
                break;
            case 5:
                // result = cmdfunc_dllcmd(val);
                break;
            case 6:
                // result = cmdfunc_ctrlcmd(val);
                break;
            case 7:
                result = [self cmdfunc_extcmd:hsp_val_tmp];
                break;
            case 8:
                result = [self cmdfunc_intcmd:hsp_val_tmp];
                break;
            default:
                break;
        }
        // if ( GetTypeInfoPtr( hsp_type_tmp )->cmdfunc( val ) ) {	//
        // タイプごとの関数振り分け
        if (result) {
            if (abc_hspctx.runmode == RUNMODE_RETURN) {
                [self cmdfunc_return];
                break;
            } else {
                // hspctx->msgfunc( hspctx );
                [self code_def_msgfunc:&(abc_hspctx)];
            }
            if (abc_hspctx.runmode == RUNMODE_END) {
                return RUNMODE_END;
            }
        }
    }
    return RUNMODE_RUN;
}

/// ユーザー拡張命令を呼び出す
///
- (int)code_callfunc:(int)cmd {
    struct_data_t *st = &abc_hspctx.mem_finfo[cmd];
    int size = sizeof(hsp_subroutine_t) + st->size;
    hsp_subroutine_t *r = (hsp_subroutine_t *) stack_push_size(TYPE_EX_CUSTOMFUNC, size);
    char *p = (char *) (r + 1);
    [self code_expandstruct:p st:st option:CODE_EXPANDSTRUCT_OPT_NONE];  // スタックの内容を初期化

    r->old_stack = abc_hspctx.prmstack;  // 以前のスタックを保存
    abc_hspctx.prmstack = (void *) p;   // 新規スタックを設定

    r->mcsret = hsp_mcsbak;             // 戻り場所
    r->stack_level = abc_hspctx.sublev++;  // ネストを進める
    r->param = st;

    hsp_mcs = (unsigned short *) (abc_hspctx.mem_mcs + (abc_hspctx.mem_ot[st->otindex]));
    [self code_next];

    //		命令内で呼び出しを完結させる
    //
    while (1) {
#ifdef FLAG_HSPDEBUG
        if (hsp_dbgmode) [self code_dbgtrace];  // トレースモード時の処理
#endif
        // NSLog(@"B:GetTypeInfoPtr( hsp_type_tmp )->cmdfunc( val )");
        int result = 0;  //結果
        switch (GetTypeInfoPtr(hsp_type_tmp)->cmdfuncNumber) {
            case 0:
                result = [self cmdfunc_var:hsp_val_tmp];
                break;
            case 1:
                result = [self cmdfunc_prog:hsp_val_tmp];
                break;
            case 2:
                result = [self cmdfunc_ifcmd:hsp_val_tmp];
                break;
            case 3:
                result = [self cmdfunc_custom:hsp_val_tmp];
                break;
            case 4:
                result = [self cmdfunc_default:hsp_val_tmp];
                break;
            case 5:
                // result = cmdfunc_dllcmd(val);
                break;
            case 6:
                // result = cmdfunc_ctrlcmd(val);
                break;
            case 7:
                result = [self cmdfunc_extcmd:hsp_val_tmp];
                break;
            case 8:
                result = [self cmdfunc_intcmd:hsp_val_tmp];
                break;
            default:
                break;
        }
        if (result) {
            // if ( GetTypeInfoPtr( hsp_type_tmp )->cmdfunc( val ) ) {	//
            // タイプごとの関数振り分け
            if (abc_hspctx.runmode == RUNMODE_END) {
                @throw [self make_nsexception:HSPERR_NONE];
            }
            if (abc_hspctx.runmode == RUNMODE_RETURN) {
                [self cmdfunc_return];
                break;
            } else {
                // hspctx.msgfunc( hspctx );
                [self code_def_msgfunc:&(abc_hspctx)];
            }
        }
    }
    return RUNMODE_RUN;
}

//------------------------------------------------------------
// structure process function
//------------------------------------------------------------

int code_newstruct(value_t *pval) {
    int max;
    int ofs;
    flex_value_t *fv;
    ofs = 0;
    if (pval->flag != TYPE_STRUCT) return 0;
    fv = (flex_value_t *) pval->pt;
    max = pval->len[1];
    for (int i = 0; i < max; i++) {
        if (fv[i].type == FLEXVAL_TYPE_NONE) return i;
    }
    hspvar_core_re_dim(pval, 1, max + 1);  // 配列を拡張する
    return max;
}

/// TYPE_STRUCTの変数を設定する
///
/// (返値:構造体を収めるための情報ポインタ)
///
- (flex_value_t *)code_setvs:(value_t *)pval aptr:(int)aptr ptr:(void *)ptr size:(int)size subid:(int)subid {
    flex_value_t fv;
    fv.customid = subid;
    fv.clonetype = 0;
    fv.size = size;
    fv.ptr = ptr;
    [self code_setva:pval aptr:aptr type:TYPE_STRUCT ptr:&fv];
    return (flex_value_t *) hspvar_core_ptr_offset(pval, aptr);
}

/// 構造体の項目にパラメーターを代入する
///
- (void)code_expandstruct:(char *)p st:(struct_data_t *)st option:(int)option {
    int chk;
    char *out;
    struct_param_t *prm = &abc_hspctx.mem_minfo[st->prmindex];

    for (int i = 0; i < st->prmmax; i++) {  // パラメーターを取得
        out = p + prm->offset;
        // alert_format("(%d)hsp_type_tmp%d index%d/%d offset%d", st->subid, prm->mptype,
        // st->prmindex + i, st->prmmax, prm->offset);
        switch (prm->mptype) {
            case MPTYPE_INUM:
                *(int *) out = [self code_getdi:0];
                break;
            case MPTYPE_MODULEVAR: {
                multi_param_module_var_data_t *var;
                value_t *refpv;
                int refap;
                var = (multi_param_module_var_data_t *) out;
                refap = [self code_getva:&refpv];
                var->magic = MODVAR_MAGICCODE;
                var->subid = prm->subid;
                var->pval = refpv;
                var->aptr = refap;
                break;
            }
            case MPTYPE_IMODULEVAR:
            case MPTYPE_TMODULEVAR:
                *(multi_param_module_var_data_t *) out = hsp_modvar_init;
                break;
            case MPTYPE_SINGLEVAR:
            case MPTYPE_ARRAYVAR: {
                multi_param_var_data_t *var;
                value_t *refpv;
                int refap;
                var = (multi_param_var_data_t *) out;
                refap = [self code_getva:&refpv];
                var->pval = refpv;
                var->aptr = refap;
                break;
            }
            case MPTYPE_LABEL:
                *(unsigned short **) out = [self code_getlb2];
                break;
            case MPTYPE_DNUM: {
                //*(double *)out = code_getd();
                double d = [self code_getd];
                memcpy(out, &d, sizeof(double));
                break;
            }
            case MPTYPE_LOCALSTRING: {
                char *str;
                char *ss;
                str = [self code_gets];
                ss = strbuf_alloc((int) strlen(str) + 1);
                strcpy(ss, str);
                *(char **) out = ss;
                break;
            }
            case MPTYPE_LOCALVAR: {
                value_t *pval;
                void *dst;
                hspvar_proc_t *proc;
                pval = (value_t *) out;
                pval->mode = HSPVAR_MODE_NONE;
                if (option & CODE_EXPANDSTRUCT_OPT_LOCALVAR) {
                    chk = [self code_get];  // パラメーター値を取得
                    if (chk == PARAM_OK) {
                        pval->flag = mpval->flag;            // 仮の型
                        hspvar_core_clear(pval, mpval->flag);  // 最小サイズのメモリを確保
                        proc = HspVarCoreGetProc(pval->flag);

                        // PDATポインタを取得
                        if (strcmp(proc->vartype_name, "int") == 0) {  //整数のGetPtr
                            dst = hspvar_int_get_ptr(pval);
                        } else if (strcmp(proc->vartype_name, "double") == 0) {  //実数のGetPtr
                            dst = hspvar_double_get_ptr(pval);
                        } else if (strcmp(proc->vartype_name, "str") == 0) {  //文字列のGetPtr
                            dst = hspvar_str_get_ptr(pval);
                        } else if (strcmp(proc->vartype_name, "label") == 0) {  //ラベルのGetPtr
                            dst = hspvar_label_get_ptr(pval);
                        } else if (strcmp(proc->vartype_name, "struct") == 0) {  // structのGetPtr
                            dst = hspvar_label_get_ptr(pval);
                        } else {
                            @throw [self make_nsexception:HSPERR_SYNTAX];
                        }

                        if (strcmp(proc->vartype_name, "int") == 0) {  //整数のSet
                            hspvar_int_set(pval, dst, mpval->pt);
                        } else if (strcmp(proc->vartype_name, "double") == 0) {  //実数のSet
                            hspvar_double_set(pval, dst, mpval->pt);
                        } else if (strcmp(proc->vartype_name, "str") == 0) {  //文字列のSet
                            hspvar_str_set(pval, dst, mpval->pt);
                        } else if (strcmp(proc->vartype_name, "label") == 0) {  //ラベルのSet
                            hspvar_label_set(pval, dst, mpval->pt);
                        } else if (strcmp(proc->vartype_name, "struct") == 0) {  // structのSet
                            hspvar_label_set(pval, dst, mpval->pt);
                        } else {
                            @throw [self make_nsexception:HSPERR_SYNTAX];
                        }
                        break;
                    }
                }
                pval->flag = HSPVAR_FLAG_INT;  // 仮の型
                hspvar_core_clear(pval, HSPVAR_FLAG_INT);  // グローバル変数を0にリセット
                break;
            }
            case MPTYPE_STRUCTTAG:
                break;
            default: {
                @throw [self make_nsexception:HSPERR_INVALID_STRUCT_SOURCE];
            }
        }
        prm++;
    }

}

/// モジュール変数を破棄する
///
- (void)code_delstruct:(value_t *)in_pval in_aptr:(int)in_aptr {
    int i;
    char *p;
    char *out;
    struct_param_t *prm;
    struct_data_t *st;
    value_t *pval;
    flex_value_t *fv = (flex_value_t *) hspvar_core_ptr_offset(in_pval, in_aptr);

    if (fv->type != FLEXVAL_TYPE_ALLOC) {
        return;
    }

    prm = &abc_hspctx.mem_minfo[fv->customid];
    st = &abc_hspctx.mem_finfo[prm->subid];
    p = (char *) fv->ptr;

    if (fv->clonetype == 0) {
        if (st->otindex) {  // デストラクタを起動
            hsp_modvar_init.magic = MODVAR_MAGICCODE;
            hsp_modvar_init.subid = prm->subid;
            hsp_modvar_init.pval = in_pval;
            hsp_modvar_init.aptr = in_aptr;
            [self code_callfunc:st->otindex];
        }

        for (i = 0; i < st->prmmax; i++) {  // パラメーターを取得
            out = p + prm->offset;
            switch (prm->mptype) {
                case MPTYPE_LOCALVAR: {
                    pval = (value_t *) out;
                    // HspVarCoreDispose( pval );
                    if (strcmp(hspvar_proc[(pval)->flag].vartype_name, "int") == 0) {  //整数のFree
                        hspvar_int_free(pval);
                    } else if (strcmp(hspvar_proc[(pval)->flag].vartype_name, "double") == 0) {  //実数のFree
                        hspvar_double_free(pval);
                    } else if (strcmp(hspvar_proc[(pval)->flag].vartype_name, "str") == 0) {  //文字列のFree
                        hspvar_str_free(pval);
                    } else if (strcmp(hspvar_proc[(pval)->flag].vartype_name, "label") == 0) {  //ラベルのFree
                        hspvar_label_free(pval);
                    } else if (strcmp(hspvar_proc[(pval)->flag].vartype_name, "struct") == 0) {  // structのFree
                        hspvar_label_free(pval);
                    } else {
                        @throw [self make_nsexception:HSPERR_SYNTAX];
                    }
                    break;
                }
            }
            prm++;
        }
    }

    strbuf_free(fv->ptr);
    fv->type = FLEXVAL_TYPE_NONE;
}

/// モジュール変数全体を破棄する
///
- (void)code_delstruct_all:(value_t *)pval {
    if (pval->mode == HSPVAR_MODE_MALLOC) {
        for (int i = 0; i < pval->len[1]; i++) {
            [self code_delstruct:pval in_aptr:i];
        }
    }
}

/// stmp(文字列一時バッファ)を指定サイズで初期化する
///
- (char *)code_stmp:(int)size {
    if (size > 1024) {
        hsp_hspctx->stmp = strbuf_expand(hsp_hspctx->stmp, size);
    }
    return hsp_hspctx->stmp;
}

/// stmp(文字列一時バッファ)にsrcをコピーする
///
- (char *)code_stmpstr:(char *)src {
    char *p = [self code_stmp:(int) strlen(src) + 1];
    strcpy(p, src);
    return p;
}

- (char *)code_getsptr:(int *)type {
    int fl;
    char *bp;
    if ([self code_get] <= PARAM_END) {
        fl = HSPVAR_FLAG_INT;
        hsp_sptr_res = 0;
        bp = (char *) &hsp_sptr_res;
    } else {
        fl = mpval->flag;
        bp = mpval->pt;
        if ((fl != HSPVAR_FLAG_INT) && (fl != HSPVAR_FLAG_STR)) {
            @throw [self make_nsexception:HSPERR_TYPE_MISMATCH];
        }
    }
    *type = fl;
    return bp;
}

//------------------------------------------------------------
// type process function
//------------------------------------------------------------

/// cmdfunc : default
///
- (int)cmdfunc_default:(int)cmd {
    int tmp;
    if (hsp_exflg & EXFLG_1) {
        tmp = hsp_type_tmp;
        [self code_next];
        if ((tmp == TYPE_INTFUNC) || (tmp == TYPE_EXTSYSVAR)) {
            @throw [self make_nsexception:HSPERR_FUNCTION_SYNTAX];
        }
        @throw [self make_nsexception:HSPERR_WRONG_NAME];
    }
    @throw [self make_nsexception:HSPERR_TOO_MANY_PARAMETERS];
    return RUNMODE_ERROR;
}

/// custom command execute
///
- (int)cmdfunc_custom:(int)cmd {
    struct_data_t *st;
    [self code_next];
    st = &abc_hspctx.mem_finfo[cmd];
    if (st->index != STRUCTDAT_INDEX_FUNC) {
        @throw [self make_nsexception:HSPERR_SYNTAX];
    }
    return [self code_callfunc:cmd];
}

/// custom function execute
///
- (void *)reffunc_custom:(int *)type_res arg:(int)arg {
    struct_data_t *st;
    void *ptr;
    int old_funcres;

    //		返値のタイプを設定する
    //
    st = &abc_hspctx.mem_finfo[arg];
    if (st->index != STRUCTDAT_INDEX_CFUNC) {
        @throw [self make_nsexception:HSPERR_SYNTAX];
    }
    old_funcres = hsp_funcres;
    hsp_funcres = TYPE_ERROR;

    //			'('で始まるかを調べる
    //
    if (hsp_type_tmp != TYPE_MARK) {
        @throw [self make_nsexception:HSPERR_INVALID_FUNCPARAM];
    }
    if (hsp_val_tmp != '(') {
        @throw [self make_nsexception:HSPERR_INVALID_FUNCPARAM];
    }
    [self code_next];
    [self code_callfunc:arg];

    *type_res = hsp_funcres;  // 返値のタイプを指定する
    switch (hsp_funcres) {    // 返値のポインタを設定する
        case TYPE_STRING:
            ptr = abc_hspctx.refstr;
            break;
        case TYPE_DNUM:
            ptr = &abc_hspctx.refdval;
            break;
        case TYPE_INUM:
            ptr = &abc_hspctx.stat;
            break;
        default: {
            if (abc_hspctx.runmode == RUNMODE_END) {
                @throw [self make_nsexception:HSPERR_NONE];
            }
            @throw [self make_nsexception:HSPERR_NORETVAL];
        }
    }

    //			')'で終わるかを調べる
    //
    if (hsp_type_tmp != TYPE_MARK) {
        @throw [self make_nsexception:HSPERR_INVALID_FUNCPARAM];
    }
    if (hsp_val_tmp != ')') {
        @throw [self make_nsexception:HSPERR_INVALID_FUNCPARAM];
    }
    [self code_next];

    hsp_funcres = old_funcres;

    return ptr;
}

/// cmdfunc : TYPE_VAR
///
/// (変数代入 : 変数名が先頭に来る場合)
///
- (int)cmdfunc_var:(int)cmd {
    value_t *pval;
    hspvar_proc_t *proc;
    int aptr;
    void *ptr;
    void *dst;
    int chk, exp, incval;
    int baseaptr;

#ifdef FLAG_HSPDEBUG
    if ((hsp_exflg & EXFLG_1) == 0) {
        @throw [self make_nsexception:HSPERR_TOO_MANY_PARAMETERS];
    }
#endif

    hsp_exflg = 0;                   // code_nextを使わない時に必要
    aptr = [self code_getva:&pval];  // 変数を取得

    if (hsp_type_tmp != TYPE_MARK) {
        hsp_mcs = hsp_mcsbak;
        @throw [self make_nsexception:HSPERR_SYNTAX];
    }
    exp = hsp_val_tmp;
    [self code_next];  // 次のコードへ

    if (hsp_exflg) {  // インクリメント(+)・デクリメント(-)
        proc = HspVarCoreGetProc(pval->flag);
        incval = 1;
        if (pval->flag == HSPVAR_FLAG_INT) {
            ptr = &incval;
        } else {
            // 型がINTでない場合は変換
            if (strcmp(proc->vartype_name, "int") == 0) {  //整数のCnv
                ptr = (int *) hspvar_int_cnv(&incval, HSPVAR_FLAG_INT);
            } else if (strcmp(proc->vartype_name, "double") == 0) {  //実数のCnv
                ptr = (int *) hspvar_double_cnv(&incval, HSPVAR_FLAG_INT);
            } else if (strcmp(proc->vartype_name, "str") == 0) {  //文字列のCnv
                ptr = (int *) hspvar_str_cnv(&incval, HSPVAR_FLAG_INT);
            } else {
                @throw [self make_nsexception:HSPERR_SYNTAX];
            }
        }
        dst = hspvar_core_ptr_offset(pval, aptr);
        switch (exp) {
            case CALCCODE_ADD: {
                if (strcmp(proc->vartype_name, "int") == 0) {  //整数のインクリメント
                    hspvar_int_add_i(dst, ptr);
                } else if (strcmp(proc->vartype_name, "double") == 0) {  //実数のインクリメント
                    hspvar_double_add_i(dst, ptr);
                } else if (strcmp(proc->vartype_name, "str") == 0) {  //文字列のインクリメント
                    hspvar_str_add_i(dst, ptr);
                } else {
                    @throw [self make_nsexception:HSPERR_SYNTAX];
                }
                break;
            }
            case CALCCODE_SUB: {
                if (strcmp(proc->vartype_name, "int") == 0) {  //整数のデクリメント
                    hspvar_int_sub_i(dst, ptr);
                } else if (strcmp(proc->vartype_name, "double") == 0) {  //実数のデクリメント
                    hspvar_double_sub_i(dst, ptr);
                } else {
                    @throw [self make_nsexception:HSPERR_SYNTAX];
                }
                break;
            }
            default: {
                @throw [self make_nsexception:HSPERR_SYNTAX];
            }
        }

        return RUNMODE_RUN;
    }

    chk = [self code_get];  // パラメーター値を取得
    if (chk != PARAM_OK) {
        @throw [self make_nsexception:HSPERR_SYNTAX];
    }

    proc = HspVarCoreGetProc(pval->flag);
    dst = hspvar_core_ptr_offset(pval, aptr);
    ptr = mpval->pt;
    if (exp == CALCCODE_EQ) {                          // '='による代入
        if (pval->support & HSPVAR_SUPPORT_NOCONVERT) {  // 型変換なしの場合
            if (hsp_arrayobj_flag) {
                //$使用できるObjectWrite関数は存在しない
                // proc->ObjectWrite( pval, ptr, mpval->flag );
                return RUNMODE_RUN;
            }
        }
        if (pval->flag != mpval->flag) {
            if (aptr != 0) {
                @throw [self make_nsexception:HSPERR_INVALID_ARRAYSTORE];  // 型変更の場合は配列要素0のみ
            }
            hspvar_core_clear(pval, mpval->flag);  // 最小サイズのメモリを確保
            proc = HspVarCoreGetProc(pval->flag);

            // PDATポインタを取得
            if (strcmp(proc->vartype_name, "int") == 0) {  //整数のGetPtr
                dst = hspvar_int_get_ptr(pval);
            } else if (strcmp(proc->vartype_name, "double") == 0) {  //実数のGetPtr
                dst = hspvar_double_get_ptr(pval);
            } else if (strcmp(proc->vartype_name, "str") == 0) {  //文字列のGetPtr
                dst = hspvar_str_get_ptr(pval);
            } else if (strcmp(proc->vartype_name, "label") == 0) {  //ラベルのGetPtr
                dst = hspvar_label_get_ptr(pval);
            } else if (strcmp(proc->vartype_name, "struct") == 0) {  // structのGetPtr
                dst = hspvar_label_get_ptr(pval);
            } else {
                @throw [self make_nsexception:HSPERR_SYNTAX];
            }
        }

        if (strcmp(proc->vartype_name, "int") == 0) {  //整数のSet
            hspvar_int_set(pval, dst, ptr);
        } else if (strcmp(proc->vartype_name, "double") == 0) {  //実数のSet
            hspvar_double_set(pval, dst, ptr);
        } else if (strcmp(proc->vartype_name, "str") == 0) {  //文字列のSet
            hspvar_str_set(pval, dst, ptr);
        } else if (strcmp(proc->vartype_name, "label") == 0) {  //ラベルのSet
            hspvar_label_set(pval, dst, ptr);
        } else if (strcmp(proc->vartype_name, "struct") == 0) {  // structのSet
            hspvar_label_set(pval, dst, ptr);
        } else {
            @throw [self make_nsexception:HSPERR_SYNTAX];
        }

        if (hsp_exflg) {
            return RUNMODE_RUN;
        }

        chk = pval->len[1];
        if (chk == 0)
            baseaptr = aptr;
        else
            baseaptr = aptr % chk;
        aptr -= baseaptr;

        while (1) {
            if (hsp_exflg) break;
            chk = [self code_get];  // パラメーター値を取得
            if (chk != PARAM_OK) {
                @throw [self make_nsexception:HSPERR_SYNTAX];
            }
            if (pval->flag != mpval->flag) {
                @throw [self make_nsexception:HSPERR_INVALID_ARRAYSTORE];  // 型変更はできない
            }
            ptr = mpval->pt;
            baseaptr++;

            pval->arraycnt = 0;  // 配列指定カウンタをリセット
            pval->offset = aptr;
            [self code_arrayint2:pval offset:baseaptr];  // 配列チェック

            // dst = HspVarCorePtr( pval );
            // PDAT * dst;
            if (strcmp(hspvar_proc[(pval)->flag].vartype_name, "int") == 0) {  //整数のFree
                dst = hspvar_int_get_ptr(pval);
            } else if (strcmp(hspvar_proc[(pval)->flag].vartype_name, "double") == 0) {  //実数のFree
                dst = hspvar_double_get_ptr(pval);
            } else if (strcmp(hspvar_proc[(pval)->flag].vartype_name, "str") == 0) {  //文字列のFree
                dst = hspvar_str_get_ptr(pval);
            } else if (strcmp(hspvar_proc[(pval)->flag].vartype_name, "label") == 0) {  //ラベルのFree
                dst = hspvar_label_get_ptr(pval);
            } else if (strcmp(hspvar_proc[(pval)->flag].vartype_name, "struct") == 0) {  // structのFree
                dst = hspvar_label_get_ptr(pval);
            } else {
                @throw [self make_nsexception:HSPERR_SYNTAX];
            }

            // 次の配列にたたき込む
            if (strcmp(proc->vartype_name, "int") == 0) {  //整数のSet
                hspvar_int_set(pval, dst, ptr);
            } else if (strcmp(proc->vartype_name, "double") == 0) {  //実数のSet
                hspvar_double_set(pval, dst, ptr);
            } else if (strcmp(proc->vartype_name, "str") == 0) {  //文字列のSet
                hspvar_str_set(pval, dst, ptr);
            } else if (strcmp(proc->vartype_name, "label") == 0) {  //ラベルのSet
                hspvar_label_set(pval, dst, ptr);
            } else if (strcmp(proc->vartype_name, "struct") == 0) {  // structのSet
                hspvar_label_set(pval, dst, ptr);
            } else {
                @throw [self make_nsexception:HSPERR_SYNTAX];
            }
        }
        return RUNMODE_RUN;
    }

    //		変数+演算子による代入
    //
    if (pval->flag != mpval->flag) {  // 型が一致しない場合は変換
        ptr = hspvar_core_cnv_ptr(mpval, pval->flag);
        // ptr = proc->Cnv( ptr, mpval->flag );
    }
    [self calcprm:proc pval:dst exp:exp ptr:ptr];
    if (proc->aftertype != pval->flag) {  // 演算後に型が変わる場合
        @throw [self make_nsexception:HSPERR_TYPE_MISMATCH];
    }

    return RUNMODE_RUN;
}

///        引数をシステム変数にセットする(返値用)
///
- (void)cmdfunc_return_setval {
    if ([self code_get] <= PARAM_END) {
        return;
    }

    abc_hspctx.retval_level = abc_hspctx.sublev;
    hsp_funcres = mpval->flag;

    switch (hsp_funcres) {
        case HSPVAR_FLAG_INT:
            abc_hspctx.stat = *(int *) mpval->pt;
            break;
        case HSPVAR_FLAG_STR:
            strbuf_copy_str(&abc_hspctx.refstr, mpval->pt);
            break;
        case HSPVAR_FLAG_DOUBLE:
            abc_hspctx.refdval = *(double *) mpval->pt;
            break;
        default:
            @throw [self make_nsexception:HSPERR_TYPE_MISMATCH];
    }
}

///    'if' command execute
///
- (int)cmdfunc_ifcmd:(int)cmd {
    unsigned short *mcstmp;
    int i = (int) *hsp_mcs;
    hsp_mcs++;  // skip offset get
    mcstmp = hsp_mcs + i;
    if (hsp_val_tmp == 0) {                      // 'if'
        [self code_next];                          // get first token
        if ([self code_geti]) return RUNMODE_RUN;  // if true
    }
    hsp_mcs = mcstmp;
    [self code_next];
    return RUNMODE_RUN;
}

/// mref command
///
- (void)cmdfunc_mref:(value_t *)pval prm:(int)prm {
    int t, size;
    char *out;
    hsp_extra_info_t *exinfo;

    if (prm & 1024) {
        @throw [self make_nsexception:HSPERR_UNSUPPORTED_FUNCTION];
    }
    if (prm >= 0x40) {
        exinfo = hsp_hspctx->exinfo2;
        //$HspFunc_mref／ex_mrefは現状は無効
        // if ( exinfo->HspFunc_mref != NULL )
        //    exinfo->HspFunc_mref( pval, prm );
        return;
    }
    if ((prm & 0x30) || (prm >= 8)) {
        @throw [self make_nsexception:HSPERR_UNSUPPORTED_FUNCTION];
    }
    out = ((char *) hsp_hspctx->prmstack);
    if (out == NULL) {
        @throw [self make_nsexception:HSPERR_ILLEGAL_FUNCTION];
    }
    t = HSPVAR_FLAG_INT;
    size = sizeof(int);
    hspvar_core_dup_ptr(pval, t, (out + (size * prm)), size);
}

/// cmdfunc : TYPE_PROGCMD
///
- (int)cmdfunc_prog:(int)cmd {
    [self code_next];  // 次のコードを取得(最初に必ず必要です)
    switch (cmd) {  // サブコマンドごとの分岐
        case 0x00:    // goto
            hsp_mcs = [self code_getlb];
            [self code_next];
            break;
        case 0x01:  // gosub
        {
            unsigned short *sbr;
            sbr = [self code_getlb];
            return [self cmdfunc_gosub:sbr];
        }
        case 0x02:  // return
            if (hsp_exflg == 0) [self cmdfunc_return_setval];
            // return cmdfunc_return();
            abc_hspctx.runmode = RUNMODE_RETURN;
            return RUNMODE_RETURN;
        case 0x03:  // break
        {
            if (abc_hspctx.looplev == 0) {
                @throw [self make_nsexception:HSPERR_LOOP_WITHOUT_REPEAT];
            }
            abc_hspctx.looplev--;
            hsp_mcs = [self code_getlb];
            [self code_next];
            break;
        }
        case 0x04:  // repeat
        {
            LOOPDAT *lop;
            unsigned short *label;
            if (abc_hspctx.looplev >= (HSP3_REPEAT_MAX - 1)) {
                @throw [self make_nsexception:HSPERR_TOO_MANY_NEST];
            }
            label = [self code_getlb];
            [self code_next];
            int p1 = [self code_getdi:ETRLOOP];
            int p2 = [self code_getdi:0];
            if (p1 == 0) {  // 0は即break
                hsp_mcs = label;
                [self code_next];
                break;
            }
            if (p1 < 0)
                p1 = ETRLOOP;
            else
                p1 += p2;
            abc_hspctx.looplev++;

            lop = (&(abc_hspctx
                    .mem_loop[abc_hspctx.looplev]));  ////GETLOP(hspctx.looplev);
            lop->cnt = p2;
            lop->time = p1;
            lop->pt = hsp_mcsbak;
            break;
        }
        case 0x05:  // loop
        {
            LOOPDAT *lop;
            if (abc_hspctx.looplev == 0) {
                @throw [self make_nsexception:HSPERR_LOOP_WITHOUT_REPEAT];
            }
            lop = (&(abc_hspctx
                    .mem_loop[abc_hspctx.looplev]));  // GETLOP(hspctx->looplev);
            lop->cnt++;
            if (lop->time != ETRLOOP) {  // not eternal loop
                if (lop->cnt >= lop->time) {
                    abc_hspctx.looplev--;
                    break;
                }
            }
            hsp_mcs = lop->pt;
            [self code_next];
            break;
        }
        case 0x06:  // continue
        {
            LOOPDAT *lop;
            unsigned short *label;
            label = [self code_getlb];
            lop = (&(abc_hspctx
                    .mem_loop[abc_hspctx.looplev]));  // GETLOP(hspctx->looplev);
            [self code_next];
            int p2 = lop->cnt + 1;
            int p1 = [self code_getdi:p2];
            lop->cnt = p1 - 1;
            hsp_mcs = label;
            hsp_val_tmp = 0x05;
            hsp_type_tmp = TYPE_PROGCMD;
            hsp_exflg = 0;  // set 'loop' code
            break;
        }
        case 0x07:  // wait
            abc_hspctx.waitcount = [self code_getdi:100];
            //修正
            usleep(abc_hspctx.waitcount * 10000);
            break;
            //元
            // hspctx->runmode = RUNMODE_WAIT;
            // return RUNMODE_WAIT;
        case 0x08:  // await
        {
            int p1 = [self code_getdi:0];
            // p2=code_getdi( -1 );
            abc_hspctx.waitcount = p1;
            abc_hspctx.waittick = -1;
            // if ( p2 > 0 ) hspctx->waitbase = p2;
            //修正
            usleep(abc_hspctx.waitcount * 1000);
            //元
            // hspctx->runmode = RUNMODE_AWAIT;
            // return RUNMODE_AWAIT;
            break;
        }
        case 0x09:  // dim
        case 0x0a:  // sdim
        case 0x0d:  // dimtype
        {
            hspvar_proc_t *proc;
            value_t *pval;
            int fl;
            pval = [self code_getpval];
            fl = TYPE_INUM;
            if (cmd == 0x0d) {
                fl = [self code_geti];
                proc = HspVarCoreGetProc(fl);
                if (proc->flag == 0) {
                    @throw [self make_nsexception:HSPERR_ILLEGAL_FUNCTION];
                }
            }
            int p1 = [self code_getdi:0];
            int p2 = [self code_getdi:0];
            int p3 = [self code_getdi:0];
            int p4 = [self code_getdi:0];
            if (cmd == 0x0a) {
                int p5 = [self code_getdi:0];
                hspvar_core_dim_flex(pval, TYPE_STRING, p1, p2, p3, p4, p5);
                // HspVarCoreAllocBlock( pval, HspVarCorePtrAPTR( pval, 0 ), p1 );
                break;
            }
            hspvar_core_dim(pval, fl, p1, p2, p3, p4);
            break;
        }
        case 0x0b:  // foreach
        {
            LOOPDAT *lop;
            unsigned short *label;
            if (abc_hspctx.looplev >= (HSP3_REPEAT_MAX - 1)) {
                @throw [self make_nsexception:HSPERR_TOO_MANY_NEST];
            }
            label = [self code_getlb];
            [self code_next];
            abc_hspctx.looplev++;
            lop = (&(abc_hspctx
                    .mem_loop[abc_hspctx.looplev]));  // GETLOP(hspctx->looplev);
            lop->cnt = 0;
            lop->time = ETRLOOP;
            lop->pt = hsp_mcsbak;
            break;
        }
        case 0x0c:  // (hidden)foreach check
        {
            int i;
            value_t *pval;
            LOOPDAT *lop;
            unsigned short *label;
            if (abc_hspctx.looplev == 0) {
                @throw [self make_nsexception:HSPERR_LOOP_WITHOUT_REPEAT];
            }
            label = [self code_getlb];
            [self code_next];
            lop = (&(abc_hspctx
                    .mem_loop[abc_hspctx.looplev]));  // GETLOP(hspctx->looplev);

            pval = [self code_getpval];
            if (lop->cnt >= pval->len[1]) {  // ループ終了
                abc_hspctx.looplev--;
                hsp_mcs = label;
                [self code_next];
                break;
            }
            if (pval->support & HSPVAR_SUPPORT_VARUSE) {
                // i = HspVarCoreGetUsing( pval, HspVarCorePtrAPTR( pval, lop->cnt ) );

                if (strcmp(hspvar_proc[(pval)->flag].vartype_name, "label") == 0) {  //ラベルのAllocBlock
                    i = hspvar_label_get_using(hspvar_core_ptr_offset(pval, lop->cnt));
                } else if (strcmp(hspvar_proc[(pval)->flag].vartype_name, "struct") == 0) {  // structのAllocBlock
                    i = hspvar_label_get_using(hspvar_core_ptr_offset(pval, lop->cnt));
                } else {
                    @throw [self make_nsexception:HSPERR_SYNTAX];
                }

                if (i == 0) {  // スキップ
                    hsp_mcs = label;
                    hsp_val_tmp = 0x05;
                    hsp_type_tmp = TYPE_PROGCMD;
                    hsp_exflg = 0;  // set 'loop' code
                }
            }
            break;
        }
        case 0x0e:  // dup
        {
            value_t *pval_m;
            value_t *pval;
            int aptr;
            pval_m = [self code_getpval];
            aptr = [self code_getva:&pval];
            hspvar_core_dup(pval_m, pval, aptr);
            break;
        }
        case 0x0f:  // dupptr
        {
            value_t *pval_m;
            pval_m = [self code_getpval];
            int p1 = [self code_geti];
            int p2 = [self code_geti];
            int p3 = [self code_getdi:HSPVAR_FLAG_INT];
            if (p2 <= 0) {
                @throw [self make_nsexception:HSPERR_ILLEGAL_FUNCTION];
            }
            if (HspVarCoreGetProc(p3)->flag == 0) {
                @throw [self make_nsexception:HSPERR_ILLEGAL_FUNCTION];
            }
            hspvar_core_dup_ptr(pval_m, p3, &p1, p2);
            break;
        }
        case 0x10:  // end
            [NSApp terminate:self];
            // printf("end");
            // hspctx.endcode = [self code_getdi:0];
            // hspctx.runmode = RUNMODE_END;
            return RUNMODE_END;
        case 0x1b:  // assert
        {
            int p1 = [self code_getdi:0];
            if (p1) break;
            abc_hspctx.runmode = RUNMODE_ASSERT;
            return RUNMODE_ASSERT;
        }
        case 0x11:  // stop
            abc_hspctx.runmode = RUNMODE_STOP;
            return RUNMODE_STOP;
        case 0x12:  // newmod
        case 0x13:  // setmod
        {
            char *p;
            value_t *pval;
            int aptr;
            flex_value_t *fv;
            struct_data_t *st;
            struct_param_t *prm;
            if (cmd == 0x12) {
                pval = [self code_getpval];
                aptr = code_newstruct(pval);
            } else {
                aptr = [self code_getva:&pval];
            }
            st = [self code_getstruct];
            //-(flex_value_t *)code_setvs:(PVal *)pval aptr:(int)aptr ptr:(void *)ptr
            //size:(int)size subid:(int)subid
            fv = [self code_setvs:pval
                             aptr:aptr
                              ptr:NULL
                             size:st->size
                            subid:st->prmindex];
            fv->type = FLEXVAL_TYPE_ALLOC;
            p = strbuf_alloc(fv->size);
            fv->ptr = (void *) p;
            prm = &abc_hspctx.mem_minfo[st->prmindex];
            if (prm->mptype != MPTYPE_STRUCTTAG) {
                @throw [self make_nsexception:HSPERR_STRUCT_REQUIRED];
            }
            [self code_expandstruct:p st:st option:CODE_EXPANDSTRUCT_OPT_NONE];
            if (prm->offset != -1) {
                hsp_modvar_init.magic = MODVAR_MAGICCODE;
                hsp_modvar_init.subid = prm->subid;
                hsp_modvar_init.pval = pval;
                hsp_modvar_init.aptr = aptr;
                return [self code_callfunc:prm->offset];
            }
            break;
        }
        case 0x14:  // delmod
        {
            value_t *pval;
            int aptr;
            aptr = [self code_getva:&pval];
            if (pval->flag != TYPE_STRUCT) {
                @throw [self make_nsexception:HSPERR_TYPE_MISMATCH];
            }
            [self code_delstruct:pval in_aptr:aptr];
            break;
        }
            /*
             case 0x15:								// alloc
             {
             PVal *pval;
             pval = code_getpval();
             p1 = code_getdi( 0 );
             if ( p1 <= 64 ) p1 = 64;
             hspvar_core_dim( pval, TYPE_STRING, 1, 0, 0, 0 );
             HspVarCoreAllocBlock( pval, HspVarCorePtrAPTR( pval, 0 ), p1 );
             break;
             }
             */
        case 0x16:  // mref
        {
            value_t *pval_m;
            pval_m = [self code_getpval];
            int p1 = [self code_geti];
            [self cmdfunc_mref:pval_m prm:p1];
            break;
        }
        case 0x17:  // run
        {
            strbuf_copy_str(&abc_hspctx.refstr, [self code_gets]);
            [self code_stmpstr:[self code_getds:""]];
            @throw [self make_nsexception:HSPERR_EXITRUN];
        }
        case 0x18:  // exgoto
        {
            value_t *pval;
            int aptr;
            int *ival;
            int i;
            unsigned short *label;
            aptr = [self code_getva:&pval];
            if (pval->flag != HSPVAR_FLAG_INT) {
                @throw [self make_nsexception:HSPERR_TYPE_MISMATCH];
            }
            ival = (int *) hspvar_core_ptr_offset(pval, aptr);
            int p1 = [self code_getdi:0];
            int p2 = [self code_getdi:0];
            label = [self code_getlb2];
            i = 0;
            if (p1 >= 0) {
                if ((*ival) >= p2) i++;
            } else {
                if ((*ival) <= p2) i++;
            }
            if (i) [self code_setpc:label];
            break;
        }
        case 0x19:  // on
        {
            unsigned short *label;
            unsigned short *otbak;
            int p1 = [self code_getdi:0];
            if (hsp_type_tmp != TYPE_PROGCMD) {
                @throw [self make_nsexception:HSPERR_SYNTAX];
            }
            if (hsp_val_tmp >= 0x02) {
                @throw [self make_nsexception:HSPERR_SYNTAX];  // goto/gosub以外はエラー
            }
            int p2 = 0;
            int p3 = hsp_val_tmp;
            otbak = NULL;
            [self code_next];
            while ((hsp_exflg & EXFLG_1) == 0) {
                label = [self code_getlb2];
                if (p1 == p2) {
                    if (p3) {
                        otbak = label;  // on〜gosub
                    } else {
                        [self code_setpc:label];  // on〜goto
                        break;
                    }
                }
                p2++;
            }
            if (otbak != NULL) {
                [self code_call:otbak];

                return abc_hspctx.runmode;
            }
            break;
        }
        case 0x1a:  // mcall
        {
            value_t *pval;
            hspvar_proc_t *varproc;
            pval = [self code_getpval];
            varproc = HspVarCoreGetProc(pval->flag);
            //$使用できるObjectMethod関数は存在しない
            // varproc->ObjectMethod( pval );
            break;
        }
        case 0x1c:  // logmes
            [self code_stmpstr:[self code_gets]];
            abc_hspctx.runmode = RUNMODE_LOGMES;
            return RUNMODE_LOGMES;
        case 0x1d:  // newlab
        {
            value_t *pval;
            int aptr;
            unsigned short *label;
            int i;
            aptr = [self code_getva:&pval];
            label = NULL;
            switch (hsp_type_tmp) {
                case TYPE_INUM:
                    i = [self code_geti];
                    if (i == 0) label = hsp_mcsbak;
                    if (i == 1) label = hsp_mcs;
                    break;
                case TYPE_LABEL:
                    label = [self code_getlb2];
                    break;
                default:
                    @throw [self make_nsexception:HSPERR_TYPE_MISMATCH];
            }
            [self code_setva:pval aptr:aptr type:HSPVAR_FLAG_LABEL ptr:&label];
            break;
        }
        case 0x1e:  // resume
            break;
        case 0x1f:  // yield
            break;
        default: {
            @throw [self make_nsexception:HSPERR_UNSUPPORTED_FUNCTION];
        }
    }
    return RUNMODE_RUN;
}

/// reffunc : TYPE_SYSVAR
///
/// (内蔵システム変数)
///
- (void *)reffunc_sysvar:(int *)type_res arg:(int)arg {
    void *ptr;

    //		返値のタイプを設定する
    //
    *type_res = HSPVAR_FLAG_INT;        // 返値のタイプを指定する
    ptr = &hsp_reffunc_intfunc_ivalue;  // 返値のポインタ

    switch (arg) {
        //	int function
        case 0x000:  // system
            hsp_reffunc_intfunc_ivalue = 0;
            break;
        case 0x001:  // hspstat
            hsp_reffunc_intfunc_ivalue = hsp_hspctx->hspstat;
            break;
        case 0x002:  // hspver
            hsp_reffunc_intfunc_ivalue = VERSION_CODE | MINOR_VERSION_CODE;
            break;
        case 0x003:  // stat
            hsp_reffunc_intfunc_ivalue = hsp_hspctx->stat;
            break;
        case 0x004:  // cnt
            hsp_reffunc_intfunc_ivalue =
                    hsp_hspctx->mem_loop[hsp_hspctx->looplev].cnt;
            break;
        case 0x005:  // err
            hsp_reffunc_intfunc_ivalue = hsp_hspctx->err;
            break;
        case 0x006:  // strsize
            hsp_reffunc_intfunc_ivalue = hsp_hspctx->strsize;
            break;
        case 0x007:  // looplev
            hsp_reffunc_intfunc_ivalue = hsp_hspctx->looplev;
            break;
        case 0x008:  // sublev
            hsp_reffunc_intfunc_ivalue = hsp_hspctx->sublev;
            break;
        case 0x009:  // iparam
            hsp_reffunc_intfunc_ivalue = hsp_hspctx->iparam;
            break;
        case 0x00a:  // wparam
            hsp_reffunc_intfunc_ivalue = hsp_hspctx->wparam;
            break;
        case 0x00b:  // lparam
            hsp_reffunc_intfunc_ivalue = hsp_hspctx->lparam;
            break;
        case 0x00c:  // refstr
            *type_res = HSPVAR_FLAG_STR;
            ptr = (void *) hsp_hspctx->refstr;
            break;
        case 0x00d:  // refdval
            *type_res = HSPVAR_FLAG_DOUBLE;
            ptr = (void *) &hsp_hspctx->refdval;
            break;
            //>>>MacOSX
        case 0x020:  // dcnt
            *type_res = HSPVAR_FLAG_DOUBLE;
            // double hsp_reffunc_intfunc_value;
            hsp_reffunc_intfunc_value = (double) (hsp_hspctx->mem_loop[hsp_hspctx->looplev].cnt);
            ptr = &hsp_reffunc_intfunc_value;  // 返値のポインタ
            break;
            //<<<MacOSX

        default: {
            @throw [self make_nsexception:HSPERR_UNSUPPORTED_FUNCTION];
        }
    }
    return ptr;
}

//------------------------------------------------------------
// controller
//------------------------------------------------------------

- (void)hsp3typeinit_var:(hsp_type_info_t *)info {
    // info->cmdfunc = cmdfunc_var;
    info->cmdfuncNumber = 0;  //変数代入 memo.md
}

- (void)hsp3typeinit_prog:(hsp_type_info_t *)info {
    // info->cmdfunc = cmdfunc_prog;
    info->cmdfuncNumber = 1;  //プログラム制御 memo.md
}

- (void)hsp3typeinit_ifcmd:(hsp_type_info_t *)info {
    // info->cmdfunc = cmdfunc_ifcmd;
    info->cmdfuncNumber = 2;  // if文 memo.md
}

- (void)hsp3typeinit_sysvar:(hsp_type_info_t *)info {
    info->reffuncNumber = 0;
}

- (void)hsp3typeinit_custom:(hsp_type_info_t *)info {
    // info->cmdfunc = cmdfunc_custom;
    info->cmdfuncNumber = 3;  //カスタム memo.md
    info->reffuncNumber = 1;  // reffunc_custom;
}

- (void)hsp3typeinit_default:(int)type {
    //		typeinfoの初期化
    hsp_type_info_t *info;
    info = GetTypeInfoPtr(type);
    info->type = type;
    info->option = 0;
    info->hspctx = hsp_hspctx;
    info->hspexinfo = hsp_hspctx->exinfo2;
    // info->cmdfunc = cmdfunc_default;
    info->cmdfuncNumber = 4;  //デフォルト memo.md
    info->reffuncNumber = -1;
    info->termfunc = NULL;
    info->eventfunc = NULL;
}

/// 指定されたタイプのHSP3TYPEINFO構造体を取得します。
///
/// ( typeがマイナスの場合は、新規typeIDを発行 )
///
- (hsp_type_info_t *)code_gettypeinfo:(int)type {
    int id;
    hsp_type_info_t *info;
    id = type;
    if (id < 0) {
        id = hsp_current_type_info_id++;
        hsp_hsp3tinfo = (hsp_type_info_t *) strbuf_expand(
                (char *) hsp_hsp3tinfo, sizeof(hsp_type_info_t) * hsp_current_type_info_id);
        [self hsp3typeinit_default:id];
    }
    info = GetTypeInfoPtr(id);
    return info;
}

/// HSPコンテキストを設定
///
- (void)code_setctx:(HSPContext *)_ctx {
    hsp_hspctx = _ctx;
}

/// デフォルトのHSPメッセージコールバック
///
- (void)code_def_msgfunc:(HSPContext *)ctx {
    ctx->runmode = RUNMODE_END;
}

/// コンテキストのリセット(オブジェクトロード後の初期化)
///
- (void)code_resetctx:(HSPContext *)_ctx {
    hsp_mpval_int = HspVarCoreGetPVal(HSPVAR_FLAG_INT);
    hspvar_core_clear_tmp(hsp_mpval_int, HSPVAR_FLAG_INT);  // int型のテンポラリを初期化

    _ctx->err = HSPERR_NONE;
#ifdef FLAG_HSPDEBUG
    _ctx->hspstat = HSPSTAT_DEBUG;
#else
    _ctx->hspstat = 0;
#endif
    _ctx->waitbase = 5;
    _ctx->lasttick = 0;
    _ctx->looplev = 0;
    _ctx->sublev = 0;
    _ctx->stat = 0;
    _ctx->strsize = 0;
    _ctx->runmode = RUNMODE_RUN;
    _ctx->prmstack = NULL;
    _ctx->note_pval = NULL;
    _ctx->notep_pval = NULL;
    //_ctx->msgfunc = code_def_msgfunc;
}

/// typeinfoを有効にする(オプションチェック)
///
- (void)code_enable_typeinfo:(hsp_type_info_t *)info {
    hsp_hspevent_opt |= info->option;
}

- (hspvar_proc_t *)HspFunc_getproc:(int)id {
    return (&hspvar_proc[id]);
}

- (HSPERROR)code_geterror {
    return hsp_hspctx->err;
}

/// プログラムカウンタを設定
///
- (void)code_setpc:(const unsigned short *)pc {
    if (hsp_hspctx->runmode == RUNMODE_END) return;
    hsp_mcs = (unsigned short *) pc;
    [self code_next];
    hsp_hspctx->runmode = RUNMODE_RUN;
}

/// プログラムカウンタを設定(interrput)
///
- (void)code_setpci:(const unsigned short *)pc {
    [self code_setpc:pc];
    hsp_hspctx->runmode = RUNMODE_INTJUMP;
}

/// サブルーチンジャンプを行なう
///
- (void)code_call:(const unsigned short *)pc {
    hsp_mcs = hsp_mcsbak;
    [self cmdfunc_gosub:(unsigned short *) pc];
    if (abc_hspctx.runmode == RUNMODE_END) {
        return;
    }
    abc_hspctx.runmode = RUNMODE_RUN;
}

///	Error report routines
///
- (int)code_getdebug_line {
    return 0;  // code_getdebug_line( hsp_mcsbak );
}

/// Get current debug line info
///
/// (最後に実行した場所を示す)
/// result :  0=none  others=line#
///
- (int)code_getdebug_line:(unsigned short *)pt {
#ifdef FLAG_HSPDEBUG
    unsigned char *mem_di;
    unsigned char ofs;
    int cl, a, tmp, curpt, debpt;

    mem_di = hsp_hspctx->mem_di;
    debpt = 0;
    curpt = (int) (pt - hsp_hspctx->mem_mcs);
    if (mem_di[0] == 255) {
        return -1;
    }

    cl = 0;
    a = 0;
    while (1) {
        ofs = mem_di[a++];
        switch (ofs) {
            case 252:
                debpt += (mem_di[a + 1] << 8) + mem_di[a];
                if (curpt <= debpt) {

                    return cl;
                }
                cl++;
                a += 2;
                break;
            case 253:
                a += 5;
                break;
            case 254:
                tmp = (mem_di[a + 2] << 16) + (mem_di[a + 1] << 8) + mem_di[a];
                if (tmp) hsp_srcname = tmp;
                cl = (mem_di[a + 4] << 8) + mem_di[a + 3];
                a += 5;
                break;
            case 255:

                return -1;
            default:
                debpt += ofs;
                if (curpt <= debpt) return cl;
                cl++;
                break;
        }
    }
    return cl;
#else
    return -1;
#endif
}

/// hsp_mem_di_valを更新
///
- (int)code_debug_init {
    unsigned char ofs;
    unsigned char *mem_di;
    int cl, a;
    cl = 0;
    a = 0;
    hsp_mem_di_val = NULL;
    mem_di = hsp_hspctx->mem_di;
    if (mem_di[0] == 255) {
        return -1;
    }
    while (1) {
        ofs = mem_di[a++];
        switch (ofs) {
            case 252:
                a += 2;
                break;
            case 253:
                hsp_mem_di_val = &mem_di[a - 1];
                return 0;
            case 254:
                cl = (mem_di[a + 4] << 8) + mem_di[a + 3];
                a += 5;
                break;
            case 255:
                return -1;
            default:
                cl++;
                break;
        }
    }
    return cl;
}

- (char *)code_getdebug_varname:(int)val_id {
    unsigned char *mm;
    int i;
    if (hsp_mem_di_val == NULL)
        return (char *) "";
    mm = hsp_mem_di_val + (val_id * 6);
    i = (mm[3] << 16) + (mm[2] << 8) + mm[1];
    return strp(i);
}

- (int)code_getdebug_seekvar:(const char *)name {
    unsigned char *mm;
    int i, ofs;
    if (hsp_mem_di_val != NULL) {
        mm = hsp_mem_di_val;
        for (i = 0; i < hsp_hspctx->hsphed->max_val; i++) {
            ofs = (mm[3] << 16) + (mm[2] << 8) + mm[1];
            if (strcmp(strp(ofs), name) == 0) return i;
            mm += 6;
        }
    }
    return -1;
}

- (char *)code_getdebug_name {
    return strp(hsp_srcname);
}

/// 時間待ち(wait)
///
/// (awaitに変換します)
///
- (int)code_exec_wait:(int)tick {
    if (hsp_hspctx->waitcount <= 0) {
        hsp_hspctx->runmode = RUNMODE_RUN;
        return RUNMODE_RUN;
    }
    hsp_hspctx->waittick = tick + (hsp_hspctx->waitcount * 10);
    return RUNMODE_AWAIT;
}

/// 時間待ち(await)
///
- (int)code_exec_await:(int)tick {
    if (hsp_hspctx->waittick < 0) {
        if (hsp_hspctx->lasttick == 0) hsp_hspctx->lasttick = tick;
        hsp_hspctx->waittick = hsp_hspctx->lasttick + hsp_hspctx->waitcount;
    }
    if (tick >= hsp_hspctx->waittick) {
        hsp_hspctx->lasttick = tick;
        hsp_hspctx->runmode = RUNMODE_RUN;
        return RUNMODE_RUN;
    }
    return RUNMODE_AWAIT;
}

//------------------------------------------------------------
// code main interface
//------------------------------------------------------------

/// データを取得(プラグイン交換用)
///
- (int)code_cnv_get {
    abc_hspctx.exinfo.mpval = &mpval;
    return [self code_get];
}

/// 変数データアドレスを取得(2.61互換用)
///
- (void *)code_cnv_getv {
    char *ptr;
    int size;
    ptr = [self code_getvptr:&hsp_plugin_pval size:&size];
    abc_hspctx.exinfo.mpval = &hsp_plugin_pval;
    return (void *) ptr;
}

/// 変数データバッファを拡張(2.61互換用)
///
- (int)code_cnv_realloc:(value_t *)pv size:(int)size mode:(int)mode {
    void *ptr = hspvar_core_ptr_offset(pv, 0);

    // HspVarCoreAllocBlock( pv, ptr, size );
    if (strcmp(hspvar_proc[(pv)->flag].vartype_name, "int") == 0) {  //整数のAllocBlock
        hspvar_int_alloc_block(pv, ptr, size);
    } else if (strcmp(hspvar_proc[(pv)->flag].vartype_name, "double") == 0) {  //実数のAllocBlock
        hspvar_double_alloc_block(pv, ptr, size);
    } else if (strcmp(hspvar_proc[(pv)->flag].vartype_name, "str") == 0) {  //文字列のAllocBlock
        hspvar_str_alloc_block(pv, ptr, size);
    } else if (strcmp(hspvar_proc[(pv)->flag].vartype_name, "label") == 0) {  //ラベルのAllocBlock
        hspvar_label_alloc_block(pv, ptr, size);
    } else if (strcmp(hspvar_proc[(pv)->flag].vartype_name, "struct") == 0) {  // structのAllocBlock
        hspvar_label_alloc_block(pv, ptr, size);
    } else {
        @throw [self make_nsexception:HSPERR_SYNTAX];
    }
    return 0;
}

- (void)code_init {
    int i;
    hsp_extra_info_t *exinfo;

    strbuf_init();  // 可変メモリバッファ初期化
    stack_init();
    hspvar_core_init();  // ストレージコア初期化
    mpval = HspVarCoreGetPVal(0);
    hsp_hspevent_opt = 0;  // イベントオプションを初期化

    //		exinfoの初期化
    //
    exinfo = &hsp_mem_exinfo;

    //		2.61互換フィールド
    exinfo->ver = VERSION_CODE;
    exinfo->min = MINOR_VERSION_CODE;
    exinfo->er = &hsp_error_dummy;
    exinfo->pstr = hsp_hspctx->stmp;
    exinfo->stmp = hsp_hspctx->refstr;
    exinfo->strsize = &hsp_hspctx->strsize;
    exinfo->refstr = hsp_hspctx->refstr;
    // exinfo->HspFunc_prm_getv = code_cnv_getv;
    // exinfo->HspFunc_val_realloc = code_cnv_realloc;
    // exinfo->HspFunc_fread = dpm_read;
    // exinfo->HspFunc_fsize = dpm_exist;

    //		共用フィールド
    exinfo->nptype = &hsp_type_tmp;
    exinfo->npval = &hsp_val_tmp;
    exinfo->mpval = &mpval;

    // exinfo->HspFunc_prm_geti = code_geti;
    // exinfo->HspFunc_prm_getdi = code_getdi;
    // exinfo->HspFunc_prm_gets = code_gets;
    // exinfo->HspFunc_prm_getds = code_getds;
    // exinfo->HspFunc_getbmscr = NULL;
    // exinfo->HspFunc_addobj = NULL;
    // exinfo->HspFunc_setobj = NULL;
    // exinfo->HspFunc_setobj = NULL;

    //		3.0拡張フィールド
    exinfo->hspctx = hsp_hspctx;
    exinfo->npexflg = &hsp_exflg;
    // exinfo->HspFunc_setobj = NULL;
    // exinfo->HspFunc_puterror = code_puterror;
    // exinfo->HspFunc_getproc = HspFunc_getproc;
    // exinfo->HspFunc_seekproc = hspvar_core_seek_proc;
    // exinfo->HspFunc_prm_next = code_next;
    // exinfo->HspFunc_prm_get = code_cnv_get;
    // exinfo->HspFunc_prm_getlb = code_getlb2;
    // exinfo->HspFunc_prm_getpval = code_getpval;
    // exinfo->HspFunc_prm_getva = code_getva;
    // exinfo->HspFunc_prm_setva = code_setva;
    // exinfo->HspFunc_prm_getd = code_getd;
    // exinfo->HspFunc_prm_getdd = code_getdd;
    // exinfo->HspFunc_malloc = sbAlloc;
    // exinfo->HspFunc_free = sbFree;
    // exinfo->HspFunc_expand = sbExpand;
    // exinfo->HspFunc_addirq = code_addirq;
    // exinfo->HspFunc_hspevent = code_event;
    // exinfo->HspFunc_registvar = hspvar_core_register_type;
    // exinfo->HspFunc_setpc = code_setpc;
    // exinfo->HspFunc_call = code_call;
    // exinfo->HspFunc_dim = hspvar_core_dim_flex;
    // exinfo->HspFunc_redim = HspVarCoreReDim;
    // exinfo->HspFunc_array = HspVarCoreArray;

    //		3.1拡張フィールド
    // exinfo->HspFunc_varname = code_getdebug_varname;
    // exinfo->HspFunc_seekvar = code_getdebug_seekvar;

    //		HSPContextにコピーする
    //
    memcpy(&hsp_hspctx->exinfo, exinfo, sizeof(hsp_extra_info_30_t));
    hsp_hspctx->exinfo2 = exinfo;

    //		標準typefunc登録
    //
    hsp_hsp3tinfo = (hsp_type_info_t *) strbuf_alloc(sizeof(hsp_type_info_t) * HSP3_FUNC_MAX);
    hsp_current_type_info_id = HSP3_FUNC_MAX;
    for (i = 0; i < hsp_current_type_info_id; i++) {
        [self hsp3typeinit_default:i];
    }

    //		内蔵タイプの登録
    //
    [self hsp3typeinit_var:GetTypeInfoPtr(TYPE_VAR)];
    [self hsp3typeinit_var:GetTypeInfoPtr(TYPE_STRUCT)];
    [self hsp3typeinit_prog:GetTypeInfoPtr(TYPE_PROGCMD)];
    [self hsp3typeinit_ifcmd:GetTypeInfoPtr(TYPE_CMPCMD)];
    [self hsp3typeinit_sysvar:GetTypeInfoPtr(TYPE_SYSVAR)];
    [self hsp3typeinit_intcmd:GetTypeInfoPtr(TYPE_INTCMD)];
    [self hsp3typeinit_intfunc:GetTypeInfoPtr(TYPE_INTFUNC)];
    [self hsp3typeinit_intfunc:GetTypeInfoPtr(TYPE_INTFUNC)];
    [self hsp3typeinit_custom:GetTypeInfoPtr(TYPE_MODCMD)];

    //		割り込みの初期化
    //
    hsp_hspctx->mem_irq = NULL;
    hsp_hspctx->irqmax = 0;
    for (i = 0; i < HSPIRQ_MAX; i++) {
        [self code_addirq];
    }                                           // 標準割り込みを確保
    [self code_enableirq:HSPIRQ_USERDEF sw:1];  // カスタムタイプのみEnable

    //		プラグイン追加の準備
    //
    hsp_current_type_info_id = HSP3_TYPE_USER;

    //		文字列バッファの初期化
    //
    hsp_hspctx->refstr = strbuf_alloc(HSPCTX_REFSTR_MAX);
    hsp_hspctx->fnbuffer = strbuf_alloc(HSP_MAX_PATH);
    hsp_hspctx->stmp = strbuf_alloc(HSPCTX_REFSTR_MAX);
    hsp_hspctx->cmdline = strbuf_alloc(HSPCTX_CMDLINE_MAX);

#ifdef FLAG_HSPDEBUG
    //		デバッグ情報の初期化
    //
    hsp_mem_di_val = NULL;
    hsp_dbgmode = HSPDEBUG_NONE;
    hsp_dbginfo.hspctx = hsp_hspctx;
    hsp_dbginfo.line = 0;
    hsp_dbginfo.fname = NULL;
    // hsp_dbginfo.get_value = code_dbgvalue;
    // hsp_dbginfo.get_varinf = code_dbgvarinf;
    // hsp_dbginfo.dbg_close = code_dbgclose;
    // hsp_dbginfo.dbg_curinf = code_dbgcurinf;
    // hsp_dbginfo.dbg_set = [self code_dbgset];
    // hsp_dbginfo.dbg_callstack = code_dbgcallstack;
#endif

}

//        コードの終了処理
//
- (void)code_termfunc {

    // NSLog(@"code_termfunc");
    int i;
    int prmmax;
    struct_data_t *st;
    hsp_type_info_t *info;
    value_t *pval;

    //		モジュール変数デストラクタ呼び出し
    //
    //#ifdef FLAG_HSP_ERROR_HANDLE
    @try {
        //#endif
        //エラー回避
        prmmax = abc_hspctx.hsphed->max_val;
        pval = abc_hspctx.mem_var;
        for (i = 0; i < prmmax; i++) {
            if (pval->flag == HSPVAR_FLAG_STRUCT) [self code_delstruct_all:pval];
            pval++;
        }
        //#ifdef FLAG_HSP_ERROR_HANDLE
    } @catch (NSException *exception) {
        //@throw exception;
        // catch( ... ) {
    }
        //#endif

        //		クリーンアップモジュールの呼び出し
        //
#ifdef FLAG_HSP_ERROR_HANDLE
    @try {
#endif
        //エラー回避
        prmmax = abc_hspctx.hsphed->max_finfo / sizeof(struct_data_t);
        i = prmmax;
        while (1) {
            i--;
            if (i < 0) break;
            st = &abc_hspctx.mem_finfo[i];
            if ((st->index == STRUCTDAT_INDEX_FUNC) &&
                    (st->funcflag & STRUCTDAT_FUNCFLAG_CLEANUP)) {
                [self code_callfunc:i];
            }
        }
#ifdef FLAG_HSP_ERROR_HANDLE
    } @catch (NSException *exception) {
        //@throw exception;
    }
#endif

    //		タイプの終了関数をすべて呼び出す
    //
    for (i = hsp_current_type_info_id - 1; i >= 0; i--) {
        info = GetTypeInfoPtr(i);
        //$現状termfuncは使用できない
        // if ( info->termfunc != NULL )
        //    info->termfunc( 0 );
    }


}

//        コード実行を終了
//
- (void)code_bye {
    hspvar_core_bye();
    //		コード用のメモリを解放する
    //
    if (hsp_hspctx->mem_irq != NULL)
        strbuf_free(hsp_hspctx->mem_irq);
    strbuf_free(hsp_hspctx->cmdline);
    strbuf_free(hsp_hspctx->stmp);
    strbuf_free(hsp_hspctx->fnbuffer);
    strbuf_free(hsp_hspctx->refstr);
    strbuf_free(hsp_hsp3tinfo);
    stack_free();
    strbuf_bye();
}

//        命令実行メイン
//
- (int)code_execcmd {
    int i;
    abc_hspctx.endcode = 0;

    rerun:
    abc_hspctx.looplev = 0;
    abc_hspctx.sublev = 0;
    stack_reset();

#ifdef FLAG_HSP_ERROR_HANDLE
    @try {
        // NSString *error_str = [NSString stringWithFormat:@"%d",
        // HSPERR_INVALID_ARRAY];
        //@throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
#endif
        while (1) {
            // alert_format( "#%d,%d line%d",hsp_type_tmp,val,code_getdebug_line() );
            // alert_format( "#%d,%d",hsp_type_tmp,val );
            // printf( "#%d,%d  line%d¥n",hsp_type_tmp,val,code_getdebug_line() );
            // stack->Reset();
            // stack->StoreLevel();
            // stack->ResumeLevel();

#ifdef FLAG_HSPDEBUG
            if (hsp_dbgmode) [self code_dbgtrace];  // トレースモード時の処理
#endif

            //                int ret = 0;
            //                if (hsp_type_tmp==15) {
            //
            //                }
            // NSLog(@"C:GetTypeInfoPtr( hsp_type_tmp )->cmdfunc( val )");
            int result = 0;  //結果
            // printf("%d\n",GetTypeInfoPtr( hsp_type_tmp )->cmdfuncNumber);
            switch (GetTypeInfoPtr(hsp_type_tmp)->cmdfuncNumber) {
                case 0:
                    result = [self cmdfunc_var:hsp_val_tmp];
                    break;
                case 1:
                    result = [self cmdfunc_prog:hsp_val_tmp];
                    break;
                case 2:
                    result = [self cmdfunc_ifcmd:hsp_val_tmp];
                    break;
                case 3:
                    result = [self cmdfunc_custom:hsp_val_tmp];
                    break;
                case 4:
                    result = [self cmdfunc_default:hsp_val_tmp];
                    break;
                case 5:
                    // result = cmdfunc_dllcmd(val);
                    break;
                case 6:
                    // result = cmdfunc_ctrlcmd(val);
                    break;
                case 7:
                    result = [self cmdfunc_extcmd:hsp_val_tmp];
                    break;
                case 8:
                    result = [self cmdfunc_intcmd:hsp_val_tmp];
                    break;
                default:
                    break;
            }
            if (result) {
                // if ( GetTypeInfoPtr( hsp_type_tmp )->cmdfunc( val ) ) {	//
                // タイプごとの関数振り分け
                if (abc_hspctx.runmode == RUNMODE_RETURN) {
                    [self cmdfunc_return];
                } else {
                    // hspctx->msgfunc( hspctx );
                    [self code_def_msgfunc:&(abc_hspctx)];
                }
                if (abc_hspctx.runmode == RUNMODE_END) {
                    return RUNMODE_END;
                    //					i = hspctx->runmode;
                    //					break;
                }
            }
        }
#ifdef FLAG_HSP_ERROR_HANDLE
    } @catch (NSException *error) {  // HSPエラー例外処理
        // HSPERROR code
        // NSLog(@"error:%@",error.description);
        int code = [error.description intValue];

        if (code == HSPERR_NONE) {
            i = RUNMODE_END;
        } else if (code == HSPERR_INTJUMP) {
            goto rerun;
        } else if (code == HSPERR_EXITRUN) {
            i = RUNMODE_EXITRUN;
        } else {
            i = RUNMODE_ERROR;
            abc_hspctx.err = (HSPERROR) code;
            abc_hspctx.runmode = i;
            if ([self code_isirq:HSPIRQ_ONERROR]) {
                [self code_sendirq:HSPIRQ_ONERROR iparam:0 wparam:(int) code lparam:[self code_getdebug_line]];
                if (abc_hspctx.runmode != i) goto rerun;
                return i;
            }
        }
    }
#endif
#ifdef FLAG_SYSTEM_ERROR_HANDLE
    @catch (NSException *error) {  // その他の例外発生時
        abc_hspctx.err = HSPERR_UNKNOWN_CODE;
        return RUNMODE_ERROR;
    }
#endif
    abc_hspctx.runmode = i;
    return i;
}

/// 部分的な実行を行なう(ENDSESSION用)
///
- (int)code_execcmd2 {
    while (1) {
        // NSLog(@"E:GetTypeInfoPtr( hsp_type_tmp )->cmdfunc( hsp_val_tmp )");
        int result = 0;  //結果
        switch (GetTypeInfoPtr(hsp_type_tmp)->cmdfuncNumber) {
            case 0:
                result = [self cmdfunc_var:hsp_val_tmp];
                break;
            case 1:
                result = [self cmdfunc_prog:hsp_val_tmp];
                break;
            case 2:
                result = [self cmdfunc_ifcmd:hsp_val_tmp];
                break;
            case 3:
                result = [self cmdfunc_custom:hsp_val_tmp];
                break;
            case 4:
                result = [self cmdfunc_default:hsp_val_tmp];
                break;
            case 5:
                // result = cmdfunc_dllcmd(hsp_val_tmp);
                break;
            case 6:
                // result = cmdfunc_ctrlcmd(hsp_val_tmp);
                break;
            case 7:
                result = [self cmdfunc_extcmd:hsp_val_tmp];
                break;
            case 8:
                result = [self cmdfunc_intcmd:hsp_val_tmp];
                break;
            default:
                break;
        }
        if (result) {
            // if ( GetTypeInfoPtr( hsp_type_tmp )->cmdfunc( hsp_val_tmp ) ) {
            // // タイプごとの関数振り分け
            break;
        }
    }
    return abc_hspctx.runmode;
}

//------------------------------------------------------------
// EVENT controller
//------------------------------------------------------------

/// 各タイプのイベントコールバックを呼び出す
///
- (int)call_eventfunc:(int)option event:(int)event prm1:(int)prm1 prm2:(int)prm2 prm3:(void *)prm3 {
    int i, res;
    hsp_type_info_t *info;
    for (i = HSP3_TYPE_USER; i < hsp_current_type_info_id; i++) {
        info = GetTypeInfoPtr(i);
        if (info->option & option) {
            if (info->eventfunc != NULL) {
                //$使用できるeventfunc関数は存在しない
                // res = info->eventfunc( event, prm1, prm2, prm3 );
                if (res) {
                    return res;
                }
            }
        }
    }
    return 0;
}

/// HSP内部イベント実行
///
/// (result:0=Not care/1=Done)
///
- (int)code_event:(int)event prm1:(int)prm1 prm2:(int)prm2 prm3:(void *)prm3 {
    short hsp_evcategory[] = {
            0,                        // HSPEVENT_NONE
            HSPEVENT_ENABLE_COMMAND,  // HSPEVENT_COMMAND
            HSPEVENT_ENABLE_HSPIRQ,   // HSPEVENT_HSPIRQ
            HSPEVENT_ENABLE_GETKEY,   // HSPEVENT_GETKEY
            HSPEVENT_ENABLE_GETKEY,   // HSPEVENT_STICK
            HSPEVENT_ENABLE_FILE,     // HSPEVENT_FNAME
            HSPEVENT_ENABLE_FILE,     // HSPEVENT_FREAD
            HSPEVENT_ENABLE_FILE,     // HSPEVENT_FWRITE
            HSPEVENT_ENABLE_FILE,     // HSPEVENT_FEXIST
            HSPEVENT_ENABLE_FILE,     // HSPEVENT_FDELETE
            HSPEVENT_ENABLE_FILE,     // HSPEVENT_FMKDIR
            HSPEVENT_ENABLE_FILE,     // HSPEVENT_FCHDIR
            HSPEVENT_ENABLE_FILE,     // HSPEVENT_FCOPY
            HSPEVENT_ENABLE_FILE,     // HSPEVENT_FDIRLIST1
            HSPEVENT_ENABLE_FILE,     // HSPEVENT_FDIRLIST2
            HSPEVENT_ENABLE_PICLOAD,  // HSPEVENT_GETPICSIZE
            HSPEVENT_ENABLE_PICLOAD,  // HSPEVENT_PICLOAD
    };
    int res = [self call_eventfunc:hsp_evcategory[event] event:event prm1:prm1 prm2:prm2 prm3:prm3];
    if (res) return res;

    switch (event) {
        case HSPEVENT_COMMAND:
            // All commands (hsp_type_tmp,val,n/a)
            break;
        case HSPEVENT_HSPIRQ:
            // HSP Interrupt (IRQid,iparam,param_ptr)
            [self code_execirq:(IRQDAT *) prm3 wparam:prm1 lparam:prm2];
            break;
        case HSPEVENT_GETKEY:
            // Key input (IDcode,option,resval ptr)
        case HSPEVENT_STICK:
            // Stick input (IDcode,option,resval ptr)
            break;
        case HSPEVENT_FNAME:
            // set FNAME (n/a,n/a,nameptr)
            strncpy(abc_hspctx.fnbuffer, (char *) prm3, HSP_MAX_PATH - 1);
            break;
        case HSPEVENT_FREAD:
            // fread (fseek,size,loadptr)
            res = dpm_read(abc_hspctx.fnbuffer, prm3, prm2, prm1);
            if (res < 0) {
                @throw [self make_nsexception:HSPERR_FILE_IO];
            }
            abc_hspctx.strsize = res;
            break;
        case HSPEVENT_FWRITE:
            // fwrite (fseek,size,saveptr)
            res = mem_save(abc_hspctx.fnbuffer, prm3, prm2, prm1);
            if (res < 0) {
                @throw [self make_nsexception:HSPERR_FILE_IO];
            }
            abc_hspctx.strsize = res;
            break;
        case HSPEVENT_FEXIST:
            // exist (n/a,n/a,n/a)
            abc_hspctx.strsize = dpm_exist(abc_hspctx.fnbuffer);
            break;
        case HSPEVENT_FDELETE:
            // delete (n/a,n/a,n/a)
            if (delete_file(abc_hspctx.fnbuffer) == 0) {
                @throw [self make_nsexception:HSPERR_FILE_IO];
            }
            break;
        case HSPEVENT_FMKDIR:
            // mkdir (n/a,n/a,n/a)
            if (make_dir(abc_hspctx.fnbuffer)) {
                @throw [self make_nsexception:HSPERR_FILE_IO];
            }
            break;
        case HSPEVENT_FCHDIR:
            // chdir (n/a,n/a,n/a)
            if (change_dir(abc_hspctx.fnbuffer)) {
                @throw [self make_nsexception:HSPERR_FILE_IO];
            }
            break;
        case HSPEVENT_FCOPY:
            // bcopy (n/a,n/a,dst filename)
            if (dpm_filecopy(abc_hspctx.fnbuffer, (char *)prm3)) {
                @throw [self make_nsexception:HSPERR_FILE_IO];
            }
            break;
        case HSPEVENT_FDIRLIST1:
            // dirlist1 (opt,n/a,result ptr**)
        {
            char **p;
            hsp_dirlist_target = strbuf_alloc(0x1000);
            abc_hspctx.stat =
                    dirlist(abc_hspctx.fnbuffer, &hsp_dirlist_target, prm1);
            p = (char **) prm3;
            *p = hsp_dirlist_target;
            break;
        }
        case HSPEVENT_FDIRLIST2:
            // dirlist2 (n/a,n/a,n/a)
            strbuf_free(hsp_dirlist_target);
            break;
        case HSPEVENT_GETPICSIZE:
            // getpicsize (n/a,n/a,resval ptr)
            break;
        case HSPEVENT_PICLOAD:
            // picload (n/a,n/a,HDC)
            break;
    }
    return 0;
}

- (void)code_bload:(char *)fname ofs:(int)ofs size:(int)size ptr:(void *)ptr {
    [self code_event:HSPEVENT_FNAME prm1:0 prm2:0 prm3:fname];
    [self code_event:HSPEVENT_FREAD prm1:ofs prm2:size prm3:ptr];
}

- (void)code_bsave:(char *)fname ofs:(int)ofs size:(int)size ptr:(void *)ptr {
    [self code_event:HSPEVENT_FNAME prm1:0 prm2:0 prm3:fname];
    [self code_event:HSPEVENT_FWRITE prm1:ofs prm2:size prm3:ptr];
}

//------------------------------------------------------------
// IRQ controller
//------------------------------------------------------------

- (IRQDAT *)code_getirq:(int)id {
    return &hsp_hspctx->mem_irq[id];
}

/// IRQの有効・無効切り替え
///
- (void)code_enableirq:(int)id sw:(int)sw {
    IRQDAT *irq = [self code_getirq:id];
    if (sw == 0) {
        irq->flag = IRQ_FLAG_DISABLE;
    } else {
        irq->flag = IRQ_FLAG_ENABLE;
    }
}

/// IRQイベントを設定する
///
- (void)code_setirq:(int)id opt:(int)opt custom:(int)custom ptr:(unsigned short *)ptr {
    IRQDAT *irq = [self code_getirq:id];
    irq->flag = IRQ_FLAG_ENABLE;
    irq->opt = opt;
    irq->ptr = ptr;
    irq->custom = custom;
}

/// 指定したIRQイベントがENABLEかを調べる
///
- (int)code_isirq:(int)id {
    if (hsp_hspctx->mem_irq[id].flag != IRQ_FLAG_ENABLE) {
        return 0;
    }
    return 1;
}

/// 指定したIRQイベントを発生
///
- (int)code_sendirq:(int)id iparam:(int)iparam wparam:(int)wparam lparam:(int)lparam {
    IRQDAT *irq = [self code_getirq:id];
    irq->iparam = iparam;
    [self code_event:HSPEVENT_HSPIRQ prm1:wparam prm2:lparam prm3:irq];
    return abc_hspctx.runmode;
}

/// カスタム指定のIRQイベントがあるかどうか調べる
///
- (int)code_isuserirq {
    if (hsp_hspctx->irqmax > HSPIRQ_USERDEF) {
        if (hsp_hspctx->mem_irq[HSPIRQ_USERDEF].flag == IRQ_FLAG_ENABLE) return 1;
    }
    return 0;
}

/// IRQイベントの戻り値を取得する
///
- (int)code_irqresult:(int *)value {
    *value = (hsp_hspctx->stat);
    return (hsp_hspctx->retval_level);
}

/// 指定したメッセージに対応するイベントを発生
///
- (int)code_checkirq:(int)id message:(int)message wparam:(int)wparam lparam:(int)lparam {
    int i, cur;
    IRQDAT *irq;
    for (i = HSPIRQ_MAX; i < abc_hspctx.irqmax; i++) {
        irq = &abc_hspctx.mem_irq[i];
        if (irq->custom == message) {
            if (irq->custom2 == id) {
                if (irq->flag == IRQ_FLAG_ENABLE) {
                    abc_hspctx.intwnd_id = id;
                    abc_hspctx.retval_level = 0;
                    cur = abc_hspctx.sublev + 1;
                    if (irq->callback != NULL) {
                        //$使用できるcallback関数は存在しない
                        // irq->callback( irq, wparam, lparam );
                    } else {
                        [self code_sendirq:i iparam:irq->custom wparam:wparam lparam:lparam];
                        if (abc_hspctx.retval_level != cur) {
                            return 0;
                        }  // returnの戻り値がなければ0を返す
                    }
                    return 1;
                }
            }
        }
    }
    return 0;
}

/// 指定したcustomを持つIRQを検索する
///
- (IRQDAT *)code_seekirq:(int)actid custom:(int)custom {
    int i;
    IRQDAT *irq;
    for (i = 0; i < hsp_hspctx->irqmax; i++) {
        irq = [self code_getirq:i];
        if (irq->flag != IRQ_FLAG_NONE) {
            if ((irq->custom == custom) && (irq->custom2 == actid)) {
                if (irq->opt != IRQ_OPT_CALLBACK) return irq;
            }
        }
    }
    return NULL;
}

/// IRQを追加する
///
- (IRQDAT *)code_addirq {
    int id;
    IRQDAT *irq;
    id = hsp_hspctx->irqmax++;
    if (hsp_hspctx->mem_irq == NULL) {
        hsp_hspctx->mem_irq = (IRQDAT *) strbuf_alloc(sizeof(IRQDAT));
    } else {
        hsp_hspctx->mem_irq = (IRQDAT *) strbuf_expand(
                (char *) hsp_hspctx->mem_irq, sizeof(IRQDAT) * (hsp_hspctx->irqmax));
    }
    irq = [self code_getirq:id];
    irq->flag = IRQ_FLAG_DISABLE;
    irq->opt = IRQ_OPT_GOTO;
    irq->custom = -1;
    irq->iparam = 0;
    irq->ptr = NULL;
    irq->callback = NULL;
    return irq;
}

/// IRQを実行する
///
- (void)code_execirq:(IRQDAT *)irq wparam:(int)wparam lparam:(int)lparam {
    abc_hspctx.iparam = irq->iparam;
    abc_hspctx.wparam = wparam;
    abc_hspctx.lparam = lparam;
    if (irq->opt == IRQ_OPT_GOTO) {
        [self code_setpci:irq->ptr];
    }
    if (irq->opt == IRQ_OPT_GOSUB) {
        hsp_mcs = hsp_mcsbak;
        [self cmdfunc_gosub:(unsigned short *) irq->ptr];
        if (abc_hspctx.runmode != RUNMODE_END) {
            abc_hspctx.runmode = RUNMODE_RUN;
        }
    }
    // alert_format("sublev%d", hspctx->sublev );
}

//------------------------------------------------------------
// Debug support
//------------------------------------------------------------

#ifdef FLAG_HSPDEBUG

- (void)code_adddbg3:(char const *)s1 sep:(char const *)sep s2:(char const *)s2 {
    char tmp[2048];
    strncpy(tmp, s1, 64);
    strncat(tmp, sep, 8);
    strncat(tmp, s2, 1973);
    strcat(tmp, "\r\n");
    strbuf_add_str(&hsp_dbgbuf, tmp);
}

- (void)code_adddbg:(char *)name str:(char *)str {
    [self code_adddbg3:name sep:"\r\n" s2:str];
}

- (void)code_adddbg2:(char *)name str:(char *)str {
    [self code_adddbg3:name sep:":" s2:str];
}

- (void)code_adddbg:(char *)name val:(double)val {
    char tmp[400];
    sprintf(tmp, "%-36.16f", val);
    [self code_adddbg:name str:tmp];
}

- (void)code_adddbg:(char *)name intval:(int)intval {
    char tmp[32];
    sprintf(tmp, "%d", intval);
    [self code_adddbg:name str:tmp];
}

- (void)code_adddbg2:(char *)name val:(int)val {
    char tmp[32];
    sprintf(tmp, "%d", val);
    [self code_adddbg2:name str:tmp];
}

- (char *)code_inidbg {
    hsp_dbgbuf = strbuf_alloc(0x4000);
    return hsp_dbgbuf;
}

- (void)code_dbg_global {
    hsp_header_t *hed = hsp_hspctx->hsphed;
    [self code_adddbg:(char *) "axサイズ" intval:hed->allsize];
    [self code_adddbg:(char *) "コードサイズ" intval:hed->max_cs];
    [self code_adddbg:(char *) "データサイズ" intval:hed->max_ds];
    [self code_adddbg:(char *) "変数予約" intval:hed->max_val];
    [self code_adddbg:(char *) "実行モード" intval:hsp_hspctx->runmode];
    [self code_adddbg:(char *) "stat" intval:hsp_hspctx->stat];
    [self code_adddbg:(char *) "cnt" intval:hsp_hspctx->mem_loop[hsp_hspctx->looplev].cnt];
    [self code_adddbg:(char *) "looplev" intval:hsp_hspctx->looplev];
    [self code_adddbg:(char *) "sublev" intval:hsp_hspctx->sublev];
    [self code_adddbg:(char *) "iparam" intval:hsp_hspctx->iparam];
    [self code_adddbg:(char *) "wparam" intval:hsp_hspctx->wparam];
    [self code_adddbg:(char *) "lparam" intval:hsp_hspctx->lparam];
    [self code_adddbg:(char *) "refstr" str:hsp_hspctx->refstr];
    [self code_adddbg:(char *) "refdval" val:hsp_hspctx->refdval];
}

/// memory Hex dump
///
- (void)code_dbgdump:(char const *)mem size:(int)size {
    int adr = 0;
    char t[512];
    char tline[1024];
    while (adr < size) {
        sprintf(tline, "%04X", adr);
        for (int i = 0; i < 8 && adr < size; ++i, ++adr) {
            sprintf(t, " %02X", (unsigned char) (mem[adr]));
            strcat(tline, t);
        }
        strcat(tline, "\r\n");
        strbuf_add_str(&hsp_dbgbuf, tline);
    }
}

/// 特殊な変数の内容を取得
///
/// (256bytes程度のバッファを確保しておいて下さい)
///
- (void)code_dbgvarinf_ext:(value_t *)pv src:(void *)src buf:(char *)buf {
    switch (pv->flag) {
        case HSPVAR_FLAG_LABEL:
            sprintf(buf, "LABEL $%08x", *(int *) src);
            break;
        case HSPVAR_FLAG_STRUCT: {
            flex_value_t *fv;
            fv = (flex_value_t *) src;
            if (fv->type == FLEXVAL_TYPE_NONE) {
                sprintf(buf, "STRUCT (Empty)");
            } else {
            }
            break;
        }
        case HSPVAR_FLAG_COMSTRUCT:
            sprintf(buf, "COMPTR $%08x", *(int *) src);
            break;
        default:
            strcpy(buf, "Unknown");
            break;
    }
}

/// variable array dump
///
- (void)code_arraydump:(value_t *)pv {
    char t[512];
    void *src;
    char *p;
    int ofs;
    int amax;
    int ok;

    amax = pv->len[1];
    if (amax <= 1) return;
    if (amax > 16) {
        strbuf_add_str(&hsp_dbgbuf, (char *) "(配列の一部だけを表示)\r\n");
        amax = 16;
    }

    for (ofs = 0; ofs < amax; ofs++) {
        src = hspvar_core_ptr_offset(pv, ofs);
        ok = 1;
        @try {
            if (strcmp(hspvar_proc[HSPVAR_FLAG_STR].vartype_name, "int") == 0) {  //整数のCnv
                p = (char *) hspvar_int_cnv(src, pv->flag);
            } else if (strcmp(hspvar_proc[HSPVAR_FLAG_STR].vartype_name, "double") == 0) {  //実数のCnv
                p = (char *) hspvar_double_cnv(src, pv->flag);
            } else if (strcmp(hspvar_proc[HSPVAR_FLAG_STR].vartype_name, "str") == 0) {  //文字列のCnv
                p = (char *) hspvar_str_cnv(src, pv->flag);
            } else {
                @throw [self make_nsexception:HSPERR_SYNTAX];
            }
            // p = (char *)HspVarCoreCnv( pv->flag, HSPVAR_FLAG_STR, src );
        } @catch (NSException *error) {
            char tmpbuf[256];
            [self code_dbgvarinf_ext:pv src:src buf:tmpbuf];
            sprintf(t, "(%d)=%s\r\n", ofs, tmpbuf);
            ok = 0;
        }
        if (ok) {
            if (strlen(p) > 63) {
                strncpy(hsp_hspctx->stmp, p, 63);
                hsp_hspctx->stmp[64] = 0;
                p = hsp_hspctx->stmp;
            }
            sprintf(t, "(%d)=%s\r\n", ofs, p);
        }
        strbuf_add_str(&hsp_dbgbuf, t);
    }
}

/// 変数情報取得
///
/// option
/// bit0 : sort ( 受け側で処理 )
/// bit1 : module
/// bit2 : array
/// bit3 : dump
///
- (char *)code_dbgvarinf:(char *)target option:(int)option {
    int i, id, max;
    char *name = NULL;
    hspvar_proc_t *proc;
    value_t *pv;
    void *src;
    char *p;
    char *padr;
    char tmp[256];
    int size;
    int orgsize;

    [self code_inidbg];
    max = hsp_hspctx->hsphed->max_val;

    if (target == NULL) {
        for (i = 0; i < max; i++) {
            name = [self code_getdebug_varname:i];
            if (strstr2(name, (char *) "@") != NULL) {
                if (!(option & 2)) name = NULL;
            }
            if (name != NULL) {
                strbuf_add_str(&hsp_dbgbuf, name);
                strbuf_add_str(&hsp_dbgbuf, (char *) "\r\n");
            }
        }

        return hsp_dbgbuf;
    }

    id = 0;
    while (1) {
        if (id >= max) break;
        name = [self code_getdebug_varname:id];
        if (strcmp(name, target) == 0) break;
        id++;
    }

    pv = &hsp_hspctx->mem_var[id];
    proc = HspVarCoreGetProc(pv->flag);
    [self code_adddbg2:(char *) "変数名" str:name];
    [self code_adddbg2:(char *) "型" str:proc->vartype_name];
    sprintf(tmp, "(%d,%d,%d,%d)", pv->len[1], pv->len[2], pv->len[3], pv->len[4]);
    [self code_adddbg2:(char *) "配列" str:tmp];
    [self code_adddbg2:(char *) "モード" val:pv->mode];
    [self code_adddbg2:(char *) "使用サイズ" val:pv->size];

    HspVarCoreReset(pv);
    if (strcmp(proc->vartype_name, "int") == 0) {  //整数のGetPtr
        src = hspvar_int_get_ptr(pv);
    } else if (strcmp(proc->vartype_name, "double") == 0) {  //実数のGetPtr
        src = hspvar_double_get_ptr(pv);
    } else if (strcmp(proc->vartype_name, "str") == 0) {  //文字列のGetPtr
        src = hspvar_str_get_ptr(pv);
    } else if (strcmp(proc->vartype_name, "label") == 0) {  //ラベルのGetPtr
        src = hspvar_label_get_ptr(pv);
    } else if (strcmp(proc->vartype_name, "struct") == 0) {  // structのGetPtr
        src = hspvar_label_get_ptr(pv);
    } else {
        @throw [self make_nsexception:HSPERR_SYNTAX];
    }

    if (strcmp(proc->vartype_name, "int") == 0) {  //整数のGetBlockSize
        padr = (char *) hspvar_int_get_block_size(pv, src, &size);
    } else if (strcmp(proc->vartype_name, "double") == 0) {  //実数のGetBlockSize
        padr = (char *) hspvar_double_get_block_size(pv, src, &size);
    } else if (strcmp(proc->vartype_name, "str") == 0) {  //文字列のGetBlockSize
        padr = (char *) hspvar_str_get_block_size(pv, src, &size);
    } else if (strcmp(proc->vartype_name, "label") == 0) {  //ラベルのGetBlockSize
        padr = (char *) hspvar_label_get_block_size(pv, src, &size);
    } else if (strcmp(proc->vartype_name, "struct") == 0) {  // structのGetBlockSize
        padr = (char *) hspvar_label_get_block_size(pv, src, &size);
    } else {
        @throw [self make_nsexception:HSPERR_SYNTAX];
    }

    [self code_adddbg2:(char *) "バッファサイズ" val:size];

    switch (pv->flag) {
        case HSPVAR_FLAG_STR:
        case HSPVAR_FLAG_DOUBLE:
        case HSPVAR_FLAG_INT:
            if (pv->flag != HSPVAR_FLAG_STR) {
                if (strcmp(hspvar_proc[HSPVAR_FLAG_STR].vartype_name, "int") == 0) {  //整数のCnv
                    p = (char *) hspvar_int_cnv(src, pv->flag);
                } else if (strcmp(hspvar_proc[HSPVAR_FLAG_STR].vartype_name, "double") == 0) {  //実数のCnv
                    p = (char *) hspvar_double_cnv(src, pv->flag);
                } else if (strcmp(hspvar_proc[HSPVAR_FLAG_STR].vartype_name, "str") == 0) {  //文字列のCnv
                    p = (char *) hspvar_str_cnv(src, pv->flag);
                } else {
                    @throw [self make_nsexception:HSPERR_SYNTAX];
                }
                // p = (char *)HspVarCoreCnv( pv->flag, HSPVAR_FLAG_STR, src );
            } else {
                p = padr;
            }
            orgsize = (int) strlen(p);
            if (orgsize >= 1024) {
                strncpy(hsp_hspctx->stmp, p, 1023);
                p = hsp_hspctx->stmp;
                p[1023] = 0;
                sprintf(tmp, "(内容%dbytesの一部を表示しています)\r\n", orgsize);
                strbuf_add_str(&hsp_dbgbuf, tmp);
            }
            [self code_adddbg:(char *) "内容:" str:p];
            break;
        case HSPVAR_FLAG_LABEL:
        default: {
            char tmpbuf[256];
            [self code_dbgvarinf_ext:pv src:src buf:tmpbuf];
            [self code_adddbg:(char *) "内容:" str:tmpbuf];
            break;
        }
    }

    if (option & 4) {
        [self code_arraydump:pv];
    }
    if (option & 8) {
        if (size > 0x1000) size = 0x1000;
        [self code_dbgdump:padr size:size];
    }

    return hsp_dbgbuf;
}

- (void)code_dbgcurinf {
    unsigned short *bak = hsp_mcsbak;
    hsp_mcsbak = hsp_mcs;
    hsp_dbginfo.line = [self code_getdebug_line];
    hsp_dbginfo.fname = [self code_getdebug_name];
    hsp_mcsbak = bak;
}

- (void)code_dbgclose:(char *)buf {
    strbuf_free(hsp_dbgbuf);
}

- (hspdebug_t *)code_getdbg {
    return &hsp_dbginfo;
}

///    ダミー用関数
- (char *)code_dbgvalue:(int)type {
    return [self code_inidbg];
}

///    デバッグモード設定
///
- (int)code_dbgset:(int)id {
    switch (hsp_hspctx->runmode) {
        case RUNMODE_STOP:
            if (id != HSPDEBUG_STOP) {
                hsp_hspctx->runmode = RUNMODE_RUN;
                if (id == HSPDEBUG_RUN) {
                    hsp_dbgmode = HSPDEBUG_NONE;
                } else {
                    hsp_dbgmode = id;
                }
                return 0;
            }
            break;
        case RUNMODE_WAIT:
        case RUNMODE_AWAIT:
            if (id == HSPDEBUG_STOP) {
                hsp_hspctx->runmode = RUNMODE_STOP;
                hsp_dbgmode = HSPDEBUG_NONE;
                return 0;
            }
            break;
    }
    return -1;
}

- (char *)code_dbgcallstack {
    stack_manager_t *it;
    hsp_subroutine_t *routine;
    int line;
    char tmp[HSP_MAX_PATH + 5 + 1];
    [self code_inidbg];
    for (it = get_stack_mem_stm(); it != get_stack_stm_cur(); it++) {
        if (it->type == TYPE_EX_SUBROUTINE || it->type == TYPE_EX_CUSTOMFUNC) {
            routine = (hsp_subroutine_t *) STM_GETPTR(it);
            line = [self code_getdebug_line:routine->mcsret];
            sprintf(tmp, "%s:%4d\r\n", [self code_getdebug_name], line);
            strbuf_add_str(&hsp_dbgbuf, tmp);
        }
    }
    return hsp_dbgbuf;
}

/// トレース処理
///
- (void)code_dbgtrace {
    int i = hsp_dbginfo.line;
    [self code_dbgcurinf];
    if (i != hsp_dbginfo.line) {
        hsp_hspctx->runmode = RUNMODE_STOP;
        // hsp_hspctx->msgfunc( hsp_hspctx );
        [self code_def_msgfunc:hsp_hspctx];
    }

}

#endif

@end
