/*--------------------------------------------------------
 HSP3 main (Console Version)
 2004/8  onitama
 --------------------------------------------------------*/

#import "hsp3cl.h"
#import "hspvar_double.h"
#import "hspvar_int.h"
#import "hspvar_label.h"
#import "hspvar_str.h"
#import "hspvar_struct.h"
#import "hsp3debug.h"
#import "utility_string.h"

#define GetPRM(id) (&hspctx.mem_finfo[id])
#define strp(dsptr) &hspctx.mem_mds[dsptr]

@implementation ViewController (hsp3cl)

/// すべて破棄
///
- (void)dealloc {
    [self code_termfunc];
    [self Dispose];
    [self code_bye];
}

/// 実行メインを呼び出す
///
- (int)hsp3cl_exec {
    int runmode;
    int endcode;
rerun:
    //		実行の開始
    //
    runmode = [self code_execcmd];
    if (runmode == RUNMODE_ERROR) {
        @try {
            [self hsp3cl_error];
        } @catch (NSException *error) {
        }
        return -1;
    }
    if (runmode == RUNMODE_EXITRUN) {
        char fname[HSP_MAX_PATH];
        char cmd[1024];
        int res;
        strncpy(fname, vc_hspctx->refstr, HSP_MAX_PATH - 1);
        strncpy(cmd, vc_hspctx->stmp, 1023);
        [self hsp3cl_bye];
        res = [self hsp3cl_init:fname];
        if (res) {
            return res;
        }
        strncpy(vc_hspctx->cmdline, cmd, 1023);
        vc_hspctx->runmode = RUNMODE_RUN;
        goto rerun;
    }
    endcode = vc_hspctx->endcode;
    [self hsp3cl_bye];
    return endcode;
}

/// システム関連の初期化
///
/// ( mode:0=debug/1=release )
///
- (int)hsp3cl_init:(char *)startfile {
    int orgexe, mode;
    int _hsp_sum, _hsp_dec;
    char a1;
    char *ss;
    char fpas[] = {'H' - 48, 'S' - 48, 'P' - 48, 'H' - 48, 'E' - 48, 'D' - 48, ' ' - 48, ' ' - 48};
    char optmes[] = "HSPHED‾‾\0_1_________2_________3______";
    int hsp_wd;
    //		HSP関連の初期化
    //
    // hsp = [[Hsp3 alloc] init];
    memset(&abc_hspctx, 0, sizeof(HSPContext));
    [self code_setctx:&abc_hspctx];
    [self code_init];
    abc_hspctx.mem_mcs = NULL;
    hsp3cl_axfile = NULL;
    hsp3cl_axname = NULL;
    
#ifdef FLAG_HSPDEBUG
    if (*startfile == 0) {
        printf("OpenHSP CL ver%s / onion software 1997-2009\n", HSP_VERSION);
        return -1;
    }
    [self SetFileName:startfile];
#else
    if (startfile != NULL) {
        [self SetFileName:startfile];
    }
#endif
    
    // 実行ファイルかデバッグ中かを調べる
    //
    mode = 0;
    orgexe = 0;
    hsp_wd = 0;
    for (int i = 0; i < 8; i++) {
        a1 = optmes[i] - 48;
        if (a1 == fpas[i]) orgexe++;
    }
    if (orgexe == 0) {
        mode = atoi(optmes + 9) + 0x10000;
        hsp_wd = (*(short *)(optmes + 26));
        _hsp_sum = *(unsigned short *)(optmes + 29);
        _hsp_dec = *(int *)(optmes + 32);
        [self SetPackValue:_hsp_sum dec:_hsp_dec];
    }
    if ([self Reset:mode]) {
        [self hsp3win_dialog:(char *)"Startup failed."];
        return -1;
    }

    vc_hspctx = &self->abc_hspctx;

    //		コマンドライン関連
    ss = (char *)"";  // コマンドラインパラメーターを入れる
    sbStrCopy(&vc_hspctx->cmdline, ss);  // コマンドラインパラメーターを保存

    //		Register Type
    //
    //注意
    // ctx->msgfunc = [self hsp3cl_msgfunc];
    [self hsp3cl_msgfunc:vc_hspctx];
    vc_hspctx->hspstat |= 16;

    // hsp3typeinit_dllcmd( code_gettypeinfo( TYPE_DLLFUNC ) );
    // hsp3typeinit_dllctrl( code_gettypeinfo( TYPE_DLLCTRL ) );

    [self hsp3typeinit_cl_extcmd:[self code_gettypeinfo:TYPE_EXTCMD]];
    [self hsp3typeinit_cl_extfunc:[self code_gettypeinfo:TYPE_EXTSYSVAR]];
    return 0;
}

