//
//	supio.cpp 関数 (for Linux)
//	Linux用のsupio.cppを別ファイルとして作成しました。
//
//	Special thanks to Charlotte at HSP開発wiki
//	http://hspdev-wiki.net/?OpenHSP%2FLinux%2Fhsp3
//

#include "supio_hsp3.h"
#include "debug_message.h"
#include "dpmread.h"
#include "hsp3config.h"
#include "strbuf.h"
#include <ctype.h>
#include <dirent.h> // dirlist
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h> // mkdir stat
#include <sys/time.h> // gettime
#include <sys/types.h>
#include <time.h>
#include <unistd.h> // changedir delfile get_current_dir_name stat

#ifndef _MAX_PATH
#define _MAX_PATH 256
#endif
#ifndef _MAX_DIR
#define _MAX_DIR 256
#endif
#ifndef _MAX_EXT
#define _MAX_EXT 256
#endif
#ifndef _MAX_FNAME
#define _MAX_FNAME 256
#endif

@implementation ViewController (supio_hsp3)

//
//		Internal function support (without Windows API)
//

/// Linux用ファイルパス切り出し
///
static void _splitpath(char* path, char* p_drive, char* dir, char* fname, char* ext) {
    char pathtmp[256];
    p_drive[0] = 0;
    
    strcpy(pathtmp, path);
    
    char* p = strchr2(pathtmp, '.');
    
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
/// return value: yes 1, no 0
///
static int wildcard(char* text, char* wc) {
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

//		basic C I/O support
//
// static FILE *fp;

char* mem_ini(int size) {
    return (char*)calloc(size, 1);
}

void mem_bye(void* ptr) {
    free(ptr);
}

int mem_save(char* fname, void* mem, int msize, int seekofs) {
    FILE* fp;
    
    if (seekofs < 0) {
        fp = fopen(fname, "wb");
    } else {
        fp = fopen(fname, "r+b");
    }
    if (fp == NULL)
        return -1;
    if (seekofs >= 0)
        fseek(fp, seekofs, SEEK_SET);
    
    int flen = (int)fwrite(mem, 1, msize, fp);
    fclose(fp);
    
    return flen;
}

/// strをすべて小文字に(全角対応版)
///
/// 注意! : SJISのみ対応です
///
void strcase(char* target) {
    unsigned char* p = (unsigned char*)target;
    unsigned char cur_char;

    while (1) {
        cur_char = *p;
        if (cur_char == 0)
            break;
        *p = tolower(cur_char);
        p++; // 検索位置を移動
        if (cur_char >= 129) { // 全角文字チェック
            if ((cur_char <= 159) || (cur_char >= 224))
                p++;
        }
    }
}

/// string copy (ret:length)
///
int strcpy2(char* str1, char* str2) {
    char* p = str1;
    char* src = str2;
    char cur_char;
    
    while (1) {
        cur_char = *src++;
        if (cur_char == 0)
            break;
        *p++ = cur_char;
    }
    *p++ = 0;
    return (int)(p - str1);
}

/// string cat (ret:length)
///
int strcat2(char* str1, char* str2) {
    char* src = str1;
    char cur_char;

    while (1) {
        cur_char = *src;
        if (cur_char == 0)
            break;
        src++;
    }
    int i = (int)(src - str1);
    return (strcpy2(src, str2) + i);
}

/// strstr関数の全角対応版
///
/// 注意! : SJISのみ対応です
///
char* strstr2(char* target, char* src) {
    unsigned char* p = (unsigned char*)target;
    unsigned char* s;
    unsigned char* p2;
    unsigned char cur_char;
    unsigned char a2;
    unsigned char a3;

    if ((*src == 0) || (*target == 0))
        return NULL;
    while (1) {
        cur_char = *p;
        if (cur_char == 0)
            break;
        p2 = p;
        s = (unsigned char*)src;
        while (1) {
            a2 = *s++;
            if (a2 == 0)
                return (char*)p;
            a3 = *p2++;
            if (a3 == 0)
                break;
            if (a2 != a3)
                break;
        }
        p++; // 検索位置を移動
        if (cur_char >= 129) { // 全角文字チェック
            if ((cur_char <= 159) || (cur_char >= 224))
                p++;
        }
    }
    return NULL;
}

char* strchr2(char* target, char code) {
    unsigned char* p = (unsigned char*)target;
    unsigned char cur_char;
    char* ret = NULL;

    while (1) {
        cur_char = *p;
        if (cur_char == 0)
            break;
        if (cur_char == code)
            ret = (char*)p;
        p++;             // 検索位置を移動
        if (cur_char >= 129) { // 全角文字チェック
            if ((cur_char <= 159) || (cur_char >= 224))
                p++;
        }
    }
    return ret;
}

void getpath(char* stmp, char* outbuf, int p2) {
    char* p = outbuf;
    char tmp[_MAX_PATH];
    char p_drive[_MAX_PATH];
    char p_dir[_MAX_DIR];
    char p_fname[_MAX_FNAME];
    char p_ext[_MAX_EXT];
    
    if (p2 & 16)
        strcase(stmp);
    _splitpath(stmp, p_drive, p_dir, p_fname, p_ext);
    
    strcat(p_drive, p_dir);
    if (p2 & 8) {
        strcpy(tmp, p_fname);
        strcat(tmp, p_ext);
    } else if (p2 & 32) {
        strcpy(tmp, p_drive);
    } else {
        strcpy(tmp, stmp);
    }
    switch (p2 & 7) {
        case 1: // Name only ( without ext )
            stmp[strlen(tmp) - strlen(p_ext)] = 0;
            strcpy(p, tmp);
            break;
        case 2: // Ext only
            strcpy(p, p_ext);
            break;
        default: // Direct Copy
            strcpy(p, tmp);
            break;
    }
}

int makedir(char* name) {
    return mkdir(name, 0755);
}

int changedir(char* name) {
    return chdir(name);
}

int delfile(char* name) {
    return unlink(name);
    // return remove( name );		// ディレクトリにもファイルにも対応
}

/// Linux System
///
int dirlist(char* fname, char** target, int p3) {
    enum {
        MASK = 3
    }; // mode 3までのビット反転用
    
    char* p;
    unsigned int fl;
    unsigned int stat_main;
    unsigned int fmask;
    DIR* sh;
    struct dirent* fd;
    struct stat st;
    char curdir[_MAX_PATH + 1];
    
    stat_main = 0;
    
    // sh = opendir( get_current_dir_name() );
    getcwd(curdir, _MAX_PATH);
    sh = opendir(curdir); // get_current_dir_nameはMinGWで通らなかったのでとりあえず
    fd = readdir(sh);
    
    while (fd != NULL) {
        p = fd->d_name;
        fl = 1;
        if (*p == 0)
            fl = 0;        // 空行を除外
        if (*p == '.') { // '.','..'を除外
            if (p[1] == 0)
                fl = 0;
            if ((p[1] == '.') && (p[2] == 0))
                fl = 0;
        }
        //		表示/非表示のマスク
        //		Linux用なのでシステム属性は考慮しない
        if (p3 != 0 && fl == 1) {
            stat(p, &st);
            fmask = 0;
            if (p3 & 4) { // 条件反転
                if (S_ISREG(st.st_mode) && (*p != '.')) {
                    fl = 0;
                } else {
                    fmask = MASK;
                }
            }
            if (fl == 1) {
                if ((p3 ^ fmask) & 1 && S_ISDIR(st.st_mode))
                    fl = 0; //ディレクトリ
                if ((p3 ^ fmask) & 2 && (*p == '.'))
                    fl = 0; //隠しファイル
            }
        }
        //		ワイルドカード処理
        //
        if (fl) {
            fl = wildcard(p, fname);
        }
        
        if (fl) {
            stat_main++;
            sbStrAdd(target, p);
            sbStrAdd(target, (char*)"\n");
        }
        fd = readdir(sh);
    }
    closedir(sh);
    return stat_main;
}


/// Get system time entries
///
/// index :
/// 0 wYear
/// 1 wMonth
/// 2 wDayOfWeek
/// 3 wDay
/// 4 wHour
/// 5 wMinute
/// 6 wSecond
/// 7 wMilliseconds
/// 8 wMicroseconds

int gettime(int index) {
    struct timeval tv;
    struct tm* lt;
    
    gettimeofday(&tv, NULL); // MinGWだとVerによって通りません
    lt = localtime(&tv.tv_sec);
    
    switch (index) {
        case 0:
            return lt->tm_year + 1900;
        case 1:
            return lt->tm_mon + 1;
        case 2:
            return lt->tm_wday;
        case 3:
            return lt->tm_mday;
        case 4:
            return lt->tm_hour;
        case 5:
            return lt->tm_min;
        case 6:
            return lt->tm_sec;
        case 7:
            return (int)tv.tv_usec / 10000;
        case 8:
            /*	一応マイクロ秒まで取れる	*/
            return (int)tv.tv_usec % 10000;
    }
    
    return 0;
}

static int splc; // split pointer

void strsp_ini(void) {
    splc = 0;
}

int strsp_getptr(void) {
    return splc;
}

/// split string with parameters
///
int strsp_get(char* srcstr, char* dststr, char splitchr, int len) {
    char cur_char;
    char a2;
    int a = 0;
    int sjflg = 0;
    
    while (1) {
        sjflg = 0;
        cur_char = srcstr[splc];
        if (cur_char == 0)
            break;
        splc++;
        if ((uint8_t)cur_char >= 0x81)
            if ((uint8_t)cur_char < 0xa0)
                sjflg++;
        if ((uint8_t)cur_char >= 0xe0)
            sjflg++;
        
        if (cur_char == splitchr)
            break;
        if (cur_char == 13) {
            a2 = srcstr[splc];
            if (a2 == 10)
                splc++;
            break;
        }
        dststr[a++] = cur_char;
        if (sjflg) {
            dststr[a++] = srcstr[splc++];
        }
        if (a >= len)
            break;
    }
    dststr[a] = 0;
    return (int)cur_char;
}

/// Skip 1parameter from command line
///
char* strsp_cmds(char* srcstr) {
    int spmode = 0;
    char* cmdchk = srcstr;
    char cur_char;
    
    while (1) {
        cur_char = *cmdchk;
        if (cur_char == 0)
            break;
        cmdchk++;
        if (cur_char == 32)
            if (spmode == 0)
                break;
        if (cur_char == 0x22)
            spmode ^= 1;
    }
    
    return cmdchk;
}

int GetLimit(int num, int min, int max) {
    if (num > max)
        return max;
    if (num < min)
        return min;
    return num;
}

/// 最後の'\\'を取り除く
///
void CutLastChr(char* p, char code) {
    char* ss = strchr2(p, '\\');
    char* ss2;

    if (ss != NULL) {
        int i = (int)strlen(p);
        ss2 = p + i - 1;
        if ((i > 3) && (ss == ss2))
            *ss = 0;
    }
}

/// exchange hex to int
///
static int htoi_sub(char hstr) {
    char cur_char = tolower(hstr);
    if ((cur_char >= '0') && (cur_char <= '9'))
        return cur_char - '0';
    if ((cur_char >= 'a') && (cur_char <= 'f'))
        return cur_char - 'a' + 10;
    return 0;
}

int htoi(char* str) {
    int d = 0;
    int conv = 0;
    char cur_char;
    while (1) {
        cur_char = str[d++];
        if (cur_char == 0)
            break;
        conv = (conv << 4) + htoi_sub(cur_char);
    }
    return conv;
}

//----------------------------------------------------------
//					HSP string trim support
//----------------------------------------------------------

/// 文字列中のcode位置を探す(2バイトコード、全角対応版)
///
/// sw = 0 : findptr = 最後に見つかったcode位置
/// sw = 1 : findptr = 最初に見つかったcode位置
/// sw = 2 : findptr = 最初に見つかったcode位置(最初の文字のみ検索)
/// 戻り値 : 次の文字にあたる位置
///
char* strchr3(char* target, int code, int sw, char** findptr) {
    unsigned char* p = (unsigned char*)target;
    unsigned char code1 = (unsigned char)(code & 0xff);
    unsigned char code2 = (unsigned char)(code >> 8);
    unsigned char cur_char;
    char* res = NULL;
    char* pres = NULL;
    *findptr = NULL;
    
    while (1) {
        cur_char = *p;
        if (cur_char == 0)
            break;
        if (cur_char == code1) {
            if (cur_char < 129) {
                res = (char*)p;
            } else {
                if ((cur_char <= 159) || (cur_char >= 224)) {
                    if (p[1] == code2) {
                        res = (char*)p;
                    }
                } else {
                    res = (char*)p;
                }
            }
        }
        p++; // 検索位置を移動
        if (cur_char >= 129) { // 全角文字チェック
            if ((cur_char <= 159) || (cur_char >= 224))
                p++;
        }
        if (res != NULL) {
            *findptr = res;
            pres = (char*)p;
            res = NULL;
        }
        
        switch (sw) {
            case 1:
                if (*findptr != NULL)
                    return (char*)p;
                break;
            case 2:
                return (char*)p;
        }
    }
    
    return pres;
}

/// 最後のcodeを取り除く
///
void TrimCodeR(char* p, int code) {
    char* ss;
    char* ss2;
    char* sslast;
    int i;
    while (1) {
        i = (int)strlen(p);
        sslast = p + i;
        ss = strchr3(p, code, 0, &ss2);
        if (ss2 == NULL)
            break;
        if (ss != sslast)
            break;
        *ss2 = 0;
    }
}

/// すべてのcodeを取り除く
///
void TrimCode(char* p, int code) {
    char* ss;
    char* ss2;
    while (1) {
        ss = strchr3(p, code, 1, &ss2);
        if (ss2 == NULL)
            break;
        strcpy(ss2, ss);
    }
}

/// 最初のcodeを取り除く
///
void TrimCodeL(char* p, int code) {
    char* ss;
    char* ss2;
    while (1) {
        ss = strchr3(p, code, 2, &ss2);
        if (ss2 == NULL)
            break;
        strcpy(ss2, ss);
    }
}

@end
