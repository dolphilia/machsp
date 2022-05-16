//
//  utility.c
//  hsedle
//
//  Created by dolphilia on 2022/04/18.
//  Copyright © 2022 dolphilia. All rights reserved.
//

#include "utility.h"

//---
// 内部関数サポート（Windows APIを使用しない）
//---

/// Linux用ファイルパス切り出し
///
static void _splitpath(const char *path, char *p_drive, char *dir, char *fname, char *ext) {
    char *p, pathtmp[256];
    
    p_drive[0] = 0;
    strcpy(pathtmp, path);
    
    p = strchr2(pathtmp, '.');
    if (p == NULL) {
        ext[0] = 0;
    } else {
        strcpy(ext, p);
        *p = 0;
    }
    p = strchr2(pathtmp, '/');
    if (p == NULL) {
        dir[0] = 0;
        strcpy(fname, pathtmp);
    } else {
        strcpy(fname, p + 1);
        p[1] = 0;
        strcpy(dir, pathtmp);
    }
}

/// textに対してワイルドカード処理を適応
///
/// @param test
/// @param wc
///
/// @return yes 1, no 0
///
static int wildcard(char *text, char *wc) {
    if (wc[0] == '\0' && *text == '\0') {
        return 1;
    }
    if (wc[0] == '*') {
        if (*text == '\0' && wc[1] == '\0') {
            return 1;
        } else if (*text == '\0') {
            return 0;
        }
        if (wc[1] == *text | wc[1] == '*' ) {
            if (wildcard(text, wc + 1)) {
                return 1;
            }
        }
        if (*text != '\0') {
            return wildcard(text + 1, wc);
        }
    }
    if ((*text != '\0') && (wc[0] == *text)) {
        return wildcard(text + 1, wc + 1);
    }
    return 0;
}


/// 基本的なC入出力のサポート
///
char *mem_ini(int size) {
    return (char *)calloc(size, 1);
}

void mem_bye(void *ptr) {
    free(ptr);
}

int mem_load(const char *fname, void *mem, int msize) {
    FILE *fp = fopen(fname, "rb");
    if (fp == NULL)
        return -1;
    int flen = (int)fread(mem, 1, msize, fp);
    fclose(fp);
    return flen;
}

int mem_save(const char *fname, const void *mem, int msize, int seekofs) {
    FILE *fp;
    int flen;
    if (seekofs < 0) {
        fp = fopen(fname, "wb");
    }
    else {
        fp = fopen(fname, "r+b");
    }
    if (fp == NULL)
        return -1;
    if (seekofs >= 0 )
        fseek(fp, seekofs, SEEK_SET);
    flen = (int)fwrite(mem, 1, msize, fp);
    fclose(fp);
    return flen;
}

/// 文字列の大文字と小文字を区別する
///
void strcase(char *str) {
    unsigned char cur_char;
    unsigned char *ptr = (unsigned char *)str;
    while(1) {
        cur_char = *ptr;
        if (cur_char == 0)
            break;
        if (cur_char >= 0x80) {
            *ptr += 1;
            cur_char = *ptr;
            *ptr += 1;
            if (cur_char == 0)
                break;
        }
        else {
            *ptr = tolower(cur_char);
            *ptr += 1;
        }
    }
}

/// 文字列の大文字と小文字をコピーする
///
void strcase2(char *str, char *str2) {
    unsigned char cur_char;
    unsigned char *ss = (unsigned char *)str;
    unsigned char *ss2 = (unsigned char *)str2;
    while(1) {
        cur_char = *ss;
        if (cur_char == 0)
            break;
        if (cur_char >= 0x80) {
            *ss++;
            *ss2++ = cur_char;
            cur_char = *ss++;
            if (cur_char == 0)
                break;
            *ss2++ = cur_char;
        }
        else {
            cur_char = tolower(cur_char);
            *ss++ = cur_char;
            *ss2++ = cur_char;
        }
    }
    *ss2 = 0;
}

/// 文字列を比較する
///
/// @return 0 = 同じではない / -1 = 同じ
///
int tstrcmp(const char *str1, const char *str2) {
    int i = 0;
    while(1) {
        if (str1[i] != str2[i])
            return 0;
        if (str1[i] == 0)
            break;
        i++;
    }
    return -1;
}

/// getpathの解説
///
void getpath(const char *src, char *outbuf, int p2) {
    char *p = outbuf;
    char stmp[_MAX_PATH];
    char p_drive[_MAX_PATH];
    char p_dir[_MAX_DIR];
    char p_fname[_MAX_FNAME];
    char p_ext[_MAX_EXT];
    strcpy(stmp, src);
    if (p2 & 16)
        strcase(stmp);
    _splitpath(stmp, p_drive, p_dir, p_fname, p_ext);
    strcat(p_drive, p_dir);
    if (p2 & 8) {
        strcpy(stmp, p_fname);
        strcat(stmp, p_ext);
    } else if (p2 & 32) {
        strcpy(stmp, p_drive);
    }
    switch(p2 & 7) {
        case 1:            // Name only ( without ext )
            stmp[strlen(stmp) - strlen(p_ext)] = 0;
            strcpy(p, stmp);
            break;
        case 2:            // Ext only
            strcpy(p, p_ext);
            break;
        default:        // Direct Copy
            strcpy(p, stmp);
            break;
    }
}