- (void)hsp3win_dialog:(char *)mes {
    printf("%s\n", mes);
}

/// HSP関連の解放
///
- (void)hsp3cl_bye {
    // delete hsp;
}

- (void)hsp3cl_msgfunc:(HSPContext *)_hspctx {
    while (1) {
        switch (_hspctx->runmode) {
            case RUNMODE_STOP: { // stop命令
                [self hsp3win_dialog:(char *)"[STOP] Press any key..."];
                getchar();
                @throw [self make_nsexception:HSPERR_NONE];
            }
            case RUNMODE_WAIT: // wait命令による時間待ち
                // (実際はcode_exec_waitにtick countを渡す)
                // NSLog(@"wait");
                // NSLog(@"%d",tick);
                _hspctx->runmode = RUNMODE_RUN;
                // hspctx->runmode = code_exec_wait( tick );
                break;
                
            case RUNMODE_AWAIT: // await命令による時間待ち
                //		(実際はcode_exec_awaitにtick countを渡す)
                _hspctx->runmode = RUNMODE_RUN;
                // hspctx->runmode = code_exec_await( tick );
                break;
            case RUNMODE_END: { // end命令
                
#if 0
                hsp3win_dialog( "[END] Press any key..." );
                getchar();
#endif
                 @throw [self make_nsexception:HSPERR_NONE];
            }
            case RUNMODE_RETURN: {
                 @throw [self make_nsexception:HSPERR_RETURN_WITHOUT_GOSUB];
            }
            case RUNMODE_ASSERT: // assertで中断
                _hspctx->runmode = RUNMODE_STOP;
                break;
            case RUNMODE_LOGMES: // logmes命令
                _hspctx->runmode = RUNMODE_RUN;
                break;
            default:
                return;
        }
    }
}

- (void)hsp3cl_error {
    char errmsg[1024];
    char *fname = [self code_getdebug_name];
    HSPERROR err = [self code_geterror];
    char *msg = hspd_geterror(err);
    int ln = [self code_getdebug_line];
    
    if (ln < 0) {
        sprintf(errmsg, "#Error %d\n-->%s\n", (int)err, msg);
        fname = NULL;
    } else {
        sprintf(errmsg, "#Error %d in line %d (%s)\n-->%s\n", (int)err, ln, fname, msg);
    }
    
    [self hsp3win_dialog:errmsg];
    [self hsp3win_dialog:(char *)"[ERROR] Press any key..."];
    getchar();
}

//------------------------------------------------------------
// interface
//------------------------------------------------------------

- (void)SetFileName:(char *)name {
    if (*name == 0) {
        hsp3cl_axname = NULL;
        return;
    }
    hsp3cl_axname = name;
}

