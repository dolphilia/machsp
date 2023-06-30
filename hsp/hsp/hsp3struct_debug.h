//
//  hsp3struct_debug.h
//

#ifndef hsp3struct_debug_h
#define hsp3struct_debug_h

// エラーコード
typedef enum {
    HSPERR_NONE = 0,                // スクリプト終了時
    HSPERR_UNKNOWN_CODE,
    HSPERR_SYNTAX,
    HSPERR_ILLEGAL_FUNCTION,
    HSPERR_WRONG_EXPRESSION,
    HSPERR_NO_DEFAULT,
    HSPERR_TYPE_MISMATCH,
    HSPERR_ARRAY_OVERFLOW,
    HSPERR_LABEL_REQUIRED,
    HSPERR_TOO_MANY_NEST,
    HSPERR_RETURN_WITHOUT_GOSUB,
    HSPERR_LOOP_WITHOUT_REPEAT,
    HSPERR_FILE_IO,
    HSPERR_PICTURE_MISSING,
    HSPERR_EXTERNAL_EXECUTE,
    HSPERR_PRIORITY,
    HSPERR_TOO_MANY_PARAMETERS,
    HSPERR_TEMP_BUFFER_OVERFLOW,
    HSPERR_WRONG_NAME,
    HSPERR_DIVIDED_BY_ZERO,
    HSPERR_BUFFER_OVERFLOW,
    HSPERR_UNSUPPORTED_FUNCTION,
    HSPERR_EXPRESSION_COMPLEX,
    HSPERR_VARIABLE_REQUIRED,
    HSPERR_INTEGER_REQUIRED,
    HSPERR_BAD_ARRAY_EXPRESSION,
    HSPERR_OUT_OF_MEMORY,
    HSPERR_TYPE_INITALIZATION_FAILED,
    HSPERR_NO_FUNCTION_PARAMETERS,
    HSPERR_STACK_OVERFLOW,
    HSPERR_INVALID_PARAMETER,
    HSPERR_INVALID_ARRAYSTORE,
    HSPERR_INVALID_FUNCPARAM,
    HSPERR_WINDOW_OBJECT_FULL,
    HSPERR_INVALID_ARRAY,
    HSPERR_STRUCT_REQUIRED,
    HSPERR_INVALID_STRUCT_SOURCE,
    HSPERR_INVALID_TYPE,
    HSPERR_DLL_ERROR,
    HSPERR_COMDLL_ERROR,
    HSPERR_NORETVAL,
    HSPERR_FUNCTION_SYNTAX,

    HSPERR_INTJUMP,                    // 割り込みジャンプ時
    HSPERR_EXITRUN,                    // 外部ファイル実行
    HSPERR_MAX

} HSPERROR;

// Debug Info ID
enum {
    DEBUGINFO_GENERAL = 0,
    DEBUGINFO_VARNAME,
    DEBUGINFO_INTINFO,
    DEBUGINFO_GRINFO,
    DEBUGINFO_MMINFO,
    DEBUGINFO_MAX
};

// Debug Flag ID
enum {
    HSPDEBUG_NONE = 0,
    HSPDEBUG_RUN,
    HSPDEBUG_STOP,
    HSPDEBUG_STEPIN,
    HSPDEBUG_STEPOVER,
    HSPDEBUG_MAX
};

typedef struct hspdebug_t {
    //	[in/out] tranfer value
    //	(システムとの通信用)
    //
    int flag;     // Flag ID
    int line;     // 行番号情報
    char *fname;  // ファイル名情報
    void *dbgwin; // デバッグウィンドウのハンドル
    char *dbgval; // debug情報取得バッファ

    //	[in] system value
    //	(初期化後に設定されます)
    //
    struct hsp_context_t *hspctx;

    //
    char *(*get_value)(int);            // debug情報取得コールバック
    char *(*get_varinf)(char *, int);    // 変数情報取得コールバック
    void (*dbg_close)(char *);            // debug情報取得終了
    void (*dbg_curinf)(void);            // 現在行・ファイル名の取得
    int (*dbg_set)(int);                // debugモード設定
    char *(*dbg_callstack)(void);     // コールスタックの取得

} hspdebug_t;

#endif /* hsp3struct_debug_h */