/// strcpy2の解説
///
void strcpy2(char *dest, const char *src, size_t size) {
    if (size == 0) {
        return;
    }
    char *d = dest;
    const char *s = src;
    size_t n = size;
    while (--n) {
        if((*d++ = *s++) == '\0') {
            return;
        }
    }
    *d = '\0';
    return;
}

/// ファイル名に拡張子を追加する
///
void addext(char *str, const char *exstr) {
    int i = 0;
    while(1) {
        if (str[i] == 0)
            break;
        if (str[i] == '.')
            return;
        i++;
    }
    str[i] = '.';
    str[i + 1] = 0;
    strcat(str, exstr);
}

/// ファイル名の拡張子を削除する
///
void cutext(char *str) {
    int i = 0;
    while(1) {
        if (str[i] == 0)
            break;
        if (str[i] == '.')
            break;
        i++;
    }
    str[i] = 0;
}

/// 末尾の文字を削除する
///
void cutlast(char *str) {
    unsigned char cur_char;
    int i = 0;
    while(1) {
        cur_char = str[i];
        if (cur_char < 33)
            break;
        str[i] = tolower(cur_char);
        i++;
    }
    str[i] = 0;
}

/// 末尾の文字を削除する
///
void cutlast2(char *str) {
    int i = 0;
    char cur_char;
    char tmp[256];
    strcpy(tmp, str);
    while(1) {
        cur_char = tmp[i];
        if (cur_char < 33)
            break;
        tmp[i] = tolower(cur_char);
        i++;
    }
    tmp[i] = 0;
    while(1) {
        i--;
        cur_char = tmp[i];
        if (cur_char == 0x5c) {
            i++;
            break;
        }
        if (i == 0)
            break;
    }
    strcpy(str, tmp + i);
}

/// str中最後のcode位置を探す(全角対応版)
///
char *strchr2(char *target, char code) {
    unsigned char *ptr = (unsigned char *)target;
    unsigned char cur_char;
    char *ret = NULL;
    while(1) {
        cur_char = *ptr;
        if (cur_char == 0)
            break;
        if (cur_char == code)
            ret = (char *)ptr;
        ptr++;                            // 検索位置を移動
        if (cur_char >= 129) {                    // 全角文字チェック
            if ((cur_char <= 159) || (cur_char >= 224))
                ptr++;
        }
    }
    return ret;
}

/// Shift_JIS文字列のposバイト目が文字の先頭バイトであるか
/// マルチバイト文字の後続バイトなら0、それ以外なら1を返す
///
int is_sjis_char_head(const unsigned char *str, int pos) {
    int ret = 1;
    while(pos != 0 && issjisleadbyte(str[--pos])) {
        ret = !ret;
    }
    return ret;
}

/// 文字列をHSPの文字列リテラル形式に
/// 戻り値のメモリは呼び出し側がfreeする必要がある。
/// HSPの文字列リテラルで表せない文字は
/// そのまま出力されるので注意。（'¥n'など）
///
char *to_hsp_string_literal(const char *src) {
    size_t length = 2;
    const unsigned char *s = (unsigned char *)src;
    while(1) {
        unsigned char cur_char = *s;
        if (cur_char == '\0')
            break;
        switch (cur_char) {
            case '\r':
                if (*(s + 1) == '\n') {
                    s++;
                }
                // FALL THROUGH
            case '\t':
            case '"':
            case '\\':
                length += 2;
                break;
            default:
                length ++;
        }
        if (issjisleadbyte(cur_char) && *(s + 1) != '\0') {
            length ++;
            s += 2;
        } else {
            s ++;
        }
    }
    char *dest = (char *)malloc(length + 1);
    if (dest == NULL)
        return dest;
    s = (unsigned char *)src;
    unsigned char *d = (unsigned char *)dest;
    *d++ = '"';
    while(1) {
        unsigned char cur_char = *s;
        if (cur_char == '\0')
            break;
        switch (cur_char) {
            case '\t':
                *d++ = '\\';
                *d++ = 't';
                break;
            case '\r':
                *d++ = '\\';
                if (*(s + 1) == '\n') {
                    *d++ = 'n';
                    s ++;
                } else {
                    *d++ = 'r';
                }
                break;
            case '"':
                *d++ = '\\';
                *d++ = '"';
                break;
            case '\\':
                *d++ = '\\';
                *d++ = '\\';
                break;
            default:
                *d++ = cur_char;
                if(issjisleadbyte(cur_char) && *(s + 1) != '\0') {
                    *d++ = *++s;
                }
        }
        s++;
    }
    *d++ = '"';
    *d = '\0';
    return dest;
}