/// axを破棄
///
- (void)Dispose {
    if (abc_hspctx.mem_mcs == NULL) {
        return;
    }
    if (abc_hspctx.mem_var != NULL) {
        for (int i = 0; i < hsp3cl_maxvar; i++) {
            char *vartype_name = hspvarproc[(&abc_hspctx.mem_var[i])->flag].vartype_name;
            if (strcmp(vartype_name, "int") == 0) {  //整数のFree
                HspVarInt_Free(&abc_hspctx.mem_var[i]);
            } else if (strcmp(vartype_name, "double") == 0) {  //実数のFree
                HspVarDouble_Free(&abc_hspctx.mem_var[i]);
            } else if (strcmp(vartype_name, "str") == 0) {  //文字列のFree
                HspVarStr_Free(&abc_hspctx.mem_var[i]);
            } else if (strcmp(vartype_name, "label") == 0) {  //ラベルのFree
                HspVarLabel_Free(&abc_hspctx.mem_var[i]);
            } else if (strcmp(vartype_name, "struct") == 0) {  // structのFree
                HspVarLabel_Free(&abc_hspctx.mem_var[i]);
            } else {
                 @throw [self make_nsexception:HSPERR_SYNTAX];
            }
        }
        delete[] abc_hspctx.mem_var;
        abc_hspctx.mem_var = NULL;
    }
    abc_hspctx.mem_mcs = NULL;
    if (hsp3cl_axfile != NULL) {
        mem_bye(hsp3cl_axfile);
        hsp3cl_axfile = NULL;
    }
}

/// axを初期化
///
/// mode:
/// 0 = normal(debug) mode
/// other = packfile PTR
///
- (int)Reset:(int)mode {
    int i;
    char *ptr;
    char fname[512];
    HSPHED *hsphed;
    char startax[] = {'S' - 40, 'T' - 40, 'A' - 40, 'R' - 40, 'T' - 40, '.' - 40, 'A' - 40, 'X' - 40, 0};
    
    if (abc_hspctx.mem_mcs != NULL) {
        [self Dispose];
    }
    
    // load HSP execute object
    //
    hsp3cl_axtype = HSP3_AXTYPE_NONE;
    if (mode) {  // "start.ax"を呼び出す
        i = [self dpm_ini:(char *)"" dpmofs:mode chksum:hsp3cl_hsp_sum deckey:hsp3cl_hsp_dec];  // customized EXE mode
    } else {
        [self dpm_ini:(char *)"data.dpm" dpmofs:0 chksum:-1 deckey:-1];  // original EXE mode
    }
    
    //		start.ax読み込み
    if (hsp3cl_axname == NULL) {
        unsigned char *p = (unsigned char *)fname;
        unsigned char *s = (unsigned char *)startax;
        unsigned char ap;
        int sum = 0;
        while (1) {
            ap = *s++;
            if (ap == 0)
                break;
            ap += 40;
            *p++ = ap;
            sum = sum * 17 + (int)ap;
        }
        *p = 0;
        if (sum != 0x6cced385) {
            return -1;
        }
        if (mode) {
            if ([self dpm_filebase:fname] != 1) {
                return -1;  // DPM,packfileからのみstart.axを読み込む
            }
        }
    } else {
        strcpy(fname, hsp3cl_axname);
    }
    
    ptr = [self dpm_readalloc:fname];
    if (ptr == NULL) {
        return -1;
    }
    
    hsp3cl_axfile = ptr;
    
    //		memory location set
    //
    hsphed = (HSPHED *)ptr;
    
    if ((hsphed->h1 != 'H') || (hsphed->h2 != 'S') || (hsphed->h3 != 'P') ||
        (hsphed->h4 != '3')) {
        mem_bye(hsp3cl_axfile);
        
        return -1;
    }
    
    hsp3cl_maxvar = hsphed->max_val;
    abc_hspctx.hsphed = hsphed;
    abc_hspctx.mem_mcs = (unsigned short *)[self copy_DAT:ptr + hsphed->pt_cs size:hsphed->max_cs];
    abc_hspctx.mem_mds = (char *)(ptr + hsphed->pt_ds);
    abc_hspctx.mem_ot = (int *)[self copy_DAT:ptr + hsphed->pt_ot size:hsphed->max_ot];
    abc_hspctx.mem_di = (unsigned char *)[self copy_DAT:ptr + hsphed->pt_dinfo size:hsphed->max_dinfo];
    abc_hspctx.mem_linfo = (LIBDAT *)[self copy_LIBDAT:hsphed ptr:ptr + hsphed->pt_linfo size:hsphed->max_linfo];
    abc_hspctx.mem_minfo = (STRUCTPRM *)[self copy_DAT:ptr + hsphed->pt_minfo size:hsphed->max_minfo];
    abc_hspctx.mem_finfo = (STRUCTDAT *)[self copy_STRUCTDAT:hsphed ptr:ptr + hsphed->pt_finfo size:hsphed->max_finfo];
    
    HspVarCoreResetVartype(hsphed->max_varhpi);  // 型の初期化
    [self code_resetctx:&abc_hspctx];            // hsp3code setup
    
    //		HspVar setup
    abc_hspctx.mem_var = NULL;
    if (hsp3cl_maxvar) {
        abc_hspctx.mem_var = new PVal[hsp3cl_maxvar];
        for (int i = 0; i < hsp3cl_maxvar; i++) {
            PVal *pval = &abc_hspctx.mem_var[i];
            pval->mode = HSPVAR_MODE_NONE;
            pval->flag = HSPVAR_FLAG_INT;            // 仮の型
            HspVarCoreClear(pval, HSPVAR_FLAG_INT);  // グローバル変数を0にリセット
        }
    }
    
    //		debug
    // Alertf( "#HSP objcode
    // initalized.(CS=%d/DS=%d/OT=%d/VAR=%d)\n",hsphed->max_cs, hsphed->max_ds,
    // hsphed->max_ot, hsphed->max_val );
    [self code_setpc:abc_hspctx.mem_mcs];
    [self code_debug_init];
    return 0;
}

