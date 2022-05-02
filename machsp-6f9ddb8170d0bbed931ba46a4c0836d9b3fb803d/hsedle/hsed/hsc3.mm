
//
//		HSP compiler class rev.3
//			onion software/onitama 2002/2
//
#import <stdio.h>
#import <stdlib.h>
#import <string.h>
#import "hsp3config.h"
#import "hsp3debug.h"
#import "hsp3struct.h"
#import "supio_linux.h"
#import "hsc3.h"
#import "membuf.h"
#import "strnote.h"
#import "label.h"
#import "token.h"
#import "localinfo.h"
#import "AppDelegate.h"
#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

extern char *hsp_prestr[];
extern char *hsp_prepp[];

#define ERRBUF_SIZE 0x10000

//-------------------------------------------------------------
//		Routines
//-------------------------------------------------------------

char *CHsc3::GetError(void) {
    return errbuf->GetBuffer();
}

int CHsc3::GetErrorSize(void) {
    return errbuf->GetSize() + 1;
}

/// エラーメッセージ消去
///
void CHsc3::ResetError(void) {
    if (errbuf != NULL) {
        delete errbuf;
        errbuf = NULL;
    }
    errbuf = new CMemBuf(ERRBUF_SIZE);
    hed_option = 0;
    hed_runtime[0] = 0;
}

//-------------------------------------------------------------
//		Interfaces
//-------------------------------------------------------------

CHsc3::CHsc3(void) {
    errbuf = new CMemBuf(ERRBUF_SIZE);
    lb_info = NULL;
    addkw = NULL;
    common_path[0] = 0;
}

CHsc3::~CHsc3(void) {
    if (addkw != NULL) {
        delete addkw;
        addkw = NULL;
    }
    if (errbuf != NULL) {
        delete errbuf;
        errbuf = NULL;
    }
}

void CHsc3::AddSystemMacros(CToken *tk, int option) {
    process_option = option;
    if ((option & HSC3_OPT_NOHSPDEF) == 0) {
        CLocalInfo linfo;
        tk->RegistExtMacro((char *)"__hspver__", vercode);
        tk->RegistExtMacro((char *)"__hsp30__", (char *)"");
        tk->RegistExtMacro((char *)"__date__", linfo.CurrentDate());
        tk->RegistExtMacro((char *)"__time__", linfo.CurrentTime());
        tk->RegistExtMacro((char *)"__line__", 0);
        tk->RegistExtMacro((char *)"__file__", (char *)"");
        if (option & HSC3_OPT_DEBUGMODE)
            tk->RegistExtMacro((char *)"_debug", (char *)"");
    }
}

/// Preprocess execute (AHT)
/// (終了時にPreProcessEndを呼ぶこと)
///
int CHsc3::PreProcessAht(char *fname, void *ahtoption, int mode) {
    int res;
    //char mm[512];
    CToken tk;
    
    lb_info = NULL;
    ahtbuf = NULL;
    tk.SetErrorBuf(errbuf);
    tk.SetCommonPath(common_path);
    tk.SetAHT((AHTMODEL *)ahtoption);
    outbuf = new CMemBuf;
    
    if (mode) {
        ahtbuf = new CMemBuf;
        tk.SetAHTBuffer(ahtbuf);
    }
    
    @autoreleasepool {
        AppDelegate* global = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        global.logString = [global.logString stringByAppendingFormat:@"#AHT processor ver%s / onion software 1997-2015(c)\n", hspver];
    }
    
    //sprintf( mm,"#AHT processor ver%s / onion software 1997-2015(c)", hspver );
    //tk.Mes( mm );
    res = tk.ExpandFile(outbuf, fname, fname);
    if (res < 0)
        return -1;
    return 0;
}


/*
	rev 54
	mingw : warning : packbuf は未初期化で使用されうる
	問題なさそう、一応対処。
 */
