
//
//	label.cpp structures
//
#ifndef __label_h
#define __label_h

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include <string> // c++
#include <map> // c++
#include <set> // c++

#define    maxname    256                // ラベル名の最大値
#define def_maxsymbol 0x10000    // シンボルテーブルのサイズ（デフォルト）
#define def_maxblock 128        // シンボルテーブルブロックの最大値（デフォルト）
#define def_maxlab 4096            // ラベルオブジェクトの最大値（デフォルト）

#define LAB_TYPE_MARK 0
#define LAB_TYPE_SYSVAL 7
#define LAB_TYPE_INTCMD 8
#define LAB_TYPE_EXTCMD 9
#define LAB_TYPE_IF 11

#define LAB_TYPE_PPVAL 0x110
#define LAB_TYPE_PPMAC 0x111
#define LAB_TYPE_PPMODFUNC 0x112
#define LAB_TYPE_PPDLLFUNC 0x113
#define LAB_TYPE_PPINTMAC 0x114
#define LAB_TYPE_PPEX_INTCMD 0x115
#define LAB_TYPE_PPEX_EXTCMD 0x116
#define LAB_TYPE_PPEX_PRECMD 0x117
#define LAB_TYPE_COMVAR 0x200
#define LAB_TYPE_PP_PREMODFUNC 0x212

#define LAB_DUMPMODE_RESCMD 3
#define LAB_DUMPMODE_DLLCMD 4
#define LAB_DUMPMODE_ALL 15

#define PRM_MASK 0xfff
#define PRM_FLAG_CTYPE 0x1000

#define LAB_INIT_NO 0
#define LAB_INIT_DONE 1

#define LAB_TYPEFIX_NONE 0
#define LAB_TYPEFIX_INT 4
#define LAB_TYPEFIX_DOUBLE 3

typedef std::set<std::string> FileNameSet; /// @warning cpp
typedef std::multimap<std::string, int> LabelMap; /// @warning cpp
typedef struct LABREL LABREL;

struct LABREL {
    LABREL *link;                // 次へのリンク (NULL=終了)
    int rel_id;                // 関連ID
};

typedef struct LABOBJ {
    int flag;                // 存在フラグ
    int type;                // オブジェクトタイプ
    int opt;                // オプションコード
    short eternal;            // エターナルフラグ
    short ref;                // 参照フラグ
    int hash;                // ハッシュコード
    char *name;                // オブジェクト名（小文字）
    char *data;                // データフィールド
    char *data2;                // データフィールド（オプション）
    LABREL *rel;                // 関係ID
    short init;                // 初期化フラグ
    short typefix;            // フォースタイプ

    char const *def_file;
    int def_line;
} LABOBJ;

//  ラベルマネージャクラス
class CLabel {
public:
    CLabel();

    CLabel(int symmax, int worksize);

    ~CLabel();

    void Reset(void);

    int Regist(char *name, int type, int opt);

    int Regist(char *name, int type, int opt, char const *filename, int line);

    void SetEternal(int id);

    int GetEternal(int id);

    void SetOpt(int id, int val);

    void SetFlag(int id, int val);

    void SetData(int id, char *str);

    void SetData2(int id, char *str, int size);

    void SetInitFlag(int id, int val);

    void SetForceType(int id, int val);

    int Search(char *oname);

    int SearchLocal(char *oname, char *loname);

    int GetCount(void);

    int GetFlag(int id);

    int GetType(int id);

    int GetOpt(int id);

    int GetSymbolSize(void);

    char *GetName(int id);

    char *GetData(int id);

    char *GetData2(int id);

    int GetInitFlag(int id);

    LABOBJ *GetLabel(int id);

    void DumpLabel(char *str);

    void DumpHSPLabel(char *str, int option, int maxsize);

    int RegistList(char **list, char *modname);

    int RegistList2(char **list, char *modname);

    int RegistList3(char **list);

    int GetNumEntry(void) {
        return cur;
    };

    void AddReference(int id);

    int GetReference(int id);

    void AddRelation(int id, int rel_id);

    void AddRelation(char *name, int rel_id);

    int SearchRelation(int id, int rel_id);

    void SetCaseMode(int flag);

    void SetDefinition(int id, char const *filename, int line);

private:
    int StrCase(char *str);

    int StrCmp(char *str1, char *str2);

    int GetHash(char *str);

    char *Prt(char *str, char *str2);

    int HtoI(void);

    char *GetListToken(char *str);

    char *ExpandSymbolBuffer(int size);

    void DisposeSymbolBuffer(void);

    void MakeSymbolBuffer(void);

    char *RegistSymbol(char *str);

    char *RegistTable(char *str, int size);

    //	data
    char *symbol;                        // シンボルテーブル
    LABOBJ *mem_lab;                    // ラベルオブジェクト

    char *symblock[def_maxblock];        // シンボルテーブルブロック
    int curblock;                        // 現在のブロック

    int cur;                            // 現在
    int symcur;                            // 現在のシンボルインデックス
    int maxsymbol;                        // 最大シンボルサイズ
    int maxlab;                            // 最大ラベルサイズ
    char token[64];                        // レジストリスト用トークン
    int casemode;                        // 大文字・小文字を区別する（0=なし/その他=ON）

    LabelMap labels;                    // ルックアップテーブル
    FileNameSet filenames;                /// @warning cpp ファイル名のプール (def_fileから指定)


    //typedef struct _string_t {
    //    int str;
    //} _string_t;
    //typedef char* string;

    //typedef char* _string;
    //typedef size_t str_size;
    //struct _string_t* zzz;
    //string* FileNameSet;
};

#endif