/// オーバーフローチェックをしないatoi
///
int atoi_allow_overflow(const char *s) {
    int ret = 0;
    while (isdigit(*s)) {
        ret = ret * 10 + (*s - '0');
        s++;
    }
    return ret;
}

/// 最後の'/'を取り除く
///
void CutLastChr(char *p, char code) {
    char *ss = strchr2(p, '/');
    char *ss2;
    int i;
    if (ss != NULL) {
        i = (int)strlen(p);
        ss2 = p + i - 1;
        if ((i > 3) && (ss == ss2))
            *ss = 0;
    }
}

//----------------------------------------------------------
// 文字列をトリミングするためのサポート
//----------------------------------------------------------

/// 文字列中のcode位置を探す(2バイトコード、全角対応版)
/// sw = 0 : findptr = 最後に見つかったcode位置
/// sw = 1 : findptr = 最初に見つかったcode位置
/// sw = 2 : findptr = 最初に見つかったcode位置(最初の文字のみ検索)
/// 戻り値 : 次の文字にあたる位置
///
char *strchr3(char *target, int code, int sw, char **findptr) {
    unsigned char *p = (unsigned char *)target;
    unsigned char cur_char;
    unsigned char code1 = (unsigned char)(code&0xff);
    unsigned char code2 = (unsigned char)(code>>8);
    char *res = NULL;
    char *pres = NULL;
    *findptr = NULL;
    while(1) {
        cur_char = *p;
        if (cur_char == 0)
            break;
        if (cur_char == code1) {
            if (cur_char < 129) {
                res = (char *)p;
            } else {
                if ((cur_char <= 159) || (cur_char >= 224)) {
                    if (p[1] == code2) {
                        res = (char *)p;
                    }
                } else {
                    res = (char *)p;
                }
            }
        }
        p++;                            // 検索位置を移動
        if (cur_char >= 129) {                    // 全角文字チェック
            if ((cur_char <= 159) || (cur_char >= 224))
                p++;
        }
        if (res != NULL) {
            *findptr = res;
            pres = (char *)p;
            res = NULL;
        }
        switch( sw ) {
            case 1:
                if (*findptr != NULL)
                    return (char *)p;
                break;
            case 2:
                return (char *)p;
        }
    }
    return pres;
}

/// 最後のcodeを取り除く
///
void TrimCodeR(char *p, int code) {
    char *ss;
    char *ss2;
    char *sslast;
    int i;
    while(1) {
        i = (int)strlen(p);
        sslast = p + i;
        ss = strchr3(p, code, 0, &ss2);
        if (ss2 == NULL )
            break;
        if (ss != sslast )
            break;
        *ss2 = 0;
    }
}

/// すべてのcodeを取り除く
///
void TrimCode(char *p, int code) {
    char *ss;
    char *ss2;
    while(1) {
        ss = strchr3(p, code, 1, &ss2);
        if (ss2 == NULL)
            break;
        strcpy(ss2, ss);
    }
}

/// 最初のcodeを取り除く
///
void TrimCodeL(char *p, int code) {
    char *ss;
    char *ss2;
    while(1) {
        ss = strchr3(p, code, 2, &ss2);
        if (ss2 == NULL)
            break;
        strcpy(ss2, ss);
    }
}

//----------------------------------------------------------
// システムサポート
//----------------------------------------------------------

/// dirinfo命令の内容をstmpに設定する
///
void dirinfo(char *p, int id) {
    switch(id) {
        case 0:                //    カレント(現在の)ディレクトリ
        case 1:                //    実行ファイルがあるディレクトリ
            getcwd(p, _MAX_PATH);
            break;
        case 2:                //    Windowsディレクトリ
        case 3:                //    Windowsのシステムディレクトリ
        default:
            *p = 0;
            return;
    }
    //        最後の'/'を取り除く
    //
    CutLastChr( p, '/' );
}

//----------------------------------------------------------

/// メモリーマネージャー
///
char *mem_alloc(void *base, int newsize, int oldsize) {
    char *p;
    if (base == NULL) {
        p = (char *)calloc( newsize, 1 );
        return p;
    }
    if (newsize <= oldsize)
        return (char *)base;
    p = (char *)calloc(newsize, 1);
    memcpy(p, base, oldsize);
    free(base);
    return p;
}

int issjisleadbyte( unsigned char c ) {
    return ( c >= 0x81 && c <= 0x9F ) || ( c >= 0xE0 && c <= 0xFC );
}

void ExecFile( char *stmp, char *ps, int mode ) {
    
}

void Alert( const char *mes ) {
    
}

void AlertV( const char *mes, int val ) {
    
}

void Alertf( const char *format, ... ) {
    
}
