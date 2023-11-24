
//
// HSPコンパイラ
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "hsp3config.h"
#include "hsp3struct.h"
#include "hsc3.h"
#include "membuf.h"
#include "label.h"
#include "token.h"
//#include "../gui/AppDelegate.h"
#include "../util/utility_time.h"
#include "../util/utility_string.h"
#include "../util/utility.h"

//#import "c_wrapper.h"

extern char *hsp_prestr[];
extern char *hsp_prepp[];

#define ERRBUF_SIZE 0x10000

//-------------------------------------------------------------
//		Routines
//-------------------------------------------------------------

char *CHsc3::getError(void) {
    return error_buffer->GetBuffer();
}

int CHsc3::getErrorSize(void) {
    return error_buffer->GetSize() + 1;
}

/// エラーメッセージ消去
///
void CHsc3::resetError(void) {
    if (error_buffer != NULL) {
        delete error_buffer;
        error_buffer = NULL;
    }
    error_buffer = new CMemBuf(ERRBUF_SIZE);
    header_option = 0;
    header_runtime[0] = 0;
}

//-------------------------------------------------------------
//		Interfaces
//-------------------------------------------------------------

CHsc3::CHsc3(void) {
    error_buffer = new CMemBuf(ERRBUF_SIZE);
    label_info = NULL;
    add_keyword = NULL;
    common_path[0] = 0;
}

CHsc3::~CHsc3(void) {
    if (add_keyword != NULL) {
        delete add_keyword;
        add_keyword = NULL;
    }
    if (error_buffer != NULL) {
        delete error_buffer;
        error_buffer = NULL;
    }
}

void CHsc3::addSystemMacros(CToken *tk, int option) {
    process_option = option;
    if ((option & HSC3_OPT_NO_HSPDEF) == 0) {
        //CLocalInfo linfo;
        tk->RegistExtMacro((char *) "__hspver__", vercode);
        tk->RegistExtMacro((char *) "__hsp30__", (char *) "");
        tk->RegistExtMacro((char *) "__date__", CurrentDate());//linfo.CurrentDate());
        tk->RegistExtMacro((char *) "__time__", CurrentTime());//linfo.CurrentTime());
        tk->RegistExtMacro((char *) "__line__", 0);
        tk->RegistExtMacro((char *) "__file__", (char *) "");
        if (option & HSC3_OPT_DEBUG_MODE)
            tk->RegistExtMacro((char *) "_debug", (char *) "");
    }
}

/// Preprocess execute (AHT)
/// (終了時にPreProcessEndを呼ぶこと)
///
int CHsc3::preProcessAht(char *fname, void *ahtoption, int mode) {
    int res;
    CToken tk;

    label_info = NULL;
    aht_buffer = NULL;
    tk.SetErrorBuf(error_buffer);
    tk.SetCommonPath(common_path);
    tk.SetAHT((AHTMODEL *) ahtoption);
    out_buffer = new CMemBuf;

    if (mode) {
        aht_buffer = new CMemBuf;
        tk.SetAHTBuffer(aht_buffer);
    }

    //@autoreleasepool {
    //    AppDelegate *global = (AppDelegate *) [[NSApplication sharedApplication] delegate];
    //    global.logString = [global.logString stringByAppendingFormat:@"#AHT processor ver%s / onion software 1997-2015(c)\n", hspver];
    //}

    res = tk.ExpandFile(out_buffer, fname, fname);
    if (res < 0)
        return -1;
    return 0;
}

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
int CHsc3::preProcess(char *fname, char *outname, int option, char *rname, void *ahtoption) {
    int res;
    CToken tk;
    CMemBuf *packbuf = NULL;

    label_info = NULL;
    out_buffer = new CMemBuf;
    aht_buffer = NULL;

    tk.SetErrorBuf(error_buffer);
    tk.SetCommonPath(common_path);
    tk.LabelRegist2(hsp_prestr);
    addSystemMacros(&tk, option);

    if (option & HSC3_OPT_MAKE_PACK) {
        packbuf = new CMemBuf(0x1000);
        tk.SetPackfileOut(packbuf);
    }
    if (option & (HSC3_OPT_READ_AHT | HSC3_OPT_MAKE_AHT)) {
        tk.SetAHT((AHTMODEL *) ahtoption);
    }
    if (option & HSC3_OPT_UTF8_IN) {
        tk.SetUTF8Input(1);
    }

    //@autoreleasepool {
    //    AppDelegate *global = (AppDelegate *) [[NSApplication sharedApplication] delegate];
    //    global.logString = [global.logString stringByAppendingFormat:@"# %s ver%s / onion software 1997-2015(c)\n", HSC3TITLE, hspver];
    //}

    tk.SetAdditionMode(1);

    res = tk.ExpandFile(out_buffer, (char *) "hspdef.as", (char *) "hspdef.as");
    tk.SetAdditionMode(0);
    if (res < -1)
        return -1;
    res = tk.ExpandFile(out_buffer, fname, rname);
    if (res < 0)
        return -1;
    tk.FinishPreprocess(out_buffer);

    compile_optimize = tk.GetCmpOption();
    if (compile_optimize & CMPMODE_PPOUT) {
        res = out_buffer->SaveFile(outname);
        if (res < 0) {
#ifdef JPNMSG
            //@autoreleasepool {
            //    AppDelegate *global = (AppDelegate *) [[NSApplication sharedApplication] delegate];
            //    global.logString = [global.logString stringByAppendingString:@"#プリプロセッサファイルの出力に失敗しました\n"];
            //}
#else
            tk.Mes("#Can't write output file.");
#endif
            return -2;
        }
    }
    out_buffer->Put((int) 0);

#if 0
    //		ソースのラベルを追加(停止中)
    if (addkw != NULL) {
        delete addkw;
        addkw = NULL;
    }
    addkw = new CMemBuf(0x1000);
    tk.LabelDump(addkw, DUMPMODE_DLLCMD);
#endif

    if (option & HSC3_OPT_MAKE_PACK) {
        tk.AddPackfile((char *) "start.ax", 1);
        res = packbuf->SaveFile((char *) "packfile");
        delete packbuf;
        if (res < 0) {
#ifdef JPNMSG
            //@autoreleasepool {
            //    AppDelegate *global = (AppDelegate *) [[NSApplication sharedApplication] delegate];
            //    global.logString = [global.logString stringByAppendingString:@"#packfileの出力に失敗しました\n"];
            //}
#else
            tk.Mes("#Can't write packfile.");
#endif
            return -3;
        }
        //@autoreleasepool {
        //    AppDelegate *global = (AppDelegate *) [[NSApplication sharedApplication] delegate];
        //    global.logString = [global.logString stringByAppendingString:@"#packfile generated.\n"];
        //}
    }

    header_option = tk.GetHeaderOption();
    strcpy(header_runtime, tk.GetHeaderRuntimeName());
    label_info = tk.GetLabelInfo();

    return 0;
}


