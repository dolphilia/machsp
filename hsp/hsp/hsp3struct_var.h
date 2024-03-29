//
//  hsp3struct_var.h
//

#ifndef hsp3struct_var_h
#define hsp3struct_var_h

#define HSPVAR_FLAG_NONE      0
#define HSPVAR_FLAG_LABEL     1
#define HSPVAR_FLAG_STR       2
#define HSPVAR_FLAG_DOUBLE    3
#define HSPVAR_FLAG_INT       4
#define HSPVAR_FLAG_STRUCT    5
#define HSPVAR_FLAG_COMSTRUCT 6
//	7はVARIANTで予約済み
#define HSPVAR_FLAG_USERDEF   8
#define HSPVAR_FLAG_MAX       8
#define HSPVAR_MODE_NONE     -1
#define HSPVAR_MODE_MALLOC    1
#define HSPVAR_MODE_CLONE     2
#define HSPVAR_ERROR_INVALID HSPERR_WRONG_EXPRESSION
#define HSPVAR_ERROR_DIVZERO HSPERR_DIVIDED_BY_ZERO
#define HSPVAR_ERROR_TYPEMISS HSPERR_TYPE_MISMATCH
#define HSPVAR_ERROR_ARRAYOVER HSPERR_ARRAY_OVERFLOW
#define HSPVAR_ERROR_ILLEGALPRM HSPERR_ILLEGAL_FUNCTION
#define HSPVAR_SUPPORT_STORAGE        1 // 固定長ストレージサポート
#define HSPVAR_SUPPORT_FLEXSTORAGE    2 // 可変長ストレージサポート
#define HSPVAR_SUPPORT_FIXEDARRAY     4 // 配列サポート
#define HSPVAR_SUPPORT_FLEXARRAY      8 // 可変長配列サポート
#define HSPVAR_SUPPORT_ARRAYOBJ      16 // 連想配列サポート
#define HSPVAR_SUPPORT_FLEXSIZE      32 // 要素ごとのデータが可変長
#define HSPVAR_SUPPORT_NOCONVERT     64 // 代入時の型変換を無効にする
#define HSPVAR_SUPPORT_VARUSE       128 // varuse関数のチェックを有効にする
#define HSPVAR_SUPPORT_TEMPVAR      256 // テンポラリ変数として使用する
#define HSPVAR_SUPPORT_USER1     0x4000 // ユーザーフラグ1
#define HSPVAR_SUPPORT_USER2     0x8000 // ユーザーフラグ2
#define HSPVAR_SUPPORT_MISCTYPE (HSPVAR_SUPPORT_ARRAYOBJ)

//typedef void *void;   // データの実態へのポインタ
//typedef int PDAT;     // 配列データへのオフセット値

enum {
    CALCCODE_ADD = 0,
    CALCCODE_SUB,
    CALCCODE_MUL,
    CALCCODE_DIV,
    CALCCODE_MOD,
    CALCCODE_AND,
    CALCCODE_OR,
    CALCCODE_XOR,
    CALCCODE_EQ,
    CALCCODE_NE,
    CALCCODE_GT,
    CALCCODE_LT,
    CALCCODE_GTEQ,
    CALCCODE_LTEQ,
    CALCCODE_RR,
    CALCCODE_LR,
    CALCCODE_MAX
};

//	PVAL structure
//
typedef struct {
    short flag;              // type of val
    short mode;              // mode (0=normal/1=clone/2=alloced)
    int len[5];              // length of array 4byte align (dim)
    int size;                // size of Val
    char *pt;                // ptr to array
    void *master;            // Master pointer for data
    unsigned short support;  // サポートフラグ
    short arraycnt;          // Array Set Count
    int offset;              // 配列データのオフセット
    int arraymul;            // Array Multiple Value
} value_t;

