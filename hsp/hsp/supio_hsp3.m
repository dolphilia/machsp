//
//	supio.cpp functions (for Linux)
//	Linux用のsupio.cppを別ファイルとして作成しました。
//
//	Special thanks to Charlotte at HSP開発wiki
//	http://hspdev-wiki.net/?OpenHSP%2FLinux%2Fhsp3
//
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
-(void)_splitpath:(char*)path p_drive:(char*)p_drive dir:(char*)dir fname:(char*)fname ext:(char*)ext {
    
    //		Linux用ファイルパス切り出し
    //
    char* p;
    char pathtmp[256];
    
    p_drive[0] = 0;
    strcpy(pathtmp, path);
    
    p = [self strchr2:pathtmp code:'.'];
    if (p == NULL) {
        ext[0] = 0;
    } else {
        strcpy(ext, p);
        *p = 0;
    }
    p = [self strchr2:pathtmp code:'/'];
    if (p == NULL) {
        dir[0] = 0;
        strcpy(fname, pathtmp);
    } else {
        strcpy(fname, p + 1);
        p[1] = 0;
        strcpy(dir, pathtmp);
    }
    
}

-(int)wildcard:(char*)text wc:(char*)wc {
    
    //		textに対してワイルドカード処理を適応
    //		return value: yes 1, no 0
    //
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
            if ([self wildcard:text wc:wc + 1]) {
                return 1;
            }
        }
        if (*text != '\0') {
            return [self wildcard:text + 1 wc:wc];
        }
    }
    if ((*text != '\0') && (wc[0] == *text)) {
        return [self wildcard:text + 1 wc:wc + 1];
    }
    
    return 0;
}

//
//		basic C I/O support
//
// static FILE *fp;

-(char*)mem_ini:(int)size {
    return (char*)calloc(size, 1);
}

-(void)mem_bye:(void*)ptr {
    free(ptr);
}

-(int)mem_save:(char*)fname mem:(void*)mem msize:(int)msize seekofs:(int)seekofs {
    FILE* fp;
    int flen;
    
    if (seekofs < 0) {
        fp = fopen(fname, "wb");
    } else {
        fp = fopen(fname, "r+b");
    }
    if (fp == NULL)
        return -1;
    if (seekofs >= 0)
        fseek(fp, seekofs, SEEK_SET);
    flen = (int)fwrite(mem, 1, msize, fp);
    fclose(fp);
    
    return flen;
}

-(void)strcase:(char*)target {
    
    //		strをすべて小文字に(全角対応版)
    //		注意! : SJISのみ対応です
    //
    unsigned char* p;
    unsigned char a1;
    p = (unsigned char*)target;
    while (1) {
        a1 = *p;
        if (a1 == 0)
            break;
        *p = tolower(a1);
        p++;             // 検索位置を移動
        if (a1 >= 129) { // 全角文字チェック
            if ((a1 <= 159) || (a1 >= 224))
                p++;
        }
    }
    
}

-(int)strcpy2:(char*)str1 str2:(char*)str2 {
    
    //	string copy (ret:length)
    //
    char* p;
    char* src;
    char a1;
    src = str2;
    p = str1;
    while (1) {
        a1 = *src++;
        if (a1 == 0)
            break;
        *p++ = a1;
    }
    *p++ = 0;
    
    return (int)(p - str1);
}

-(int)strcat2:(char*)str1 str2:(char*)str2 {
    
    //	string cat (ret:length)
    //
    char* src;
    char a1;
    int i;
    src = str1;
    while (1) {
        a1 = *src;
        if (a1 == 0)
            break;
        src++;
    }
    i = (int)(src - str1);
    
    return ([self strcpy2:src str2:str2] + i);
}

