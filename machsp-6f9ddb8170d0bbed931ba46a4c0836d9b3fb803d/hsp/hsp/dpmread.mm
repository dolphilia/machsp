//-----------------------------------------------------
//	Datafile Pack Manager service
//	( No encryption for OpenHSP )
//			onion software 1996/6
//			Modified for win32 in 1997/8
//			Modified for HSP2.6 in 2000/7
//			Modified for HSP3.0 in 2004/11
//-----------------------------------------------------

#import "dpmread.h"
#import <ctype.h>
#import <stdio.h>
#import <stdlib.h>
#import <string.h>
#import "ViewController.h"
#import "debug_message.h"
#import "hsp.h"
#import "hsp3config.h"
#import "supio_hsp3.h"

typedef struct MEMFILE {
    char *pt;  // target ptr
    int cur;   // current ptr
    int size;  // size
} MEMFILE;

static MEMFILE memfile = {NULL, 0, -1};

#define p_optr 0x04  // 実データ開始ポインタ
#define p_dent 0x08  // ディレクトリエントリ数
#define p_dnam 0x0c  // ネームスペース確保サイズ(ver2.6)
#define d_farc 0x08  // 圧縮flag(先頭が'¥0'の時のみ有効)
#define d_fasz 0x0c  // 圧縮後size(先頭が'¥0'の時のみ有効)
#define d_fnpt 0x10  // 名前格納ポインタ(先頭が'¥0'の時のみ有効)
#define d_fenc 0x14  // 暗号化flag(先頭が'¥0'の時のみ有効)
#define d_fent 0x18  // ファイル格納ポインタ
#define d_fsiz 0x1c  // ファイルsize
#define getdw(ofs) (*(unsigned long *)(buf + ofs))

@implementation ViewController (dpmread)

static int dpm_flag = 0;   // 0=none/1=packed
static int memf_flag = 0;  // 0=none/1=on memory
static unsigned char *mem_dpm = NULL;
// static unsigned char *nameptr;
static unsigned char buf[0x80];
static char dpm_file[HSP_MAX_PATH];
static long dpm_ofs, optr, fs, fptr;
static int dpm_fenc, dpm_enc1, dpm_enc2;
static int dpm_opmode;
static int dent;
// static int seed1, seed2;
static unsigned char dpm_lastchr;
static FILE *fp;

- (int)dpmchk:(char *)fname {
    int a1, a2;
    char c1;
    char f1[HSP_MAX_PATH];
    char *ss;
    // unsigned char *uc;
    
    dpm_opmode = 0;
    dpm_fenc = 0;
    dpm_enc1 = 0;
    dpm_enc2 = 0;
    
    a1 = 0;
    while (1) {
        c1 = fname[a1];
        f1[a1] = tolower(c1);
        if (c1 == 0) break;
        a1++;
    }
    
    if (mem_dpm == NULL) {
        return -1;
    }
    
    a2 = -1;
    ss = (char *)(mem_dpm + 16);
    for (a1 = 0; a1 < dent; a1++) {
        if (strcmp(ss, f1) == 0) {
            memcpy(buf, ss, 32);
            a2 = a1;
            break;
        }
        ss += 32;
    }
    if (a2 == -1) {
        return -1;
    }
    
    fs = getdw(d_fsiz);
    fptr = getdw(d_fent);
    fp = fopen(dpm_file, "rb");
    if (fp == NULL) {
        return -1;
    }
    
    fseek(fp, fptr + optr, SEEK_SET);
    dpm_fenc = (int)getdw(d_fenc);
    dpm_lastchr = 0;
    dpm_opmode = 1;
    
    return 0;
}

/// メモリストリームをチェック
///
- (int)dpm_chkmemf:(char *)fname {
    int i = *(int *)fname;
    char *p;
    char tmp[HSP_MAX_PATH];
    memf_flag = 0;

    if ((i == 0x3a4d5044) || (i == 0x3a6d7064)) {  // 'DPM:'をチェックする
        p = strchr2(fname + 4, ':');
        [self dpm_bye];
        if (p != NULL) {
            *p = 0;
            strcpy(tmp, p + 1);
            [self dpm_ini:fname + 4 dpmofs:0 chksum:-1 deckey:-1];
            strcpy(fname, tmp);
        }
        return 0;
    }
    if ((i == 0x3a4d454d) || (i == 0x3a6d656d)) {  // 'MEM:'をチェックする
        memf_flag = 1;
        return 1;
    }
    
    return 0;
}

