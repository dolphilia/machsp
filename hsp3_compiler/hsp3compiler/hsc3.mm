//@
//
//		HSP compiler class rev.3
//			onion software/onitama 2002/2
//
#import <stdio.h>
#import <stdlib.h>
#import <string.h>
#import "hsp3config.h"
#import "hsp3debug.h"
#import "hsp3struct.h"
#import "supio_linux.h"
#import "hsc3.h"
#import "membuf.h"
#import "strnote.h"
#import "label.h"
#import "token.h"
#import "localinfo.h"

extern char *hsp_prestr[];
extern char *hsp_prepp[];
#define ERRBUF_SIZE 0x10000

@implementation CHsc3 : NSObject
- (instancetype)init {
    self = [super init];
    if (self) {
        errbuf = [[CMemBuf alloc] init];
        [errbuf InitMemBuf:ERRBUF_SIZE];
        lb_info = NULL;
        addkw = NULL;
        common_path[0] = 0;
    }
    return self;
}
- (void)dealloc {
    if ( addkw != NULL ) {
        //delete addkw;
        addkw=NULL;
    }
    if ( errbuf != NULL ) {
        //delete errbuf;
        errbuf=NULL;
    }
}
-(char*)GetError {
    return [errbuf GetBuffer];
}
-(int)GetErrorSize {
    return [errbuf GetSize] + 1;
}
-(void)ResetError {
    //		エラーメッセージ消去
    //
    if ( errbuf != NULL ) {
        //delete errbuf;
        errbuf=NULL;
    }
    errbuf = [[CMemBuf alloc] init];//new CMemBuf( ERRBUF_SIZE );
    [errbuf InitMemBuf:ERRBUF_SIZE];
    hed_option = 0;
    hed_runtime[0] = 0;
}
//-------------------------------------------------------------
//		Interfaces
//-------------------------------------------------------------
-(void)AddSystemMacros:(CToken*)tk option:(int)option {
    process_option = option;
    if (( option & HSC3_OPT_NOHSPDEF )==0 ) {
        //CLocalInfo linfo;
        [tk RegistExtMacro_val:(char *)"__hspver__" val:vercode];
        [tk RegistExtMacro_str:(char *)"__hsp30__" str:(char *)""];
        [tk RegistExtMacro_str:(char *)"__date__" str:get_current_date()];
        [tk RegistExtMacro_str:(char *)"__time__" str:get_current_time()];
        [tk RegistExtMacro_val:(char *)"__line__" val:0];
        [tk RegistExtMacro_str:(char *)"__file__" str:(char *)""];
        if ( option & HSC3_OPT_DEBUGMODE )
            [tk RegistExtMacro_str:(char *)"_debug" str:(char *)""];
    }
}
//int CHsc3::PreProcessAht( char *fname, void *ahtoption, int mode )
//{
//    //		Preprocess execute (AHT)
//    //		(終了時にPreProcessEndを呼ぶこと)
//    //
//    int res;
//    //char mm[512];
//    CToken tk;
//    lb_info = NULL;
//    ahtbuf = NULL;
//    tk.SetErrorBuf( errbuf );
//    tk.SetCommonPath( common_path );
//    tk.SetAHT( (AHTMODEL *)ahtoption );
//    outbuf = new CMemBuf;
//    if ( mode ) {
//        ahtbuf = new CMemBuf;
//        tk.SetAHTBuffer( ahtbuf );
//    }
//    @autoreleasepool {
//        NSLog(@"#AHT processor ver%s / onion software 1997-2015(c)\n", hspver);
//    }
//    //sprintf( mm,"#AHT processor ver%s / onion software 1997-2015(c)", hspver );
//    //tk.Mes( mm );
//    res = tk.ExpandFile( outbuf, fname, fname );
//    if ( res < 0 ) return -1;
//    return 0;
//}
/*
	rev 54
	mingw : warning : packbuf は未初期化で使用されうる
	問題なさそう、一応対処。
 */