/// Preprocess execute
/// (終了時にPreProcessEndを呼ぶこと)
/// option :
/// bit0 = ver2.55 mode(ON)
/// bit1 = debug mode(ON)
/// bit2 = make packfile(ON)
/// bit3 = read AHT file(on)
/// bit4 = write AHT file(on)
/// bit5 = UTF8(on)
///
int CHsc3::PreProcess(char *fname, char *outname, int option, char *rname, void *ahtoption) {
    int res;
    CToken tk;
    CMemBuf *packbuf = NULL;
    
    lb_info = NULL;
    outbuf = new CMemBuf;
    ahtbuf = NULL;
    
    tk.SetErrorBuf(errbuf);
    tk.SetCommonPath(common_path);
    tk.LabelRegist2(hsp_prestr);
    AddSystemMacros(&tk, option);
    
    if (option & HSC3_OPT_MAKEPACK) {
        packbuf = new CMemBuf(0x1000);
        tk.SetPackfileOut(packbuf);
    }
    if (option & (HSC3_OPT_READAHT|HSC3_OPT_MAKEAHT)) {
        tk.SetAHT((AHTMODEL *)ahtoption);
    }
    if (option & HSC3_OPT_UTF8IN) {
        tk.SetUTF8Input( 1 );
    }
    
    @autoreleasepool {
        AppDelegate* global = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        global.logString = [global.logString stringByAppendingFormat:@"# %s ver%s / onion software 1997-2015(c)\n",HSC3TITLE, hspver];
    }
    //sprintf( mm,"#%s ver%s / onion software 1997-2015(c)", HSC3TITLE, hspver );
    //tk.Mes( mm );
    tk.SetAdditionMode(1);
    
    res = tk.ExpandFile(outbuf, (char *)"hspdef.as", (char *)"hspdef.as");
    tk.SetAdditionMode(0);
    if (res < -1)
        return -1;
    res = tk.ExpandFile(outbuf, fname, rname);
    if (res < 0)
        return -1;
    tk.FinishPreprocess(outbuf);
    
    cmpopt = tk.GetCmpOption();
    if (cmpopt & CMPMODE_PPOUT) {
        res = outbuf->SaveFile(outname);
        if (res < 0) {
#ifdef JPNMSG
            @autoreleasepool {
                AppDelegate* global = (AppDelegate *)[[NSApplication sharedApplication] delegate];
                global.logString = [global.logString stringByAppendingString:@"#プリプロセッサファイルの出力に失敗しました\n"];
            }
            //tk.Mes( (char *)"#プリプロセッサファイルの出力に失敗しました" );
#else
            tk.Mes("#Can't write output file.");
#endif
            return -2;
        }
    }
    outbuf->Put((int)0);
    
#if 0
    //		ソースのラベルを追加(停止中)
    if (addkw != NULL) {
        delete addkw;
        addkw = NULL;
    }
    addkw = new CMemBuf(0x1000);
    tk.LabelDump(addkw, DUMPMODE_DLLCMD);
#endif
    
    //sprintf( mm,"#Macro buffer %x.", tk.GetLabelBufferSize() );
    //tk.Mes( mm );
    
    if (option & HSC3_OPT_MAKEPACK) {
        tk.AddPackfile((char *)"start.ax", 1);
        res = packbuf->SaveFile((char *)"packfile");
        delete packbuf;
        if (res < 0) {
#ifdef JPNMSG
            @autoreleasepool {
                AppDelegate* global = (AppDelegate *)[[NSApplication sharedApplication] delegate];
                global.logString = [global.logString stringByAppendingString:@"#packfileの出力に失敗しました\n"];
            }
            //tk.Mes( (char *)"#packfileの出力に失敗しました" );
#else
            tk.Mes("#Can't write packfile.");
#endif
            return -3;
        }
        //tk.Mes( (char *)"#packfile generated." );
        @autoreleasepool {
            AppDelegate* global = (AppDelegate *)[[NSApplication sharedApplication] delegate];
            global.logString = [global.logString stringByAppendingString:@"#packfile generated.\n"];
        }
    }
    
    hed_option = tk.GetHeaderOption();
    strcpy( hed_runtime, tk.GetHeaderRuntimeName() );
    lb_info = tk.GetLabelInfo();
    
    return 0;
}


void CHsc3::PreProcessEnd(void) {
    if (lb_info != NULL) {
        delete lb_info;
        lb_info = NULL;
    }
    if (outbuf != NULL) {
        delete outbuf;
        outbuf = NULL;
    }
    if (ahtbuf != NULL) {
        delete ahtbuf;
        ahtbuf = NULL;
    }
}

