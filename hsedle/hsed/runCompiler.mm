
//
//  コンパイラを実行する
//

#include "runCompiler.h"
#include "hsc3.h"

@implementation MyWindow (run)

static void usage1(void) {
    static char *p[] = {
            (char *) "usage: hspcmp [options] [filename]",
            (char *) "       -o??? set output file to ???",
            (char *) "       -d    add debug information",
            (char *) "       -p    preprocessor only",
            (char *) "       -c    HSP2.55 compatible mode",
            (char *) "       -i    input UTF-8 source code",
            (char *) "       -u    output UTF-8 strings",
            (char *) "       -w    force debug window on",
            (char *) "       --compath=??? set common path to ???",
            NULL};
    for (int i = 0; p[i]; i++) {
        @autoreleasepool {
            AppDelegate *global = (AppDelegate *) [[NSApplication sharedApplication] delegate];
            global.logString = [global.logString stringByAppendingFormat:@"%s\n", p[i]];
        }
    }
}

- (int)runCompiler:(int)argc argv:(char **)argv {
    int st = 0;
    int cmpopt = 0;
    int ppopt = HSC3_OPT_UTF8IN;
    int utfopt = 1;
    int pponly;
    char fname[HSP_MAX_PATH];
    char fname2[HSP_MAX_PATH];
    char oname[HSP_MAX_PATH];
    char compath[HSP_MAX_PATH];
    CHsc3 *hsc3 = NULL;

    if (argc < 2) { // check switch and prm
        usage1();
        return -1;
    }

    fname[0] = 0;
    fname2[0] = 0;
    oname[0] = 0;

    strcpy(compath, "common/");

    for (int i = 1; i < argc; i++) {
        if (*argv[i] != '-') {
            strcpy(fname, argv[i]);
        } else {
            if (strncmp(argv[i], "--compath=", 10) == 0) {
                strcpy(compath, argv[i] + 10);
                continue;
            }
            switch (tolower(*(argv[i] + 1))) {
                case 'c':
                    ppopt |= HSC3_OPT_NOHSPDEF;
                    break;
                case 'p':
                    pponly = 1;
                    break;
                case 'd':
                    ppopt |= HSC3_OPT_DEBUGMODE;
                    cmpopt |= HSC3_MODE_DEBUG;
                    break;
                case 'i':
                    ppopt |= HSC3_OPT_UTF8IN;
                    utfopt = 1;
                    cmpopt |= HSC3_MODE_UTF8;
                    break;
                case 'u':
                    utfopt = 1;
                    cmpopt |= HSC3_MODE_UTF8;
                    break;
                case 'w':
                    cmpopt |= HSC3_MODE_DEBUGWIN;
                    break;
                case 'o':
                    strcpy(oname, argv[i] + 2);
                    break;
                default:
                    st = 1;
                    break;
            }
        }
    }

    if (st) {
        global.logString = [global.logString stringByAppendingString:@"Illegal switch selected.\n"];
        return 1;
    }
    if (fname[0] == 0) {
        global.logString = [global.logString stringByAppendingString:@"No file name selected.\n"];
        return 1;
    }

    if (oname[0] == 0) {
        strcpy(oname, fname);
        cutext(oname);
        addext(oname, "ax");
    }
    strcpy(fname2, fname);
    cutext(fname2);
    addext(fname2, "i");
    addext(fname, "hsp"); // 拡張子がなければ追加する

    hsc3 = new CHsc3; // call main
    hsc3->SetCommonPath(compath);
    st = hsc3->PreProcess(fname, fname2, ppopt, fname);
    if ((cmpopt < 2) && (st == 0)) {
        st = hsc3->Compile(fname2, oname, cmpopt);
    }
    puts(hsc3->GetError());
    hsc3->PreProcessEnd();
    if (hsc3 != NULL) {
        delete hsc3;
        hsc3 = NULL;
    }

    //printf("!!!!!!!!!!!! \n");
    //[cwrap call_c];
    return st;
}

@end