//		command execute core function
//
typedef struct {
    //		データフィールド
    //
    short flag;                            // 型タイプ値 (親アプリケーションで設定されます)
    short aftertype;                    // 演算後のタイプ値
    short version;                        // 型タイプランタイムバージョン(0x100 = 1.0)
    unsigned short support;                // サポート状況フラグ(HSPVAR_SUPPORT_*)
    short basesize;                        // １つのデータが使用するサイズ(byte) / 可変長の時は-1
    short opt;                            // (未使用)

    char *vartype_name;                    // 型タイプ名文字列へのポインタ
    char *user;                            // ユーザーデータ(未使用)

    //		システム参照・型変換用
    //
    void *(*Cnv)(const void *buffer, int flag);

    void *(*CnvCustom)(const void *buffer, int flag);

    void *(*GetPtr)(value_t *pval);

    void *(*ArrayObjectRead)(value_t *pval, int *mptype);// 配列要素の指定 (連想配列/読み出し)
    void (*ArrayObject)(value_t *pval);                            // 配列要素の指定 (連想配列/書き込み準備)
    void (*ObjectWrite)(value_t *pval, void *data, int type);        // HSPVAR_SUPPORT_NOCONVERT指定時の代入
    void (*ObjectMethod)(value_t *pval);                            // 変数に対するメソッドの指定

    void (*Alloc)(value_t *pval, const value_t *pval2);        // 変数メモリを確保する
    void (*Free)(value_t *pval);                        // 変数メモリを解放する

    int (*GetSize)(const void *pdat);            // 要素が使用するメモリサイズを返す(可変長のため)
    int (*GetUsing)(const void *pdat);            // 要素が使用中であるかを返す(varuse関数用)

    //		変数バッファ(バイナリ)のポインタとサイズを返す
    //		(要素が可変長(str)の場合は該当する１配列バイナリのみ)
    //		(要素が固定長(int,double)の場合は全配列バイナリ)
    //		(サイズはメモリ確保サイズを返す)
    void *(*GetBlockSize)(value_t *pval, void *pdat, int *size);

    //		バイナリデータ用にメモリブロックを確保する
    //		(要素が可変長(str)の場合にブロックサイズを強制的に確保する)
    //		(固定長の場合は何もしない)
    void (*AllocBlock)(value_t *pval, void *pdat, int size);

    //		代入用関数(型の一致が保障されます)
    //
    void (*Set)(value_t *pval, void *pdat, const void *in);

    //		演算用関数(型の一致が保障されます)
    //
    void (*AddI)(void *pval, const void *val);

    void (*SubI)(void *pval, const void *val);

    void (*MulI)(void *pval, const void *val);

    void (*DivI)(void *pval, const void *val);

    void (*ModI)(void *pval, const void *val);

    void (*AndI)(void *pval, const void *val);

    void (*OrI)(void *pval, const void *val);

    void (*XorI)(void *pval, const void *val);

    void (*EqI)(void *pval, const void *val);

    void (*NeI)(void *pval, const void *val);

    void (*GtI)(void *pval, const void *val);

    void (*LtI)(void *pval, const void *val);

    void (*GtEqI)(void *pval, const void *val);

    void (*LtEqI)(void *pval, const void *val);

    void (*RrI)(void *pval, const void *val);

    void (*LrI)(void *pval, const void *val);
} hspvar_proc_t;

extern hspvar_proc_t *hspvar_proc;
extern int hspvar_type_max;

typedef void (*HSPVAR_COREFUNC)(hspvar_proc_t *);

extern value_t *mem_pval;

#define HspVarCoreGetPVal(flag) (&mem_pval[flag])


//	flex value define
//
#define FLEXVAL_TYPE_NONE 0
#define FLEXVAL_TYPE_ALLOC 1
#define FLEXVAL_TYPE_CLONE 2

typedef struct {
    short type;            // typeID
    short myid;            // 固有ID(未使用)
    short customid;        // structure ID
    short clonetype;    // typeID for clone
    int size;            // data size
    void *ptr;            // data ptr
} flex_value_t;

#endif /* hsp3struct_var_h */
