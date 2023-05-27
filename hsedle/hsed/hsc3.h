
//
//	hsc3.cpp structures
//
#ifndef __hsc3_h
#define __hsc3_h

#define HSC3TITLE "HSP script preprocessor"
#define HSC3TITLE2 "HSP code generator"

#define HSC3_OPT_NOHSPDEF 1
#define HSC3_OPT_DEBUGMODE 2
#define HSC3_OPT_MAKEPACK 4
#define HSC3_OPT_READAHT 8
#define HSC3_OPT_MAKEAHT 16
#define HSC3_OPT_UTF8IN 32        // UTF8ソースを入力
#define HSC3_OPT_UTF8OUT 64        // UTF8コードを出力

#define HSC3_MODE_DEBUG 1
#define HSC3_MODE_DEBUGWIN 2
#define HSC3_MODE_UTF8 4        // UTF8コードを出力

class CMemBuf;

class CToken;

class CLabel;

// HSC3クラス
class CHsc3 {
public:
    CHsc3();

    ~CHsc3();

    char *GetError(void);

    int GetErrorSize(void);

    void ResetError(void);

    int PreProcess(char *fname, char *outname, int option, char *rname, void *ahtoption = NULL);

    int PreProcessAht(char *fname, void *ahtoption, int mode = 0);

    void PreProcessEnd(void);

    int Compile(char *fname, char *outname, int mode);

    void SetCommonPath(char *path);

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
    //
    CMemBuf *errbuf;
    CMemBuf *pfbuf;
    CMemBuf *addkw;
    CMemBuf *outbuf;
    CMemBuf *ahtbuf;

private:
    // プライベートデータ
    //
    int process_option;

    void AddSystemMacros(CToken *tk, int option);

    char common_path[512];            // 共通path

    // ヘッダー情報用
    int hed_option;
    char hed_runtime[64];

    // コンパイル最適化用
    int cmpopt; //Compile Optimize
    CLabel *lb_info;
};


#endif