/// Compile
///
int CHsc3::Compile(char *fname, char *outname, int mode) {
    //int res;
    //res = tcomp_main( fname, outname, errbuf, mode, "" );
    int res;
    CToken tk;
    if (lb_info != NULL)
        tk.SetLabelInfo(lb_info);		// プリプロセッサのラベル情報
    
    tk.SetErrorBuf(errbuf);
    tk.SetCommonPath(common_path);
    tk.LabelRegist(hsp_prestr, 1);
    tk.SetHeaderOption(hed_option, hed_runtime);
    tk.SetCmpOption(cmpopt);
    
    if (process_option & HSC3_OPT_UTF8IN) {
        tk.SetUTF8Input(1);
    }
    
    @autoreleasepool {
        AppDelegate* global = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        global.logString = [global.logString stringByAppendingFormat:@"# %s ver%s / onion software 1997-2015(c)\n",HSC3TITLE2, hspver];
    }
    //sprintf( mm,"#%s ver%s / onion software 1997-2015(c)", HSC3TITLE2, hspver );
    //tk.Mes( mm );
    
    if (outbuf != NULL) {
        res = tk.GenerateCode(outbuf, outname, mode);
    } else {
        res = tk.GenerateCode(fname, outname, mode);
    }
    return res;
}


void CHsc3::SetCommonPath(char *path) {
    if (path == NULL) {
        common_path[0] = 0;
        return;
    }
    strcpy(common_path, path);
}

int CHsc3::GetCmdList(int option) {
    int res;
    CToken tk;
    CMemBuf outbuf;
    
    tk.SetErrorBuf(errbuf);
    tk.SetCommonPath(common_path);
    tk.LabelRegist3(hsp_prestr); // 標準キーワード
    tk.LabelRegist3(hsp_prepp); // プリプロセッサキーワード
    AddSystemMacros(&tk, option);
    
    res = tk.ExpandFile(&outbuf, (char *)"hspdef.as", (char *)"hspdef.as");
    //	if ( res<-1 ) return -1;
    tk.LabelDump(errbuf, DUMPMODE_ALL);
    
    //errbuf->PutStr("-----¥r¥n");
    //if ( addkw != NULL ) errbuf->PutStr( addkw->GetBuffer() );
    return 0;
}

int CHsc3::OpenPackfile(void) {
    pfbuf = new CMemBuf(0x1000);
    if (pfbuf->PutFile((char *)"packfile" ) < 0 ) {
        delete pfbuf;
        return -1;
    }
    return 0;
}

void CHsc3::GetPackfileOption(char *out, char *keyword, char *defval) {
    int max;
    char tmp[512];
    char *s;
    char a1;
    CStrNote note;
    note.Select(pfbuf->GetBuffer());
    max = note.GetMaxLine();
    strcpy(out, defval);
    for(int i = 0; i < max; i++) {
        note.GetLine(tmp, i);
        if ((tmp[0] == ';' ) && (tmp[1] == '!')) {
            s = tmp + 2;
            while(1) {
                a1 = *s;
                if ((a1 == 0) || (a1 == '='))
                    break;
                s++;
            }
            if (a1 != 0) {
                s[0] = 0;
                if (tstrcmp(tmp + 2, keyword)) {
                    strcpy(out, s + 1 );
                }
            }
        }
    }
}

int CHsc3::GetPackfileOptionInt(char *keyword, int defval) {
    char tmp[512];
    char deftmp[32];
    sprintf(deftmp, "%d", defval);
    GetPackfileOption(tmp, keyword, deftmp);
    if ((tmp[0] >= '0') && (tmp[0] <= '9'))
        return atoi(tmp);
    return defval;
}

void CHsc3::ClosePackfile(void) {
    delete pfbuf;
}

int CHsc3::GetRuntimeFromHeader(char *fname, char *res) {
    HSPHED hsphed;
    int hedsize;
    int exsize;
    int ires;
    char *data;
    FILE *fp = fopen(fname, "rb");

    if (fp == NULL)
        return -1;
    hedsize = sizeof(hsphed);
    fread(&hsphed, 1, hedsize, fp);
    exsize = hsphed.pt_cs - hedsize;

    if (exsize == 0) {
        fclose(fp);
        return 0;
    }
    
    data = (char *)malloc(exsize);
    fread(data, 1, exsize, fp);
    fclose(fp);
    ires = 0;
    if (hsphed.bootoption & HSPHED_BOOTOPT_RUNTIME) {
        char runtime[HSP_MAX_PATH];
        strcpy(runtime, data + (hsphed.runtime - hedsize));
        cutext(runtime);
        addext(runtime, "exe");
        strcpy(res, runtime);
        ires = 1;
    }
    free(data);
    return ires;
}

int CHsc3::SaveOutbuf(char *fname) {
    int res = outbuf->SaveFile(fname);
    if (res < 0) {
        return -1;
    }
    return 0;
}

int CHsc3::SaveAHTOutbuf(char *fname) {
    int res = ahtbuf->SaveFile(fname);
    if (res < 0) {
        return -1;
    }
    return 0;
}
