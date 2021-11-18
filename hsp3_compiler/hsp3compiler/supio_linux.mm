//@
//
//	supio.cpp functions (for Linux)
//	Linux用のsupio.cppを別ファイルとして作成しました。
//
//	Special thanks to Charlotte at HSP開発wiki
//	http://hspdev-wiki.net/?OpenHSP%2FLinux%2Fhsp3
//
//
#import <stdio.h>
#import <stdlib.h>
#import <string.h>
#import <stdarg.h>
#import <ctype.h>// gettime
#import <sys/time.h>
#import <time.h>
// mkdir stat
#import <sys/stat.h>
#import <sys/types.h>
// changedir delfile get_current_dir_name stat
#import <unistd.h>
// dirlist
#import <dirent.h>
#import "supio_linux.h"
#ifndef _MAX_PATH
#define _MAX_PATH	256
#endif
#ifndef _MAX_DIR
#define _MAX_DIR	256
#endif
#ifndef _MAX_EXT
#define _MAX_EXT	256
#endif
#ifndef _MAX_FNAME
#define _MAX_FNAME	256
#endif
//
//		Internal function support (without Windows API)
//

///        Linux用ファイルパス切り出し
///
static void _splitpath(const char *path, char *p_drive, char *dir, char *fname, char *ext) {
    char *p;
    char pathtmp[256];
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
    if ( p == NULL ) {
        dir[0] = 0;
        strcpy(fname, pathtmp);
    } else {
        strcpy(fname, p + 1);
        p[1] = 0;
        strcpy(dir, pathtmp);
    }
}