void CHsc3::preProcessEnd(void) {
    if (label_info != NULL) {
        delete label_info;
        label_info = NULL;
    }
    if (out_buffer != NULL) {
        delete out_buffer;
        out_buffer = NULL;
    }
    if (aht_buffer != NULL) {
        delete aht_buffer;
        aht_buffer = NULL;
    }
}

/// compile
///
int CHsc3::compile(char *fname, char *outname, int mode) {
    int res;
    CToken tk;
    if (label_info != NULL)
        tk.SetLabelInfo(label_info);        // プリプロセッサのラベル情報

    tk.SetErrorBuf(error_buffer);
    tk.SetCommonPath(common_path);
    tk.LabelRegist(hsp_prestr, 1);
    tk.SetHeaderOption(header_option, header_runtime);
    tk.SetCmpOption(compile_optimize);

    if (process_option & HSC3_OPT_UTF8_IN) {
        tk.SetUTF8Input(1);
    }

    //@autoreleasepool {
    //    AppDelegate *global = (AppDelegate *) [[NSApplication sharedApplication] delegate];
    //    global.logString = [global.logString stringByAppendingFormat:@"# %s ver%s / onion software 1997-2015(c)\n", HSC3TITLE2, hspver];
    //}

    if (out_buffer != NULL) {
        res = tk.GenerateCode(out_buffer, outname, mode);
    } else {
        res = tk.GenerateCode(fname, outname, mode);
    }
    return res;
}


void CHsc3::setCommonPath(char *path) {
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

    tk.SetErrorBuf(error_buffer);
    tk.SetCommonPath(common_path);
    tk.LabelRegist3(hsp_prestr); // 標準キーワード
    tk.LabelRegist3(hsp_prepp); // プリプロセッサキーワード
    addSystemMacros(&tk, option);

    res = tk.ExpandFile(&outbuf, (char *) "hspdef.as", (char *) "hspdef.as");
    tk.LabelDump(error_buffer, DUMPMODE_ALL);

    return 0;
}

int CHsc3::OpenPackfile(void) {
    pack_file_buffer = new CMemBuf(0x1000);
    if (pack_file_buffer->PutFile((char *) "packfile") < 0) {
        delete pack_file_buffer;
        return -1;
    }
    return 0;
}

void CHsc3::GetPackfileOption(char *out, char *keyword, char *defval) {
    int max;
    char tmp[512];
    char *s;
    char a1;
    Select(pack_file_buffer->GetBuffer());
    max = GetMaxLine();
    //CStrNote note;
    //note.Select(pfbuf->GetBuffer());
    //max = note.GetMaxLine();
    strcpy(out, defval);
    for (int i = 0; i < max; i++) {
        GetLine(tmp, i);
        //note.GetLine(tmp, i);
        if ((tmp[0] == ';') && (tmp[1] == '!')) {
            s = tmp + 2;
            while (1) {
                a1 = *s;
                if ((a1 == 0) || (a1 == '='))
                    break;
                s++;
            }
            if (a1 != 0) {
                s[0] = 0;
                if (tstrcmp(tmp + 2, keyword)) {
                    strcpy(out, s + 1);
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
    delete pack_file_buffer;
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

    data = (char *) malloc(exsize);
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
    int res = out_buffer->SaveFile(fname);
    if (res < 0) {
        return -1;
    }
    return 0;
}

int CHsc3::SaveAHTOutbuf(char *fname) {
    int res = aht_buffer->SaveFile(fname);
    if (res < 0) {
        return -1;
    }
    return 0;
}
