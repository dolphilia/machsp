//
//  runCompiler.c
//  documentbasededitor
//
//  Created by dolphilia on 2016/02/26.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#import "runCompiler.h"
#import <stdio.h>
#import <stdlib.h>
#import <string.h>
#import <ctype.h>
#import "hsp3config.h"
#import "supio_linux.h"
#import "hsc3.h"
#import "token.h"
#import "runCompiler.h"
#import <Foundation/Foundation.h>
#import "MyWindow.h"
#import "AppDelegate.h"

@implementation MyWindow(run)

/*----------------------------------------------------------*/

-(void)usage1 {
    static 	char *p[] = {
        (char *)"usage: hspcmp [options] [filename]",
        (char *)"       -o??? set output file to ???",
        (char *)"       -d    add debug information",
        (char *)"       -p    preprocessor only",
        (char *)"       -c    HSP2.55 compatible mode",
        (char *)"       -i    input UTF-8 source code",
        (char *)"       -u    output UTF-8 strings",
        (char *)"       -w    force debug window on",
        (char *)"       --compath=??? set common path to ???",
        NULL };
    int i;
    for(i=0; p[i]; i++) {
        @autoreleasepool {
            AppDelegate* global = (AppDelegate *)[[NSApplication sharedApplication] delegate];
            global.logString = [global.logString stringByAppendingFormat:@"%s\n", p[i]];
        }
    }
}

/*----------------------------------------------------------*/

-(int)runCompiler:(int)argc argv:(char **)argv {
    char a1,a2;
    int b,st;
    int cmpopt,ppopt,utfopt,pponly;
    char fname[HSP_MAX_PATH];
    char fname2[HSP_MAX_PATH];
    char oname[HSP_MAX_PATH];
    char compath[HSP_MAX_PATH];
    CHsc3 *hsc3=NULL;
    
    //	check switch and prm
    if (argc<2) {
        [self usage1];
        return -1;
    }
    
    st = 0; ppopt = 0; cmpopt = 0;
    fname[0]=0;
    fname2[0]=0;
    oname[0]=0;
    
    ppopt = HSC3_OPT_UTF8IN;
    //cmpopt = HSC3_MODE_UTF8;
    utfopt=1;
    
    //NSLog(@"%s",argv[0]);
    //NSLog(@"%s",argv[1]);
    
#ifdef HSPLINUX
    strcpy( compath,"common/" );
#else
    strcpy( compath,"common¥¥" );
#endif
    
    for (b=1;b<argc;b++) {
        a1=*argv[b];a2=tolower(*(argv[b]+1));
#ifdef HSPLINUX
        if (a1!='-') {
#else
            if ((a1!='/')&&(a1!='-')) {
#endif
                strcpy(fname,argv[b]);
            } else {
                if (strncmp(argv[b], "--compath=", 10) == 0) {
                    strcpy( compath, argv[b] + 10 );
                    continue;
                }
                switch (a2) {
                    case 'c':
                        ppopt |= HSC3_OPT_NOHSPDEF; break;
                    case 'p':
                        pponly=1; break;
                    case 'd':
                        ppopt |= HSC3_OPT_DEBUGMODE; cmpopt|=HSC3_MODE_DEBUG; break;
                    case 'i':
                        ppopt |= HSC3_OPT_UTF8IN; utfopt=1; cmpopt|=HSC3_MODE_UTF8; break;
                    case 'u':
                        utfopt=1; cmpopt|=HSC3_MODE_UTF8; break;
                    case 'w':
                        cmpopt|=HSC3_MODE_DEBUGWIN; break;
                    case 'o':
                        strcpy( oname,argv[b]+2 );
                        break;
                    default:
                        st=1;break;
                }
            }
        }
        
        if (st) {
            @autoreleasepool {
                //AppDelegate* global = (AppDelegate *)[[NSApplication sharedApplication] delegate];
                global.logString = [global.logString stringByAppendingString:@"Illegal switch selected.\n"];
            }
            //printf("Illegal switch selected.¥n");
            return 1;
        }
        if (fname[0]==0) {
            @autoreleasepool {
                //AppDelegate* global = (AppDelegate *)[[NSApplication sharedApplication] delegate];
                global.logString = [global.logString stringByAppendingString:@"No file name selected.\n"];
            }
            //printf("No file name selected.¥n");
            return 1;
        }
        
        
        if (oname[0]==0) {
            strcpy( oname,fname );
            cutext( oname );
            addext( oname,"ax" );
        }
        strcpy( fname2, fname );
        cutext( fname2 );
        addext( fname2,"i" );
        addext( fname,"hsp" );			// 拡張子がなければ追加する
        
        //		call main
        
        hsc3 = new CHsc3;
        hsc3->SetCommonPath( compath );
        
        st = hsc3->PreProcess( fname, fname2, ppopt, fname );
        if (( cmpopt < 2 )&&( st == 0 )) {
            st = hsc3->Compile( fname2, oname, cmpopt );
        }
        puts( hsc3->GetError() );
        hsc3->PreProcessEnd();
        if ( hsc3 != NULL ) {
            delete hsc3;
            hsc3=NULL;
        }
        return st;
    }
@end
