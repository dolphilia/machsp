
//
//	hsc3.cpp structures
//
#ifndef __hsc3_h
#define __hsc3_h

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include "hsp3config.h"
#include "hsp3struct.h"
#include "membuf.h"
#include "label.h"
#include "token.h"
#include "../util/utility_time.h"
#include "../util/utility_string.h"
#include "../util/utility.h"

#define ERROR_BUFFER_SIZE 0x10000

#define HSC3TITLE "HSP script preprocessor"
#define HSC3TITLE2 "HSP code generator"

#define HSC3_OPT_NO_HSPDEF 1
#define HSC3_OPT_DEBUG_MODE 2
#define HSC3_OPT_MAKE_PACK 4
#define HSC3_OPT_READ_AHT 8
#define HSC3_OPT_MAKE_AHT 16
#define HSC3_OPT_UTF8_IN 32        // UTF8ソースを入力
#define HSC3_OPT_UTF8_OUT 64        // UTF8コードを出力

#define HSC3_MODE_DEBUG 1
#define HSC3_MODE_DEBUG_WIN 2
#define HSC3_MODE_UTF8 4        // UTF8コードを出力

class CMemBuf;
class CToken;
class CLabel;

// HSC3クラス
class HspCompiler {
public:
    HspCompiler();
    ~HspCompiler();

    char *get_error(void) const;
    int preprocess(char *fname, char *outname, int option, char *rname, void *ahtoption = NULL);
    void end_preprocess(void);
    int compile(char *fname, char *outname, int mode);
    void set_common_path(char *path);

    // データ
    CMemBuf *error_buffer;
    CMemBuf *add_keyword;
    CMemBuf *out_buffer{};
    CMemBuf *aht_buffer{};

private:
    void addSystemMacros(CToken *token, int option);

    CLabel *label_info;
    int process_option{};
    char common_path[512]{};
    int header_option{};
    char header_runtime[64]{};
    int compile_optimize{};

};


#endif
