
//
// HSPコンパイラ
//

#include "hsc3.h"

extern char *hsp_pre_str[];

HspCompiler::HspCompiler() {
    error_buffer = new CMemBuf(ERROR_BUFFER_SIZE);
    label_info = nullptr;
    add_keyword = nullptr;
    common_path[0] = 0;
}

HspCompiler::~HspCompiler() {
    if (add_keyword != nullptr) {
        delete add_keyword;
        add_keyword = nullptr;
    }
    if (error_buffer != nullptr) {
        delete error_buffer;
        error_buffer = nullptr;
    }
}

char *HspCompiler::get_error() const  {
    return error_buffer->GetBuffer();
}

void HspCompiler::addSystemMacros(CToken *token, int option) {
    process_option = option;
    if ((option & HSC3_OPT_NO_HSPDEF) == 0) {
        token->RegistExtMacro((char *) "__hspver__", HSP_VERSION_CODE);
        token->RegistExtMacro((char *) "__hsp30__", (char *) "");
        token->RegistExtMacro((char *) "__date__", CurrentDate());//linfo.CurrentDate());
        token->RegistExtMacro((char *) "__time__", CurrentTime());//linfo.CurrentTime());
        token->RegistExtMacro((char *) "__line__", 0);
        token->RegistExtMacro((char *) "__file__", (char *) "");
        if (option & HSC3_OPT_DEBUG_MODE) {
            token->RegistExtMacro((char *) "_debug", (char *) "");
        }
    }
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
int HspCompiler::preprocess(char *fname, char *outname, int option, char *rname, void *ahtoption) {
    label_info = NULL;
    out_buffer = new CMemBuf;
    aht_buffer = NULL;

    CToken token;
    token.SetErrorBuf(error_buffer);
    token.SetCommonPath(common_path);
    token.LabelRegist2(hsp_pre_str);
    addSystemMacros(&token, option);

    CMemBuf *pack_buffer = NULL;
    if (option & HSC3_OPT_MAKE_PACK) {
        pack_buffer = new CMemBuf(0x1000);
        token.SetPackfileOut(pack_buffer);
    }
    if (option & (HSC3_OPT_READ_AHT | HSC3_OPT_MAKE_AHT)) {
        token.SetAHT((AHTMODEL *) ahtoption);
    }
    if (option & HSC3_OPT_UTF8_IN) {
        token.SetUTF8Input(1);
    }

    printf("# %s ver%s / onion software 1997-2015(c)\n", HSC3TITLE, hspver);

    token.SetAdditionMode(1);

    int res = token.ExpandFile(out_buffer, (char *) "hspdef.as", (char *) "hspdef.as");
    token.SetAdditionMode(0);
    if (res < -1)
        return -1;
    res = token.ExpandFile(out_buffer, fname, rname);
    if (res < 0)
        return -1;
    token.FinishPreprocess(out_buffer);

    compile_optimize = token.GetCmpOption();
    if (compile_optimize & CMPMODE_PPOUT) {
        res = out_buffer->SaveFile(outname);
        if (res < 0) {
            printf("#プリプロセッサファイルの出力に失敗しました\n");
            return -2;
        }
    }
    out_buffer->Put((int) 0);

    if (option & HSC3_OPT_MAKE_PACK) {
        token.AddPackfile((char *) "start.ax", 1);
        res = pack_buffer->SaveFile((char *) "packfile");
        delete pack_buffer;
        if (res < 0) {
            printf("#packfileの出力に失敗しました\n");
            return -3;
        }
        printf("#packfile generated.\n");
    }

    header_option = token.GetHeaderOption();
    strcpy(header_runtime, token.GetHeaderRuntimeName());
    label_info = token.GetLabelInfo();

    return 0;
}

void HspCompiler::end_preprocess(void) {
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

int HspCompiler::compile(char *fname, char *outname, int mode) {

    CToken token;
    if (label_info != NULL) {
        token.SetLabelInfo(label_info);        // プリプロセッサのラベル情報
    }

    token.SetErrorBuf(error_buffer);
    token.SetCommonPath(common_path);
    token.LabelRegist(hsp_pre_str, 1);
    token.SetHeaderOption(header_option, header_runtime);
    token.SetCmpOption(compile_optimize);

    if (process_option & HSC3_OPT_UTF8_IN) {
        token.SetUTF8Input(1);
    }

    printf("# %s ver%s / onion software 1997-2015(c)\n", HSC3TITLE2, hspver);

    if (out_buffer != NULL) {
        return token.GenerateCode(out_buffer, outname, mode);
    }
    return token.GenerateCode(fname, outname, mode);
}

void HspCompiler::set_common_path(char *path) {
    if (path == NULL) {
        common_path[0] = 0;
        return;
    }
    strcpy(common_path, path);
}