-(char*)strstr2:(char*)target src:(char*)src {
    
    //		strstr関数の全角対応版
    //		注意! : SJISのみ対応です
    //
    unsigned char* p;
    unsigned char* s;
    unsigned char* p2;
    unsigned char a1;
    unsigned char a2;
    unsigned char a3;
    p = (unsigned char*)target;
    if ((*src == 0) || (*target == 0))
        return NULL;
    while (1) {
        a1 = *p;
        if (a1 == 0)
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
        p++;             // 検索位置を移動
        if (a1 >= 129) { // 全角文字チェック
            if ((a1 <= 159) || (a1 >= 224))
                p++;
        }
    }
    
    return NULL;
}

-(char*)strchr2:(char*)target code:(char)code {
    
    //		str中最後のcode位置を探す(全角対応版)
    //		注意! : SJISのみ対応です
    //
    unsigned char* p;
    unsigned char a1;
    char* res;
    p = (unsigned char*)target;
    res = NULL;
    while (1) {
        a1 = *p;
        if (a1 == 0)
            break;
        if (a1 == code)
            res = (char*)p;
        p++;             // 検索位置を移動
        if (a1 >= 129) { // 全角文字チェック
            if ((a1 <= 159) || (a1 >= 224))
                p++;
        }
    }
    
    return res;
}

-(void)getpath:(char*)stmp outbuf:(char*)outbuf p2:(int)p2 {
    
    char* p;
    char tmp[_MAX_PATH];
    char p_drive[_MAX_PATH];
    char p_dir[_MAX_DIR];
    char p_fname[_MAX_FNAME];
    char p_ext[_MAX_EXT];
    
    p = outbuf;
    if (p2 & 16)
        [self strcase:stmp];
    [self _splitpath:stmp p_drive:p_drive dir:p_dir fname:p_fname ext:p_ext];
    
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

-(int)makedir:(char*)name {
    return mkdir(name, 0755);
}

-(int)changedir:(char*)name {
    return chdir(name);
}

-(int)delfile:(char*)name {
    return unlink(name);
    // return remove( name );		// ディレクトリにもファイルにも対応
}

-(int)dirlist:(char*)fname target:(char**)target p3:(int)p3 {
    
    //		Linux System
    //
    enum
    {
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
    sh =
    opendir(curdir); // get_current_dir_nameはMinGWで通らなかったのでとりあえず
    
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
            fl = [self wildcard:p wc:fname];
        }
        
        if (fl) {
            stat_main++;
            [self sbStrAdd:target str:p];
            [self sbStrAdd:target str:(char*)"\n"];
        }
        fd = readdir(sh);
    }
    closedir(sh);
    
    return stat_main;
}

