//
//  main.m
//
#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <stdlib.h>
#import <string.h>
#import <stdio.h>
#import <ctype.h>
#import "hsp3config.h"
#import "utility_string.h"
#import "hsc3.h"
#import "token.h"

void usage1() {
    static char *p[] = {
        (char *)"利用方法: hspcmp [オプション] [ファイル名]",
        (char *)"       -oX   出力ファイルをXに設定する",
        (char *)"       -d    デバッグ情報を追加する",
        (char *)"       -p    プリプロセッサのみ",
        (char *)"       -c    HSP2.55互換モード",
        (char *)"       -i    UTF-8のソースコードの入力",
        (char *)"       -u    UTF-8文字列の出力",
        (char *)"       -w    デバッグウィンドウを強制的にオンにする",
        (char *)"       --compath=X Xへの共通パスを設定",
//        (char *)"usage: hspcmp [options] [filename]",
//        (char *)"       -o??? set output file to ???",
//        (char *)"       -d    add debug information",
//        (char *)"       -p    preprocessor only",
//        (char *)"       -c    HSP2.55 compatible mode",
//        (char *)"       -i    input UTF-8 source code",
//        (char *)"       -u    output UTF-8 strings",
//        (char *)"       -w    force debug window on",
//        (char *)"       --compath=??? set common path to ???",
        NULL };
    for(int i = 0; p[i]; i++) {
        printf("%s\n", p[i]);
    }
}

int main(int argc, const char * argv[]) {
    CStrNote* note = [[CStrNote alloc] init];
    [note Select:"aiueo\nkakikukeko\nsasisus"];
    int size = [note GetSize];
    char str[] = "aiueo\nkakikukeko\nsasisus";
    int line = [note GetLine:str line:0];
    printf("%d\n",size);
    printf("%s\n",str);
    return 0;
/*
    char a1, a2;
    int b, st;
    int cmpopt, ppopt, utfopt, pponly;
    char fname[HSP_MAX_PATH] = "start.hsp";
    char fname2[HSP_MAX_PATH] = "start.i";
    char oname[HSP_MAX_PATH] = "start.ax";
    char compath[HSP_MAX_PATH];
    //CHsc3 *hsc3=NULL;
    //    check switch and prm
//    if (argc < 2) {
//        usage1();
//        return -1;
//    }
    st = 0;
    ppopt = 0;
    cmpopt = 0;
//    fname[0] = 0;
//    fname2[0] = 0;
//    oname[0] = 0;
    ppopt = HSC3_OPT_UTF8IN;
    //cmpopt = HSC3_MODE_UTF8;
    utfopt = 1;
    strcpy(compath, "common/");
//    for (b = 1; b < argc; b++) {
//        a1 = *argv[b];
//        a2 = tolower(*(argv[b] + 1));
//        if (a1 != '-') {
//            strcpy(fname, argv[b]);
//        } else {
//            if (strncmp(argv[b], "--compath=", 10) == 0) {
//                strcpy(compath, argv[b] + 10);
//                continue;
//            }
//            switch (a2) {
//                case 'c':
//                    ppopt |= HSC3_OPT_NOHSPDEF;
//                    break;
//                case 'p':
//                    pponly = 1;
//                    break;
//                case 'd':
//                    ppopt |= HSC3_OPT_DEBUGMODE;
//                    cmpopt |= HSC3_MODE_DEBUG;
//                    break;
//                case 'i':
//                    ppopt |= HSC3_OPT_UTF8IN;
//                    utfopt = 1;
//                    cmpopt |= HSC3_MODE_UTF8;
//                    break;
//                case 'u':
//                    utfopt = 1;
//                    cmpopt |= HSC3_MODE_UTF8;
//                    break;
//                case 'w':
//                    cmpopt |= HSC3_MODE_DEBUGWIN;
//                    break;
//                case 'o':
//                    strcpy(oname, argv[b] + 2);
//                    break;
//                default:
//                    st = 1;
//                    break;
//            }
//        }
//    }
//    if (st) {
//        NSLog(@"Illegal switch selected.\n");
//        return 1;
//    }
//    if (fname[0] == 0) {
//        NSLog(@"No file name selected.\n");
//        return 1;
//    }
//    if (oname[0] == 0) {
//        strcpy(oname, fname);
//        cutext(oname);
//        addext(oname, "ax");
//    }
//
//    strcpy(fname2, fname);
//    cutext(fname2);
//    addext(fname2, "i");
//    addext(fname, "hsp");            // 拡張子がなければ追加する
    
//    printf("%s\n",fname); //start.hsp
//    printf("%s\n",fname2); //start.i
//    printf("%s\n",oname); //start.ax
//    printf("%s\n",compath); //common/
    
    
    //        call main
    CHsc3* hsc3 = [[CHsc3 alloc] init];
    [hsc3 SetCommonPath:compath];
    st = [hsc3 PreProcess:fname outname:fname2 option:ppopt rname:fname ahtoption:NULL];
    if ((cmpopt < 2) && (st == 0)) {
        st = [hsc3 Compile:fname2 outname:oname mode:cmpopt];
    }
    puts([hsc3 GetError]);
    [hsc3 PreProcessEnd];
    if (hsc3 != NULL) {
        //delete hsc3;
        hsc3 = NULL;
    }
    return st;
*/
}