- (FILE *)dpm_open:(char *)fname {
    [self dpm_chkmemf:fname];
    if (memf_flag) {
        memfile.cur = 0;
        if (memfile.size < 0) {
            
            return NULL;
        }
        
        return (FILE *)&memfile;
    }
    if (dpm_flag) {
        if ([self dpmchk:fname] == 0) {
            
            return fp;
        }
    }
    fp = fopen(fname, "rb");
    
    return fp;
}

- (void)dpm_close {
    if (memf_flag) {
        return;
    }
    fclose(fp);
}

- (int)dpm_fread:(void *)mem size:(int)size stream:(FILE *)stream {
    // int a;
    int len;
    // unsigned char *p;
    // unsigned char ch;
    // int seed1x,seed2x;
    
    if (memf_flag) {  // メモリストリーム時
        len = size;
        if ((memfile.cur + size) >= memfile.size) len = memfile.size - memfile.cur;
        if (len > 0) {
            memcpy(mem, memfile.pt + memfile.cur, len);
            memfile.cur += len;
        }
        
        return len;
    }
    len = (int)fread(mem, 1, size, stream);
    
    return len;
}

//----------------------------------------------------------------------------------

/// DPMファイル読み込みの初期化
///
- (int)dpm_ini:(char *)dpmfile dpmofs:(long)dpmofs chksum:(int)chksum deckey:(int)deckey {
    int hedsize;
    int namsize;
    int dirsize;
    int sum, sumseed, sumsize;
    int a1;
    char _dpmfile[HSP_MAX_PATH];
    // unsigned char *dec;
    
    optr = 0;
    dpm_flag = 0;
    memf_flag = 0;
    dpm_ofs = dpmofs;
    mem_dpm = NULL;
    
    strcpy(_dpmfile, dpmfile);
    
    fp = fopen(_dpmfile, "rb");
    if (fp == NULL) {
        return -1;
    }
    
    if (dpmofs > 0)
        fseek(fp, dpmofs, SEEK_SET);
    
    fread(buf, 16, 1, fp);
    optr = getdw(p_optr) + dpmofs;
    dent = (int)getdw(p_dent);
    fclose(fp);
    
    buf[4] = 0;
    if (strcmp((char *)buf, "DPMX") != 0) {
        return -1;
    }
    
    namsize = (int)getdw(p_dnam);
    dirsize = 32 * dent;
    hedsize = 16 + namsize + dirsize;
    mem_dpm = (unsigned char *)malloc(hedsize);
    if (mem_dpm == NULL) {
        
        return -1;
    }
    
    //		内部バッファにDPMヘッダを読み込む
    //
    fp = fopen(_dpmfile, "rb");
    if (dpmofs > 0)
        fseek(fp, dpmofs, SEEK_SET);
    fread(mem_dpm, hedsize, 1, fp);
    fclose(fp);
    
    //		DPMのチェックサムを検証する
    //
    sum = 0;
    sumsize = 0;
    sumseed = ((deckey >> 24) & 0xff) / 7;
    if (chksum != -1) {
        fp = fopen(_dpmfile, "rb");
        if (dpmofs > 0)
            fseek(fp, dpmofs, SEEK_SET);
        while (1) {
            a1 = fgetc(fp);
            if (a1 < 0)
                break;
            sum += a1 + sumseed;
            sumsize++;
        }
        fclose(fp);
        sum &= 0xffff;  // lower 16bit sum
        if (chksum != sum) {
            return -2;
        }
        sumsize -= hedsize;
    }
    
    //		DPMモードにする
    //
    dpm_flag = 1;
    strcpy(dpm_file, _dpmfile);
    
    return 0;
}

- (void)dpm_bye {
    if (mem_dpm != NULL)
        free(mem_dpm);
    dpm_flag = 0;
}

