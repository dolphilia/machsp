//
//	HSPVAR manager
//	onion software/onitama 2003/4
//
//関数ポインタの使用箇所あり
//->LrI
//->Cnv
//=============================================================================>>>hspvar_core
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
//=============================================================================<<<hspvar_core
@implementation ViewController (hspvar_core)
//=============================================================================>>>hspvar_core
/*------------------------------------------------------------*/
/*
 master pointer
 */
/*------------------------------------------------------------*/
PVal* mem_pval;
HspVarProc* hspvarproc;
int hspvartype_max;
int hspvartype_limit;
-(PDAT*)HspVarCorePtrAPTR:(PVal*)pv ofs:(APTR)ofs {
    //		変数データの実態ポインタを得る
    //		(APTRとpvalから実態を求める)
    //
    pv->offset = ofs;
    PDAT* dst;
    if (strcmp(hspvarproc[(pv)->flag].vartype_name, "int") == 0) { //整数のFree
        dst = [self HspVarInt_GetPtr:pv];
    } else if (strcmp(hspvarproc[(pv)->flag].vartype_name, "double") ==
               0) { //実数のFree
        dst = [self HspVarDouble_GetPtr:pv];
    } else if (strcmp(hspvarproc[(pv)->flag].vartype_name, "str") ==
               0) { //文字列のFree
        dst = [self HspVarStr_GetPtr:pv];
    } else if (strcmp(hspvarproc[(pv)->flag].vartype_name, "label") ==
               0) { //ラベルのFree
        dst = [self HspVarLabel_GetPtr:pv];
    } else if (strcmp(hspvarproc[(pv)->flag].vartype_name, "struct") ==
               0) { // structのFree
        dst = [self HspVarLabel_GetPtr:pv];
    } else {
        NSString* error_str = [NSString stringWithFormat:@"%d", HSPERR_SYNTAX];
        @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
    }
    return dst; // hspvarproc[(pv)->flag].GetPtr(pv);
}
-(void)HspVarCoreInit {
    int i;
    hspvarproc = (HspVarProc*)[self sbAlloc:sizeof(HspVarProc) * HSPVAR_FLAG_MAX];
    hspvartype_max = HSPVAR_FLAG_MAX;
    for (i = 0; i < HSPVAR_FLAG_MAX; i++) {
        hspvarproc[i].flag = 0;
    }
    //		mpval(テンポラリ変数)を初期化します
    //		(実態の初期化は、変数使用時に行なわれます)
    PVal* pval;
    mem_pval = (PVal*)[self sbAlloc:sizeof(PVal) * HSPVAR_FLAG_MAX];
    for (i = 0; i < HSPVAR_FLAG_MAX; i++) {
        pval = &mem_pval[i];
        pval->mode = HSPVAR_MODE_NONE;
        pval->flag = HSPVAR_FLAG_INT; // 仮の型
    }
}
-(void)HspVarCoreBye {
    int i;
    for (i = 0; i < hspvartype_max; i++) {
        if (mem_pval[i].mode == HSPVAR_MODE_MALLOC) {
            // HspVarCoreDispose( &mem_pval[i] );
            if (strcmp(hspvarproc[(&mem_pval[i])->flag].vartype_name, "int") ==
                0) { //整数のFree
                [self HspVarInt_Free:&mem_pval[i]];
            } else if (strcmp(hspvarproc[(&mem_pval[i])->flag].vartype_name,
                              "double") == 0) { //実数のFree
                [self HspVarDouble_Free:&mem_pval[i]];
            } else if (strcmp(hspvarproc[(&mem_pval[i])->flag].vartype_name, "str") ==
                       0) { //文字列のFree
                [self HspVarStr_Free:&mem_pval[i]];
            } else if (strcmp(hspvarproc[(&mem_pval[i])->flag].vartype_name,
                              "label") == 0) { //ラベルのFree
                [self HspVarLabel_Free:&mem_pval[i]];
            } else if (strcmp(hspvarproc[(&mem_pval[i])->flag].vartype_name,
                              "struct") == 0) { // structのFree
                [self HspVarLabel_Free:&mem_pval[i]];
            } else {
                NSString* error_str = [NSString stringWithFormat:@"%d", HSPERR_SYNTAX];
                @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
            }
        }
    }
    [self sbFree:mem_pval];
    [self sbFree:hspvarproc];
}
-(void)HspVarCoreResetVartype:(int)expand {
    //		VARTYPEを初期化する(HspVarCoreInitの後で呼ぶ)
    //		(expandに拡張するVARTYPEの数を指定する)
    //
    hspvartype_limit = hspvartype_max + expand;
    if (expand >= 0) {
        hspvarproc = (HspVarProc*)[self sbExpand:(char*)hspvarproc
                                            size:sizeof(HspVarProc) * hspvartype_limit];
        mem_pval =
        (PVal*)[self sbExpand:(char*)mem_pval size:sizeof(PVal) * hspvartype_limit];
    }
    //		標準の型を登録する
    //
    [self HspVarCoreRegisterType:(HSPVAR_FLAG_INT) vartype_name:(char*)"int"];
    [self HspVarCoreRegisterType:(HSPVAR_FLAG_STR) vartype_name:(char*)"str"];
    [self HspVarCoreRegisterType:(HSPVAR_FLAG_DOUBLE) vartype_name:(char*)"double"];
    [self HspVarCoreRegisterType:(HSPVAR_FLAG_STRUCT) vartype_name:(char*)"struct"];
    [self HspVarCoreRegisterType:(HSPVAR_FLAG_LABEL) vartype_name:(char*)"label"]; // ラベル型(3.1)
}
-(int)HspVarCoreAddType {
    int id;
    PVal* pval;
    if (hspvartype_max >= hspvartype_limit)
        return -1;
    id = hspvartype_max++;
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
//static void
//PutInvalid(void)
//{
//
//    NSString* error_str =
//    [NSString stringWithFormat:@"%d", HSPERR_UNSUPPORTED_FUNCTION];
//    @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
//
//}
-(void)HspVarCoreRegisterType:(int)flag vartype_name:(char*)vartype_name {
    int id;
    //void** procs;
    HspVarProc* p;
    id = flag;
    if (id < 0) {
        id = [self HspVarCoreAddType];
        if (id < 0) {
            return;
        }
    }
    p = &hspvarproc[id];
    p->flag = p->aftertype = id;
    // procs = (void **)(&p->Cnv);
    // while(1) {
    //    *procs = (void *)(PutInvalid);
    //    if ( procs == (void **)(&p->LrI) ) //$
    //        break;
    //    procs++;
    //}
    //	初期化関数の呼び出し
    if (strcmp(vartype_name, "int") == 0) {
        [self HspVarInt_Init:p];
    } else if (strcmp(vartype_name, "str") == 0) {
        [self HspVarStr_Init:p];
    } else if (strcmp(vartype_name, "double") == 0) {
        [self HspVarDouble_Init:p];
    } else if (strcmp(vartype_name, "struct") == 0) {
        [self HspVarStruct_Init:p];
    } else if (strcmp(vartype_name, "label") == 0) {
        [self HspVarLabel_Init:p];
    } else {
        NSString* error_str =
        [NSString stringWithFormat:@"%d", HSPERR_UNKNOWN_CODE];
        @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
    }
    // func( p );
}
/*------------------------------------------------------------*/
-(void)HspVarCoreDupPtr:(PVal*)pval flag:(int)flag ptr:(void*)ptr size:(int)size {
    //		指定されたポインタからのクローンになる
    //
    PDAT* buf;
    HspVarProc* p;
    p = &hspvarproc[flag];
    buf = (PDAT*)ptr;
    // HspVarCoreDispose( pval );
    if (strcmp(hspvarproc[(pval)->flag].vartype_name, "int") == 0) { //整数のFree
        [self HspVarInt_Free:pval];
    } else if (strcmp(hspvarproc[(pval)->flag].vartype_name, "double") ==
               0) { //実数のFree
        [self HspVarDouble_Free:pval];
    } else if (strcmp(hspvarproc[(pval)->flag].vartype_name, "str") ==
               0) { //文字列のFree
        [self HspVarStr_Free:pval];
    } else if (strcmp(hspvarproc[(pval)->flag].vartype_name, "label") ==
               0) { //ラベルのFree
        [self HspVarLabel_Free:pval];
    } else if (strcmp(hspvarproc[(pval)->flag].vartype_name, "struct") ==
               0) { // structのFree
        [self HspVarLabel_Free:pval];
    } else {
        NSString* error_str = [NSString stringWithFormat:@"%d", HSPERR_SYNTAX];
        @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
    }
    pval->pt = (char*)buf;
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
-(void)HspVarCoreDup:(PVal*)pval arg:(PVal*)arg aptr:(APTR)aptr {
    //		指定された変数のクローンになる
    //
    int size;
    PDAT* buf;
    HspVarProc* p;
    p = &hspvarproc[arg->flag];
    buf = [self HspVarCorePtrAPTR:arg ofs:aptr];
    // HspVarCoreGetBlockSize( arg, buf, &size );
    void* dst;
    if (strcmp(hspvarproc[(arg)->flag].vartype_name, "int") ==
        0) { //整数のGetBlockSize
        dst = [self HspVarInt_GetBlockSize:arg pdat:buf size:&size];
    } else if (strcmp(hspvarproc[(arg)->flag].vartype_name, "double") ==
               0) { //実数のGetBlockSize
        dst = [self HspVarDouble_GetBlockSize:arg pdat:buf size:&size];
    } else if (strcmp(hspvarproc[(arg)->flag].vartype_name, "str") ==
               0) { //文字列のGetBlockSize
        dst = [self HspVarStr_GetBlockSize:arg pdat:buf size:&size];
    } else if (strcmp(hspvarproc[(arg)->flag].vartype_name, "label") ==
               0) { //ラベルのGetBlockSize
        dst = [self HspVarLabel_GetBlockSize:arg pdat:buf size:&size];
    } else if (strcmp(hspvarproc[(arg)->flag].vartype_name, "struct") ==
               0) { // structのGetBlockSize
        dst = [self HspVarLabel_GetBlockSize:arg pdat:buf size:&size];
    } else {
        NSString* error_str = [NSString stringWithFormat:@"%d", HSPERR_SYNTAX];
        @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
    }
    [self HspVarCoreDupPtr:pval flag:arg->flag ptr:buf size:size];
}
-(void)HspVarCoreDim:(PVal*)pval flag:(int)flag len1:(int)len1 len2:(int)len2 len3:(int) len3 len4:(int)len4 {
    //		配列を確保する
    //		(len1〜len4は、4byte単位なので注意)
    //
    HspVarProc* p;
    p = &hspvarproc[flag];
    if ((len1 < 0) || (len2 < 0) || (len3 < 0) || (len4 < 0)) {
        NSString* error_str =
        [NSString stringWithFormat:@"%d", HSPVAR_ERROR_ILLEGALPRM];
        @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
    }
    // HspVarCoreDispose( pval );
    if (strcmp(hspvarproc[(pval)->flag].vartype_name, "int") == 0) { //整数のFree
        [self HspVarInt_Free:pval];
    } else if (strcmp(hspvarproc[(pval)->flag].vartype_name, "double") ==
               0) { //実数のFree
        [self HspVarDouble_Free:pval];
    } else if (strcmp(hspvarproc[(pval)->flag].vartype_name, "str") ==
               0) { //文字列のFree
        [self HspVarStr_Free:pval];
    } else if (strcmp(hspvarproc[(pval)->flag].vartype_name, "label") ==
               0) { //ラベルのFree
        [self HspVarLabel_Free:pval];
    } else if (strcmp(hspvarproc[(pval)->flag].vartype_name, "struct") ==
               0) { // structのFree
        [self HspVarLabel_Free:pval];
    } else {
        NSString* error_str = [NSString stringWithFormat:@"%d", HSPERR_SYNTAX];
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
        [self HspVarInt_Alloc:pval pval2:NULL];
    } else if (strcmp(p->vartype_name, "double") == 0) { //実数のAlloc
        [self HspVarDouble_Alloc:pval pval2:NULL];
    } else if (strcmp(p->vartype_name, "str") == 0) { //文字列のAlloc
        [self HspVarStr_Alloc:pval pval2:NULL];
    } else if (strcmp(p->vartype_name, "label") == 0) { //ラベルのAlloc
        [self HspVarLabel_Alloc:pval pval2:NULL];
    } else if (strcmp(p->vartype_name, "struct") == 0) { // structのAlloc
        [self HspVarLabel_Alloc:pval pval2:NULL];
    } else {
        NSString* error_str = [NSString stringWithFormat:@"%d", HSPERR_SYNTAX];
        @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
    }
}
-(void)HspVarCoreDimFlex:(PVal*)pval flag:(int)flag len0:(int)len0 len1:(int)len1 len2:(int) len2 len3:(int)len3 len4:(int)len4 {
    //		配列を確保する(可変長配列用)
    //		(len1〜len4は、4byte単位なので注意)
    //
    HspVarProc* p;
    p = &hspvarproc[flag];
    if ((len1 < 0) || (len2 < 0) || (len3 < 0) || (len4 < 0)) {
        NSString* error_str =
        [NSString stringWithFormat:@"%d", HSPVAR_ERROR_ILLEGALPRM];
        @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
    }
    // HspVarCoreDispose( pval );
    if (strcmp(hspvarproc[(pval)->flag].vartype_name, "int") == 0) { //整数のFree
        [self HspVarInt_Free:pval];
    } else if (strcmp(hspvarproc[(pval)->flag].vartype_name, "double") ==
               0) { //実数のFree
        [self HspVarDouble_Free:pval];
    } else if (strcmp(hspvarproc[(pval)->flag].vartype_name, "str") ==
               0) { //文字列のFree
        [self HspVarStr_Free:pval];
    } else if (strcmp(hspvarproc[(pval)->flag].vartype_name, "label") ==
               0) { //ラベルのFree
        [self HspVarLabel_Free:pval];
    } else if (strcmp(hspvarproc[(pval)->flag].vartype_name, "struct") ==
               0) { // structのFree
        [self HspVarLabel_Free:pval];
    } else {
        NSString* error_str = [NSString stringWithFormat:@"%d", HSPERR_SYNTAX];
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
        [self HspVarInt_Alloc:pval pval2:NULL];
    } else if (strcmp(p->vartype_name, "double") == 0) { //実数のAlloc
        [self HspVarDouble_Alloc:pval pval2:NULL];
    } else if (strcmp(p->vartype_name, "str") == 0) { //文字列のAlloc
        [self HspVarStr_Alloc:pval pval2:NULL];
    } else if (strcmp(p->vartype_name, "label") == 0) { //ラベルのAlloc
        [self HspVarLabel_Alloc:pval pval2:NULL];
    } else if (strcmp(p->vartype_name, "struct") == 0) { // structのAlloc
        [self HspVarLabel_Alloc:pval pval2:NULL];
    } else {
        NSString* error_str = [NSString stringWithFormat:@"%d", HSPERR_SYNTAX];
        @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
    }
    pval->len[0] = 1;
}
- (void)HspVarCoreReDim:(PVal*)pval lenid:(int)lenid len:(int)len {
    //		配列を拡張する
    //
    HspVarProc* p;
    p = &hspvarproc[pval->flag];
    pval->len[lenid] = len;
    if (strcmp(p->vartype_name, "int") == 0) { //整数のAlloc
        [self HspVarInt_Alloc:pval pval2:pval];
    } else if (strcmp(p->vartype_name, "double") == 0) { //実数のAlloc
        [self HspVarDouble_Alloc:pval pval2:pval];
    } else if (strcmp(p->vartype_name, "str") == 0) { //文字列のAlloc
        [self HspVarStr_Alloc:pval pval2:pval];
    } else if (strcmp(p->vartype_name, "label") == 0) { //ラベルのAlloc
        [self HspVarLabel_Alloc:pval pval2:pval];
    } else if (strcmp(p->vartype_name, "struct") == 0) { // structのAlloc
        [self HspVarLabel_Alloc:pval pval2:pval];
    } else {
        NSString* error_str = [NSString stringWithFormat:@"%d", HSPERR_SYNTAX];
        @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
    }
}
-(void) HspVarCoreClear:(PVal*)pval flag:(int)flag {
    //		指定タイプの変数を最小メモリで初期化する
    //
    [self HspVarCoreDim:pval flag:flag len1:1 len2:0 len3:0 len4:0]; // 最小サイズのメモリを確保
}
- (void) HspVarCoreClearTemp:(PVal*)pval flag:(int)flag {
    //		指定タイプの変数を最小メモリで初期化する(テンポラリ用)
    //
    [self HspVarCoreDim:pval flag:flag len1:1 len2:0 len3:0 len4:0]; // 最小サイズのメモリを確保
    pval->support |= HSPVAR_SUPPORT_TEMPVAR;
}
-(void*)HspVarCoreCnvPtr:(PVal*)pval flag:(int)flag {
    //		指定されたtypeフラグに変換された値のポインタを得る
    //
    PDAT* dst;
    if (pval->flag == flag) {
        if (strcmp(hspvarproc[flag].vartype_name, "int") == 0) { //整数のFree
            dst = [self HspVarInt_GetPtr:pval];
        } else if (strcmp(hspvarproc[flag].vartype_name, "double") ==
                   0) { //実数のFree
            dst = [self HspVarDouble_GetPtr:pval];
        } else if (strcmp(hspvarproc[flag].vartype_name, "str") ==
                   0) { //文字列のFree
            dst = [self HspVarStr_GetPtr:pval];
        } else if (strcmp(hspvarproc[flag].vartype_name, "label") ==
                   0) { //ラベルのFree
            dst = [self HspVarLabel_GetPtr:pval];
        } else if (strcmp(hspvarproc[flag].vartype_name, "struct") ==
                   0) { // structのFree
            dst = [self HspVarLabel_GetPtr:pval];
        } else {
            NSString* error_str = [NSString stringWithFormat:@"%d", HSPERR_SYNTAX];
            @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
        }
        return (void*)dst; // hspvarproc[ flag ].GetPtr( pval );
    }
    //		型変換をする
    void* buf;
    // buf = hspvarproc[ pval->flag ].GetPtr( pval );
    if (strcmp(hspvarproc[pval->flag].vartype_name, "int") == 0) { //整数のFree
        dst = [self HspVarInt_GetPtr:pval];
    } else if (strcmp(hspvarproc[pval->flag].vartype_name, "double") ==
               0) { //実数のFree
        dst = [self HspVarDouble_GetPtr:pval];
    } else if (strcmp(hspvarproc[pval->flag].vartype_name, "str") ==
               0) { //文字列のFree
        dst = [self HspVarStr_GetPtr:pval];
    } else if (strcmp(hspvarproc[pval->flag].vartype_name, "label") ==
               0) { //ラベルのFree
        dst = [self HspVarLabel_GetPtr:pval];
    } else if (strcmp(hspvarproc[pval->flag].vartype_name, "struct") ==
               0) { // structのFree
        dst = [self HspVarLabel_GetPtr:pval];
    } else {
        NSString* error_str = [NSString stringWithFormat:@"%d", HSPERR_SYNTAX];
        @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
    }
    buf = (void*)dst;
    if (pval->flag >= HSPVAR_FLAG_USERDEF) {
        //$使用できるCnvCustom関数は存在しない
        return NULL; //( hspvarproc[ pval->flag ].CnvCustom( buf, flag ) );
    }
    if (strcmp(hspvarproc[flag].vartype_name, "int") == 0) { //整数のCnv
        buf = [self HspVarInt_Cnv:buf flag:pval->flag];
    } else if (strcmp(hspvarproc[flag].vartype_name, "double") == 0) { //実数のCnv
        buf = [self HspVarDouble_Cnv:buf flag:pval->flag];
    } else if (strcmp(hspvarproc[flag].vartype_name, "str") == 0) { //文字列のCnv
        buf = [self HspVarStr_Cnv:buf flag:pval->flag];
    } else {
        NSString* error_str = [NSString stringWithFormat:@"%d", HSPERR_SYNTAX];
        @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
    }
    return (void*)dst; //( hspvarproc[flag].Cnv( buf, pval->flag ) );
}
#if 0
-(PDAT *)HspVarCorePtrAPTR:(PVal*)pv ofs:(APTR)ofs {
    //		変数データの実態ポインタを得る
    //		(APTRとpvalから実態を求める)
    //
    pv->offset=ofs;
    PDAT * dst;
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
-(HspVarProc*) HspVarCoreSeekProc:(const char*)name {
    int i;
    HspVarProc* p;
    for (i = 0; i < hspvartype_max; i++) {
        p = &hspvarproc[i];
        if (p->flag) {
            if (strcmp(p->vartype_name, name) == 0) {
                return p;
            }
        }
    }
    return NULL;
}
-(void)HspVarCoreArray:(PVal*)pval offset:(int)offset {
    //		配列要素の指定 (index)
    //		( Reset後に次元数だけ連続で呼ばれます )
    //
    if (pval->arraycnt >= 5) {
        NSString* error_str =
        [NSString stringWithFormat:@"%d", HSPVAR_ERROR_ARRAYOVER];
        @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
    }
    if (pval->arraycnt == 0) {
        pval->arraymul = 1; // 最初の値
    } else {
        pval->arraymul *= pval->len[pval->arraycnt];
    }
    pval->arraycnt++;
    if (offset < 0) {
        NSString* error_str =
        [NSString stringWithFormat:@"%d", HSPVAR_ERROR_ARRAYOVER];
        @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
    }
    if (offset >= (pval->len[pval->arraycnt])) {
        NSString* error_str =
        [NSString stringWithFormat:@"%d", HSPVAR_ERROR_ARRAYOVER];
        @throw [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
    }
    pval->offset += offset * pval->arraymul;
}
//=============================================================================<<<hspvar_core
@end