-(int)PreProcess:(char*)fname outname:(char*)outname option:(int)option rname:(char*)rname ahtoption:(void*)ahtoption {
    //		Preprocess execute
    //		(終了時にPreProcessEndを呼ぶこと)
    //			option : bit0=ver2.55 mode(ON)
    //			         bit1=debug mode(ON)
    //			         bit2=make packfile(ON)
    //					 bit3=read AHT file(on)
    //					 bit4=write AHT file(on)
    //					 bit5=UTF8(on)
    //
    int res;
    //char mm[512];
    CToken* tk;
    CMemBuf* packbuf = NULL;
    lb_info = NULL;
    outbuf = [[CMemBuf alloc] init];
    [outbuf InitMemBuf:0x10000];
    ahtbuf = NULL;
    [tk SetErrorBuf:errbuf];
    [tk SetCommonPath:common_path];
    [tk LabelRegist2:hsp_prestr];
    [self AddSystemMacros:tk option:option];
    if ( option & HSC3_OPT_MAKEPACK ) {
        packbuf = [[CMemBuf alloc] init];
        [outbuf InitMemBuf:0x1000];
        [tk SetPackfileOut:packbuf];
    }
//    if ( option & (HSC3_OPT_READAHT|HSC3_OPT_MAKEAHT) ) {
//        tk.SetAHT( (AHTMODEL *)ahtoption );
//    }
    if ( option & HSC3_OPT_UTF8IN ) {
        [tk SetUTF8Input:1];
    }
    NSLog(@"# %s ver%s / onion software 1997-2015(c)\n",HSC3TITLE, hspver);
    //sprintf( mm,"#%s ver%s / onion software 1997-2015(c)", HSC3TITLE, hspver );
    //tk.Mes( mm );
    [tk SetAdditionMode:1];
    res = [tk ExpandFile:outbuf fname:(char *)"hspdef.as" refname:(char *)"hspdef.as"];
    [tk SetAdditionMode:0];
    if ( res<-1 )
        return -1;
    res = [tk ExpandFile:outbuf fname:fname refname:rname];
    if ( res<0 )
        return -1;
    [tk FinishPreprocess:outbuf];
    cmpopt = [tk GetCmpOption];
    if ( cmpopt & CMPMODE_PPOUT	 ) {
        res = [outbuf SaveFile:outname];
        if ( res<0 ) {
            NSLog(@"#プリプロセッサファイルの出力に失敗しました\n");
            return -2;
        }
    }
    [outbuf Put_int:(int)0];
#if 0
    //		ソースのラベルを追加(停止中)
    if ( addkw != NULL ) { delete addkw; addkw=NULL; }
    addkw = new CMemBuf( 0x1000 );
    tk.LabelDump( addkw, DUMPMODE_DLLCMD );
#endif
    //sprintf( mm,"#Macro buffer %x.", tk.GetLabelBufferSize() );
    //tk.Mes( mm );
    if ( option & HSC3_OPT_MAKEPACK ) {
        [tk AddPackfile:(char *)"start.ax" mode:1];
        res = [packbuf SaveFile:(char *)"packfile"];
        //delete packbuf;
        packbuf = NULL;
        if ( res<0 ) {
            NSLog(@"#packfileの出力に失敗しました\n");
            return -3;
        }
        NSLog(@"#packfile generated.\n");
    }
    hed_option = [tk GetHeaderOption];
    strcpy( hed_runtime, [tk GetHeaderRuntimeName] );
    lb_info = [tk GetLabelInfo];
    return 0;
}
-(void)PreProcessEnd {
    if ( lb_info != NULL ) {
        //delete lb_info;
        lb_info = NULL;
    }
    if ( outbuf != NULL ) {
        //delete outbuf;
        outbuf = NULL;
    }
    if ( ahtbuf != NULL ) {
        //delete ahtbuf;
        ahtbuf = NULL;
    }
}
-(int)Compile:(char*)fname outname:(char*)outname mode:(int)mode {
    //		Compile
    //
    //int res;
    //res = tcomp_main( fname, outname, errbuf, mode, "" );
    int res;
    //char mm[512];
    CToken* tk;
    if ( lb_info != NULL )
        [tk SetLabelInfo:lb_info];		// プリプロセッサのラベル情報
    [tk SetErrorBuf:errbuf];
    [tk SetCommonPath:common_path];
    [tk LabelRegist:hsp_prestr mode:1];
    [tk SetHeaderOption:hed_option name:hed_runtime];
    [tk SetCmpOption:cmpopt];
    if ( process_option & HSC3_OPT_UTF8IN ) {
        [tk SetUTF8Input:1];
    }
    NSLog(@"# %s ver%s / onion software 1997-2015(c)\n",HSC3TITLE2, hspver);
    if ( outbuf != NULL ) {
        res = [tk GenerateCode_membuf:outbuf oname:outname mode:mode];
    } else {
        res = [tk GenerateCode:fname oname:outname mode:mode];
    }
    return res;
}
-(void)SetCommonPath:(char*)path {
    if ( path==NULL ) {
        common_path[0]=0;
        return;
    }
    strcpy( common_path, path );
}
-(int)GetCmdList:(int)option {
    int res;
    CToken* tk;
    //CMemBuf outbuf;
    [tk SetErrorBuf:errbuf];
    [tk SetCommonPath:common_path];
    [tk LabelRegist3:hsp_prestr];			// 標準キーワード
    [tk LabelRegist3:hsp_prepp];			// プリプロセッサキーワード
    [self AddSystemMacros:tk option:option];
    res = [tk ExpandFile:outbuf fname:(char *)"hspdef.as" refname:(char *)"hspdef.as"];
    //	if ( res<-1 ) return -1;
    [tk LabelDump:errbuf option:DUMPMODE_ALL];
    //errbuf->PutStr("-----¥r¥n");
    //if ( addkw != NULL ) errbuf->PutStr( addkw->GetBuffer() );
    return 0;
}
-(int)OpenPackfile {
    pfbuf = [[CMemBuf alloc] init];
    [pfbuf InitMemBuf:0x1000];
    if ( [pfbuf PutFile:(char *)"packfile"] < 0 ) {
        //delete pfbuf;
        pfbuf = NULL;
        return -1;
    }
    return 0;
}
-(void)GetPackfileOption:(char*)out keyword:(char*)keyword defval:(char*)defval {
    int max,i;
    char tmp[512];
    char *s;
    char a1;
    CStrNote* note = [[CStrNote alloc] init];
    [note Select:[pfbuf GetBuffer]];
    max = [note GetMaxLine];
    strcpy( out, defval );
    for( i=0;i<max;i++ ) {
        [note GetLine:tmp line:i];
        if (( tmp[0]==';' )&&( tmp[1]=='!' )) {
            s = tmp+2;while(1) {
                a1 = *s;if (( a1==0 )||( a1=='=' )) break;
                s++;
            }
            if ( a1 != 0 ) {
                s[0]=0;
                if ( tstrcmp( tmp+2, keyword )) { strcpy( out, s+1 ); }
            }
        }
    }
}
-(int)GetPackfileOptionInt:(char*)keyword defval:(int)defval {
    char tmp[512];
    char deftmp[32];
    sprintf( deftmp,"%d",defval );
    [self GetPackfileOption:tmp keyword:keyword defval:deftmp];
    if (( tmp[0]>='0' )&&( tmp[0]<='9' )) return atoi( tmp );
    return defval;
}
-(void)ClosePackfile {
    //delete pfbuf;
    pfbuf = NULL;
}
-(int)GetRuntimeFromHeader:(char*)fname res:(char*)res {
    FILE *fp;
    hsp_header_t hsphed;
    int hedsize;
    int exsize;
    int ires;
    char *data;
    fp=fopen( fname, "rb" );
    if ( fp == NULL ) return -1;
    hedsize = sizeof(hsphed);
    fread( &hsphed, 1, hedsize, fp );
    exsize = hsphed.pt_cs - hedsize;
    if ( exsize == 0 ) {
        fclose(fp);
        return 0;
    }
    data = (char *)malloc( exsize );
    fread( data, 1, exsize, fp );
    fclose(fp);
    ires = 0;
    if ( hsphed.bootoption & HSPHED_BOOTOPT_RUNTIME ) {
        char runtime[HSP_MAX_PATH];
        strcpy( runtime, data + (hsphed.runtime - hedsize) );
        cutext( runtime );
        addext( runtime, "exe" );
        strcpy( res, runtime );
        ires = 1;
    }
    free( data );
    return ires;
}
-(int)SaveOutbuf:(char*)fname {
    int res;
    res = [outbuf SaveFile:fname];
    if ( res<0 ) {
        return -1;
    }
    return 0;
}
-(int)SaveAHTOutbuf:(char*)fname {
    int res;
    res = [ahtbuf SaveFile:fname];
    if ( res<0 ) {
        return -1;
    }
    return 0;
}
@end