-(int)gettime:(int)index {
    
    /*
     Get system time entries
     index :
     0 wYear
     1 wMonth
     2 wDayOfWeek
     3 wDay
     4 wHour
     5 wMinute
     6 wSecond
     7 wMilliseconds
     8 wMicroseconds
     */
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

-(void)strsp_ini {
    splc = 0;
}

-(int)strsp_getptr {
    return splc;
}

-(int)strsp_get:(char*)srcstr dststr:(char*)dststr splitchr:(char)splitchr len:(int)len {
    //		split string with parameters
    //
    char a1;
    char a2;
    int a;
    int sjflg;
    a = 0;
    sjflg = 0;
    while (1) {
        sjflg = 0;
        a1 = srcstr[splc];
        if (a1 == 0)
            break;
        splc++;
        if ((uint8_t)a1 >= 0x81)
            if ((uint8_t)a1 < 0xa0)
                sjflg++;
        if ((uint8_t)a1 >= 0xe0)
            sjflg++;
        
        if (a1 == splitchr)
            break;
        if (a1 == 13) {
            a2 = srcstr[splc];
            if (a2 == 10)
                splc++;
            break;
        }
        dststr[a++] = a1;
        if (sjflg) {
            dststr[a++] = srcstr[splc++];
        }
        if (a >= len)
            break;
    }
    dststr[a] = 0;
    
    return (int)a1;
}

-(char*)strsp_cmds:(char*)srcstr {
    
    //		Skip 1parameter from command line
    //
    int spmode;
    char a1;
    char* cmdchk;
    cmdchk = srcstr;
    spmode = 0;
    while (1) {
        a1 = *cmdchk;
        if (a1 == 0)
            break;
        cmdchk++;
        if (a1 == 32)
            if (spmode == 0)
                break;
        if (a1 == 0x22)
            spmode ^= 1;
    }
    
    return cmdchk;
}

-(int)GetLimit:(int)num min:(int)min max:(int)max {
    if (num > max)
        return max;
    if (num < min)
        return min;
    return num;
}

-(void)CutLastChr:(char*)p code:(char)code {
    
    //		最後の'\\'を取り除く
    //
    char* ss;
    char* ss2;
    int i;
    ss = [self strchr2:p code:'\\'];
    if (ss != NULL) {
        i = (int)strlen(p);
        ss2 = p + i - 1;
        if ((i > 3) && (ss == ss2))
            *ss = 0;
    }
    
}

static int
htoi_sub(char hstr)
{
    
    //	exchange hex to int
    
    char a1;
    a1 = tolower(hstr);
    if ((a1 >= '0') && (a1 <= '9'))
        return a1 - '0';
    if ((a1 >= 'a') && (a1 <= 'f'))
        return a1 - 'a' + 10;
    
    return 0;
}

-(int)htoi:(char*)str {
    
    char a1;
    int d;
    int conv;
    conv = 0;
    d = 0;
    while (1) {
        a1 = str[d++];
        if (a1 == 0)
            break;
        conv = (conv << 4) + htoi_sub(a1);
    }
    
    return conv;
}

/*----------------------------------------------------------*/
//					HSP string trim support
/*----------------------------------------------------------*/

-(char*)strchr3:(char*)target code:(int)code sw:(int)sw findptr:(char**)findptr {
    
    //		文字列中のcode位置を探す(2バイトコード、全角対応版)
    //		sw = 0 : findptr = 最後に見つかったcode位置
    //		sw = 1 : findptr = 最初に見つかったcode位置
    //		sw = 2 : findptr = 最初に見つかったcode位置(最初の文字のみ検索)
    //		戻り値 : 次の文字にあたる位置
    //
    unsigned char* p;
    unsigned char a1;
    unsigned char code1;
    unsigned char code2;
    char* res;
    char* pres;
    
    p = (unsigned char*)target;
    code1 = (unsigned char)(code & 0xff);
    code2 = (unsigned char)(code >> 8);
    
    res = NULL;
    pres = NULL;
    *findptr = NULL;
    
    while (1) {
        a1 = *p;
        if (a1 == 0)
            break;
        if (a1 == code1) {
            if (a1 < 129) {
                res = (char*)p;
            } else {
                if ((a1 <= 159) || (a1 >= 224)) {
                    if (p[1] == code2) {
                        res = (char*)p;
                    }
                } else {
                    res = (char*)p;
                }
            }
        }
        p++;             // 検索位置を移動
        if (a1 >= 129) { // 全角文字チェック
            if ((a1 <= 159) || (a1 >= 224))
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

-(void)TrimCodeR:(char*)p code:(int)code {
    //		最後のcodeを取り除く
    //
    char* ss;
    char* ss2;
    char* sslast;
    int i;
    while (1) {
        i = (int)strlen(p);
        sslast = p + i;
        ss = [self strchr3:p code:code sw:0 findptr:&ss2];
        if (ss2 == NULL)
            break;
        if (ss != sslast)
            break;
        *ss2 = 0;
    }
    
}

-(void)TrimCode:(char*)p code:(int)code {
    //		すべてのcodeを取り除く
    //
    char* ss;
    char* ss2;
    while (1) {
        ss = [self strchr3:p code:code sw:1 findptr:&ss2];
        if (ss2 == NULL)
            break;
        strcpy(ss2, ss);
    }
    
}

-(void)TrimCodeL:(char*)p code:(int)code {
    
    //		最初のcodeを取り除く
    //
    char* ss;
    char* ss2;
    while (1) {
        ss = [self strchr3:p code:code sw:2 findptr:&ss2];
        if (ss2 == NULL)
            break;
        strcpy(ss2, ss);
    }
    
}

@end
