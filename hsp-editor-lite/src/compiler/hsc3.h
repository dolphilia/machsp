
//
//	hsc3.cpp structures
//
#ifndef __hsc3_h
#define __hsc3_h

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
class CHsc3 {
public:
    CHsc3();
    ~CHsc3();

    char *getError(void);
    int getErrorSize(void);
    void resetError(void);
    int preProcess(char *fname, char *outname, int option, char *rname, void *ahtoption = NULL);
    int preProcessAht(char *fname, void *ahtoption, int mode = 0);
    void preProcessEnd(void);
    int compile(char *fname, char *outname, int mode);
    void setCommonPath(char *path);

    // サービス
    int GetCmdList(int option);
    int OpenPackfile(void);
    void ClosePackfile(void);
    void GetPackfileOption(char *out, char *keyword, char *defval);
    int GetPackfileOptionInt(char *keyword, int defval);
    int GetRuntimeFromHeader(char *fname, char *res);
    int SaveOutbuf(char *fname);
    int SaveAHTOutbuf(char *fname);

    // データ
    CMemBuf *error_buffer;
    CMemBuf *pack_file_buffer;
    CMemBuf *add_keyword;
    CMemBuf *out_buffer;
    CMemBuf *aht_buffer;

private:
    void addSystemMacros(CToken *tk, int option);

    CLabel *label_info;
    int process_option;
    char common_path[512];
    int header_option;
    char header_runtime[64];
    int compile_optimize;


};


#endif