- (int)dpm_read:(char *)fname readmem:(void *)readmem rlen:(int)rlen seekofs:(int)seekofs {
    char *lpRd;
    FILE *ff;
    int a1;
    int seeksize;
    int filesize;
    
    [self dpm_chkmemf:fname];
    
    seeksize = seekofs;
    if (seeksize < 0)
        seeksize = 0;
    
    lpRd = (char *)readmem;
    
    if (memf_flag) {  // メモリストリーム時
        [self dpm_open:fname];
        memfile.cur = seeksize;
        a1 = [self dpm_fread:lpRd size:rlen stream:NULL];
        [self dpm_close];
        
        return a1;
    }
    
    if (dpm_flag) {
        if ([self dpmchk:fname] == 0) {
            filesize = (int)fs;
            fclose(fp);
            
            //	Read DPM file
            ff = fopen(dpm_file, "rb");
            if (ff == NULL) {
                return -1;
            }
            fseek(ff, optr + fptr + seeksize, SEEK_SET);
            if (rlen < filesize)
                filesize = rlen;
            a1 = [self dpm_fread:lpRd size:filesize stream:ff];
            fclose(ff);
            
            return a1;
        }
    }
    
    //	Read normal file
    ff = fopen(fname, "rb");
    if (ff == NULL) {
        
        return -1;
    }
    if (seekofs >= 0) fseek(ff, seeksize, SEEK_SET);
    a1 = (int)fread(lpRd, 1, rlen, ff);
    fclose(ff);
    
    return a1;
}

- (int)dpm_exist:(char *)fname {
    [self dpm_chkmemf:fname];
    if (memf_flag) {  // メモリストリーム時
        return memfile.size;
    }
    
    if (dpm_flag) {
        if ([self dpmchk:fname] == 0) {
            [self dpm_close];
            return (int)fs;  // dpm file size
        }
    }
    
    FILE *ff = fopen(fname, "rb");
    if (ff == NULL)
        return -1;
    fseek(ff, 0, SEEK_END);
    
    int length = (int)ftell(ff);  // normal file size
    fclose(ff);
    
    return length;
}

/// 指定ファイルがどこにあるかを得る
///
/// (-1:error/0=file/1=dpm/2=memory)
///
- (int)dpm_filebase:(char *)fname {
    FILE *ff;
    [self dpm_chkmemf:fname];
    if (memf_flag) {
        
        return 2;
    }
    if (dpm_flag) {
        if ([self dpmchk:fname] == 0) {
            [self dpm_close];
            
            return 1;
        }
    }
    ff = fopen(fname, "rb");
    if (ff == NULL) {
        
        return -1;
    }
    fclose(ff);
    
    return 0;
}

- (void)dpm_getinf:(char *)inf {
    long a  = dpm_ofs;
    if (dpm_flag == 0)
        a = -1;
    /*
     rev 43
     mingw : warning : 仮引数:int 実引数:long
     に対処
     */
    sprintf(inf, "%s,%d", dpm_file, static_cast<int>(a));
}

- (int)dpm_filecopy:(char *)fname sname:(char *)sname {
    FILE *fp1;
    FILE *fp2;
    int fres;
    int flen;
    int xlen;
    int max = 0x8000;
    char *mem;
    
    [self dpm_chkmemf:fname];
    flen = [self dpm_exist:fname];
    if (flen < 0) {
        return 1;
    }
    
    fp2 = fopen(sname, "wb");
    if (fp2 == NULL) {
        return 1;
    }
    fp1 = [self dpm_open:fname];
    
    mem = (char *)malloc(max);
    while (1) {
        if (flen == 0) break;
        if (flen < max)
            xlen = flen;
        else
            xlen = max;
        [self dpm_fread:mem size:xlen stream:fp1];
        fres = (int)fwrite(mem, 1, xlen, fp2);
        if (fres < xlen) break;
        flen -= xlen;
    }
    
    [self dpm_close];
    fclose(fp2);
    free(mem);
    
    if (flen != 0) {
        return 1;
    }
    
    return 0;
}

- (void)dpm_memfile:(void *)mem size:(int)size {
    memfile.pt = (char *)mem;
    memfile.cur = 0;
    memfile.size = size;
}

- (char *)dpm_readalloc:(char *)fname {
    int len = [self dpm_exist:fname];
    
    if (len < 0) {
        return NULL;
    }
    
    char *p = mem_ini(len + 1);
    [self dpm_read:fname readmem:p rlen:len seekofs:0];
    p[len] = 0;
    
    return p;
}

@end