- (void)SetPackValue:(int)sum dec:(int)dec {
    hsp3cl_hsp_sum = sum;
    hsp3cl_hsp_dec = dec;
}

//------------------------------------------------------------
// util
//------------------------------------------------------------

- (void *)copy_DAT:(char *)ptr size:(size_t)size {
    if (size <= 0) {
        return ptr;
    }
    void *dst = malloc(size);
    memcpy(dst, ptr, size);
    return dst;
}

/// libdatの準備
///
- (LIBDAT *)copy_LIBDAT:(HSPHED *)hsphed ptr:(char *)ptr size:(size_t)size {
    int max;
    int newsize;
    LIBDAT *mem_dst;
    LIBDAT *dst;
    HED_LIBDAT org_dat;
    
    max = (int)(size / sizeof(HED_LIBDAT));
    if (max <= 0)
        return (LIBDAT *)ptr;
    newsize = sizeof(LIBDAT) * max;
    mem_dst = (LIBDAT *)malloc(newsize);
    dst = mem_dst;
    for (int i = 0; i < max; i++) {
        memcpy(&org_dat, ptr, sizeof(HED_LIBDAT));

        dst->flag = org_dat.flag;
        dst->nameidx = org_dat.nameidx;
        dst->clsid = org_dat.clsid;
        dst->hlib = NULL;
        
        dst++;
        ptr += sizeof(HED_LIBDAT);
    }
    hsphed->max_linfo = newsize;
    
    return mem_dst;
}

/// structdatの準備
///
- (STRUCTDAT *)copy_STRUCTDAT:(HSPHED *)hsphed ptr:(char *)ptr size:(size_t)size {
    int i, max;
    int newsize;
    STRUCTDAT *mem_dst;
    STRUCTDAT *dst;
    HED_STRUCTDAT org_dat;
    max = (int)(size / sizeof(HED_STRUCTDAT));
    if (max <= 0) return (STRUCTDAT *)ptr;
    newsize = sizeof(STRUCTDAT) * max;
    mem_dst = (STRUCTDAT *)malloc(sizeof(STRUCTDAT) * max);
    dst = mem_dst;
    for (i = 0; i < max; i++) {
        memcpy(&org_dat, ptr, sizeof(HED_STRUCTDAT));
        dst->index = org_dat.index;
        dst->subid = org_dat.subid;
        dst->prmindex = org_dat.prmindex;
        dst->prmmax = org_dat.prmmax;
        dst->nameidx = org_dat.nameidx;
        dst->size = org_dat.size;
        dst->otindex = org_dat.otindex;
        dst->funcflag = org_dat.funcflag;
#ifdef PTR64BIT
        dst->proc = NULL;
#endif
        dst++;
        ptr += sizeof(HED_STRUCTDAT);
    }
    hsphed->max_finfo = newsize;
    return mem_dst;
}

@end