///        textに対してワイルドカード処理を適応
///        return value: yes 1, no 0
///
static int wildcard( char *text, char *wc ) {
    if (wc[0] == '\0' && *text == '\0') {
        return 1;
    }
    if (wc[0] == '*') {
        if (*text == '\0' && wc[1] == '\0') {
            return 1;
        } else if (*text == '\0') {
            return 0;
        }
        if (wc[1] == *text | wc[1] == '*') {
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

//
//		basic C I/O support
//

char *mem_ini(int size) {
    return (char *)calloc(size, 1);
}

void mem_bye(void *ptr) {
    free(ptr);
}

int mem_load(const char *file_name, void *mem, int mem_size) {
    FILE *fp;
    int file_size;
    fp = fopen(file_name, "rb");
    if (fp == NULL) //ファイルが存在しない場合
        return -1;
    file_size = (int)fread(mem, 1, mem_size, fp);
    fclose(fp);
    return file_size;
}

/// Description
///
/// @param fname <#fname description#>
/// @param mem <#mem description#>
/// @param msize <#msize description#>
/// @param seekofs <#seekofs description#>
int mem_save(const char *fname, const void *mem, int msize, int seekofs) {
    FILE *fp;
    int size;
    if (seekofs<0) {
        fp=fopen(fname,"wb");
    }
    else {
        fp=fopen(fname,"r+b");
    }
    if (fp==NULL)
        return -1;
    if ( seekofs>=0 )
        fseek( fp, seekofs, SEEK_SET );
    size = (int)fwrite( mem, 1, msize, fp );
    fclose(fp);
    return size;
}

///    string case to lower
///
void strcase(char *str) {
    unsigned char *buf = (unsigned char *)str;
    unsigned char tmp;
    while(1) {
        tmp = *buf;
        if (tmp == 0)
            break;
        if (tmp >= 0x80) {
            *buf++;
            tmp = *buf++;
            if (tmp == 0)
                break;
        }
        else {
            *buf++ = tolower(tmp);
        }
    }
}

///    string case to lower and copy
///
void strcase2(char *str, char *str2) {
    unsigned char *buf1 = (unsigned char *)str;
    unsigned char *buf2 = (unsigned char *)str2;
    unsigned char tmp;
    while(1) {
        tmp = *buf1;
        if (tmp == 0)
            break;
        if (tmp >= 0x80) {
            *buf1++;
            *buf2++ = tmp;
            tmp = *buf1++;
            if (tmp == 0)
                break;
            *buf2++ = tmp;
        }
        else {
            tmp = tolower(tmp);
            *buf1++ = tmp;
            *buf2++ = tmp;
        }
    }
    *buf2 = 0;
}

///    string compare (0=not same/-1=same)
///
int tstrcmp(const char *str1, const char *str2) {
    int index = 0;
    char tmp;
    while(1) {
        tmp = str1[index];
        if (tmp != str2[index])
            return 0;
        if (tmp == 0)
            break;
        index++;
    }
    return -1;
}

void getpath( const char *src, char *outbuf, int p2 ) {
    char *p;
    char stmp[_MAX_PATH];
    char p_drive[_MAX_PATH];
    char p_dir[_MAX_DIR];
    char p_fname[_MAX_FNAME];
    char p_ext[_MAX_EXT];
    p = outbuf;
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
        case 1:			// Name only ( without ext )
            stmp[strlen(stmp) - strlen(p_ext)] = 0;
            strcpy(p, stmp);
            break;
        case 2:			// Ext only
            strcpy(p, p_ext);
            break;
        default:		// Direct Copy
            strcpy(p, stmp);
            break;
    }
}

void strcpy2( char *dest, const char *src, size_t size ) {
    char *d = dest;
    const char *s = src;
    size_t n = size;
    if(size == 0) {
        return;
    }
    while (--n) {
        if((*d++ = *s++) == '\0') {
            return;
        }
    }
    *d = '\0';
    return;
}

/*----------------------------------------------------------*/
///    add extension of filename
/// ファイル名に拡張子を追加する
/// @param st <#st description#>
/// @param exstr <#exstr description#>
void addext(char *st, const char *exstr) {
    int index = 0;
    char tmp;
    while(1) {
        tmp = st[index];
        if (tmp == 0)
            break;
        if (tmp == '.')
            return;
        index++;
    }
    st[index] = '.';
    st[index + 1] = 0;
    strcat(st, exstr);
}

/// ファイルの拡張子を削除する
///    cut extension of filename
void cutext(char *str) {
    int index = 0;
    char tmp;
    while(1) {
        tmp = str[index];
        if (tmp == 0)
            break;
        if (tmp == '.')
            break;
        index++;
    }
    str[index] = 0;
}

/// 文字列の末尾の文字を削除する
///    cut last characters
void cutlast(char *str) {
    int index = 0;
    unsigned char tmp;
    while(1) {
        tmp = str[index];
        if (tmp < 33)
            break;
        str[index] = tolower(tmp);
        index++;
    }
    str[index] = 0;
}

/// 文字列の末尾の文字を削除する
///    cut last characters
void cutlast2(char *str) {
    int index = 0;
    char tmp;
    char buf[256];
    strcpy(buf, str);
    while(1) {
        tmp = buf[index];
        if (tmp < 33)
            break;
        buf[index] = tolower(tmp);
        index++;
    }
    buf[index] = 0;
    while(1) {
        index--;
        tmp = buf[index];
        if (tmp == 0x5c) {
            index++;
            break;
        }
        if (index == 0)
            break;
    }
    strcpy(str, buf + index);
}

/// target中最後のcode位置を探す(全角対応版)
/// @param target char* 対象の文字列
/// @param code char 探したい文字
char *strchr2(char *target, char code) {
    unsigned char *ptr;
    unsigned char tmp;
    char *res;
    ptr = (unsigned char*)target;
    res = NULL;
    while(1) {
        tmp = *ptr;
        if (tmp == 0) //文字列の終端
            break;
        if (tmp == code) //マッチした
            res = (char *)ptr;
        ptr++; // 検索位置を移動
        if (tmp >= 129) { // 全角文字チェック
            if ((tmp <= 159) || (tmp >= 224))
                ptr++;
        }
    }
    return res;
}

int issjisleadbyte(unsigned char c) {
    return (c >= 0x81 && c <= 0x9F) || (c >= 0xE0 && c <= 0xFC);
}

/// Shift_JIS文字列のposバイト目が文字の先頭バイトであるか
///
/// 戻り値 int マルチバイト文字の後続バイトなら0、それ以外なら1を返す
/// @param str 文字列(ShiftJIS)
/// @param pos 位置
int is_sjis_char_head(const unsigned char *str, int pos) {
    int result = 1;
    while(pos != 0 && issjisleadbyte(str[--pos])) {
        result = ! result;
    }
    return result;
}

///        文字列をHSPの文字列リテラル形式に
///        戻り値のメモリは呼び出し側がfreeする必要がある。
///        HSPの文字列リテラルで表せない文字は
///        そのまま出力されるので注意。（'¥n'など）
///
char *to_hsp_string_literal( const char *src ) {
    size_t length = 2;
    const unsigned char *s = (unsigned char *)src;
    while (1) {
        unsigned char c = *s;
        if (c == '\0')
            break;
        switch (c) {
            case '\r':
                if (*(s+1) == '\n') {
                    s++;
                }
                // FALL THROUGH
            case '\t':
            case '"':
            case '\\':
                length += 2;
                break;
            default:
                length++;
        }
        if (issjisleadbyte(c) && *(s+1) != '\0') {
            length++;
            s += 2;
        } else {
            s++;
        }
    }
    char *dest = (char *)malloc(length + 1);
    if (dest == NULL)
        return dest;
    s = (unsigned char *)src;
    unsigned char *d = (unsigned char *)dest;
    *d++ = '"';
    while (1) {
        unsigned char c = *s;
        if ( c == '\0' )
            break;
        switch (c) {
            case '\t':
                *d++ = '\\';
                *d++ = 't';
                break;
            case '\r':
                *d++ = '\\';
                if (*(s+1) == '\n') {
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
                *d++ = c;
                if(issjisleadbyte(c) && *(s+1) != '\0') {
                    *d++ = *++s;
                }
        }
        s++;
    }
    *d++ = '"';
    *d = '\0';
    return dest;
}

/// 文字列をint型の数値に変換する
///
/// int n = atoi_allow_overflow("100"); // n == 100
/// @param str 変換する文字列
/// @return 変換後の数値
/// @warning オーバーフローチェックをしないatoi
int atoi_allow_overflow(const char *str) {
    int result = 0;
    while (isdigit(*str)) {
        result = result * 10 + (*str - '0');
        str++;
    }
    return result;
}

/// 末尾の / を取り除く
/// @param p 文字列のポインタ
/// @param code 不要
void CutLastChr(char *p, char code) {
    char *buf1 = strchr2(p, '/');
    char *buf2;
    if (buf1 != NULL) {
        int len = (int)strlen(p);
        buf2 = p + len -1;
        if ((len > 3) && (buf1 == buf2))
            *buf1 = 0;
    }
}

/*----------------------------------------------------------*/
//					HSP string trim support
/*----------------------------------------------------------*/

///        文字列中のcode位置を探す(2バイトコード、全角対応版)
///        sw = 0 : findptr = 最後に見つかったcode位置
///        sw = 1 : findptr = 最初に見つかったcode位置
///        sw = 2 : findptr = 最初に見つかったcode位置(最初の文字のみ検索)
///        戻り値 : 次の文字にあたる位置
///
char *strchr3(char *target, int code, int sw, char **findptr) {
    unsigned char *p;
    unsigned char a1;
    unsigned char code1;
    unsigned char code2;
    char *res;
    char *pres;
    p = (unsigned char *)target;
    code1 = (unsigned char)(code&0xff);
    code2 = (unsigned char)(code>>8);
    res = NULL;
    pres = NULL;
    *findptr = NULL;
    while(1) {
        a1 = *p;
        if (a1 == 0)
            break;
        if (a1 == code1) {
            if (a1 < 129) {
                res = (char *)p;
            } else {
                if ((a1 <= 159) || (a1 >= 224)) {
                    if (p[1] == code2) {
                        res = (char *)p;
                    }
                } else {
                    res = (char *)p;
                }
            }
        }
        p++;							// 検索位置を移動
        if (a1 >= 129) {					// 全角文字チェック
            if ((a1 <= 159)||(a1 >= 224))
                p++;
        }
        if (res != NULL) {
            *findptr = res;
            pres = (char *)p;
            res = NULL;
        }
        switch(sw) {
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
/// @param p <#p description#>
/// @param code <#code description#>
void TrimCodeR( char *p, int code ) {
    char *buf1;
    char *buf2;
    char *last;
    int i;
    while(1) {
        i = (int)strlen(p);
        last = p + i;
        buf1 = strchr3(p, code, 0, &buf2);
        if (buf2 == NULL)
            break;
        if (buf1 != last)
            break;
        *buf2 = 0;
    }
}

/// すべてのcodeを取り除く
/// @param p <#p description#>
/// @param code <#code description#>
void TrimCode(char *p, int code) {
    char *buf1;
    char *buf2;
    while(1) {
        buf1 = strchr3(p, code, 1, &buf2);
        if (buf2 == NULL)
            break;
        strcpy(buf2, buf1);
    }
}

/// 最初のcodeを取り除く
/// @param p <#p description#>
/// @param code <#code description#>
void TrimCodeL( char *p, int code ) {
    char *buf1;
    char *buf2;
    while(1) {
        buf1 = strchr3(p, code, 2, &buf2);
        if (buf2 == NULL)
            break;
        strcpy(buf2, buf1);
    }
}

void dirinfo( char *p, int id ) {
    //		dirinfo命令の内容をstmpに設定する
    //
    switch( id ) {
        case 0:				//    カレント(現在の)ディレクトリ
        case 1:				//    実行ファイルがあるディレクトリ
            getcwd(p, _MAX_PATH);
            break;
        case 2:				//    Windowsディレクトリ
        case 3:				//    Windowsのシステムディレクトリ
        default:
            *p = 0;
            return;
    }
    //		最後の'/'を取り除く
    //
    CutLastChr( p, '/' );
}

char* mem_alloc( void *base, int newsize, int oldsize ) {
    char *p;
    if ( base == NULL ) {
        p = (char *)calloc( newsize, 1 );
        return p;
    }
    if (newsize <= oldsize)
        return (char *)base;
    p = (char*)calloc( newsize, 1 );
    memcpy( p, base, oldsize );
    free( base );
    return p;
}
