//@
//
//		Token analysis class
//			onion software/onitama 2002/2
//
#import <stdio.h>
#import <stdlib.h>
#import <string.h>
#import <stdarg.h>
#import <ctype.h>
#import <math.h>
#import <assert.h>
#import "hsp3config.h"
#import "supio_linux.h"
#import "token.h"
#import "label.h"
#import "tagstack.h"
#import "membuf.h"
#import "strnote.h"
#import "AppDelegate.h"
#import "label.h"
#import "tagstack.h"
#define s3size 0x8000
@implementation CToken : NSObject
- (instancetype)init
{
    self = [super init];
    if (self) {
        s3 = (unsigned char *)malloc( s3size );
        lb = [[CLabel alloc] init];
        tmp_lb = NULL;
        hed_cmpmode = CMPMODE_OPTCODE | CMPMODE_OPTPRM | CMPMODE_SKIPJPSPC;
        tstack = [[CTagStack alloc] init];
        errbuf = NULL;
        packbuf = NULL;
        //ahtmodel = NULL;
        ahtbuf = NULL;
        scnvbuf = NULL;
        [self ResetCompiler];
    }
    return self;
}
//CToken::CToken( char *buf )
//{
//    s3 = (unsigned char *)malloc( s3size );
//    lb = new CLabel;
//    tmp_lb = NULL;
//    hed_cmpmode = CMPMODE_OPTCODE | CMPMODE_OPTPRM | CMPMODE_SKIPJPSPC;
//    tstack = new CTagStack;
//    errbuf = NULL;
//    packbuf = NULL;
//    ahtmodel = NULL;
//    ahtbuf = NULL;
//    scnvbuf = NULL;
//    ResetCompiler();
//}
- (void)dealloc
{
    if ( scnvbuf!=NULL )
        [self InitSCNV:-1];
    if ( tstack!=NULL ) {
        //delete tstack;
        tstack = NULL;
    }
    if ( lb!=NULL ) {
        //delete lb;
        lb = NULL;
    }
    if ( s3 != NULL ) {
        free( s3 );
        s3 = NULL;
    }
    //    buffer = NULL;
}
-(int)GetHeaderOption { return hed_option; }
-(char*)GetHeaderRuntimeName { return hed_runtime; }
-(void)SetHeaderOption:(int)opt name:(char*)name { hed_option=opt; strcpy( hed_runtime, name ); }
-(int)GetCmpOption { return hed_cmpmode; }
-(void)SetCmpOption:(int)cmpmode { hed_cmpmode = cmpmode; }
-(void)SetUTF8Input:(int)utf8mode { pp_utf8 = utf8mode; }
-(bool)CG_optCode { return (hed_cmpmode & CMPMODE_OPTCODE) != 0; }
-(bool)CG_optInfo { return (hed_cmpmode & CMPMODE_OPTINFO) != 0; }
-(void)Mes:(char*)mes {
    //		メッセージ登録
    //
    [errbuf PutStr:mes];
    [errbuf PutStr:(char *)"\r\n"];
}
-(void)Mesf:(char*)format, ... {
    //		メッセージ登録
    //		(フォーマット付き)
    //
    char textbf[1024];
    va_list args;
    va_start(args, format);
    vsprintf(textbf, format, args);
    va_end(args);
    [errbuf PutStr:textbf];
    [errbuf PutStr:(char *)"\r\n"];
}
-(void)Error:(char*)mes {
    //		エラーメッセージ登録
    //
    char tmp[256];
    sprintf( tmp, "#Error:%s\r\n", mes );
    [errbuf PutStr:tmp];
}
-(void)LineError:(char*)mes line:(int)line fname:(char*)fname {
    //		エラーメッセージ登録(line/filename)
    //
    char tmp[256];
    sprintf( tmp, "#Error:%s in line %d [%s]\r\n", mes, line, fname );
    [errbuf PutStr:tmp];
}
-(void)SetErrorBuf:(CMemBuf*)buf {
    //		エラーメッセージバッファ登録
    //
    errbuf = buf;
}
-(void)SetPackfileOut:(CMemBuf*)pack {
    //		packfile出力バッファ登録
    //
    packbuf = pack;
    [packbuf PutStr:(char *)";\r\n;\tsource generated packfile\r\n;\r\n"];
}
-(void)SetError:(char*)mes {
    //		エラーメッセージ仮登録
    //
    strcpy( errtmp, mes );
}
-(int)AddPackfile:(char*)name mode:(int)mode {
    //		packfile出力
    //			0=name/1=+name/2=other
    //
    CStrNote* note = [[CStrNote alloc] init];
    int i,max;
    char packadd[1024];
    char tmp[1024];
    char *s;
    strcpy( packadd, name );
    strcase( packadd );
    if ( mode<2 ) {
        [note Select:[packbuf GetBuffer]];
        max = [note GetMaxLine];
        for( i=0;i<max;i++ ) {//12
            [note GetLine:tmp line:i];
            s = tmp;if ( *s=='+' ) s++;
            if ( tstrcmp( s, packadd )) return -1;
        }
        if ( mode==1 )
            [packbuf PutStr:(char *)"+"];
    }
    [packbuf PutStr:packadd];
    [packbuf PutStr:(char *)"\r\n"];
    return 0;
}
-(CLabel*)GetLabelInfo {
    //		ラベル情報取り出し
    //		(CLabel *を取得したらそちらで、deleteすること)
    //
    CLabel *res;
    res = lb;
    lb = NULL;
    return res;
}
-(void)SetLabelInfo:(CLabel*)lbinfo {
    //		ラベル情報設定
    //
    tmp_lb = lbinfo;
}
-(void)ResetCompiler {
    //	buffer = buf;
    //	wp = (unsigned char *)buf;
    line = 1;
    fpbit = 256.0;
    incinf = 0;
    swsp = 0;
    swmode = 0;
    swlevel = 0;
    [self SetModuleName:(char *)""];
    modgc = 0;
    search_path[0] = 0;
    [lb Reset];
    fileadd = 0;    //		reset header info
    hed_option = 0;
    hed_runtime[0] = 0;
    hed_autoopt_timer = 0;
    pp_utf8 = 0;
}
//-(void)SetAHT:(AHTMODEL*)aht {
//    ahtmodel = aht;
//}
//-(void)SetAHTBuffer:(CMemBuf*)aht {
//    ahtbuf = aht;
//}
-(void)SetLook:(char*)buf {
    wp = (unsigned char *)buf;
}
-(char*)GetLook {
    return (char *)wp;
}
-(char*)GetLookResult {
    return (char *)s2;
}
-(int)GetLookResultInt {
    return val;
}
-(void)Pickstr {
    //		Strings pick sub
    //
    int a=0;
    unsigned char a1;
    while(1) {
    pickag:
        a1=(unsigned char)*wp;
        if (a1>=0x81) {
            if (a1<0xa0) {				// s-jis code
                s3[a++]=a1;wp++;
                s3[a++]=*wp;wp++;
                continue;
            }
            else if (a1>=0xe0) {		// s-jis code2
                s3[a++]=a1;wp++;
                s3[a++]=*wp;wp++;
                continue;
            }
        }
        if (a1==0x5c) {					// '\' extra control
            wp++;a1=tolower(*wp);
            switch(a1) {
                case 'n':
                    s3[a++]=13;a1=10;
                    break;
                case 't':
                    a1=9;
                    break;
                case 'r':
                    s3[a++]=13;wp++;
                    goto pickag;
                case 0x22:
                    s3[a++]=a1;wp++;
                    goto pickag;
            }
        }
        if (a1==0) { wp=NULL;break; }
        if (a1==10) {
            wp++;
            line++;
            break;
        }
        if (a1==13) {
            wp++;if ( *wp==10 ) wp++;
            line++;
            break;
        }
        if (a1==0x22) {
            wp++;
            if ( *wp == 0 ) wp=NULL;
            break;
        }
        s3[a++]=a1;wp++;
    }
    s3[a]=0;
}
-(char*)Pickstr2:(char*)str {
    //		Strings pick sub '〜'
    //
    unsigned char *vs;
    unsigned char *pp;
    unsigned char a1;
    int skip,i;
    vs = (unsigned char *)str;
    pp = s3;
    while(1) {
        a1=*vs;
        if (a1==0) break;
        if (a1==0x27) { vs++; break; }
        if (a1==0x5c) {					// '\'チェック
            vs++;
            a1 = tolower( *vs );
            if ( a1 < 32 ) continue;
            switch( a1 ) {
                case 'n':
                    *pp++ = 13;
                    a1 = 10;
                    break;
                case 't':
                    a1 = 9;
                    break;
                case 'r':
                    a1 = 13;
                    break;
            }
        }
        //if (a1>=129) {					// 全角文字チェック
        //    if ((a1<=159)||(a1>=224)) {
        skip = [self SkipMultiByte:a1];
        if ( skip ) {                   // 全角文字チェック
            for(i=0;i<skip;i++) {
                *pp++ = a1;
                vs++;
                a1=*vs;
            }
        }
        vs++;
        *pp++ = a1;
    }
    *pp = 0;
    return (char *)vs;
}
-(int)CheckModuleName:(char*)name {
    int a;
    unsigned char *p;
    unsigned char a1;
    a = 0;
    p = (unsigned char *)name;
    while(1) {								// normal object name
        a1=*p;
        if (a1==0) { return 0; }
        if (a1<0x30) break;
        if ((a1>=0x3a)&&(a1<=0x3f)) break;
        if ((a1>=0x5b)&&(a1<=0x5e)) break;
        if ((a1>=0x7b)&&(a1<=0x7f)) break;
        //if (a1>=129) {						// 全角文字チェック
        //    if (a1<=159) { p++;a1=*p; }
        //    else if (a1>=224) { p++;a1=*p; }
        //}
        p++;
        p += [self SkipMultiByte:a1];       // 全角文字チェック
    }
    return -1;
}
-(int)GetToken {
    //
    //	get new word from wp ( result:s3 )
    //			result : word type
    //
    int rval;
    int a,b;
    int minmode;
    unsigned char a1,a2,an;
    int fpflag;
    int *fpival;
    unsigned char *wp_bak = nullptr;
    int ft_bak;
    if (wp==NULL) return TK_NONE;
    a = 0;
    minmode = 0;
    rval=TK_OBJ;
    while(1) {
        a1=*wp;
        if ((a1!=32)&&(a1!=9)) break;	// Skip Space & Tab
        wp++;
    }
    if (a1==0) { wp=NULL;return TK_NONE; }		// End of Source
    if (a1==13) {					// Line Break
        wp++;if (*wp==10) wp++;
        line++;
        return TK_NONE;
    }
    if (a1==10) {					// Unix Line Break
        wp++;
        line++;
        return TK_NONE;
    }    //	Check Extra Character
    if (a1<0x30) rval=TK_NONE;
    if ((a1>=0x3a)&&(a1<=0x3f)) rval=TK_NONE;
    if ((a1>=0x5b)&&(a1<=0x5e)) rval=TK_NONE;
    if ((a1>=0x7b)&&(a1<=0x7f)) rval=TK_NONE;
    if (a1==':' || a1 == '{' || a1 == '}') {   // multi statement
        wp++;
        return TK_SEPARATE;
    }
    if (a1=='0') {
        a2=wp[1];
        if (a2=='x') { wp++;a1='$'; }		// when hex code (0x)
        if (a2=='b') { wp++;a1='%'; }		// when bin code (0b)
    }
    if (a1=='$') {							// when hex code ($)
        wp++;val=0;
        while(1) {
            a1=toupper(*wp);b=-1;
            if (a1==0) { wp=NULL;break; }
            if ((a1>=0x30)&&(a1<=0x39)) b=a1-0x30;
            if ((a1>=0x41)&&(a1<=0x46)) b=a1-55;
            if (a1=='_') b=-2;
            if (b==-1) break;
            if (b>=0) { s3[a++]=a1;val=(val<<4)+b; }
            wp++;
        }
        s3[a]=0;
        return TK_NUM;
    }
    if (a1=='%') {							// when bin code (%)
        wp++;val=0;
        while(1) {
            a1=*wp;b=-1;
            if (a1==0) { wp=NULL;break; }
            if ((a1>=0x30)&&(a1<=0x31)) b=a1-0x30;
            if (a1=='_') b=-2;
            if (b==-1) break;
            if (b>=0) { s3[a++]=a1;val=(val<<1)+b; }
            wp++;
        }
        s3[a]=0;
        return TK_NUM;
    }
    /*
     if (a1=='-') {							// minus operator (-)
     wp++;an=*wp;
     if ((an<0x30)||(an>0x39)) {
     s3[0]=a1;s3[1]=0;
     return a1;
     }
     minmode++;
     a1=an;						// 次が数値ならばそのまま継続
     }
     */
    if ((a1>=0x30)&&(a1<=0x39)) {			// when 0-9 numerical
        fpflag = 0;
        ft_bak = 0;
        while(1) {
            a1=*wp;
            if (a1==0) { wp=NULL;break; }
            if (a1=='.') {
                if ( fpflag ) {
                    break;
                }
                a2=*(wp+1);
                if ((a2<0x30)||(a2>0x39)) break;
                wp_bak = wp;
                ft_bak = a;
                fpflag = 3;
                //fpflag = -1;
                s3[a++]=a1;wp++;
                continue;
            }
            if ((a1<0x30)||(a1>0x39)) break;
            s3[a++]=a1;
            wp++;
        }
        s3[a]=0;
        if ( wp != NULL ) {
            if ( *wp=='k' ) { fpflag=1;wp++; }
            if ( *wp=='f' ) { fpflag=2;wp++; }
            if ( *wp=='d' ) { fpflag=3;wp++; }
            if ( *wp=='e' ) { fpflag=4;wp++; }
        }
        if ( fpflag<0 ) {				// 小数値でない時は「.」までで終わり
            s3[ft_bak] = 0;
            wp = wp_bak;
            fpflag = 0;
        }
        switch( fpflag ) {
            case 0:					// 通常の整数
                val=atoi_allow_overflow((char *)s3);
                if ( minmode ) val=-val;
                break;
            case 1:					// int固定小数
                val_d = atof( (char *)s3 );
                val = (int)( val_d * fpbit );
                if ( minmode ) val=-val;
                break;
            case 2:					// int形式のfloat値を返す
                val_f = (float)atof( (char *)s3 );
                if ( minmode ) val_f=-val_f;
                fpival = (int *)&val_f;
                val = *fpival;
                break;
            case 4:					// double値(指数表記)
                s3[a++]='e';
                a1 = *wp;
                if (( a1=='-' )||( a1=='+' )) {
                    s3[a++] = a1;
                    wp++;
                }
                while(1) {
                    a1=*wp;
                    if ((a1<0x30)||(a1>0x39)) break;
                    s3[a++]=a1;wp++;
                }
                s3[a]=0;
            case 3:					// double値
                val_d = atof( (char *)s3 );
                if ( minmode ) val_d=-val_d;
                return TK_DNUM;
        }
        return TK_NUM;
    }
    if (a1==0x22) {							// when "string"
        wp++;
        [self Pickstr];
        return TK_STRING;
    }
    if (a1==0x27) {							// when 'char'
        wp++;
        wp = (unsigned char *)[self Pickstr2:(char *)wp];
        val=*(unsigned char *)s3;
        return TK_NUM;
    }
    if (rval==TK_NONE) {					// token code
        wp++;an=*wp;
        if (a1=='!') {
            if (an=='=') wp++;
        }
        /*
         else if (a1=='<') {
         if (an=='<') { wp++;a1=0x63; }	// '<<'
         if (an=='=') { wp++;a1=0x61; }	// '<='
         }
         else if (a1=='>') {
         if (an=='>') { wp++;a1=0x64; }	// '>>'
         if (an=='=') { wp++;a1=0x62; }	// '>='
         }
         */
        else if (a1=='=') {
            if (an=='=') { wp++; }			// '=='
        }
        else if (a1=='|') {
            if (an=='|') { wp++; }			// '||'
        }
        else if (a1=='&') {
            if (an=='&') { wp++; }			// '&&'
        }
        s3[0]=a1;s3[1]=0;
        return a1;
    }
    while(1) {								// normal object name
        int skip,i;
        a1=*wp;
        if (a1==0) { wp=NULL;break; }
        if (a1<0x30) break;
        if ((a1>=0x3a)&&(a1<=0x3f)) break;
        if ((a1>=0x5b)&&(a1<=0x5e)) break;
        if ((a1>=0x7b)&&(a1<=0x7f)) break;
        if ( a>=OBJNAME_MAX ) break;
        //if (a1>=129) {						// 全角文字チェック
        skip = [self SkipMultiByte:a1]; // 全角文字チェック
        if ( skip ) {
            //if (a1<=159) { s3[a++]=a1;wp++;a1=*wp; }
            //else if (a1>=224) { s3[a++]=a1;wp++;a1=*wp; }
            for(i=0;i<skip;i++) {
                s3[a++]=a1;wp++;a1=*wp;
            }
        }
        s3[a++]=a1;wp++;
    }
    s3[a]=0;
    return TK_OBJ;
}
-(int)PeekToken {
    // 戻すのは wp のみ。
    // s3, val, val_f, val_d などは戻されない
    unsigned char *wp_bak = wp;
    int result = [self GetToken];
    wp = wp_bak;
    return result;
}
-(void)Calc_token {
    lasttoken = (char *)wp;
    ttype = [self GetToken];
}
-(void)Calc_factor:(CALCVAR &)v {
    CALCVAR v1;
    int id,type;
    char *ptr_dval;
    if ( ttype==TK_NUM ) {
        v=(CALCVAR)val;
        [self Calc_token];
        return;
    }
    if ( ttype==TK_DNUM ) {
        v=(CALCVAR)val_d;
        [self Calc_token];
        return;
    }
    if ( ttype==TK_OBJ ) {
        id = [lb Search:(char *)s3];
        if ( id == -1 ) { ttype=TK_CALCERROR; return; }
        type = [lb GetType:id];
        if ( type != LAB_TYPE_PPVAL ) { ttype=TK_CALCERROR; return; }
        ptr_dval = [lb GetData2:id];
        if ( ptr_dval == NULL ) {
            v = (CALCVAR)[lb GetOpt:id];
        } else {
            v = *(CALCVAR *)ptr_dval;
        }
        [self Calc_token];
        return;
    }
    if( ttype!='(' ) { ttype=TK_ERROR; return; }
    [self Calc_token];
    [self Calc_start:v1];
    if( ttype!=')' ) { ttype=TK_CALCERROR; return; }
    [self Calc_token];
    v=v1;
}
-(void)Calc_unary:(CALCVAR &)v {
    CALCVAR v1;
    int op;
    if ( ttype=='-' ) {
        op=ttype;
        [self Calc_token];
        [self Calc_unary:v1];
        v1 = -v1;
    } else {
        [self Calc_factor:v1];
    }
    v=v1;
}
-(void)Calc_muldiv:(CALCVAR &)v {
    CALCVAR v1,v2;
    int op;
    [self Calc_unary:v1];
    while( (ttype=='*')||(ttype=='/')||(ttype==0x5c)) {
        op=ttype;
        [self Calc_token];
        [self Calc_unary:v2];
        if (op=='*')
            v1*=v2;
        else if (op=='/') {
            if ( (int)v2==0 ) {
                ttype=TK_CALCERROR;
                return;
            }
            v1/=v2;
        } else if (op==0x5c) {
            if ( (int)v2==0 ) {
                ttype=TK_CALCERROR;
                return;
            }
            v1 = fmod( v1, v2 );
        }
    }
    v=v1;
}
-(void)Calc_addsub:(CALCVAR &)v {
    CALCVAR v1,v2;
    int op;
    [self Calc_muldiv:v1];
    while( (ttype=='+')||(ttype=='-')) {
        op=ttype;
        [self Calc_token];
        [self Calc_muldiv:v2];
        if (op=='+') v1+=v2;
        else if (op=='-') v1-=v2;
    }
    v=v1;
}
-(void)Calc_compare:(CALCVAR &)v {
    CALCVAR v1,v2;
    int v1i = 0,v2i,op;
    [self Calc_addsub:v1];
    while( (ttype=='<')||(ttype=='>')||(ttype=='=')) {
        op=ttype;
        [self Calc_token];
        if (op=='=') {
            [self Calc_addsub:v2];
            v1i = v1==v2;
            v1=(CALCVAR)v1i;
            continue;
        }
        if (op=='<') {
            if ( ttype=='=' ) {
                [self Calc_token];
                [self Calc_addsub:v2];
                v1i=(v1<=v2);
                v1=(CALCVAR)v1i;
                continue;
            }
            if ( ttype=='<' ) {
                [self Calc_token];
                [self Calc_addsub:v2];
                v1i = (int)v1;
                v2i = (int)v2;
                v1i<<=v2i;
                v1=(CALCVAR)v1i;
                continue;
            }
            [self Calc_addsub:v2];
            v1i=(v1<v2);
            v1=(CALCVAR)v1i;
            continue;
        }
        if (op=='>') {
            if ( ttype=='=' ) {
                [self Calc_token];
                [self Calc_addsub:v2];
                v1i=(v1>=v2);
                v1=(CALCVAR)v1i;
                continue;
            }
            if ( ttype=='>' ) {
                [self Calc_token];
                [self Calc_addsub:v2];
                v1i = (int)v1;
                v2i = (int)v2;
                v1i>>=v2i;
                v1=(CALCVAR)v1i;
                continue;
            }
            [self Calc_addsub:v2];
            v1i=(v1>v2);
            v1=(CALCVAR)v1i;
            continue;
        }
        v1=(CALCVAR)v1i;
    }
    v=v1;
}
-(void)Calc_bool2:(CALCVAR &)v {
    CALCVAR v1,v2;
    int v1i,v2i;
    [self Calc_compare:v1];
    while( ttype=='!') {
        [self Calc_token];
        [self Calc_compare:v2];
        v1i = (int)v1;
        v2i = (int)v2;
        v1i = v1i != v2i;
        v1=(CALCVAR)v1i;
    }
    v=v1;
}
-(void)Calc_bool:(CALCVAR &)v {
    CALCVAR v1,v2;
    int op,v1i,v2i;
    [self Calc_bool2:v1];
    while( (ttype=='&')||(ttype=='|')||(ttype=='^')) {
        op=ttype;
        [self Calc_token];
        [self Calc_bool2:v2];
        v1i = (int)v1;
        v2i = (int)v2;
        if (op=='&') v1i&=v2i;
        else if (op=='|') v1i|=v2i;
        else if (op=='^') v1i^=v2i;
        v1=(CALCVAR)v1i;
    }
    v=v1;
}
-(void)Calc_start:(CALCVAR &)v {
    //		entry point
    [self Calc_bool:v];
}
-(int)Calc:(CALCVAR &)val {
    CALCVAR v;
    [self Calc_token];
    [self Calc_start:v];
    if ( ttype == TK_CALCERROR ) {
        [self SetError:(char *)"abnormal calculation"];
        return -1;
    }
    if ( wp==NULL ) { val = v; return 0; }
    if ( *wp==0 ) { val = v; return 0; }
    [self SetError:(char *)"expression syntax error"];
    return -1;
}
-(char*)ExpandStr:(char*)str opt:(int)opt {
    //		指定文字列をmembufへ展開する
    //			opt:0=行末までスキップ/1="まで/2='まで
    //
    int a;
    unsigned char *vs;
    unsigned char a1;
    unsigned char sep;
    int skip,i;
    vs = (unsigned char *)str;
    a = 0;
    sep = 0;
    if (opt==1) sep=0x22;
    if (opt==2) sep=0x27;
    s3[a++]=sep;
    while(1) {
        a1=*vs;
        if (a1==0) break;
        if (a1==sep) { vs++;break; }
        if ((a1<32)&&(a1!=9)) break;
        s3[a++]=a1;vs++;
        if (a1==0x5c) {					// '\'チェック
            s3[a++] = *vs++;
        }
        // 全角文字チェック＊
        //if (a1>=129) {
        //    if ((a1<=159)||(a1>=224)) {
        skip = [self SkipMultiByte:a1]; // 全角文字チェック
        if ( skip ) {
            for( i=0;i<skip;i++ ) {
                //NSLog(@"D:%s",str);
                s3[a++] = *vs++;
            }
        }
//        uint8 c = a1;
//        //if (c >= 0 && c < 128) { return 1; }
//        if (c >= 128 && c < 192) { s3[a++] = *vs++; }
//        if (c >= 192 && c < 224) { s3[a++] = *vs++; }
//        if (c >= 224 && c < 240) { s3[a++] = *vs++; s3[a++] = *vs++; }
//        if (c >= 240 && c < 248) { s3[a++] = *vs++; s3[a++] = *vs++; s3[a++] = *vs++; }
//        if (c >= 248 && c < 252) { s3[a++] = *vs++; s3[a++] = *vs++; s3[a++] = *vs++; s3[a++] = *vs++; }
//        if (c >= 252 && c < 254) { s3[a++] = *vs++; s3[a++] = *vs++; s3[a++] = *vs++; s3[a++] = *vs++; s3[a++] = *vs++; }
//        if (c >= 254 && c <= 255) { s3[a++] = *vs++; s3[a++] = *vs++; s3[a++] = *vs++; s3[a++] = *vs++; s3[a++] = *vs++; }
    }
    s3[a++]=sep;
    s3[a]=0;
    if ( opt!=0 ) {
        if (wrtbuf!=NULL)
            [wrtbuf PutData:s3 sz:a];
    }
    return (char *)vs;
}
-(char*)ExpandAhtStr:(char*)str {
    //		コメントを展開する
    //		( ;;に続くAHT指定文字列用 )
    //
    unsigned char *vs;
    unsigned char a1;
    vs = (unsigned char *)str;    while(1) {
        a1=*vs;
        if (a1==0) break;
        if ((a1<32)&&(a1!=9)) break;
        vs++;
    }
    return (char *)vs;
}
-(char*)ExpandStrEx:(char*)str {
    //		指定文字列をmembufへ展開する
    //		( 複数行対応 {"〜"} )
    //
    int a;
    unsigned char *vs;
    unsigned char a1;
    int skip,i;
    vs = (unsigned char *)str;
    a = 0;
    //s3[a++]=0x22;
    while(1) {
        a1=*vs;
        if (a1==0) {
            //s3[a++]=13; s3[a++]=10;
            break;
        }
        if (a1==13) {
            s3[a++]=0x5c; s3[a++]='n';
            vs++;
            if (*vs==10) { vs++; }
            continue;
        }
        if (a1==10) {
            s3[a++]=0x5c; s3[a++]='n';
            vs++;
            continue;
        }
        //		if ((a1<32)&&(a1!=9)) break;
        if (a1==0x22) {
            if (vs[1]=='}') {
                s3[a++]=0x22; s3[a++]='}';
                mulstr=LMODE_ON; vs+=2;
                break;
            }
            s3[a++]=0x5c; s3[a++]=0x22;
            vs++;
            continue;
        }
        s3[a++]=a1;vs++;
        if (a1==0x5c) {					// '\'チェック
            if (*vs>=32) { s3[a++] = *vs; vs++; }
        }
        skip = [self SkipMultiByte:a1]; // 全角文字チェック
        if ( skip ) {
            for(i=0;i<skip;i++) {
        //if (a1>=129) {					// 全角文字チェック
        //    if ((a1<=159)||(a1>=224)) {
                s3[a++] = *vs++;
            }
        }
    }
    //s3[a++]=0x22;
    s3[a]=0;
    if (wrtbuf!=NULL) {
        [wrtbuf PutData:s3 sz:a];
    }
    return (char *)vs;
}
-(char*)ExpandStrComment:(char*)str opt:(int)opt {
    //		/*〜*/ コメントを展開する
    //
    int a;
    unsigned char *vs;
    unsigned char a1;
    vs = (unsigned char *)str;
    a = 0;
    while(1) {
        a1=*vs;
        if (a1==0) {
            //s3[a++]=13; s3[a++]=10;
            break;
        }
        if (a1=='*') {
            if (vs[1]=='/') {
                mulstr=LMODE_ON; vs+=2; break;
            }
            vs++;
            continue;
        }
        vs++;
        //if (a1>=129) {					// 全角文字チェック
        //    if ((a1<=159)||(a1>=224)) vs++;
        //}
        vs += [self SkipMultiByte:a1];    // 全角文字チェック
    }
    s3[a]=0;
    if ( opt==0 ) {
        if (wrtbuf!=NULL) {
            [wrtbuf PutData:s3 sz:a];
        }
    }
    return (char *)vs;
}
-(char*)ExpandHex:(char*)str val:(int*)val {
    //		16進数文字列をmembufへ展開する
    //
    int a,b,num;
    unsigned char *vs;
    unsigned char a1;
    vs = (unsigned char *)str;
    s3[0]='$';
    a=1;
    num=0;
    while(1) {
        a1=toupper(*vs);b=-1;
        if ((a1>=0x30)&&(a1<=0x39)) b=a1-0x30;
        if ((a1>=0x41)&&(a1<=0x46)) b=a1-55;
        if (a1=='_') b=-2;
        if (b==-1) break;
        if (b>=0) { s3[a++]=a1;num=(num<<4)+b; }
        vs++;
    }
    s3[a]=0;
    if (wrtbuf!=NULL) {
        [wrtbuf PutData:s3 sz:a];
    }
    *val = num;
    return (char *)vs;
}
-(char*)ExpandBin:(char*)str aval:(int*)val {
    //		2進数文字列をmembufへ展開する
    //
    int a,b,num;
    unsigned char *vs;
    unsigned char a1;
    vs = (unsigned char *)str;
    s3[0]='%';
    a=1;
    num=0;
    while(1) {
        a1=*vs;b=-1;
        if ((a1>=0x30)&&(a1<=0x31)) b=a1-0x30;
        if (a1=='_') b=-2;
        if (b==-1) break;
        if (b>=0) { s3[a++]=a1;num=(num<<1)+b; }
        vs++;
    }
    s3[a]=0;
    if (wrtbuf!=NULL) {
        [wrtbuf PutData:s3 sz:a];
    }
    return (char *)vs;
}
-(char*)ExpandToken:(char*)str type:(int*)type ppmode:(int)ppmode {
    //		stringデータをmembufへ展開する
    //			ppmode : 0=通常、1=プリプロセッサ時
    //
    int a,chk,id,ltype,opt;
    int flcnt;
    unsigned char *vs;
    unsigned char *vs_bak;
    unsigned char a1;
    unsigned char a2;
    unsigned char *vs_modbrk;
    char cnvstr[80];
    char fixname[256];
    char *macptr;
    vs = (unsigned char *)str;
    if ( vs==NULL ) {
        *type = TK_EOF;
        return NULL;			// already end
    }
    a1=*vs;
    if (a1==0) {							// end
        *type = TK_EOF;
        return NULL;
    }
    if (a1==10) {							// Unix改行
        vs++;
        if (wrtbuf!=NULL) {
            [wrtbuf PutStr:(char *)"\r\n"];
        }
        *type = TK_EOL;
        return (char *)vs;
    }
    if (a1==13) {							// 改行
        vs++;if ( *vs==10 ) vs++;
        if (wrtbuf!=NULL) {
            [wrtbuf PutStr:(char *)"\r\n"];
        }
        *type = TK_EOL;
        return (char *)vs;
    }
    if (a1==';') {							// コメント
        *type = TK_VOID;
        *vs=0;
        vs++;
        if ( *vs == ';' ) {
            vs++;
            //if ( ahtmodel != NULL ) {
                //ahtkeyword = (char *)vs;
            //}
        }
        return [self ExpandStr:(char *)vs opt:0];
    }
    if (a1=='/') {							// Cコメント
        if (vs[1]=='/') {
            *type = TK_VOID;
            *vs=0;
            return [self ExpandStr:(char *)vs+2 opt:0];
        }
        if (vs[1]=='*') {
            mulstr = LMODE_COMMENT;
            *type = TK_VOID;
            *vs=0;
            return [self ExpandStrComment:(char *)vs+2 opt:0];
        }
    }
    if (a1==0x22) {							// "〜"
        *type = TK_STRING;
        return [self ExpandStr:(char *)vs+1 opt:1];
    }
    if (a1==0x27) {							// '〜'
        *type = TK_STRING;
        return [self ExpandStr:(char *)vs+1 opt:2];
    }
    if (a1=='{') {							// {"〜"}
        if (vs[1]==0x22) {
            if (wrtbuf!=NULL)
                [wrtbuf PutStr:(char *)"{\""];
            mulstr = LMODE_STR;
            *type = TK_STRING;
            return [self ExpandStrEx:(char *)vs+2];
        }
    }
    if (a1=='0') {
        a2=vs[1];
        if (a2=='x') { vs++;a1='$'; }		// when hex code (0x)
        if (a2=='b') { vs++;a1='%'; }		// when bin code (0b)
    }
    if (a1=='$') {							// when hex code ($)
        *type = TK_OBJ;
        return [self ExpandHex:(char *)vs+1 val:&a];
    }
    if (a1=='%') {							// when bin code (%)
        *type = TK_OBJ;
        return [self ExpandBin:(char *)vs+1 val:&a];
    }
    if (a1<0x30) {							// space,tab
        *type = TK_CODE;
        vs++;
        if (wrtbuf!=NULL)
            [wrtbuf Put_char:(char)a1];
        return (char *)vs;
    }
    chk=0;
    if ((a1>=0x3a)&&(a1<=0x3f)) chk++;
    if ((a1>=0x5b)&&(a1<=0x5e)) chk++;
    if ((a1>=0x7b)&&(a1<=0x7f)) chk++;
    if (chk) {
        vs++;
        if (wrtbuf!=NULL)
            [wrtbuf Put_char:(char)a1];		// 記号
        *type = a1;
        return (char *)vs;
    }
    if ((a1>=0x30)&&(a1<=0x39)) {			// when 0-9 numerical
        a=0; flcnt=0;
        while(1) {
            a1=*vs;
            if ( a1 == '.' ) {
                flcnt++;if ( flcnt>1 ) break;
            } else {
                if ((a1<0x30)||(a1>0x39)) break;
            }
            s2[a++]=a1;vs++;
        }
        if (( a1=='k' )||( a1=='f' )||( a1=='d' )) { s2[a++]=a1; vs++; }
        if ( a1 == 'e' ) {
            s2[a++]=a1; vs++;
            a1=*vs;
            if (( a1=='-' )||( a1=='+' )) {
                s2[a++] = a1;
                vs++;
            }
            while(1) {
                a1=*vs;
                if ((a1<0x30)||(a1>0x39)) break;
                s2[a++]=a1;vs++;
            }
        }
        s2[a]=0;
        if (wrtbuf!=NULL)
            [wrtbuf PutData:s2 sz:a];
        *type = TK_OBJ;
        return (char *)vs;
    }
    a=0;
    vs_modbrk = NULL;
    /*
     if ( ppmode ) {					// プリプロセッサ時は#を含めてキーワードとする
     s2[a++]='#';
     }
     */
    //	 シンボル取り出し
    //
    while(1) {
        int skip,i;
        a1=*vs;
        //if ((a1>='A')&&(a1<='Z')) a1+=0x20;		// to lower case
        //if (a1>=129) {				// 全角文字チェック＊
        skip = [self SkipMultiByte:a1];                 // 全角文字チェック
        if ( skip ) {
            //if ((a1<=159)||(a1>=224)) {
            for(i=0;i<(skip+1);i++) {
                NSLog(@"E:%s",str);
                if ( a<OBJNAME_MAX ) {
                    s2[a++]=a1;
                    vs++;
                    a1=*vs;
                    //if (a1>=32) { s2[a++] = a1; vs++; }
                    //s2[a++] = a1; vs++;
                } else {
                    //vs+=2;
                    vs++;
                }
            }
            continue;
        }
        chk=0;
        if (a1<0x30) chk++;
        if ((a1>=0x3a)&&(a1<=0x3f)) chk++;
        if ((a1>=0x5b)&&(a1<=0x5e)) chk++;
        if ((a1>=0x7b)&&(a1<=0x7f)) chk++;
        if ( chk ) break;
        vs++;
        //		if ( a1=='@' ) if ( *vs==0 ) {
        //			vs_modbrk = s2+a;
        //		}
        if ( a<OBJNAME_MAX )
            s2[a++]=a1;
    }
    s2[a]=0;
    if ( *s2=='@' ) {
        if (wrtbuf!=NULL) [wrtbuf PutData:s2 sz:a];
        *type = TK_CODE;
        return (char *)vs;
    }
    //		シンボル検索
    //
    strcase2( (char *)s2, fixname );
    //	if ( vs_modbrk != NULL ) *vs_modbrk = 0;
    [self FixModuleName:(char *)s2];
    [self AddModuleName:fixname];
    id = [lb SearchLocal:(char *)s2 loname:fixname];
    if ( id!=-1 ) {
        ltype = [lb GetType:id];
        switch( ltype ) {
            case LAB_TYPE_PPVAL:
            {
                //		constマクロ展開
                char *ptr_dval;
                ptr_dval = [lb GetData2:id];
                if ( ptr_dval == NULL ) {
                    sprintf( cnvstr, "%d", [lb GetOpt:id] );
                } else {
                    sprintf( cnvstr, "%f", *(CALCVAR *)ptr_dval );
                }
                chk = [self ReplaceLineBuf:str str2:(char *)vs repl:cnvstr macopt:0 macdef:NULL];
                break;
            }
            case LAB_TYPE_PPINTMAC:
                //		内部マクロ
                //
                if ( ppmode ) {//	プリプロセッサ時はそのまま展開
                    if (wrtbuf!=NULL) {
                        [self FixModuleName:(char *)s2];
                        [wrtbuf PutStr:(char *)s2];
                    }
                    *type = TK_OBJ;
                    return (char *)vs;
                }
            case LAB_TYPE_PPMAC:
                //		マクロ展開
                //
                vs_bak = vs;
                while(1) {		// 直後のspace/tabを除去
                    a1=*vs_bak;
                    if ((a1!=32)&&(a1!=9)) break;
                    vs_bak++;
                }
                opt = [lb GetOpt:id];
                if (( a1 == '=' )&&( opt & PRM_MASK ) ) {	// マクロに代入しようとした場合のエラー
                    [self SetError:(char *)"Reserved word syntax error"];
                    *type = TK_ERROR;
                    return (char *)vs;
                }
                //
                macptr = [lb GetData:id];
                if ( macptr == NULL ) {
                    *cnvstr=0;
                    macptr=cnvstr;
                }
                chk = [self ReplaceLineBuf:str str2:(char *)vs repl:macptr macopt:opt macdef:(MACDEF *)[lb GetData2:id]];
                break;
            case LAB_TYPE_PPDLLFUNC:
                //		モジュール名付き展開キーワード
                if (wrtbuf!=NULL) {
                    //				AddModuleName( (char *)s2 );
                    if ( [lb GetEternal:id] ) {
                        [self FixModuleName:(char *)s2];
                        [wrtbuf PutStr:(char *)s2];
                    } else {
                        [wrtbuf PutStr:fixname];
                    }
                }
                *type = TK_OBJ;
                if ( *modname == 0 ) {
                    [lb AddReference:id];
                } else {
                    int i;
                    i = [lb Search:[self GetModuleName]];
                    if ( [lb SearchRelation:id rel_id:i] == 0 ) {
                        [lb AddRelation:id rel_id:i];
                    }
                }
                return (char *)vs;
                break;
            case LAB_TYPE_COMVAR:
                //		COMキーワードを展開
                if (wrtbuf!=NULL) {
                    if ( [lb GetEternal:id] ) {
                        [self FixModuleName:(char *)s2];
                        [wrtbuf PutStr:(char *)s2];
                    } else {
                        [wrtbuf PutStr:fixname];
                    }
                }
                *type = TK_OBJ;
                [lb AddReference:id];
                return (char *)vs;
            case LAB_TYPE_PPMODFUNC:
            default:
                //		通常キーワードはそのまま展開
                if (wrtbuf!=NULL) {
                    if ( ![lb GetEternal:id] ) { // local func
                        strcpy((char*)s2, [lb GetName:id]);
                    }
                    [self FixModuleName:(char *)s2];
                    [wrtbuf PutStr:(char *)s2];
                }
                *type = TK_OBJ;
                [lb AddReference:id];
                return (char *)vs;
        }
        if ( chk ) {
            *type = TK_ERROR;
            return str;
        }
        *type = TK_OBJ;
        return str;
    }
    //		登録されていないキーワードを展開
    //
    if (wrtbuf!=NULL) {
        //		AddModuleName( (char *)s2 );
        if ( strcmp( (char *)s2, fixname ) ) {
            //	後ろで定義されている関数の呼び出しのために
            //	モジュール内で@をつけていない識別子の位置を記録する
            undefined_symbol_t sym;
            sym.pos = [wrtbuf GetSize];
            sym.len_include_modname = (int)strlen( fixname );
            sym.len = (int)strlen( (char *)s2 );
            undefined_symbols.push_back( sym );
        }
        [wrtbuf PutStr:fixname];
        //		wrtbuf->Put( '?' );
    }
    *type = TK_OBJ;
    return (char *)vs;
}
-(char*)SkipLine:(char*)str pline:(int*)pline {
    //		strから改行までをスキップする
    //		( 行末に「\」で次行を接続 )
    //
    unsigned char *vs;
    unsigned char a1;
    unsigned char a2;
    vs = (unsigned char *)str;
    a2=0;
    while(1) {
        a1=*vs;
        if (a1==0) break;
        if (a1==13) {
            pline[0]++;
            vs++;if ( *vs==10 ) vs++;
            if ( a2!=0x5c ) break;
            continue;
        }
        if (a1==10) {
            pline[0]++;
            vs++;
            if ( a2!=0x5c ) break;
            continue;
        }
        if ((a1<32)&&(a1!=9)) break;
        vs++;a2=a1;
    }
    return (char *)vs;
}
-(char*)SendLineBuf:(char*)str {
    //		１行分のデータをlinebufに転送
    //
    char *p;
    char *w;
    char a1;
    p = str;
    w = linebuf;
    while(1) {
        a1 = *p;if ( a1==0 ) break;
        p++;
        if ( a1 == 10 ) break;
        if ( a1 == 13 ) {
            if ( *p==10 ) p++;
            break;
        }
        *w++=a1;
    }
    *w=0;
    return p;
}
#define IS_CHAR_HEAD(str, pos) \
is_sjis_char_head((unsigned char *)(str), (int)((pos) - (unsigned char *)(str)))
-(char*)SendLineBufPP:(char*)str lines:(int*)lines {
    //		１行分のデータをlinebufに転送
    //			(行末の'\'は継続 linesに行数を返す)
    //
    unsigned char *p;
    unsigned char *w;
    unsigned char a1,a2;
    int ln;
    p = (unsigned char *)str;
    w = (unsigned char *)linebuf;
    a2 = 0; ln =0;
    while(1) {
        a1 = *p;if ( a1==0 ) break;
        p++;
        if ( a1 == 10 ) {
            if ( a2==0x5c && IS_CHAR_HEAD(str, p - 2) ) {
                ln++; w--; a2=0; continue;
            }
            break;
        }
        if ( a1 == 13 ) {
            if ( a2==0x5c && IS_CHAR_HEAD(str, p - 2) ) {
                if ( *p==10 ) p++;
                ln++; w--; a2=0; continue;
            }
            if ( *p==10 ) p++;
            break;
        }
        *w++=a1; a2=a1;
    }
    *w=0;
    *lines = ln;
    return (char *)p;
}
#undef IS_CHAR_HEAD
-(char*)ExpandStrComment2:(char*)str {
    //		"*/" で終端していない場合は NULL を返す
    //
    int mulstr_bak = mulstr;
    mulstr = LMODE_COMMENT;
    char *result = [self ExpandStrComment:str opt:1];
    if ( mulstr == LMODE_COMMENT ) {
        result = NULL;
    }
    mulstr = mulstr_bak;
    return result;
}
-(int)ReplaceLineBuf:(char*)str1 str2:(char*)str2 repl:(char*)repl opt:(int)opt macdef:(MACDEF*)macdef {
    //		linebufのキーワードを置き換え
    //		(linetmpを破壊します)
    //			str1 : 置き換え元キーワード先頭(linebuf内)
    //			str2 : 置き換え元キーワード次ptr(linebuf内)
    //			repl : 置き換えキーワード
    //			macopt : マクロ添字の数
    //
    //		return : 0=ok/1=error
    //
    char *w;
    char *w2;
    char *p;
    char *endp;
    char *prm[32];
    char *prme[32];
    char *last;
    char *macbuf;
    char *macbuf2;
    char a1;
    char dummy[4];
    char mactmp[128];
    int i,flg,type,cnvfnc, tagid, stklevel;
    int macopt, ctype, noprm, kakko;
    i = 0; flg = 1; cnvfnc = 0; ctype = 0; kakko = 0;
    macopt = opt & PRM_MASK;
    if ( opt & PRM_FLAG_CTYPE ) ctype=1;
    *dummy = 0;
    strcpy( linetmp, str2 );
    wp = (unsigned char *)linetmp;
    if (( macopt )||( ctype )) {
        p = (char *)wp;
        type = [self GetToken];
        if ( ctype ) {
            if ( type!='(' ) {
                [self SetError:(char *)"ctypeマクロの直後には、丸括弧でくくられた引数リストが必要です" ];
                return 4;
            }
            p = (char *)wp;
            type = [self GetToken];
        }
        if ( type != TK_NONE ) {
            wp = (unsigned char *)p;
            prm[i]=p;
            while(1) {					// マクロパラメータを取り出す
                p = (char *)wp;
                type = [self GetToken];
                if ( type==';' ) type = TK_SEPARATE;
                if ( type=='}' ) type = TK_SEPARATE;
                if ( type=='/' ) {		// Cコメント??
                    if (*wp=='/') { type = TK_SEPARATE; }
                    if (*wp=='*') {
                        char *start = (char *)wp-1;
                        char *end = [self ExpandStrComment2:start+2];
                        if ( end == NULL ) {	// 範囲コメントが次の行まで続いている
                            type = TK_SEPARATE;
                        } else {
                            wp = (unsigned char *)end;
                        }
                    }
                }
                if ( flg ) {
                    flg=0;
                    prm[i]=p;
                    if ( type == TK_NONE ) {
                        prme[i++]=p;
                        break;
                    }
                }
                if ( type==TK_SEPARATE ) {
                    wp = (unsigned char *)p;
                    prme[i++]=(char *)wp;
                    break;
                }
                if ( wp==NULL ) {
                    prme[i++]=NULL; break;
                }
                if ( type==',' ) {
                    if ( kakko == 0 ) {	// カッコに囲まれている場合は無視する
                        prme[i]=p;
                        flg=1;i++;
                    }
                }
                if ( ctype == 0 ) {		// 通常時のカッコ処理
                    if ( type=='(' ) kakko++;
                    if ( type==')' ) kakko--;
                } else {				// Cタイプ時のカッコ処理
                    if ( type=='(' ) { kakko++; ctype++; }
                    if ( type==')' ) {
                        kakko--;
                        if ( ctype==1 ) {
                            wp = (unsigned char *)p;
                            prme[i++]=(char *)wp;
                            while(1) {
                                if ((*wp!=32)&&(*wp!=9)) break;
                                wp++;
                            }
                            *wp = 32;		// ')'をspaceに
                            break;
                        }
                        ctype--;
                    }
                }
            }
        }
        if ( i>macopt ) {
            noprm=1;
            if (( ctype )&&( i==1 )&&( macopt==0 )&&( prm[0] == prme[0] )) noprm=0;
            if ( noprm ) {
                [self SetError:(char *)"マクロの引数が多すぎます"];
                return 3;
            }
        }
        while(1) {					// 省略パラメータを補完
            if ( i>=macopt ) break;
            prm[i]=dummy; prme[i]=dummy;
            i++;
        }
        //		{ int a;for(a=0;a<i;a++) {
        //			sprintf( errtmp,"[%d][%s]",a,prm[a] );Alert( errtmp );
        //		} }
    }
    last = (char *)wp;
    tagid = 0x10000;
    w = str1;
    wp = (unsigned char *)repl;
    while(1) {					// マクロ置き換え
        if ( wp==NULL ) break;
        if ( w>=linetmp ) {
            [self SetError:(char *)"macro buffer overflow"];
            return 4;
        }
        a1=*wp++;if (a1==0) break;
        if (a1=='%') {
            if (*wp=='%') {
                *w++=a1;
                wp++;
                continue;
            }
            type = [self GetToken];
            if ( type==TK_OBJ ) {			// 特殊コマンドラベル処理
                macbuf = mactmp;
                *mactmp=0; a1 = tolower( (int)*s3 );
                switch( a1 ) {
                    case 't':					// %tタグ名
                        tagid = [tstack GetTagID:(char *)(s3+1)];
                        break;
                    case 'i':
                        [tstack GetTagUniqueName:tagid outname:mactmp];
                        [tstack PushTag:tagid str:mactmp];
                        if ( s3[1]=='0' ) *mactmp=0;
                        break;
                    case 's':
                        val = (int)(s3[1]-48);val--;
                        if ( !( 0 <= val && val <= macopt - 1 ) ) {
                            [self SetError:(char *)"illegal macro parameter %s"];
                            return 2;
                        }
                        w2 = mactmp;
                        p = prm[val]; endp = prme[val];
                        if ( p==endp ) {				// 値省略時
                            macbuf2 = macdef->data + macdef->index[val];
                            while(1) {
                                a1=*macbuf2++;if (a1==0) break;
                                *w2++ = a1;
                            }
                        } else {
                            while(1) {						// %numマクロ展開
                                if ( p==endp ) break;
                                a1 = *p++;if ( a1==0 ) break;
                                *w2++ = a1;
                            }
                        }
                        *w2=0;
                        [tstack PushTag:tagid str:mactmp];
                        *mactmp=0;
                        break;
                    case 'n':
                        [tstack GetTagUniqueName:tagid outname:mactmp];
                        break;
                    case 'p':
                        stklevel = (int)(s3[1]-48);
                        if (( stklevel<0 )||( stklevel>9 )) stklevel=0;
                        macbuf = [tstack LookupTag:tagid level:stklevel];
                        break;
                    case 'o':
                        if ( s3[1]!='0' ) {
                            macbuf = [tstack PopTag:tagid];
                        } else {
                            [tstack PopTag:tagid];
                        }
                        break;
                    case 'c':
                        mactmp[0]=0x0d; mactmp[1]=0x0a; mactmp[2]=0;
                        break;
                    default:
                        macbuf = NULL;
                        break;
                }
                if ( macbuf == NULL ) {
                    sprintf( mactmp, "macro syntax error [%s]",[tstack GetTagName:tagid] );
                    [self SetError:mactmp];
                    return 2;
                }
                while(1) {					//mactmp展開
                    a1 = *macbuf++;if ( a1==0 ) break;
                    *w++ = a1;
                }
                if ( wp!=NULL ) {
                    a1=*wp;if (a1==' ') wp++;	// マクロ後のspace除去
                }
                continue;
            }
            if ( type!=TK_NUM ) {
                [self SetError:(char *)"macro parameter invalid"];
                return 1;
            }
            val--;
            if ( !( 0 <= val && val <= macopt - 1 ) ) {
                [self SetError:(char *)"illegal macro parameter"];
                return 2;
            }
            p = prm[val]; endp = prme[val];
            if ( p==endp ) {				// 値省略時
                macbuf = macdef->data + macdef->index[val];
                if ( *macbuf == 0 ) {
                    [self SetError:(char *)"デフォルトパラメータのないマクロの引数は省略できません"];
                    return 5;
                }
                while(1) {
                    a1=*macbuf++;if (a1==0) break;
                    *w++ = a1;
                }
                continue;
            }
            while(1) {						// %numマクロ展開
                if ( p==endp ) break;
                a1 = *p++;if ( a1==0 ) break;
                *w++ = a1;
            }
            continue;
        }
        *w++ = a1;
    }
    *w = 0;
    if ( last!=NULL ) {
        if ( w + strlen(last) + 1 >= linetmp ) {
            [self SetError:(char *)"macro buffer overflow"];
            return 4;
        }
        strcpy( w, last );
    }
    return 0;
}
-(ppresult_t)PP_SwitchStart:(int)sw {
    if ( swsp==0 ) { swflag = 1; swlevel = LMODE_ON; }
    if ( swsp >= SWSTACK_MAX ) {
        [self SetError:(char *)"#if nested too deeply"];
        return PPRESULT_ERROR;
    }
    swstack[swsp] = swflag;				// 有効フラグ
    swstack2[swsp] = swmode;			// elseモード
    swstack3[swsp] = swlevel;			// ON/OFF
    swsp++;
    swmode = 0;
    if ( swflag == 0 ) return PPRESULT_SUCCESS;
    if ( sw==0 ) { swlevel = LMODE_OFF; }
    else { swlevel = LMODE_ON; }
    mulstr = swlevel;
    if ( mulstr == LMODE_OFF ) swflag=0;
    return PPRESULT_SUCCESS;
}
-(ppresult_t)PP_SwitchEnd {
    if ( swsp == 0 ) {
        [self SetError:(char *)"#endif without #if"];
        return PPRESULT_ERROR;
    }
    swsp--;
    swflag = swstack[swsp];
    swmode = swstack2[swsp];
    swlevel = swstack3[swsp];
    if ( swflag ) mulstr = swlevel;
    return PPRESULT_SUCCESS;
}
-(ppresult_t)PP_SwitchReverse {
    if ( swsp == 0 ) {
        [self SetError:(char *)"#else without #if"];
        return PPRESULT_ERROR;
    }
    if ( swmode != 0 ) {
        [self SetError:(char *)"#else after #else"];
        return PPRESULT_ERROR;
    }
    if ( swstack[swsp-1] == 0 ) return PPRESULT_SUCCESS;	// 上のスタックが無効なら無視
    swmode = 1;
    if ( swlevel == LMODE_ON ) { swlevel = LMODE_OFF; } else { swlevel = LMODE_ON; }
    mulstr = swlevel;
    swflag ^= 1;
    return PPRESULT_SUCCESS;
}
-(ppresult_t)PP_Include:(int)is_addition {
    char *word = (char *)s3;
    char tmp_spath[HSP_MAX_PATH];
    int add_bak = 0;
    if ( [self GetToken] != TK_STRING ) {
        if ( is_addition ) {
            [self SetError:(char *)"invalid addition suffix"];
        } else {
            [self SetError:(char *)"invalid include suffix"];
        }
        return PPRESULT_ERROR;
    }
    incinf++;
    if ( incinf > 32 ) {
        [self SetError:(char *)"too many include level"];
        return PPRESULT_ERROR;
    }
    strcpy( tmp_spath, search_path );
    if ( is_addition ) add_bak = [self SetAdditionMode:1];
    int res = [self ExpandFile:wrtbuf fname:word refname:word];
    if ( is_addition ) [self SetAdditionMode:add_bak];
    strcpy( search_path, tmp_spath );    //printf("%s\n",search_path);
    //printf("%d\n",is_addition);
    //printf("%d\n",res);
    //printf("%s\n",word);    incinf--;
    if (res) {
        if ( is_addition && res == -1 )
            return PPRESULT_SUCCESS;
        return PPRESULT_ERROR;
    }
    return PPRESULT_INCLUDED;
}
-(ppresult_t)PP_Const {
    //		#const解析
    //
    enum ConstType { Indeterminate, Double, Int };
    ConstType valuetype = ConstType::Indeterminate;
    char *word;
    int id, res, glmode;
    char keyword[256];
    char strtmp[512];
    CALCVAR cres;
    glmode = 0;
    word = (char *)s3;
    if ( [self GetToken] != TK_OBJ ) {
        sprintf( strtmp,"invalid symbol [%s]", word );
        [self SetError:strtmp];
        return PPRESULT_ERROR;
    }
    strcase( word );
    if (tstrcmp(word,"global")) {		// global macro
        if ( [self GetToken] != TK_OBJ ) {
            [self SetError:(char *)"bad global syntax"];
            return PPRESULT_ERROR;
        }
        glmode=1;
        strcase( word );
    }
    // 型指定キーワード
    if ( tstrcmp(word, "double") ) {
        valuetype = ConstType::Double;
    } else if ( tstrcmp(word, "int") ) {
        valuetype = ConstType::Int;
    }
    if (valuetype != ConstType::Indeterminate) {
        if ( [self GetToken] != TK_OBJ ) {
            [self SetError:(char *)"bad #const syntax"];
            return PPRESULT_ERROR;
        }
        strcase(word);
    }
    strcpy( keyword, word );
    if ( glmode )
        [self FixModuleName:keyword];
    else
        [self AddModuleName:keyword];
    res = [lb Search:keyword];
    if ( res != -1 ) {
        [self SetErrorSymbolOverdefined:keyword label_id:res];
        return PPRESULT_ERROR;
    }
    if ( [self Calc:cres] )
        return PPRESULT_ERROR;
//    //		AHT keyword check
//    if ( ahtkeyword != NULL ) {
//        if ( ahtbuf != NULL ) {						// AHT出力時
//            AHTPROP *prop;
//            CALCVAR dbval;
//            prop = ahtmodel->GetProperty( keyword );
//            if ( prop != NULL ) {
//                id = lb->Regist( keyword, LAB_TYPE_PPVAL, prop->GetValueInt() );
//                if ( cres != floor( cres ) ) {
//                    dbval = prop->GetValueDouble();
//                    lb->SetData2( id, (char *)(&dbval), sizeof(CALCVAR) );
//                }
//                if ( glmode ) lb->SetEternal( id );
//                return PPRESULT_SUCCESS;
//            }
//        } else {									// AHT読み出し時
//            if ( cres != floor( cres ) ) {
//                ahtmodel->SetPropertyDefaultDouble( keyword, (double)cres );
//            } else {
//                ahtmodel->SetPropertyDefaultInt( keyword, (int)cres );
//            }
//            if ( ahtmodel->SetAHTPropertyString( keyword, ahtkeyword ) ) {
//                SetError( (char *)"AHT parameter syntax error" ); return PPRESULT_ERROR;
//            }
//        }
//    }
    id = [lb Regist:keyword type:LAB_TYPE_PPVAL opt:(int)cres];
    if ( valuetype == ConstType::Double
        || (valuetype == ConstType::Indeterminate && cres != floor(cres)) ) {
        [lb SetData2:id str:(char *)(&cres) size:sizeof(CALCVAR)];
    }
    if ( glmode )
        [lb SetEternal:id];
    return PPRESULT_SUCCESS;
}
-(ppresult_t)PP_Enum {
    //		#enum解析
    //
    char *word;
    int id,res,glmode;
    CALCVAR cres;
    char keyword[256];
    char strtmp[512];
    glmode = 0;
    word = (char *)s3;
    if ( [self GetToken] != TK_OBJ ) {
        sprintf( strtmp,"invalid symbol [%s]", word );
        [self SetError:strtmp];
        return PPRESULT_ERROR;
    }
    strcase( word );
    if (tstrcmp(word,"global")) {		// global macro
        if ( [self GetToken] != TK_OBJ ) {
            [self SetError:(char *)"bad global syntax"];
            return PPRESULT_ERROR;
        }
        glmode=1;
        strcase( word );
    }
    strcpy( keyword, word );
    if ( glmode )
        [self FixModuleName:keyword];
    else
        [self AddModuleName:keyword];
    res = [lb Search:keyword];
    if ( res != -1 ) {
        [self SetErrorSymbolOverdefined:keyword label_id:res];
        return PPRESULT_ERROR;
    }
    if ( [self GetToken] == '=' ) {
        if ( [self Calc:cres] )
            return PPRESULT_ERROR;
        enumgc = (int)cres;
    }
    res = enumgc++;
    id = [lb Regist:keyword type:LAB_TYPE_PPVAL opt:res];
    if ( glmode )
        [lb SetEternal:id];
    return PPRESULT_SUCCESS;
}
/*
 rev 54
 mingw : warning : 比較は常に…
 に対処。
 */
-(char*)CheckValidWord {
    //		行末までにコメントがあるか調べる
    //			( return : 有効文字列の先頭ポインタ )
    //
    char *res;
    char *p;
    char *p2;
    unsigned char a1;
    int qqflg, qqchr = 0;
    res = (char *)wp;
    if ( res == NULL ) return res;
    qqflg = 0;
    p = res;
    while(1) {
        a1 = *p;
        if ( a1==0 ) break;
        if ( qqflg==0 ) {						// コメント検索フラグ
            if ( a1==0x22 ) { qqflg=1; qqchr=a1; }
            if ( a1==0x27 ) { qqflg=1; qqchr=a1; }
            if ( a1==';' ) {						// コメント
                *p = 0; break;
            }
            if ( a1=='/' ) {						// Cコメント
                if (p[1]=='/') {
                    *p = 0; break;
                }
                if (p[1]=='*') {
                    mulstr = LMODE_COMMENT;
                    p2 = [self ExpandStrComment:(char *)p+2 opt:1];
                    while(1) {
                        if ( p>=p2 ) break;
                        *p++=32;			// コメント部分をspaceに
                    }
                    continue;
                }
            }
        } else {								// 文字列中はコメント検索せず
            if (a1==0x5c) {							// '\'チェック
                p++; a1 = *p;
                if ( a1>=32 ) p++;
                continue;
            }
            if ( a1==qqchr ) qqflg=0;
        }
        //if (a1>=129) {					// 全角文字チェック
        //    if ((a1<=159)||(a1>=224)) {
        //        p++;
        //    }
        //}
        p += [self SkipMultiByte:a1];           // 全角文字チェック
        p++;
    }
    return res;
}
-(ppresult_t)PP_Define {
    //		#define解析
    //
    char *word;
    char *wdata;
    int id,res,type,prms,flg,glmode,ctype;
    char a1;
    MACDEF *macdef;
    int macptr;
    char *macbuf;
    char keyword[256];
    char strtmp[512];
    glmode = 0; ctype = 0;
    word = (char *)s3;
    if ( [self GetToken] != TK_OBJ ) {
        sprintf( strtmp,"invalid symbol [%s]", word );
        [self SetError:strtmp];
        return PPRESULT_ERROR;
    }
    strcase( word );
    if (tstrcmp(word,"global")) {		// global macro
        if ( [self GetToken] != TK_OBJ ) {
            [self SetError:(char *)"bad macro syntax"];
            return PPRESULT_ERROR;
        }
        glmode=1;
        strcase( word );
    }
    if (tstrcmp(word,"ctype")) {		// C-type macro
        if ( [self GetToken] != TK_OBJ ) {
            [self SetError:(char *)"bad macro syntax"];
            return PPRESULT_ERROR;
        }
        ctype=1;
        strcase( word );
    }
    strcpy( keyword, word );
    if ( glmode )
        [self FixModuleName:keyword];
    else
        [self AddModuleName:keyword];
    res = [lb Search:keyword];
    if ( res != -1 ) {
        [self SetErrorSymbolOverdefined:keyword label_id:res];
        return PPRESULT_ERROR;
    }
    //		skip space,tab code
    if ( wp==NULL ) a1=0;
    else {
        a1 = *wp;
        if (a1!='(') a1=0;
    }
    if ( a1==0 ) {					// no parameters
        prms = 0;
        if ( ctype ) prms|=PRM_FLAG_CTYPE;
        wdata = [self CheckValidWord];
        //		AHT keyword check
//        if ( ahtkeyword != NULL ) {
//            if ( ahtbuf != NULL ) {						// AHT出力時
//                AHTPROP *prop;
//                prop = ahtmodel->GetProperty( keyword );
//                if ( prop != NULL ) wdata = prop->GetOutValue();
//            } else {									// AHT読み込み時
//                AHTPROP *prop;
//                prop = ahtmodel->SetPropertyDefault( keyword, wdata );
//                if ( ahtmodel->SetAHTPropertyString( keyword, ahtkeyword ) ) {
//                    SetError( (char *)"AHT parameter syntax error" ); return PPRESULT_ERROR;
//                }
//                if ( prop->ahtmode & AHTMODE_OUTPUT_RAW ) {
//                    ahtmodel->SetPropertyDefaultStr( keyword, wdata );
//                }
//            }
//        }
        id = [lb Regist:keyword type:LAB_TYPE_PPMAC opt:prms];
        [lb SetData:id str:wdata];
        if ( glmode )
            [lb SetEternal:id];
        return PPRESULT_SUCCESS;
    }
    //		パラメータ定義取得
    //
    macdef = (MACDEF *)linetmp;
    macdef->data[0] = 0;
    macptr = 1;				// デフォルトマクロデータ参照オフセット
    wp++;
    prms=0; flg=0;
    while(1) {
        if ( wp==NULL ) goto bad_macro_param_expr;
        a1 = *wp++;
        if ( a1==')' ) {
            if ( flg==0 ) goto bad_macro_param_expr;
            prms++;
            break;
        }
        switch( a1 ) {
            case 9:
            case 32:
                break;
            case ',':
                if ( flg==0 ) goto bad_macro_param_expr;
                prms++;flg=0;
                break;
            case '%':
                if ( flg!=0 ) goto bad_macro_param_expr;
                type = [self GetToken];
                if ( type != TK_NUM ) goto bad_macro_param_expr;
                if ( val != (prms+1) ) goto bad_macro_param_expr;
                flg = 1;
                macdef->index[prms] = 0;			// デフォルト(初期値なし)
                break;
            case '=':
                if ( flg!=1 ) goto bad_macro_param_expr;
                flg = 2;
                macdef->index[prms] = macptr;		// 初期値ポインタの設定
                type = [self GetToken];
                switch(type) {
                    case TK_NUM:
                        sprintf( word, "%d", val );
                        break;
                    case TK_DNUM:
                        strcpy( word, (char *)s3 );
                        break;
                    case TK_STRING:
                        sprintf( strtmp,"\"%s\"", word );
                        strcpy( word, strtmp );
                        break;
                    case TK_OBJ:
                        break;
                    case '-':
                        type = [self GetToken];
                        if ( type == TK_DNUM ) {
                            sprintf( strtmp,"-%s", s3 );
                            strcpy( word, strtmp );
                            break;
                        }
                        if ( type != TK_NUM ) {
                            [self SetError:(char *)"bad default value"];
                            return PPRESULT_ERROR;
                        }
                        //_itoa( val, word, 10 );
                        sprintf( word,"-%d",val );
                        break;
                    default:
                        [self SetError:(char *)"bad default value"];
                        return PPRESULT_ERROR;
                }
                macbuf = (macdef->data) + macptr;
                res = (int)strlen( word );
                strcpy( macbuf, word );
                macptr+=res+1;
                break;
            default:
                goto bad_macro_param_expr;
        }
    }
    //		skip space,tab code
    if ( wp==NULL ) a1=0; else {
        while(1) {
            a1=*wp;if (a1==0) break;
            if ( (a1!=9)&&(a1!=32) ) break;
            wp++;
        }
    }
    if ( a1 == 0 ) {
        [self SetError:(char *)"macro contains no data"];
        return PPRESULT_ERROR;
    }
    if ( ctype ) prms|=PRM_FLAG_CTYPE;    //		データ定義
    id = [lb Regist:keyword type:LAB_TYPE_PPMAC opt:prms];
    wdata = [self CheckValidWord];
    [lb SetData:id str:wdata];
    [lb SetData2:id str:(char *)macdef size:macptr+sizeof(macdef->index)];
    if ( glmode )
        [lb SetEternal:id];
    //sprintf( keyword,"[%d]-[%s]",id,wdata );Alert( keyword );
    return PPRESULT_SUCCESS;
bad_macro_param_expr:
    [self SetError:(char *)"bad macro parameter expression"];
    return PPRESULT_ERROR;
}
-(ppresult_t)PP_Defcfunc:(int)mode {
    //		#defcfunc解析
    //			mode : 0 = 通常cfunc
    //			       1 = modcfunc
    //
    int i,id;
    char *word;
    char *mod;
    char fixname[128];
    int glmode, premode;
    word = (char *)s3;
    mod = [self GetModuleName];
    id = -1;
    glmode = 0;
    premode = LAB_TYPE_PPMODFUNC;
    i = [self GetToken];
    if ( i == TK_OBJ ) {
        strcase( word );
        if (tstrcmp(word,"local")) {		// local option
            if ( *mod == 0 ) {
                [self SetError:(char *)"module name not found"];
                return PPRESULT_ERROR;
            }
            glmode = 1;
            i = [self GetToken];
        }
        if (tstrcmp(word,"prep")) {			// prepare option
            premode = LAB_TYPE_PP_PREMODFUNC;
            i = [self GetToken];
        }
    }
    strcase2( word, fixname );
    if ( i != TK_OBJ ) {
        [self SetError:(char *)"invalid func name"];
        return PPRESULT_ERROR;
    }
    i = [lb Search:fixname];
    if ( i != -1 ) {
        if ( [lb GetFlag:i] != LAB_TYPE_PP_PREMODFUNC ) {
            [self SetErrorSymbolOverdefined:fixname label_id:i];
            return PPRESULT_ERROR;
        }
        id = i;
    }
    if ( glmode )
        [self AddModuleName:fixname];
    if ( premode == LAB_TYPE_PP_PREMODFUNC ) {
        [wrtbuf PutStrf:(char *)"#defcfunc prep %s ",fixname];
    } else {
        [wrtbuf PutStrf:(char *)"#defcfunc %s ",fixname];
    }
    if ( id == -1 ) {
        id = [lb Regist:fixname type:premode opt:0];
        if ( glmode == 0 ) [lb SetEternal:id];
        if ( *mod != 0 ) { [lb AddRelation_name:mod rel_id:id]; }		// モジュールラベルに依存を追加
    } else {
        [lb SetFlag:id val:premode];
    }
    if ( mode ) {
        if ( mode == 1 ) {
            [wrtbuf PutStr:(char *)"modvar "];
        } else {
            [wrtbuf PutStr:(char *)"modinit "];
        }
        if ( *mod == 0 ) {
            [self SetError:(char *)"module name not found"];
            return PPRESULT_ERROR;
        }
        [wrtbuf PutStr:mod];
        if ( wp != NULL )
            [wrtbuf Put_char:','];
    }
    /*
     char resname[512];
     i = [self GetToken];
     if ( i != TK_OBJ ) { SetError("invalid result name"); return PPRESULT_ERROR; }
     strcpy( resname, word );
     */
    while(1) {
        i = [self GetToken];
        if ( i == TK_OBJ ) {
            [wrtbuf PutStr:word];
        }
        if ( wp == NULL ) break;
        if ( i != TK_OBJ ) {
            [self SetError:(char *)"invalid func param"];
            return PPRESULT_ERROR;
        }
        i = [self GetToken];
        if ( i == TK_OBJ ) {
            strcase2( word, fixname );
            [self AddModuleName:fixname];
            [wrtbuf Put_char:' '];
            [wrtbuf PutStr:fixname];
            i = [self GetToken];
        }
        if ( wp == NULL ) break;
        if ( i != ',' ) {
            [self SetError:(char *)"invalid func param"];
            return PPRESULT_ERROR;
        }
        [wrtbuf Put_char:','];
        
    }
    //wrtbuf->PutStr( linebuf );
    [wrtbuf PutCR];
    //
    return PPRESULT_WROTE_LINE;
}
-(ppresult_t)PP_Deffunc:(int)mode {
    //		#deffunc解析
    //			mode : 0 = 通常func
    //			       1 = modfunc
    //			       2 = modinit
    //			       3 = modterm
    int i,id;
    char *word;
    char *mod;
    char fixname[128];
    int glmode, premode;
    word = (char *)s3;
    mod = [self GetModuleName];
    id = -1;
    glmode = 0;
    premode = LAB_TYPE_PPMODFUNC;
    if ( mode < 2 ) {
        i = [self GetToken];
        if ( i == TK_OBJ ) {
            strcase( word );
            if (tstrcmp(word,"local")) {		// local option
                if ( *mod == 0 ) {
                    [self SetError:(char *)"module name not found"];
                    return PPRESULT_ERROR;
                }
                glmode = 1;
                i = [self GetToken];
            }
            if (tstrcmp(word,"prep")) {			// prepare option
                premode = LAB_TYPE_PP_PREMODFUNC;
                i = [self GetToken];
            }
        }
        strcase2( word, fixname );
        if ( i != TK_OBJ ) {
            [self SetError:(char *)"invalid func name"];
            return PPRESULT_ERROR;
        }
        i = [lb Search:fixname];
        if ( i != -1 ) {
            if ( [lb GetFlag:i] != LAB_TYPE_PP_PREMODFUNC ) {
                [self SetErrorSymbolOverdefined:fixname label_id:i];
                return PPRESULT_ERROR;
            }
            id = i;
        }
        if ( glmode )
            [self AddModuleName:fixname];
        if ( premode == LAB_TYPE_PP_PREMODFUNC ) {
            [wrtbuf PutStrf:(char *)"#deffunc prep %s ",fixname];
        } else {
            [wrtbuf PutStrf:(char *)"#deffunc %s ", fixname];
        }
        if ( id == -1 ) {
            id = [lb Regist:fixname type:premode opt:0];
            if ( glmode == 0 ) [lb SetEternal:id];
            if ( *mod != 0 ) { [lb AddRelation_name:mod rel_id:id]; }		// モジュールラベルに依存を追加
        } else {
            [lb SetFlag:id val:premode];
        }
        if ( mode ) {
            [wrtbuf PutStr:(char *)"modvar "];
            if ( *mod == 0 ) {
                [self SetError:(char *)"module name not found"];
                return PPRESULT_ERROR;
            }
            [wrtbuf PutStr:mod];
            if ( wp != NULL )
                [wrtbuf Put_char:','];
        }
    } else {
        if ( mode == 2 ) {
            [wrtbuf PutStr:(char *)"#deffunc __init modinit "];
        } else {
            [wrtbuf PutStr:(char *)"#deffunc __term modterm "];
        }
        if ( *mod == 0 ) {
            [self SetError:(char *)"module name not found"];
            return PPRESULT_ERROR;
        }
        [wrtbuf PutStr:mod];
        if ( wp != NULL )
            [wrtbuf Put_char:','];
    }
    while(1) {
        i = [self GetToken];
        if ( i == TK_OBJ ) {
            [wrtbuf PutStr:word];
            strcase( word );
            if (tstrcmp(word,"onexit")) {							// onexitは参照済みにする
                [lb AddReference:id];
            }
        }
        if ( wp == NULL ) break;
        if ( i != TK_OBJ ) {
            [self SetError:(char *)"invalid func param"];
            return PPRESULT_ERROR;
        }
        i = [self GetToken];
        if ( i == TK_OBJ ) {
            strcase2( word, fixname );
            [self AddModuleName:fixname];
            [wrtbuf Put_char:' '];
            [wrtbuf PutStr:fixname];
            i = [self GetToken];
        }
        if ( wp == NULL ) break;
        if ( i != ',' ) {
            [self SetError:(char *)"invalid func param"];
            return PPRESULT_ERROR;
        }
        [wrtbuf Put_char:','];
    }
    //wrtbuf->PutStr( linebuf );
    [wrtbuf PutCR];
    //
    return PPRESULT_WROTE_LINE;
}
-(ppresult_t)PP_Struct {
    //		#struct解析
    //
    char *word;
    int i;
    int id,res,glmode;
    char keyword[256];
    char tagname[256];
    char strtmp[0x4000];
    glmode = 0;
    word = (char *)s3;
    if ( [self GetToken] != TK_OBJ ) {
        sprintf( strtmp,"invalid symbol [%s]", word );
        [self SetError:strtmp];
        return PPRESULT_ERROR;
    }
    strcase( word );
    if (tstrcmp(word,"global")) {		// global macro
        if ( [self GetToken] != TK_OBJ ) {
            [self SetError:(char *)"bad global syntax"];
            return PPRESULT_ERROR;
        }
        glmode=1;
        strcase( word );
    }
    strcpy( tagname, word );
    if ( glmode )
        [self FixModuleName:tagname];
    else [self AddModuleName:tagname];
    res = [lb Search:tagname];
    if ( res != -1 ) {
        [self SetErrorSymbolOverdefined:tagname label_id:res];
        return PPRESULT_ERROR;
    }
    id = [lb Regist:tagname type:LAB_TYPE_PPDLLFUNC opt:0];
    if ( glmode )
        [lb SetEternal:id];
    [wrtbuf PutStrf:(char *)"#struct %s ",tagname];
    while(1) {
        i = [self GetToken];
        if ( wp == NULL ) break;
        if ( i != TK_OBJ ) {
            [self SetError:(char *)"invalid struct param"];
            return PPRESULT_ERROR;
        }
        [wrtbuf PutStr:word];
        [wrtbuf Put_char:' '];
        i = [self GetToken];
        if ( i != TK_OBJ ) {
            [self SetError:(char *)"invalid struct param"];
            return PPRESULT_ERROR;
        }
        sprintf( keyword,"%s_%s", tagname, word );
        if ( glmode )
            [self FixModuleName:keyword];
        else
            [self AddModuleName:keyword];
        res = [lb Search:keyword];
        if ( res != -1 ) {
            [self SetErrorSymbolOverdefined:keyword label_id:res];
            return PPRESULT_ERROR;
        }
        id = [lb Regist:keyword type:LAB_TYPE_PPDLLFUNC opt:0];
        if ( glmode )
            [lb SetEternal:id];
        [wrtbuf PutStr:keyword];
        i = [self GetToken];
        if ( wp == NULL ) break;
        if ( i != ',' ) {
            [self SetError:(char *)"invalid struct param"];
            return PPRESULT_ERROR;
        }
        [wrtbuf Put_char:','];
    }
    [wrtbuf PutCR];
    return PPRESULT_WROTE_LINE;
}
-(ppresult_t)PP_Func:(char*)name {
    //		#func解析
    //
    int i, id;
    int glmode;
    char *word;
    word = (char *)s3;
    i = [self GetToken];
    if ( i != TK_OBJ ) {
        [self SetError:(char *)"invalid func name"];
        return PPRESULT_ERROR;
    }
    glmode = 0;
    strcase( word );
    if (tstrcmp(word,"global")) {		// global macro
        if ( [self GetToken] != TK_OBJ ) {
            [self SetError:(char *)"bad global syntax"];
            return PPRESULT_ERROR;
        }
        glmode=1;
    }
    if ( glmode )
        [self FixModuleName:word];
    else
        [self AddModuleName:word];
        //AddModuleName( word );
    i = [lb Search:word];
    if ( i != -1 ) {
        [self SetErrorSymbolOverdefined:word label_id:i];
        return PPRESULT_ERROR;
    }
    id = [lb Regist:word type:LAB_TYPE_PPDLLFUNC opt:0];
    if ( glmode )
        [lb SetEternal:id];
    //
    [wrtbuf PutStrf:(char *)"#%s %s%s",name, word, (char *)wp];
    [wrtbuf PutCR];
    //
    return PPRESULT_WROTE_LINE;
}
-(ppresult_t)PP_Cmd:(char*)name {
    //		#cmd解析
    //
    int i, id;
    char *word;
    word = (char *)s3;
    i = [self GetToken];
    if ( i != TK_OBJ ) {
        [self SetError:(char *)"invalid func name"];
        return PPRESULT_ERROR;
    }
    i = [lb Search:word];
    if ( i != -1 ) {
        [self SetErrorSymbolOverdefined:word label_id:i];
        return PPRESULT_ERROR;
    }
    id = [lb Regist:word type:LAB_TYPE_PPINTMAC opt:0];		// 内部マクロとして定義
    strcat( word, "@hsp" );
    [lb SetData:id str:word];
    [lb SetEternal:id];    //AddModuleName( word );
    //id = lb->Regist( word, LAB_TYPE_PPDLLFUNC, 0 );
    //lb->SetEternal( id );
    //
    [wrtbuf PutStrf:(char *)"#%s %s%s", name, word, (char *)wp];
    [wrtbuf PutCR];
    //
    //NSString* str = [NSString stringWithFormat:<#(nonnull NSString *), ...#>]
    return PPRESULT_WROTE_LINE;
}
-(ppresult_t)PP_Usecom {
    //		#usecom解析
    //
    int i, id;
    int glmode;
    char *word;
    word = (char *)s3;
    i = [self GetToken];
    if ( i != TK_OBJ ) {
        [self SetError:(char *)"invalid COM symbol name"];
        return PPRESULT_ERROR;
    }
    glmode = 0;
    strcase( word );
    if (tstrcmp(word,"global")) {		// global macro
        if ( [self GetToken] != TK_OBJ ) {
            [self SetError:(char *)"bad global syntax"];
            return PPRESULT_ERROR;
        }
        glmode=1;
    }
    i = [lb Search:word];
    if ( i != -1 ) {
        [self SetErrorSymbolOverdefined:word label_id:i];
        return PPRESULT_ERROR;
    }
    if ( glmode )
        [self FixModuleName:word];
    else
        [self AddModuleName:word];
    id = [lb Regist:word type:LAB_TYPE_COMVAR opt:0];
    if ( glmode )
        [lb SetEternal:id];
    //
    [wrtbuf PutStrf:(char *)"#usecom %s%s",word, (char *)wp];
    [wrtbuf PutCR];
    //
    return PPRESULT_WROTE_LINE;
}
-(ppresult_t)PP_Module {
    //		#module解析
    //
    int res,i,id,fl;
    char *word;
    char tagname[MODNAME_MAX+1];
    //char tmp[0x4000];
    word = (char *)s3; fl = 0;
    i = [self GetToken];
    if (( i == TK_OBJ )||( i == TK_STRING )) fl=1;
    if ( i == TK_NONE ) {
        sprintf( word, "M%d", modgc );
        modgc++;
        fl=1;
    }
    if ( fl == 0 ) {
        [self SetError:(char *)"invalid module name"];
        return PPRESULT_ERROR;
    }
    if ( ![self IsGlobalMode] ) {
        [self SetError:(char *)"not in global mode" ];
        return PPRESULT_ERROR;
    }
    if ( [self CheckModuleName:word] ) {
        [self SetError:(char *)"bad module name"];
        return PPRESULT_ERROR;
    }
    sprintf( tagname, "%.*s", MODNAME_MAX, word );
    res = [lb Search:tagname];
    if ( res != -1 ) {
        [self SetErrorSymbolOverdefined:tagname label_id:res];
        return PPRESULT_ERROR;
    }
    id = [lb Regist:tagname type:LAB_TYPE_PPDLLFUNC opt:0];
    [lb SetEternal:id];
    [self SetModuleName:tagname];
    [wrtbuf PutStrf:(char *)"#module %s",tagname];
    [wrtbuf PutCR];
    [wrtbuf PutStrf:(char *)"goto@hsp *_%s_exit",tagname];
    [wrtbuf PutCR];
    if ( [self PeekToken] != TK_NONE ) {
        [wrtbuf PutStrf:(char *)"#struct %s ",tagname];
        while(1) {
            i = [self GetToken];
            if ( i != TK_OBJ ) {
                [self SetError:(char *)"invalid module param"];
                return PPRESULT_ERROR;
            }
            [self AddModuleName:word];
            res = [lb Search:word];
            if ( res != -1 ) {
                [self SetErrorSymbolOverdefined:word label_id:res];
                return PPRESULT_ERROR;
            }
            id = [lb Regist:word type:LAB_TYPE_PPDLLFUNC opt:0];
            [wrtbuf PutStr:(char *)"var "];
            [wrtbuf PutStr:word];
            i = [self GetToken];
            if ( wp == NULL ) break;
            if ( i != ',' ) {
                [self SetError:(char *)"invalid module param"];
                return PPRESULT_ERROR;
            }
            [wrtbuf Put_char:','];
        }
        [wrtbuf PutCR];
    }
    return PPRESULT_WROTE_LINES;
}
-(ppresult_t)PP_Global {
    //		#global解析
    //
    if ( [self IsGlobalMode] ) {
        [self SetError:(char *)"#module と対応していない #global があります"];
        return PPRESULT_ERROR;
    }
    //
    [wrtbuf PutStrf:(char *)"*_%s_exit", [self GetModuleName]];
    [wrtbuf PutCR];
    [wrtbuf PutStr:(char *)"#global"];
    [wrtbuf PutCR];
    [self SetModuleName:(char *)""];
    return PPRESULT_WROTE_LINES;
}
//ppresult_t CToken::PP_Aht( void )
//{
//    //		#aht解析
//    //
//    int i;
//    char tmp[512];
//    if ( ahtmodel == NULL ) return PPRESULT_SUCCESS;
//    if ( ahtbuf != NULL ) return PPRESULT_SUCCESS;					// AHT出力時は無視する
//    i = [self GetToken];
//    if ( i != TK_OBJ ) {
//        SetError((char *)"invalid AHT option name"); return PPRESULT_ERROR;
//    }
//    strcpy2( tmp, (char *)s3, 512 );
//    i = [self GetToken];
//    if (( i != TK_STRING )&&( i != TK_NUM )) {
//        SetError((char *)"invalid AHT option value"); return PPRESULT_ERROR;
//    }
//    ahtmodel->SetAHTOption( tmp, (char *)s3 );    return PPRESULT_SUCCESS;
//}
//ppresult_t CToken::PP_Ahtout( void )
//{
//    //		#ahtout解析
//    //
//    if ( ahtmodel == NULL ) return PPRESULT_SUCCESS;
//    if ( ahtbuf == NULL ) return PPRESULT_SUCCESS;
//    if ( wp == NULL ) return PPRESULT_SUCCESS;
//    ahtbuf->PutStr( (char *)wp );
//    ahtbuf->PutCR();
//    return PPRESULT_SUCCESS;
//}
//ppresult_t CToken::PP_Ahtmes( void )
//{
//    //		#ahtmes解析
//    //
//    int i;
//    int addprm;
//    if ( ahtmodel == NULL ) return PPRESULT_SUCCESS;
//    if ( ahtbuf == NULL ) return PPRESULT_SUCCESS;
//    if ( wp == NULL ) return PPRESULT_SUCCESS;
//    addprm = 0;
//    while(1) {
//        if ( wp == NULL ) break;
//        i = [self GetToken];
//        if ( i == TK_NONE ) break;
//        if (( i != TK_OBJ )&&( i != TK_NUM )&&( i != TK_STRING )) {
//            SetError((char *)"illegal ahtmes parameter"); return PPRESULT_ERROR;
//        }
//        ahtbuf->PutStr( (char *)s3 );
//        if ( wp == NULL ) {	addprm = 0; break; }
//        i = [self GetToken];
//        if ( i != '+' ) { SetError((char *)"invalid ahtmes format"); return PPRESULT_ERROR; }
//        addprm++;
//    }
//    if ( addprm == 0 ) ahtbuf->PutCR();
//    return PPRESULT_SUCCESS;
//}
-(ppresult_t)PP_Pack:(int)mode {
    //		#pack,#epack解析
    //			(mode:0=normal/1=encrypt)
    int i;
    if ( packbuf!=NULL ) {
        i = [self GetToken];
        if ( i != TK_STRING ) {
            [self SetError:(char *)"invalid pack name"];
            return PPRESULT_ERROR;
        }
        [self AddPackfile:(char *)s3 mode:mode];
    }
    return PPRESULT_SUCCESS;
}
-(ppresult_t)PP_PackOpt {
    //		#packopt解析
    //
    int i;
    char tmp[1024];
    char optname[1024];
    if ( packbuf!=NULL ) {
        i = [self GetToken];
        if ( i != TK_OBJ ) {
            [self SetError:(char *)"illegal option name"];
            return PPRESULT_ERROR;
        }
        strncpy( optname, (char *)s3, 128 );
        i = [self GetToken];
        if (( i != TK_OBJ )&&( i != TK_NUM )&&( i != TK_STRING )) {
            [self SetError:(char *)"illegal option parameter"];
            return PPRESULT_ERROR;
        }
        sprintf( tmp, ";!%s=%s", optname, (char *)s3 );
        [self AddPackfile:tmp mode:2];
    }
    return PPRESULT_SUCCESS;
}
-(ppresult_t)PP_CmpOpt {
    //		#cmpopt解析
    //
    int i;
    char optname[1024];
    i = [self GetToken];
    if ( i != TK_OBJ ) {
        [self SetError:(char *)"illegal option name"];
        return PPRESULT_ERROR;
    }
    strcase2( (char *)s3, optname );
    i = [self GetToken];
    if ( i != TK_NUM ) {
        [self SetError:(char *)"illegal option parameter"];
        return PPRESULT_ERROR;
    }
    i = 0;
    if (tstrcmp(optname,"ppout")) {			// preprocessor out sw
        i = CMPMODE_PPOUT;
    }
    if (tstrcmp(optname,"optcode")) {		// code optimization sw
        i = CMPMODE_OPTCODE;
    }
    if (tstrcmp(optname,"case")) {			// case sensitive sw
        i = CMPMODE_CASE;
    }
    if (tstrcmp(optname,"optinfo")) {		// optimization info sw
        i = CMPMODE_OPTINFO;
    }
    if (tstrcmp(optname,"varname")) {		// VAR name out sw
        i = CMPMODE_PUTVARS;
    }
    if (tstrcmp(optname,"varinit")) {		// VAR initalize check
        i = CMPMODE_VARINIT;
    }
    if (tstrcmp(optname,"optprm")) {		// parameter optimization sw
        i = CMPMODE_OPTPRM;
    }
    if (tstrcmp(optname,"skipjpspc")) {		// skip Japanese Space Code sw
        i = CMPMODE_SKIPJPSPC;
    }
    if ( i == 0 ) {
        [self SetError:(char *)"illegal option name"];
        return PPRESULT_ERROR;
    }
    if ( val ) {
        hed_cmpmode |= i;
    } else {
        hed_cmpmode &= ~i;
    }
    //Alertf("%s(%d)",optname,val);
    //wrtbuf->PutCR();
    return PPRESULT_SUCCESS;
}
-(ppresult_t)PP_RuntimeOpt {
    //		#runtime解析
    //
    int i;
    char tmp[1024];
    i = [self GetToken];
    if ( i != TK_STRING ) {
        [self SetError:(char *)"illegal runtime name"];
        return PPRESULT_ERROR;
    }
    strncpy( hed_runtime, (char *)s3, sizeof hed_runtime );
    hed_runtime[sizeof hed_runtime - 1] = '\0';
    if ( packbuf!=NULL ) {
        sprintf( tmp, ";!runtime=%s.hrt", hed_runtime );
        [self AddPackfile:tmp mode:2];
    }
    hed_option |= HEDINFO_RUNTIME;
    return PPRESULT_SUCCESS;
}
-(ppresult_t)PP_BootOpt {
    //		#bootopt解析
    //
    int i;
    char optname[1024];
    i = [self GetToken];
    if (i != TK_OBJ) {
        [self SetError:(char *)"illegal option name"];
        return PPRESULT_ERROR;
    }
    strcase2((char *)s3, optname);
    i = [self GetToken];
    if (i != TK_NUM) {
        [self SetError:(char *)"illegal option parameter"];
        return PPRESULT_ERROR;
    }
    i = 0;
    if (tstrcmp(optname, "notimer")) {			// No MMTimer sw
        i = HEDINFO_NOMMTIMER;
        hed_autoopt_timer = -1;
    }
    if (tstrcmp(optname, "nogdip")) {			// No GDI+ sw
        i = HEDINFO_NOGDIP;
    }
    if (tstrcmp(optname, "float32")) {			// float32 sw
        i = HEDINFO_FLOAT32;
    }
    if (tstrcmp(optname, "orgrnd")) {			// standard random sw
        i = HEDINFO_ORGRND;
    }
    if (i == 0) {
        [self SetError:(char *)"illegal option name"];
        return PPRESULT_ERROR;
    }
    if (val) {
        hed_option |= i;
    }
    else {
        hed_option &= ~i;
    }
    return PPRESULT_SUCCESS;
}
-(void)PreprocessCommentCheck:(char*)str {
    int qmode;
    unsigned char *vs;
    unsigned char a1;
    vs = (unsigned char *)str;
    qmode = 0;
    while(1) {
        a1=*vs++;
        if (a1==0) break;
        if ( qmode == 0 ) {
            if (( a1 == ';' )&&( *vs == ';' )) {
                vs++;
                ahtkeyword = (char *)vs;
            }
        }
        if (a1==0x22) qmode^=1;
        //if (a1>=129) {					// 全角文字チェック
        //    if ((a1<=159)||(a1>=224)) {
        //        vs++;
        //    }
        //}
        vs += [self SkipMultiByte:a1];          // 全角文字チェック
    }
}
-(ppresult_t)PreprocessNM:(char*)str {
    //		プリプロセスの実行(マクロ展開なし)
    //
    char *word;
    int id,type;
    ppresult_t res;
    char fixname[128];
    word = (char *)s3;
    wp = (unsigned char *)str;
    //if ( ahtmodel != NULL ) {
    //    PreprocessCommentCheck( str );
    //}
    type = [self GetToken];
    if ( type != TK_OBJ )
        return PPRESULT_UNKNOWN_DIRECTIVE;
    //		ソース生成コントロール
    //
    if (tstrcmp(word,"ifdef")) {		// generate control
        if ( mulstr == LMODE_OFF ) {
            res = [self PP_SwitchStart:0];
        } else {
            res = PPRESULT_ERROR;
            type = [self GetToken];
            if ( type == TK_OBJ ) {
                strcase2( word, fixname );
                [self AddModuleName:fixname];
                id = [lb SearchLocal:word loname:fixname];
                //id = lb->Search( word );
                res = [self PP_SwitchStart:(id!=-1)];
            }
        }
        return res;
    }
    if (tstrcmp(word,"ifndef")) {		// generate control
        if ( mulstr == LMODE_OFF ) {
            res = [self PP_SwitchStart:0];
        } else {
            res = PPRESULT_ERROR;
            type = [self GetToken];
            if ( type == TK_OBJ ) {
                strcase2( word, fixname );
                [self AddModuleName:fixname];
                id = [lb SearchLocal:word loname:fixname];
                //id = lb->Search( word );
                res = [self PP_SwitchStart:(id==-1)];
            }
        }
        return res;
    }
    if (tstrcmp(word,"else")) {			// generate control
        return [self PP_SwitchReverse];
    }
    if (tstrcmp(word,"endif")) {		// generate control
        return [self PP_SwitchEnd];
    }
    //		これ以降は#off時に実行しません
    //
    if ( mulstr == LMODE_OFF ) {
        return PPRESULT_UNKNOWN_DIRECTIVE;
    }
    if (tstrcmp(word,"define")) {		// keyword define
        return [self PP_Define];
    }
    if (tstrcmp(word,"undef")) {		// keyword terminate
        if ( [self GetToken] != TK_OBJ ) {
            [self SetError:(char *)"invalid symbol"];
            return PPRESULT_ERROR;
        }
        strcase2( word, fixname );
        [self AddModuleName:fixname];
        id = [lb SearchLocal:word loname:fixname];
        //id = lb->Search( word );
        if ( id >= 0 ) {
            [lb SetFlag:id val:-1];
        }
        return PPRESULT_SUCCESS;
    }
    return PPRESULT_UNKNOWN_DIRECTIVE;
}
-(ppresult_t)Preprocess:(char*)str {
    //		プリプロセスの実行
    //
    char *word;
    int type,a;
    ppresult_t res;
    CALCVAR cres;
    word = (char *)s3;
    wp = (unsigned char *)str;
    type = [self GetToken];
    if ( type != TK_OBJ )
        return PPRESULT_SUCCESS;
    //		ソース生成コントロール
    //
    if (tstrcmp(word,"if")) {			// generate control
        if ( mulstr == LMODE_OFF ) {
            res = [self PP_SwitchStart:0];
        } else {
            res = PPRESULT_SUCCESS;
            if ( [self Calc:cres]==0 ) {
                a = (int)cres;
                res = [self PP_SwitchStart:a];
            }
            else
                res=PPRESULT_ERROR;
        }
        return res;
    }
    //		これ以降は#off時に実行しません
    //
    if ( mulstr == LMODE_OFF ) {
        return PPRESULT_SUCCESS;
    }
    //		コード生成コントロール
    //
    if (tstrcmp(word,"include")) {		// text include
        res = [self PP_Include:0];
        return res;
    }
    if (tstrcmp(word,"addition")) {		// text include
        res = [self PP_Include:1];
        return res;
    }
    if (tstrcmp(word,"const")) {		// constant define
        res = [self PP_Const];
        return res;
    }
    if (tstrcmp(word,"enum")) {			// constant enum define
        res = [self PP_Enum];
        return res;
    }
    /*
     if (tstrcmp(word,"define")) {		// keyword define
     res = PP_Define();
     if ( res==6 ) SetError("bad macro parameter expression");
     return res;
     }
     */
    if (tstrcmp(word,"module")) {		// module define
        res = [self PP_Module];
        return res;
    }
    if (tstrcmp(word,"global")) {		// module exit
        res = [self PP_Global];
        return res;
    }
    if (tstrcmp(word,"deffunc")) {		// module function
        res = [self PP_Deffunc:0];
        return res;
    }
    if (tstrcmp(word,"defcfunc")) {		// module function (1)
        res = [self PP_Defcfunc:0];
        return res;
    }
    if (tstrcmp(word,"modfunc")) {		// module function (2)
        res = [self PP_Deffunc:1];
        return res;
    }
    if (tstrcmp(word,"modcfunc")) {		// module function (2+)
        res = [self PP_Defcfunc:1];
        return res;
    }
    if (tstrcmp(word,"modinit")) {		// module function (3)
        res = [self PP_Deffunc:2];
        return res;
    }
    if (tstrcmp(word,"modterm")) {		// module function (4)
        res = [self PP_Deffunc:3];
        return res;
    }
    if (tstrcmp(word,"struct")) {		// struct define
        res = [self PP_Struct];
        return res;
    }
    if (tstrcmp(word,"func")) {			// DLL function
        res = [self PP_Func:(char *)"func"];
        return res;
    }
    if (tstrcmp(word,"cfunc")) {		// DLL function
        res = [self PP_Func:(char *)"cfunc"];
        return res;
    }
    if (tstrcmp(word,"cmd")) {			// DLL function (3.0)
        res = [self PP_Cmd:(char *)"cmd"];
        return res;
    }
    /*
     if (tstrcmp(word,"func2")) {		// DLL function (2)
     res = PP_Func( "func2" );
     return res;
     }
     */
//    if (tstrcmp(word,"comfunc")) {		// COM Object function
//        res = PP_Func( (char *)"comfunc" );
//        return res;
//    }
//    if (tstrcmp(word,"aht")) {			// AHT definition
//        res = PP_Aht();
//        return res;
//    }
//    if (tstrcmp(word,"ahtout")) {		// AHT command line output
//        res = PP_Ahtout();
//        return res;
//    }
//    if (tstrcmp(word,"ahtmes")) {		// AHT command line output (mes)
//        res = PP_Ahtmes();
//        return res;
//    }
    if (tstrcmp(word,"pack")) {			// packfile process
        res = [self PP_Pack:0];
        return res;
    }
    if (tstrcmp(word,"epack")) {		// packfile process
        res = [self PP_Pack:1];
        return res;
    }
    if (tstrcmp(word,"packopt")) {		// packfile process
        res = [self PP_PackOpt];
        return res;
    }
    if (tstrcmp(word,"runtime")) {		// runtime process
        res = [self PP_RuntimeOpt];
        return res;
    }
    if (tstrcmp(word, "bootopt")) {		// boot option process
        res = [self PP_BootOpt];
        return res;
    }
    if (tstrcmp(word, "cmpopt")) {		// compile option process
        res = [self PP_CmpOpt];
        return res;
    }
    if (tstrcmp(word,"usecom")) {		// COM definition
        res = [self PP_Usecom];
        return res;
    }
    //		登録キーワード以外はコンパイラに渡す
    //
    [wrtbuf Put_char:(char)'#'];
    [wrtbuf PutStr:linebuf];
    [wrtbuf PutCR];
    //wrtbuf->PutStr( (char *)s3 );
    return PPRESULT_WROTE_LINE;
}
-(int)ExpandTokens:(char*)vp buf:(CMemBuf*)buf lineext:(int*)lineext is_preprocess_line:(int)is_preprocess_line {
    //		マクロを展開
    //
    *lineext = 0;				// 1行->複数行にマクロ展開されたか?
    int macloop = 0;			// マクロ展開無限ループチェック用カウンタ
    while(1) {
        if ( mulstr == LMODE_OFF ) {				// １行無視
            if ( wrtbuf!=NULL )
                [wrtbuf PutCR];	// 行末CR/LFを追加
            break;
        }
        // {"〜"}の処理
        //
        if ( mulstr == LMODE_STR ) {
            wrtbuf = buf;
            vp = [self ExpandStrEx:vp];
            if ( *vp!=0 )
                continue;
        }
        // /*〜*/の処理
        //
        if ( mulstr == LMODE_COMMENT ) {
            vp = [self ExpandStrComment:vp opt:0];
            if ( *vp!=0 )
                continue;
        }
        char *vp_bak = vp;
        int type;
        vp = [self ExpandToken:vp type:&type ppmode:is_preprocess_line];
        if ( type < 0 ) {
            return type;
        }
        if ( type == TK_EOL ) { (*lineext)++; }
        if ( type == TK_EOF ) {
            if ( wrtbuf!=NULL )
                [wrtbuf PutCR];	// 行末CR/LFを追加
            break;
        }
        if ( vp_bak == vp ) {
            macloop++;
            if ( macloop > 999 ) {
                [self SetError:(char *)"Endless macro loop"];
                return -1;
            }
        }
    }
    return 0;
}
-(int)ExpandLine:(CMemBuf*)buf src:(CMemBuf*)src refname:(char*)refname {
    //		stringデータをmembufへ展開する
    //
    char *p = [src GetBuffer];
    int pline = 1;
    enumgc = 0;
    mulstr = LMODE_ON;
    *errtmp = 0;
    unsigned char a1;
    while(1) {
        [self RegistExtMacro_val:(char *)"__line__" val:pline];			// 行番号マクロを更新
        while(1) {
            a1 = *(unsigned char *)p;
            if ( a1 == ' ' || a1 == '\t' ) {
                p++;
                continue;
            }
            break;
        }
        if ( *p==0 )
            break;					// 終了(EOF)
        ahtkeyword = NULL;					// AHTキーワードをリセットする
        int is_preprocess_line = *p == '#' &&
        mulstr != LMODE_STR &&
        mulstr != LMODE_COMMENT;
        //		行データをlinebufに展開
        int mline;
        if ( is_preprocess_line ) {
            p = [self SendLineBufPP:p + 1 lines:&mline];// 行末までを取り出す('\'継続)
            wrtbuf = NULL;
        } else {
            p = [self SendLineBuf:p];			// 行末までを取り出す
            mline = 0;
            wrtbuf = buf;
        }
        //		Mesf("%d:%s", pline, src->GetFileName() );
        //		sprintf( mestmp,"%d:%s:%s(%d)", pline, src->GetFileName(), linebuf, is_preprocess_line );
        //		Alert( mestmp );
        //		buf->PutStr( mestmp );
        //		マクロ展開前に処理されるプリプロセッサ
        if ( is_preprocess_line ) {
            ppresult_t res = [self PreprocessNM:linebuf];
            if ( res == PPRESULT_ERROR ) {
                [self LineError:errtmp line:pline fname:refname];
                return 1;
            }
            if ( res == PPRESULT_SUCCESS ) {			// プリプロセッサで処理された時
                mline++;
                pline += mline;
                for (int i = 0; i < mline; i++) {
                    [buf PutCR];
                }
                continue;
            }
            assert( res == PPRESULT_UNKNOWN_DIRECTIVE );
        }
        //		if ( wrtbuf!=NULL ) {
        //			char ss[64];
        //			sprintf( ss,"__%d:",pline );
        //			wrtbuf->PutStr( ss );
        //		}
        //		マクロを展開
        int lineext;			// 1行->複数行にマクロ展開されたか?
        int res = [self ExpandTokens:linebuf buf:buf lineext:&lineext is_preprocess_line:is_preprocess_line];
        if ( res ) {
            [self LineError:errtmp line:pline fname:refname];
            return res;
        }
        //		プリプロセッサ処理
        if ( is_preprocess_line ) {
            wrtbuf = buf;
            ppresult_t res = [self Preprocess:linebuf];
            if ( res == PPRESULT_INCLUDED ) {
                // include後の処理
                pline += 1+mline;
                char *fname_literal = to_hsp_string_literal( refname );
                [self RegistExtMacro_str:(char *)"__file__" str:fname_literal];
                // ファイル名マクロを更新
                wrtbuf = buf;
                [wrtbuf PutStrf:(char *)"##%d %s\r\n", pline-1, fname_literal];
                free( fname_literal );
                continue;
            }
            if ( res == PPRESULT_WROTE_LINES ) {
                // プリプロセスで行が増えた後の処理
                pline += mline;
                [wrtbuf PutStrf:(char *)"##%d\r\n", pline];
                pline++;
                continue;
            }
            if ( res == PPRESULT_ERROR ) {
                [self LineError:errtmp line:pline fname:refname];
                return 1;
            }
            pline += 1+mline;
            if ( res != PPRESULT_WROTE_LINE ) mline++;
            for (int i = 0; i < mline; i++) {
                [buf PutCR];
            }
            assert( res == PPRESULT_SUCCESS || res == PPRESULT_WROTE_LINE );
            continue;
        }
        //		マクロ展開後に行数が変わった場合の処理
        pline += 1+mline;
        if ( lineext != mline ) {
            [wrtbuf PutStrf:(char *)"##%d\r\n", pline];
        }
    }
    return 0;
}
-(int)ExpandFile:(CMemBuf*)buf fname:(char*)fname refname:(char*)refname {
    //		ソースファイルをmembufへ展開する
    //
    int res;
    char cname[HSP_MAX_PATH];
    char purename[HSP_MAX_PATH];
    char foldername[HSP_MAX_PATH];
    char refname_copy[HSP_MAX_PATH];
    CMemBuf* fbuf;
    getpath( fname, purename, 8 );
    getpath( fname, foldername, 32 );
    if ( *foldername != 0 ) {
        strcpy( search_path, foldername );
    }
    //-------
    //AppDelegate* global = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    //#includeのsearchパスを設定する
    NSString * ns_search_path;
    //if (global.isStartAxInResource) { //リソース内にstart.axがある場合
    //    path = [NSBundle mainBundle].resourcePath; //リソースディレクトリ
    //    path = [path stringByAppendingString:@"/"];
    //    path = [path stringByAppendingString:filename];
    //}
    //else
    //if( ![[global.currentPaths objectAtIndex:global.runtimeAccessNumber] isEqual:@""] ) { //ソースコードのあるディレクトリ
       // ns_search_path = [global.currentPaths objectAtIndex:global.runtimeAccessNumber];
    //}
    //else { //hsptmp
        ns_search_path = [NSHomeDirectory() stringByAppendingString:@"/Documents/hsptmp"];
    //}
    ns_search_path = [ns_search_path stringByAppendingString:@"/"];
    //パスに%記号が入っていたらエラーにする
    for(int n=0;n<ns_search_path.length;n++) {
        //- (NSString*) charAt:(NSString*)str index:(int)index { //文字列の指定位置で指定された位置の文字を返す
        //    if (index>=str.length) {
        //        return @"";
        //    }
        //    if (index<0) return @"";
        //    return ;
        //}
        //printf("%hu",[ns_search_path characterAtIndex:n]);
        if([[ns_search_path substringWithRange:NSMakeRange(n, 1)] isEqual:@"%"]) {
            NSLog(@"ソースコードのパスに非ASCII文字が含まれています。処理を中断します。\n>> ");
            return 0;
        }
        //NSLog(@"%@",);
    }
    //ns_search_path = [ns_search_path stringByRemovingPercentEncoding]; //URLデコード
    //NSData *data = [ns_search_path dataUsingEncoding:NSUTF8StringEncoding];
    //NSUInteger len = [data length];
    //Byte* byteData = (Byte*)malloc(len+1);
    //memcpy(byteData,[data bytes],len);
    //byteData[len+1] = *(char *)"\0";
    const char * c_search_path = (char *)[ns_search_path UTF8String];
    int i=0;
    for(;i<strlen(c_search_path)-1;i++) {
        search_path[i] = c_search_path[i];
    }
    search_path[i] = *(char *)"/";i++;
    search_path[i] = *(char *)"\0";
    //NSString *filename =  [NSString stringWithCString:fname encoding:NSUTF8StringEncoding];
    //path = [path stringByAppendingString:filename];
    if(strcmp(common_path,"common/")==0) {
        //#includeのcommonパスを設定する
        //NSLog(@"null");
        NSString* ns_common_path = @"";
        ns_common_path = [NSBundle mainBundle].resourcePath; //リソースディレクトリ
        ns_common_path = [ns_common_path stringByAppendingString:@"/"];
        char * c_common_path = (char *)[ns_common_path UTF8String];
        int i=0;
        for(;i<strlen(c_common_path)-1;i++) {
            common_path[i] = c_common_path[i];
        }
        common_path[i] = *(char *)"/";i++;
        common_path[i] = *(char *)"\0";
    }
    //NSString *decodedString = [ns_search_path stringByRemovingPercentEncoding];
    //NSLog(@"%@",decodedString);
    //    NSLog(@"c_path:%s",c_search_path);
    //    NSLog(@"path:%@",ns_search_path);
    //    NSLog(@"purename:%s",purename);
    //    NSLog(@"common_path:%s",common_path);
    //    NSLog(@"search_path:%s",search_path);
    //-------
    //NSLog(@"1:%s",fname);
    if ( [fbuf PutFile:fname] < 0 ) {
        strcpy( cname, common_path );
        strcat( cname, purename );
        //NSLog(@"2:%s",cname);
        if ( [fbuf PutFile:cname] < 0 ) {
            strcpy( cname, search_path );
            strcat( cname, purename );
            // NSLog(@"3:%s",cname);
            if ( [fbuf PutFile:cname] < 0 ) {
                strcpy( cname, common_path );
                strcat( cname, search_path );
                strcat( cname, purename );
                //  NSLog(@"4:%s",cname);
                if ( [fbuf PutFile:cname] < 0 ) {
                    if ( fileadd == 0 ) {
#ifdef JPNMSG
                        //Mesf( (char *)"#スクリプトファイルが見つかりません [%s]", purename );
                        @autoreleasepool {
                            NSLog(@"#スクリプトファイルが見つかりません [%s]\n", purename);
                        }
#else
                        Mesf( "#Source file not found.[%s]", purename );
#endif
                    }
                    return -1;
                }
            }
        }
    }
    //NSLog(@"----");
    [fbuf Put_char:(char)0];
    if ( fileadd ) {
        //Mesf( (char *)"#Use file [%s]",purename );
        @autoreleasepool {
            NSLog(@"#Use file [%s]\n",purename);
        }
    }
    char *fname_literal = to_hsp_string_literal( refname );
    [self RegistExtMacro_str:(char *)"__file__" str:fname_literal];
    // ファイル名マクロを更新
    [buf PutStrf:(char *)"##0 %s\r\n", fname_literal];
    free( fname_literal );
    strcpy2( refname_copy, refname, sizeof refname_copy );
    res = [self ExpandLine:buf src:fbuf refname:refname_copy];
    if ( res == 0 ) {
        //		プリプロセス後チェック
        //
        res = [tstack StackCheck:linebuf];
        if ( res ) {
            NSLog(@"#スタックが空になっていないマクロタグが%d個あります [%s]\n", res, refname_copy);
            NSLog(@"%s\n", linebuf);
            //Mes( linebuf );
        }
    }
    if ( res ) {
        NSLog(@"#重大なエラーが検出されています\n");
        return -2;
    }
    return 0;
}
-(int)SetAdditionMode:(int)mode {
    //		Additionによるファイル追加モード設定(1=on/0=off)
    //
    int i;
    i = fileadd;
    fileadd = mode;
    return i;
}
-(void)SetCommonPath:(char*)path {
    if ( path==NULL ) {
        common_path[0]=0;
        return;
    }
    strcpy( common_path, path );
}
-(void)FinishPreprocess:(CMemBuf*)buf {
    //	後ろで定義された関数がある場合、それに書き換える
    //
    //	この関数では foo@modname を foo に書き換えるなどバッファサイズが小さくなる変更しか行わない
    //
    int read_pos = 0;
    int write_pos = 0;
    size_t len = undefined_symbols.size();
    char *p = [buf GetBuffer];
    for ( size_t i = 0; i < len; i ++ ) {
        undefined_symbol_t sym = undefined_symbols[i];
        int pos = sym.pos;
        int len_include_modname = sym.len_include_modname;
        int len = sym.len;
        int id;
        memmove( p + write_pos, p + read_pos, pos - read_pos );
        write_pos += pos - read_pos;
        read_pos = pos;
        // @modname を消した名前の関数が存在したらそれに書き換え
        p[pos+len] = '\0';
        id = [lb Search:p + pos];
        if ( id >= 0 && [lb GetType:id] == LAB_TYPE_PPMODFUNC ) {
            memmove( p + write_pos, p + pos, len );
            write_pos += len;
            read_pos += len_include_modname;
        }
        p[pos+len] = '@';
    }
    memmove( p + write_pos, p + read_pos, [buf GetSize] - read_pos );
    [buf ReduceSize:[buf GetSize] - (read_pos - write_pos)];
}
-(int)LabelRegist:(char**)list mode:(int)mode {
    //		ラベル情報を登録
    //
    if ( mode ) {
        return [lb RegistList:list modname:(char *)"@hsp"];
    }
    return [lb RegistList:list modname:(char *)""];
}
-(int)LabelRegist2:(char**)list {
    //		ラベル情報を登録(マクロ)
    //
    return [lb RegistList2:list modname:(char *)"@hsp"];
}
-(int)LabelRegist3:(char**)list {
    //		ラベル情報を登録(色分け用)
    //
    return [lb RegistList3:list];
}
-(int)RegistExtMacroPath:(char*)keyword str:(char*)str {
    //		マクロを外部から登録(path用)
    //
    int id, res;
    char path[1024];
    char mm[512];
    unsigned char *p;
    unsigned char *src;
    unsigned char a1;
    p = (unsigned char *)path;
    src = (unsigned char *)str;
    while(1) {
        a1 = *src++;
        if ( a1 == 0 ) break;
        if ( a1 == 0x5c ) {	*p++=a1; }		// '\'チェック
        if ( a1>=129 ) {					// 全角文字チェック
            if (a1<=159) { *p++=a1;a1=*src++; }
            else if (a1>=224) { *p++=a1;a1=*src++; }
        }
        *p++ = a1;
    }
    *p = 0;
    strcpy( mm, keyword );
    [self FixModuleName:mm];
    res = [lb Search:mm];
    if ( res != -1 ) {	// すでにある場合は上書き
        [lb SetData:res str:path];
        return -1;
    }
    //		データ定義
    id = [lb Regist:mm type:LAB_TYPE_PPMAC opt:0];
    [lb SetData:id str:path];
    [lb SetEternal:id];
    return 0;
}
-(int)RegistExtMacro_str:(char*)keyword str:(char*)str {
    //		マクロを外部から登録
    //
    int id, res;
    char mm[512];
    strcpy( mm, keyword );
    [self FixModuleName:mm];
    res = [lb Search:mm];
    if ( res != -1 ) {	// すでにある場合は上書き
        [lb SetData:res str:str];
        return -1;
    }
    //		データ定義
    id = [lb Regist:mm type:LAB_TYPE_PPMAC opt:0];
    [lb SetData:id str:str];
    [lb SetEternal:id];
    return 0;
}
-(int)RegistExtMacro_val:(char*)keyword val:(int)val {
    //		マクロを外部から登録(数値)
    //
    int id, res;
    char mm[512];
    strcpy( mm, keyword );
    [self FixModuleName:mm];
    res = [lb Search:mm];
    if ( res != -1 ) {	// すでにある場合は上書き
        [lb SetOpt:res val:val];
        return -1;
    }
    //		データ定義
    id = [lb Regist:mm type:LAB_TYPE_PPVAL opt:val];
    [lb SetEternal:id];
    return 0;
}
-(int)LabelDump:(CMemBuf*)out option:(int)option {
    //		登録されているラベル情報をerrbufに展開
    //
    [lb DumpHSPLabel:linebuf option:option maxsize:LINEBUF_MAX - 256];
    [out PutStr:linebuf];
    return 0;
}
-(void)SetModuleName:(char*)name {
    //		モジュール名を設定
    //
    if ( *name==0 ) {
        modname[0] = 0; return;
    }
    sprintf( modname, "@%.*s", MODNAME_MAX, name );
    strcase( modname+1 );
}
-(char*)GetModuleName {
    //		モジュール名を取得
    //
    if ( *modname == 0 ) return modname;
    return modname+1;
}
-(void)AddModuleName:(char*)str {
    //		キーワードにモジュール名を付加(モジュール依存ラベル用)
    //
    unsigned char a1;
    unsigned char *wp;
    wp=(unsigned char *)str;
    while(1) {
        a1=*wp;
        if (a1==0) break;
        if (a1=='@') {
            a1=wp[1];
            if (a1==0) *wp=0;
            return;
        }
        if (a1>=129) wp++;
        wp++;
    }
    if ( *modname==0 ) return;
    strcpy( (char *)wp, modname );
}
-(void)FixModuleName:(char*)str {
    //		キーワードのモジュール名を正規化(モジュール非依存ラベル用)
    //
    //	char *wp;
    //	wp = str + ( strlen(str)-1 );
    //	if ( *wp=='@' ) *wp=0;
    unsigned char a1;
    unsigned char *wp;
    wp=(unsigned char *)str;
    while(1) {
        a1=*wp;
        if (a1==0) break;
        if (a1=='@') {
            a1=wp[1];
            if (a1==0) *wp=0;
            return;
        }
        if (a1>=129) wp++;
        wp++;
    }
}
-(int)IsGlobalMode {
    //		モジュール内(0)か、グローバル(1)かを返す
    //
    if ( *modname==0 ) return 1;
    return 0;
}
-(int)GetLabelBufferSize {
    //		ラベルバッファサイズを得る
    //
    return [lb GetSymbolSize];
}
-(void)InitSCNV:(int)size {
    //		文字コード変換の初期化
    //		(size<0の場合はメモリを破棄)
    //
    if ( scnvbuf != NULL ) {
        free( scnvbuf );
        scnvbuf = NULL;
    }
    if ( size <= 0 ) return;
    scnvbuf = (char *)malloc(size);
    scnvsize = size;
}
-(char*)ExecSCNV:(char*)srcbuf opt:(int)opt {
    //		文字コード変換
    //
    //int ressize;
    int size;
    if ( scnvbuf == NULL )
        [self InitSCNV:SCNVBUF_DEFAULTSIZE];
    size = (int)strlen( srcbuf );
    switch( opt ) {
        case SCNV_OPT_NONE:
            strcpy( scnvbuf, srcbuf );
            break;
        case SCNV_OPT_SJISUTF8:
            strcpy( scnvbuf, srcbuf );
            break;
        default:
            *scnvbuf = 0;
            break;
    }
    return scnvbuf;
}
-(void)SetErrorSymbolOverdefined:(char*)keyword label_id:(int)label_id {
    // 識別子の多重定義エラー
    char strtmp[0x100];
    sprintf( strtmp,"定義済みの識別子は使用できません [%s]", keyword );
    [self SetError:strtmp];
}
-(int)CheckByteSJIS:(unsigned char)c {
    //  SJISの全角1バイト目を判定する
    //  (戻り値は以降に続くbyte数)
    if (((c>=0x81)&&(c<=0x9f))||((c>=0xe0)&&(c<=0xfc))) return 1;
    return 0;
}
-(int)CheckByteUTF8:(unsigned char)c {
    //  UTF8の全角1バイト目を判定する
    //  (戻り値は以降に続くbyte数)
    if ( c <= 0x7f ) return 0;
    if ((c >= 0xc2) && (c <= 0xdf)) return 1;
    if ((c >= 0xe0) && (c <= 0xef)) return 2;
    if ((c >= 0xf0) && (c <= 0xf7)) return 3;
    if ((c >= 0xf8) && (c <= 0xfb)) return 4;
    if ((c >= 0xfc) && (c <= 0xfd)) return 5;
    return 0;
}
-(int)SkipMultiByte:(unsigned char)byte {
    //  マルチバイトコードの2byte目以降をスキップする
    //  ( 1バイト目のcharを渡すと、2byte目以降スキップするbyte数を返す )
    //  ( pp_utf8のフラグによってUTF-8とSJISを判断する )
    //
    if ( pp_utf8 ) {
        return [self CheckByteUTF8:byte];
    }
    return [self CheckByteSJIS:byte];
}
//============================================================================
//============================================================================
//============================================================================
//============================================================================
//============================================================================
//============================================================================
//============================================================================
//============================================================================
//============================================================================
//============================================================================
//============================================================================
//============================================================================
//============================================================================
//============================================================================
//============================================================================
//
//
//
//
// CodeGenerator
-(void)CalcCG_token {
    [self GetTokenCG:GETTOKEN_DEFAULT];
    if (ttype == TK_NONE)
        ttype = val;
}
-(void)CalcCG_token_exprbeg {
    [self GetTokenCG:GETTOKEN_EXPRBEG];
    if (ttype == TK_NONE)
        ttype = val;
}
-(void)CalcCG_token_exprbeg_redo {
    //        GETTOKEN_EXPRBEG でトークンを取得し直す
    //
    //        GetTokenCG は 文字列リテラルや文字コードリテラルの場合、
    //        cg_ptr のバッファを破壊するので常に取得し直すわけにはいかない
    //
    if (ttype == TK_NONE)
        ttype = val;
    if (ttype == '-' || ttype == '*') {
        cg_ptr = cg_ptr_bak;
        [self CalcCG_token_exprbeg];
    }
}
-(int)is_statement_end:(int)type {
    return (type == TK_SEPARATE) || (type == TK_EOL) || (type == TK_EOF);
}
-(void)CalcCG_regmark:(int)mark {
    //        演算子を登録する
    //
    int op;
    op = 0;
    switch (mark) {
        case '+':
            op = CALCCODE_ADD;
            break;
        case '-':
            op = CALCCODE_SUB;
            break;
        case '*':
            op = CALCCODE_MUL;
            break;
        case '/':
            op = CALCCODE_DIV;
            break;
        case '=':
            op = CALCCODE_EQ;
            break;
        case '!':
            op = CALCCODE_NE;
            break;
        case '<':
            op = CALCCODE_LT;
            break;
        case '>':
            op = CALCCODE_GT;
            break;
        case 0x61: // '<='
            op = CALCCODE_LTEQ;
            break;
        case 0x62: // '>='
            op = CALCCODE_GTEQ;
            break;
        case '&':
            op = CALCCODE_AND;
            break;
        case '|':
            op = CALCCODE_OR;
            break;
        case '^':
            op = CALCCODE_XOR;
            break;
        case 0x5c: // '¥'
            op = CALCCODE_MOD;
            break;
        case 0x63: // '<<'
            op = CALCCODE_LR;
            break;
        case 0x64: // '>>'
            op = CALCCODE_RR;
            break;
        default:
            throw CGERROR_CALCEXP;
    }
    calccount++;
    [self PutCS:TK_NONE value:op exflg:texflag];
}
-(void)CalcCG_factor {
    int id;
    cs_lasttype = ttype;
    switch (ttype) {
        case TK_NUM:
            [self PutCS:TYPE_INUM value:val exflg:texflag];
            texflag = 0;
            [self CalcCG_token];
            calccount++;
            return;
        case TK_DNUM:
            [self PutCS:TYPE_DNUM value:val_d exflg:texflag];
            texflag = 0;
            [self CalcCG_token];
            calccount++;
            return;
        case TK_STRING:
            [self PutCS:TYPE_STRING value:[self PutDS:cg_str] exflg:texflag];
            texflag = 0;
            [self CalcCG_token];
            calccount++;
            return;
        case TK_LABEL:
            [self GenerateCodeLabel:cg_str ex:texflag];
            texflag = 0;
            [self CalcCG_token];
            calccount++;
            return;
        case TK_OBJ:
            id = [self SetVarsFixed:cg_str fixedvalue:cg_defvarfix];
            if ([lb GetType:id] == TYPE_VAR) {
                if ([lb GetInitFlag:id] == LAB_INIT_NO) {
                    NSLog(@"#未初期化の変数があります(%s)\n",cg_str);
                    if (hed_cmpmode & CMPMODE_VARINIT) {
                        throw CGERROR_VAR_NOINIT;
                    }
                    [lb SetInitFlag:id val:LAB_INIT_DONE];
                }
            }
            [self GenerateCodeVAR:id ex:texflag];
            texflag = 0;
            if (ttype == TK_NONE)
                ttype = val; // CalcCG_token()に合わせるため
            calccount++;
            return;
        case TK_SEPARATE:
        case TK_EOL:
        case TK_EOF:
            return;
        default:
            break;
    }
    if (ttype != '(') {
        // Mesf("#Invalid%d",ttype);
        ttype = TK_CALCERROR;
        return;
    }
    //        カッコの処理
    //
    [self CalcCG_token_exprbeg];
    [self CalcCG_start];
    if (ttype != ')') {
        ttype = TK_CALCERROR;
        return;
    }
    [self CalcCG_token];
}
-(void)CalcCG_unary {
    //        単項演算子
    //
    int op;
    if (ttype == '-') {
        op = ttype;
        [self CalcCG_token_exprbeg];
        if ([self is_statement_end:ttype])
            throw CGERROR_CALCEXP;
        [self CalcCG_unary];
        texflag = 0;
        [self PutCS:TYPE_INUM value:-1 exflg:texflag];
        [self CalcCG_regmark:'*'];
    } else {
        [self CalcCG_factor];
    }
}
-(void)CalcCG_muldiv {
    int op;
    [self CalcCG_unary];
    while ((ttype == '*') || (ttype == '/') || (ttype == '\\')) {
        op = ttype;
        [self CalcCG_token_exprbeg];
        if ([self is_statement_end:ttype])
            throw CGERROR_CALCEXP;
        [self CalcCG_unary];
        [self CalcCG_regmark:op];
    }
}
-(void)CalcCG_addsub {
    int op;
    [self CalcCG_muldiv];
    while ((ttype == '+') || (ttype == '-')) {
        op = ttype;
        [self CalcCG_token_exprbeg];
        if ([self is_statement_end:ttype])
            throw CGERROR_CALCEXP;
        [self CalcCG_muldiv];
        [self CalcCG_regmark:op];
    }
}
-(void)CalcCG_shift {
    int op;
    [self CalcCG_addsub];
    while ((ttype == 0x63) || (ttype == 0x64)) {
        op = ttype;
        [self CalcCG_token_exprbeg];
        if ([self is_statement_end:ttype])
            throw CGERROR_CALCEXP;
        [self CalcCG_addsub];
        [self CalcCG_regmark:op];
    }
}
-(void)CalcCG_compare {
    int op;
    [self CalcCG_shift];
    while ((ttype == '<') || (ttype == '>') || (ttype == '=') || (ttype == '!') ||
           (ttype == 0x61) || (ttype == 0x62)) {
        op = ttype;
        [self CalcCG_token_exprbeg];
        if ([self is_statement_end:ttype])
            throw CGERROR_CALCEXP;
        [self CalcCG_shift];
        [self CalcCG_regmark:op];
    }
}
-(void)CalcCG_bool {
    int op;
    [self CalcCG_compare];
    while ((ttype == '&') || (ttype == '|') || (ttype == '^')) {
        op = ttype;
        [self CalcCG_token_exprbeg];
        if ([self is_statement_end:ttype])
            throw CGERROR_CALCEXP;
        [self CalcCG_compare];
        [self CalcCG_regmark:op];
    }
}
-(void)CalcCG_start {
    //        entry point
    [self CalcCG_bool];
}
-(void)CalcCG:(int)ex {
    //        パラメーターの式を評価する
    //        (結果は逆ポーランドでコードを出力する)
    //
    texflag = ex;
    cs_lastptr = [cs_buf GetSize];
    calccount = 0;
    [self CalcCG_token_exprbeg_redo];
    [self CalcCG_start];
    if (ttype == TK_CALCERROR) {
        throw CGERROR_CALCEXP;
    }
}
//-----------------------------------------------------------------------------
-(char*)PickLongStringCG:(char*)str {
    //        指定文字列をmembufへ展開する
    //        ( 複数行対応 {"〜"} )
    //
    char* p;
    char* psrc;
    char* ps;
    p = psrc = str;
    while (1) {
        p = [self PickStringCG2:p strsrc:&psrc];
        if (*psrc != 0)
            break;
        ps = [self GetLineCG];
        if (ps == NULL)
            throw CGERROR_MULTILINE_STR;
        psrc = ps;
        cg_orgline++;
        //        行の終端にある0を改行に置き換える
        p[0] = 13;
        p[1] = 10;
        p += 2;
    }
    if (*psrc != '}')
        throw CGERROR_MULTILINE_STR;
    if (cg_debug) {
        [self PutDI_int:254 a:0 subid:cg_orgline]; // ラインだけをデバッグ情報として登録
    }
    psrc++;
    return psrc;
}
-(char*)PickStringCG:(char*)str sep:(int)sep {
    //        指定文字列をスキップして終端コードを付加する
    //            sep = 区切り文字
    //
    unsigned char* vs;
    unsigned char* pp;
    int skip, i;
    unsigned char a1;
    vs = (unsigned char*)str;
    pp = vs;
    while (1) {
        a1 = *vs;
        if (a1 == 0)
            break;
        if (a1 == sep) {
            vs++;
            break;
        }
        if (a1 == 0x5c) { // '¥'チェック
            vs++;
            a1 = tolower(*vs);
            if (a1 < 32)
                continue;
            switch (a1) {
                case 'n':
                    *pp++ = 13;
                    a1 = 10;
                    break;
                case 't':
                    a1 = 9;
                    break;
                case 'r':
                    a1 = 13;
                    break;
            }
        }
        // 全角文字チェック＊
        // if (a1>=129) {
        //    if ((a1<=159)||(a1>=224)) {
        //        NSLog(@"A:%s",str);
        skip = [self SkipMultiByte:a1]; // 全角文字チェック
        if (skip) {
            for (i = 0; i < skip; i++) {
                *pp++ = a1;
                vs++;
                a1 = *vs;
            }
        }
        //        uint8 c = a1;
        //        //if (c >= 0 && c < 128) { return 1; }
        //        if (c >= 128 && c < 192) { *pp++ = a1; vs++; a1=*vs; }
        //        if (c >= 192 && c < 224) { *pp++ = a1; vs++; a1=*vs; }
        //        if (c >= 224 && c < 240) { *pp++ = a1; vs++; a1=*vs; }
        //        if (c >= 240 && c < 248) { *pp++ = a1; vs++; a1=*vs; }
        //        if (c >= 248 && c < 252) { *pp++ = a1; vs++; a1=*vs; }
        //        if (c >= 252 && c < 254) { *pp++ = a1; vs++; a1=*vs; }
        //        if (c >= 254 && c <= 255) { *pp++ = a1; vs++; a1=*vs; }
        vs++;
        *pp++ = a1;
    }
    // NSLog(@"%s",pp);
    *pp = 0;
    return (char*)vs;
}
-(char*)PickStringCG2:(char*)str strsrc:(char**)strsrc {
    //        指定文字列をスキップして終端コードを付加する
    //            sep = 区切り文字
    //
    unsigned char* vs;
    unsigned char* pp;
    unsigned char a1;
    int skip, i;
    vs = (unsigned char*)*strsrc;
    pp = (unsigned char*)str;
    while (1) {
        a1 = *vs;
        // Alertf("%d(%c)",a1,a1);
        if (a1 == 0)
            break;
        if (a1 == 0x22) {
            vs++;
            if (*vs == '}')
                break;
            *pp++ = a1;
            continue;
        }
        if (a1 == 0x5c) { // '¥'チェック
            vs++;
            a1 = tolower(*vs);
            if (a1 < 32)
                continue;
            switch (a1) {
                case 'n':
                    *pp++ = 13;
                    a1 = 10;
                    break;
                case 't':
                    a1 = 9;
                    break;
                case 'r':
                    a1 = 13;
                    break;
                case 0x22:
                    a1 = 0x22;
                    break;
            }
        }
        // if (a1>=129) {                    // 全角文字チェック
        //    if ((a1<=159)||(a1>=224)) {
        skip = [self SkipMultiByte:a1]; // 全角文字チェック
        if (skip) {
            for (i = 0; i < skip; i++) {
                *pp++ = a1;
                vs++;
                a1 = *vs;
            }
        }
        vs++;
        *pp++ = a1;
    }
    *pp = 0;
    *strsrc = (char*)vs;
    return (char*)pp;
}
-(char*)GetTokenCG:(int)option{
    cg_ptr_bak = cg_ptr;
    cg_ptr = [self GetTokenCG:cg_ptr option:option];
    return cg_ptr;
}
-(int)PickNextCodeCG{
    //        次のコード(１文字を返す)
    //        (終端の場合は0を返す)
    //
    unsigned char* vs;
    unsigned char a1;
    vs = (unsigned char*)cg_ptr;
    if (vs == NULL)
        return 0;
    while (1) {
        a1 = *vs;
        if ((a1 != 32) && (a1 != '\t')) { // space,tab以外か?
            break;
        }
        vs++;
    }
    return (int)a1;
}
-(char*)GetTokenCG:(char*)str option:(int)option {
    //        stringデータのタイプと内容を返す
    //        (次のptrを返す)
    //        (ttypeにタイプを、val,val_d,cg_strに内容を書き込みます)
    //
    unsigned char* vs;
    unsigned char a1;
    unsigned char a2;
    int a, b, chk, labmode;
    int skip, i;
    vs = (unsigned char*)str;
    if (vs == NULL) {
        ttype = TK_EOF;
        return NULL; // already end
    }
    while (1) {
        a1 = *vs;
        if ((a1 != 32) && (a1 != '\t')) { // space,tab以外か?
            break;
        }
        vs++;
    }
    if (a1 == 0) { // end
        ttype = TK_EOL;
        return (char*)vs;
        // return [self GetLineCG];
    }
    if (a1 < 0x20) { // 無効なコード
        ttype = TK_ERROR;
        throw CGERROR_UNKNOWN;
    }
    if (a1 == 0x22) { // "〜"
        vs++;
        ttype = TK_STRING;
        cg_str = (char*)vs;
        return [self PickStringCG:(char*)vs sep:0x22];
    }
    if (a1 == '{') { // {"〜"}
        if (vs[1] == 0x22) {
            vs += 2;
            if (*vs == 0) {
                vs = (unsigned char*)[self GetLineCG];
                cg_orgline++;
            }
            ttype = TK_STRING;
            cg_str = (char*)vs;
            return [self PickLongStringCG:(char*)vs];
        }
    }
    if (a1 == 0x27) { // '〜'
        char* p;
        vs++;
        cg_str = (char*)vs;
        p = [self PickStringCG:(char*)vs sep:0x27];
        ttype = TK_NUM;
        val = ((unsigned char*)cg_str)[0];
        return p;
    }
    if ((a1 == ':') || (a1 == '{') || (a1 == '}')) { // multi statement
        cg_str = (char*)s2;
        ttype = TK_SEPARATE;
        cg_str[0] = a1;
        cg_str[1] = 0;
        return (char*)vs + 1;
    }
    if (a1 == '0') {
        a2 = tolower(vs[1]);
        if (a2 == 'x') {
            vs++;
            a1 = '$';
        } // when hex code (0x)
        if (a2 == 'b') {
            vs++;
            a1 = '%';
        } // when bin code (0b)
    }
    if (a1 == '$') { // when hex code ($)
        vs++;
        val = 0;
        cg_str = (char*)s2;
        a = 0;
        while (1) {
            a1 = toupper(*vs);
            b = -1;
            if (a1 == 0)
                break;
            if ((a1 >= 0x30) && (a1 <= 0x39))
                b = a1 - 0x30;
            if ((a1 >= 0x41) && (a1 <= 0x46))
                b = a1 - 55;
            if (a1 == '_')
                b = -2;
            if (b == -1)
                break;
            if (b >= 0) {
                cg_str[a++] = (char)a1;
                val = (val << 4) + b;
            }
            vs++;
        }
        cg_str[a] = 0;
        ttype = TK_NUM;
        return (char*)vs;
    }
    if (a1 == '%') { // when bin code (%)
        vs++;
        val = 0;
        cg_str = (char*)s2;
        a = 0;
        while (1) {
            a1 = *vs;
            b = -1;
            if (a1 == 0)
                break;
            if ((a1 >= 0x30) && (a1 <= 0x31))
                b = a1 - 0x30;
            if (a1 == '_')
                b = -2;
            if (b == -1)
                break;
            if (b >= 0) {
                cg_str[a++] = (char)a1;
                val = (val << 1) + b;
            }
            vs++;
        }
        cg_str[a] = 0;
        ttype = TK_NUM;
        return (char*)vs;
    }
    chk = 0;
    labmode = 0;
    if (a1 < 0x30)
        chk++;
    if ((a1 >= 0x3a) && (a1 <= 0x3f))
        chk++;
    if ((a1 >= 0x5b) && (a1 <= 0x5e))
        chk++;
    if ((a1 >= 0x7b) && (a1 <= 0x7f))
        chk++;
    if (option & (GETTOKEN_EXPRBEG | GETTOKEN_LABEL)) {
        if (a1 == '*') { // ラベル
            a2 = vs[1];
            b = 0;
            if (a2 < 0x30)
                b++;
            if ((a2 >= 0x30) && (a2 <= 0x3f))
                b++;
            if ((a2 >= 0x5b) && (a2 <= 0x5e))
                b++;
            if ((a2 >= 0x7b) && (a2 <= 0x7f))
                b++;
            if (b == 0) {
                chk = 0;
                labmode = 1;
                vs++;
                a1 = *vs;
            }
        }
    }
    int is_negative_number = 0;
    if (option & GETTOKEN_EXPRBEG && a1 == '-') {
        is_negative_number = isdigit(vs[1]);
    }
    if (is_negative_number || isdigit(a1)) { // when 0-9 numerical
        a = 0;
        chk = 0;
        if (is_negative_number) {
            vs++;
        }
        while (1) {
            a1 = *vs;
            if (option & GETTOKEN_NOFLOAT) {
                if ((a1 < 0x30) || (a1 > 0x39))
                    break;
            } else {
                if (a1 == '.') {
                    chk++;
                    if (chk > 1) {
                        ttype = TK_ERROR;
                        throw CGERROR_FLOATEXP;
                        return (char*)vs;
                    }
                } else {
                    if ((a1 < 0x30) || (a1 > 0x39))
                        break;
                }
            }
            s2[a++] = a1;
            vs++;
        }
        if ((a1 == 'f') || (a1 == 'd')) {
            chk = 1;
            vs++;
        }
        if (a1 == 'e') { // 指数部を取り込む
            chk = 1;
            s2[a++] = 'e';
            vs++;
            a1 = *vs;
            if ((a1 == '-') || (a1 == '+')) {
                s2[a++] = a1;
                vs++;
            }
            while (1) {
                a1 = *vs;
                if ((a1 < 0x30) || (a1 > 0x39))
                    break;
                s2[a++] = a1;
                vs++;
            }
        }
        s2[a] = 0;
        switch (chk) {
            case 1:
                val_d = atof((char*)s2);
                if (is_negative_number) {
                    val_d = -val_d;
                }
                ttype = TK_DNUM;
                break;
            default:
                val = atoi_allow_overflow((char*)s2);
                if (is_negative_number) {
                    val = -val;
                }
                ttype = TK_NUM;
                break;
        }
        return (char*)vs;
    }
    if (chk) { // 記号
        vs++;
        a2 = *vs;
        switch (a1) {
            case '-':
                if (a2 == '>') {
                    vs++;
                    a1 = 0x65;
                } // '->'
                break;
            case '!':
                if (a2 == '=')
                    vs++;
                break;
            case '<':
                if (a2 == '<') {
                    vs++;
                    a1 = 0x63;
                } // '<<'
                if (a2 == '=') {
                    vs++;
                    a1 = 0x61;
                } // '<='
                break;
            case '>':
                if (a2 == '>') {
                    vs++;
                    a1 = 0x64;
                } // '>>'
                if (a2 == '=') {
                    vs++;
                    a1 = 0x62;
                } // '>='
                break;
            case '=':
                if (a2 == '=') {
                    vs++;
                } // '=='
                break;
            case '|':
                if (a2 == '|') {
                    vs++;
                } // '||'
                break;
            case '&':
                if (a2 == '&') {
                    vs++;
                } // '&&'
                break;
        }
        ttype = TK_NONE;
        val = (int)a1;
        return (char*)vs;
    }
    a = 0;
    while (1) { // シンボル取り出し
        a1 = *vs;
        // if (a1>=129) {
        //全角文字チェック＊
        //    if ((a1<=159)||(a1>=224)) {
        skip = [self SkipMultiByte:a1]; // 全角文字チェック
        if (skip) {
            for (i = 0; i < (skip + 1); i++) {
                NSLog(@"B:%s", str);
                if (a < OBJNAME_MAX) {
                    s2[a++] = a1;
                    vs++;
                    a1 = *vs;
                    // s2[a++] = a1; vs++;
                } else {
                    // vs+=2;
                    vs++;
                }
                // continue;
            }
            continue;
        }
        //        uint8 c = a1;
        //        //if (c >= 0 && c < 128) { return 1; }
        //        if (c >= 128 && c < 192) { if (a<OBJNAME_MAX){s2[a++]=a1; vs++;
        //        a1=*vs; s2[a++]=a1; vs++;} else {vs+=2;} continue; }
        //        if (c >= 192 && c < 224) { if (a<OBJNAME_MAX){s2[a++]=a1; vs++;
        //        a1=*vs; s2[a++]=a1; vs++;} else {vs+=2;} continue; }
        //        if (c >= 224 && c < 240) { if (a<OBJNAME_MAX){s2[a++]=a1; vs++;
        //        a1=*vs; s2[a++]=a1; vs++;} else {vs+=2;} continue; }
        //        if (c >= 240 && c < 248) { if (a<OBJNAME_MAX){s2[a++]=a1; vs++;
        //        a1=*vs; s2[a++]=a1; vs++;} else {vs+=2;} continue; }
        //        if (c >= 248 && c < 252) { if (a<OBJNAME_MAX){s2[a++]=a1; vs++;
        //        a1=*vs; s2[a++]=a1; vs++;} else {vs+=2;} continue; }
        //        if (c >= 252 && c < 254) { if (a<OBJNAME_MAX){s2[a++]=a1; vs++;
        //        a1=*vs; s2[a++]=a1; vs++;} else {vs+=2;} continue; }
        //        if (c >= 254 && c <= 255) { if (a<OBJNAME_MAX){s2[a++]=a1; vs++;
        //        a1=*vs; s2[a++]=a1; vs++;} else {vs+=2;} continue; }
        chk = 0;
        if (a1 < 0x30)
            chk++;
        if ((a1 >= 0x3a) && (a1 <= 0x3f))
            chk++;
        if ((a1 >= 0x5b) && (a1 <= 0x5e))
            chk++;
        if ((a1 >= 0x7b) && (a1 <= 0x7f))
            chk++;
        if (chk)
            break;
        vs++;
        if (a < OBJNAME_MAX)
            s2[a++] = a1;
    }
    s2[a] = 0;
    //        シンボル
    //
    if (labmode) {
        ttype = TK_LABEL;
    } else {
        ttype = TK_OBJ;
    }
    cg_str = (char*)s2;
    return (char*)vs;
}
-(char*)GetSymbolCG:(char*)str {
    //        stringデータのシンボル内容を返す
    //
    unsigned char* vs;
    unsigned char a1;
    int a, chk, labmode;
    int skip, i;
    vs = (unsigned char*)str;
    if (vs == NULL)
        return NULL; // already end
    while (1) {
        a1 = *vs;
        if ((a1 != 32) && (a1 != '\t')) { // space,tab以外か?
            break;
        }
        vs++;
    }
    if (a1 < 0x20) { // 無効なコード
        return NULL;
    }
    chk = 0;
    labmode = 0;
    if (a1 < 0x30)
        chk++;
    if ((a1 >= 0x3a) && (a1 <= 0x3f))
        chk++;
    if ((a1 >= 0x5b) && (a1 <= 0x5e))
        chk++;
    if ((a1 >= 0x7b) && (a1 <= 0x7f))
        chk++;
    if (chk) { // 記号
        return NULL;
    }
    a = 0;
    while (1) { // シンボル取り出し
        a1 = *vs;
        // if (a1>=129) {                // 全角文字チェック
        //    if ((a1<=159)||(a1>=224)) {
        skip = [self SkipMultiByte:a1]; // 全角文字チェック
        if (skip) {
            for (i = 0; i < (skip + 1); i++) {
                if (a < OBJNAME_MAX) {
                    s2[a++] = a1;
                    vs++;
                    a1 = *vs;
                    // s2[a++] = a1; vs++;
                } else {
                    // vs+=2;
                    vs++;
                }
            }
            continue;
        }
        chk = 0;
        if (a1 < 0x30)
            chk++;
        if ((a1 >= 0x3a) && (a1 <= 0x3f))
            chk++;
        if ((a1 >= 0x5b) && (a1 <= 0x5e))
            chk++;
        if ((a1 >= 0x7b) && (a1 <= 0x7f))
            chk++;
        if (chk)
            break;
        vs++;
        if (a < OBJNAME_MAX)
            s2[a++] = a1;
    }
    s2[a] = 0;
    return (char*)s2;
}
//-----------------------------------------------------------------------------
-(void)GenerateCodePRM {
    //        HSP3Codeを展開する(パラメーター)
    //
    int ex;
    ex = 0;
    while (1) {
        if (ttype == TK_NONE) {
            if (val == ',') { // 先頭が','の場合は省略
                if (ex & EXFLG_2)
                    [self PutCS:TYPE_MARK value:'?' exflg:EXFLG_2];
                [self GetTokenCG:GETTOKEN_DEFAULT];
                ex |= EXFLG_2;
                continue;
            }
        }
        [self CalcCG:ex]; // 式の評価
        // Mesf( "#count %d", calccount );
        if (hed_cmpmode & CMPMODE_OPTPRM) {
            if (calccount == 1) { // パラメーターが単一項目の時
                switch (cs_lasttype) {
                    case TK_NUM:
                    case TK_DNUM:
                    case TK_STRING: {
                        unsigned short* cstmp;
                        cstmp = (unsigned short*)([cs_buf GetBuffer] + cs_lastptr);
                        *cstmp |= EXFLG_0; // 単一項目フラグを立てる
                        break;
                    }
                    default:
                        break;
                }
            }
        }
        if (ttype >= TK_SEPARATE)
            break;
        if (ttype != ',') {
            // NSLog(@"%d",ttype);
            //
            //エラー箇所
            throw CGERROR_CALCEXP;
        }
        [self GetTokenCG:GETTOKEN_DEFAULT];
        ex |= EXFLG_2;
        if (ttype >= TK_SEPARATE) {
            [self PutCS:TYPE_MARK value:'?' exflg:EXFLG_2];
            break;
        }
    }
}
-(int)GenerateCodePRMF {
    //        HSP3Codeを展開する(カッコ内のパラメーター)
    //        (戻り値 : exflg)
    //
    int ex;
    ex = 0;
    while (1) {
        if (ttype == TK_NONE) {
            if (val == ')') { // ')'の場合は終了
                return ex;
            }
            if (val == ',') { // 先頭が','の場合は省略
                if (ex & EXFLG_2)
                    [self PutCS:TYPE_MARK value:'?' exflg:EXFLG_2];
                [self GetTokenCG:GETTOKEN_DEFAULT];
                ex |= EXFLG_2;
                continue;
            }
        }
        [self CalcCG:ex];
        if (ttype >= TK_SEPARATE)
            throw CGERROR_PRMEND;
        if (ttype == ')')
            break;
        if (ttype != ',') {
            throw CGERROR_CALCEXP;
        }
        [self GetTokenCG:GETTOKEN_DEFAULT];
        ex |= EXFLG_2;
    }
    return 0;
}
-(void)GenerateCodePRMF2 {
    //        HSP3Codeを展開する('.'から始まる配列内のパラメーター)
    //
    int t;
    int id, ex;
    int tmp;
    ex = 0;
    while (1) {
        if (ttype >= TK_SEPARATE)
            break;
        // Mesf( "(type:%d val:%d) line:%d", ttype, val, cg_orgline );
        switch (ttype) {
            case TK_NONE:
                if (val == '(') {
                    [self GetTokenCG:GETTOKEN_DEFAULT];
                    [self CalcCG:ex];
                    if (ttype != ')')
                        throw CGERROR_CALCEXP;
                } else {
                    throw CGERROR_ARRAYEXP;
                }
                [self GetTokenCG:GETTOKEN_NOFLOAT];
                break;
            case TK_NUM:
                [self PutCS:TYPE_INUM value:val exflg:ex];
                [self GetTokenCG:GETTOKEN_NOFLOAT];
                break;
            case TK_OBJ:
                id = [self SetVarsFixed:cg_str fixedvalue:cg_defvarfix];
                t = [lb GetType:id];
                if ((t == TYPE_XLABEL) || (t == TYPE_LABEL))
                    throw CGERROR_LABELNAME;
                [self PutCSSymbol:id exflag:ex];
                [self GetTokenCG:GETTOKEN_DEFAULT];
                if (ttype == TK_NONE) {
                    if (val == '(') { // '(' 配列指定
                        [self GetTokenCG:GETTOKEN_DEFAULT];
                        [self PutCS:TYPE_MARK value:'(' exflg:0];
                        tmp = [self GenerateCodePRMF];
                        if (tmp)
                            [self PutCS:TYPE_MARK value:'?' exflg:EXFLG_2];
                        [self PutCS:TYPE_MARK value:')' exflg:0];
                        [self GetTokenCG:GETTOKEN_DEFAULT];
                    }
                }
                // GenerateCodeVAR( id, ex );
                break;
            default:
                throw CGERROR_ARRAYEXP;
        }
        if (ttype >= TK_SEPARATE)
            return;
        if (ttype != TK_NONE && ttype != '.')
            throw CGERROR_ARRAYEXP;
        if (val != '.')
            return;
        [self GetTokenCG:GETTOKEN_NOFLOAT];
        ex |= EXFLG_2;
    }
}
-(void)GenerateCodePRMF3 {
    //        HSP3Codeを展開する('<'から始まる構造体参照元のパラメーター)
    //
    int id, ex;
    ex = 0;
    [self GetTokenCG:GETTOKEN_DEFAULT];
    if (ttype != TK_OBJ)
        throw CGERROR_PP_BAD_STRUCT_SOURCE;
    id = [self SetVarsFixed:cg_str fixedvalue:cg_defvarfix];
    [self GenerateCodeVAR:id ex:ex];
    if (ttype != TK_NONE)
        throw CGERROR_PP_BAD_STRUCT_SOURCE;
    if (val != ']')
        throw CGERROR_PP_BAD_STRUCT_SOURCE;
    [self GetTokenCG:GETTOKEN_DEFAULT];
}
-(int)GenerateCodePRMF4:(int)t {
    //        HSP3Codeを展開する(構造体/配列指定パラメーター)
    //
    //    int t,id;
    int ex;
    int tmp;
    ex = 0;
    if (ttype == TK_NONE) {
        if (val == '.') {
            [self GetTokenCG:GETTOKEN_NOFLOAT];
            /*
             if ( ttype == TK_OBJ ) {
             id = lb->Search( cg_str );
             if ( id < 0 ) throw CGERROR_PP_BAD_STRUCT;
             t = [lb GetType:id];
             if ( t == TYPE_STRUCT ) {
             PutCS( t, [lb GetOpt:id];, ex );
             GetTokenCG( GETTOKEN_DEFAULT );
             return GenerateCodePRMF4();
             }
             }
             */
            [self PutCS:TYPE_MARK value:'(' exflg:0]; // '.' 配列指定
            [self GenerateCodePRMF2];
            [self PutCS:TYPE_MARK value:')' exflg:0];
            return 1;
        }
        if (val == '(') { // '(' 配列指定
            [self GetTokenCG:GETTOKEN_DEFAULT];
            [self PutCS:TYPE_MARK value:'(' exflg:0];
            tmp = [self GenerateCodePRMF];
            if (tmp)
                [self PutCS:TYPE_MARK value:'?' exflg:EXFLG_2];
            [self PutCS:TYPE_MARK value:')' exflg:0];
            [self GetTokenCG:GETTOKEN_DEFAULT];
            return 1;
        }
        if (t == TYPE_STRUCT) {
            if (val == '[') { // '[' ソース指定
                [self PutCS:TYPE_MARK value:'[' exflg:0];
                [self GenerateCodePRMF3];
                return 0;
            }
        }
    }
    return 0;
}
-(void)GenerateCodeMethod {
    //        HSP3Codeを展開する(->に続くメソッド名)
    //
    int id, ex;
    ex = 0;
    if (ttype >= TK_SEPARATE)
        throw CGERROR_SYNTAX;
    switch (ttype) {
        case TK_NUM:
            [self PutCS:TYPE_INUM value:val exflg:ex];
            [self GetTokenCG:GETTOKEN_DEFAULT];
            break;
        case TK_STRING:
            [self PutCS:TYPE_STRING value:[self PutDS:cg_str] exflg:ex];
            [self GetTokenCG:GETTOKEN_DEFAULT];
            break;
        case TK_OBJ:
            id = [self SetVarsFixed:cg_str fixedvalue:cg_defvarfix];
            [self GenerateCodeVAR:id ex:ex];
            break;
        default:
            throw CGERROR_SYNTAX;
    }
    ex |= EXFLG_2;
    while (1) {
        if (ttype == TK_NONE) {
            if (val == ',') { // 先頭が','の場合は省略
                if (ex & EXFLG_2)
                    [self PutCS:TYPE_MARK value:'?' exflg:EXFLG_2];
                [self GetTokenCG:GETTOKEN_DEFAULT];
                ex |= EXFLG_2;
                continue;
            }
        }
        [self CalcCG:ex]; // 式の評価
        if (ttype >= TK_SEPARATE)
            break;
        if (ttype != ',') {
            throw CGERROR_CALCEXP;
        }
        [self GetTokenCG:GETTOKEN_DEFAULT];
        ex |= EXFLG_2;
    }
}
#if 0
-(void)GenerateCodePRMN {
    //        HSP3Codeを展開する(パラメーター)
    //        (ソースの順番通りに展開する/実験用)
    //
    int i,t,ex;
    ex = 0;
    while(1) {
        if ( ttype >= TK_SEPARATE ) break;
        switch( ttype ) {
            case TK_NONE:
                if ( val == ',' ) {
                    if ( ex & EXFLG_2 )
                        [self PutCS:TYPE_MARK value:'?' exflg:ex];
                    ex |= EXFLG_2;
                } else {
                    [self PutCS:TYPE_MARKa value:val exflg:ex];
                    ex = 0;
                }
                break;
            case TK_NUM:
                [self PutCS:TYPE_INUM value:val exflg:ex];
                ex = 0;
                break;
            case TK_STRING:
                [self PutCS:TYPE_STRING value:[self PutDS:cg_str] exflg:ex];
                ex = 0;
                break;
            case TK_DNUM:
                [self PutCS:TYPE_DNUM val;ue:val_d exflg:ex];
                ex = 0;
                break;
            case TK_OBJ:
                i = [lb Search:cg_str];
                if ( i < 0 ) {
                    [lb Regist:cg_str type:TYPE_VAR opt:cg_valcnt];
                    [self PutCS:TYPE_VAR value:cg_valcnt exflg:ex];
                    cg_valcnt++;
                } else {
                    t = lb->GetType( i );
                    if ( t == TYPE_XLABEL ) t = TYPE_LABEL;
                    [self PutCS:t value:[lb GetOpt:i] exflg:ex];
                }
                ex = 0;
                break;
            case TK_LABEL:
                GenerateCodeLabel( cg_str, ex );
                ex = 0;
                break;
            default:
                throw CGERROR_SYNTAX;
        }
        GetTokenCG( GETTOKEN_DEFAULT );
    }
}
#endif
-(void)GenerateCodeLabel:(char*)keyname ex:(int)ex {
    //        HSP3Codeを展開する(ラベル)
    //
    int id, t, i;
    char lname[128];
    char* name;
    name = keyname;
    if (*name == '@') {
        switch (tolower(name[1])) {
            case 'f':
                i = cg_locallabel;
                break;
            case 'b':
                i = cg_locallabel - 1;
                break;
            default:
                throw CGERROR_LABELNAME;
        }
        sprintf(lname, "@l%d", i); // local label
        name = lname;
    }
    id = [lb Search:name];
    if (id < 0) { // 仮のラベル
        i = [self PutOT:-1];
        id = [lb Regist:name type:TYPE_XLABEL opt:i];
    } else {
        t = [lb GetType:id];
        if ((t != TYPE_XLABEL) && (t != TYPE_LABEL))
            throw CGERROR_LABELEXIST;
    }
    [self PutCS:TYPE_LABEL value:[lb GetOpt:id] exflg:ex];
}
-(void)GenerateCodeVAR:(int)id ex:(int)ex {
    //        HSP3Codeを展開する(変数ほか)
    //        (idはlabel ID)
    //
    int t;
    t = [lb GetType:id];
    if ((t == TYPE_XLABEL) || (t == TYPE_LABEL))
        throw CGERROR_LABELNAME;
    //
    [self PutCSSymbol:id exflag:ex];
    [self GetTokenCG:GETTOKEN_DEFAULT];
    if (t == TYPE_SYSVAR)
        return;
    [self GenerateCodePRMF4:t]; // 構造体/配列のチェック
}
-(void)CheckCMDIF_Set:(int)mode {
    //        set 'if'&'else' command additional code
    //            mode/ 0=if 1=else
    //
    if (iflev >= CG_IFLEV_MAX)
        throw CGERROR_IF_OVERFLOW;
    iftype[iflev] = mode;
    ifptr[iflev] = [self GetCS];
    [cs_buf Put_short:(short)0];
    ifmode[iflev] = [self GetCS];
    ifscope[iflev] = CG_IFCHECK_LINE;
    ifterm[iflev] = 0;
    iflev++;
    // sprintf(tmp,"#IF BEGIN [L=%d(%d)]¥n",cline,iflev);
    // prt(tmp);
}
-(void)CheckCMDIF_Fin:(int)mode {
    //        finish 'if'&'else' command
    //            mode/ 0=if 1=else
    //
    int a;
    short* p;
    if (iflev == 0)
        return;
finag:
    iflev--;
    a = [self GetCS] - ifmode[iflev];
    if (mode) { // when 'else'
        a++;
    }
    if (ifterm[iflev] == 0) {
        ifterm[iflev] = 1;
        p = (short*)[cs_buf GetBuffer];
        p[ifptr[iflev]] = (short)a;
    }
    // sprintf(tmp,"#IF FINISH [L=%d(%d)] [skip%d]¥n",cline,iflev,a);
    // prt(tmp);
    // Mesf( "lev%d : %d: line%d", iflev, ifscope[iflev], cg_orgline );
    if (mode == 0) {
        if (iflev) {
            if (ifscope[iflev - 1] == CG_IFCHECK_LINE)
                goto finag;
        }
    }
}
-(void)CheckInternalIF:(int)opt {
    //        内蔵命令生成時チェック
    //
    if (opt) { // 'else'+offset
        if (iflev == 0)
            throw CGERROR_ELSE_WO_IF;
        [self CheckCMDIF_Fin:1];
        [self CheckCMDIF_Set:1];
        return;
    }
    [self CheckCMDIF_Set:0]; // normal if
}
-(void)CheckInternalListenerCMD:(int)opt {
    //        命令生成時チェック(命令+命令セット)
    //
    int i, t, o;
    if (ttype != TK_OBJ)
        return;
    i = [lb Search:cg_str];
    if (i < 0)
        return;
    t = [lb GetType:i];
    o = [lb GetOpt:i];
    if (t != TYPE_PROGCMD)
        return;
    if (o == 0x001) { // gosub
        [self PutCS:t value:o&0xffff exflg:0];
    }
    [self GetTokenCG:GETTOKEN_DEFAULT];
}
-(void)CheckInternalProgCMD:(int)opt orgcs:(int)orgcs {
    //        内蔵プログラム命令生成時チェック
    //
    int i;
    switch (opt) {
        case 0x03: // repeat break
        case 0x06: // repeat continue
            if (replev == 0) {
                if (opt == 0x03)
                    throw CGERROR_BREAK_WO_REPEAT;
                throw CGERROR_CONT_WO_REPEAT;
            }
            i = repend[replev];
            if (i == -1) {
                i = [self PutOT:-1];
                repend[replev] = i;
            }
            [self PutCS:TK_LABEL value:i exflg:0];
            break;
        case 0x04: // repeat start
        case 0x0b: // (foreach)
            if (replev == CG_REPLEV_MAX)
                throw CGERROR_REPEAT_OVERFLOW;
            replev++;
            i = repend[replev];
            if (i == -1) {
                i = [self PutOT:-1];
                repend[replev] = i;
            }
            [self PutCS:TK_LABEL value:i exflg:0];
            if (opt == 0x0b) {
                [self PutCS:TYPE_PROGCMD value:0x0c exflg:EXFLG_1];
                [self PutCS:TK_LABEL value:i exflg:0];
            }
            break;
        case 0x05: // repeat end
            if (replev == 0)
                throw CGERROR_LOOP_WO_REPEAT;
            i = repend[replev];
            if (i != -1) {
                [self SetOT:i value:[self GetCS]];
                repend[replev] = -1;
            }
            replev--;
            break;
        case 0x11: // stop
            i = [self PutOT:orgcs];
            [self PutCS:TYPE_PROGCMD value:0 exflg:EXFLG_1];
            [self PutCS:TYPE_LABEL value:i exflg:0];
            break;
        case 0x19: // on
            [self GetTokenCG:GETTOKEN_DEFAULT];
            [self CalcCG:0]; // 式の評価
            if (ttype != TK_OBJ)
                throw CGERROR_SYNTAX;
            i = [lb Search:cg_str];
            if (i < 0)
                throw CGERROR_SYNTAX;
            [self PutCS:[lb GetType:i] value:[lb GetOpt:i] exflg:EXFLG_2];
            break;
        case 0x08: // await
            //    await命令の出現をカウントする(HEDINFO_NOMMTIMER自動設定のため)
            if (hed_autoopt_timer >= 0)
                hed_autoopt_timer++;
            break;
        case 0x09: // dim
        case 0x0a: // sdim
        case 0x0d: // dimtype
        case 0x0e: // dup
        case 0x0f: // dupptr
            [self GetTokenCG:GETTOKEN_DEFAULT];
            if (ttype == TK_OBJ) {
                i = [self SetVarsFixed:cg_str fixedvalue:cg_defvarfix];
                //    変数の初期化フラグをセットする
                [lb SetInitFlag:i val:LAB_INIT_DONE];
                // Mesf( "#initflag set [%s]", cg_str );
            }
            cg_ptr = cg_ptr_bak;
            break;
    }
}
-(void)GenerateCodeCMD:(int)id {
    //        HSP3Codeを展開する(コマンド)
    //        (idはlabel ID)
    //
    int t, opt;
    int orgcs;
    t = [lb GetType:id];
    opt = [lb GetOpt:id];;
    orgcs = [self GetCS];
    [self PutCSSymbol:id exflag:EXFLG_1];
    if (t == TYPE_PROGCMD)
        [self CheckInternalProgCMD:opt orgcs:orgcs];
    if (t == TYPE_CMPCMD)
        [self CheckInternalIF:opt];
    [self GetTokenCG:GETTOKEN_DEFAULT];
    if (opt & 0x10000)
        [self CheckInternalListenerCMD:opt];
    [self GenerateCodePRM];
    cg_lastcmd = CG_LASTCMD_CMD;
    cg_lasttype = t;
    cg_lastval = opt;
}
-(void)GenerateCodeLET:(int)id {
    //        HSP3Codeを展開する(代入)
    //        (idはlabel ID)
    //
    int op;
    int t;
    int mcall;
    t = [lb GetType:id];
    if ((t == TYPE_XLABEL) || (t == TYPE_LABEL))
        throw CGERROR_LABELNAME;
    //
    mcall = 0;
    [self GetTokenCG:GETTOKEN_DEFAULT];
    if ((ttype == TK_NONE) && (val == 0x65)) { // ->が続いているか?
        [self PutCS:TYPE_PROGCMD value:0x1a exflg:EXFLG_1]; // 'mcall'コマンドに置き換える
        [self PutCS:t value:[lb GetOpt:id] exflg:0];        // 変数パラメーター
        [self GetTokenCG:GETTOKEN_DEFAULT];
        [self GenerateCodeMethod]; // パラメーター展開
        return;
    }
    [self PutCS:t value:[lb GetOpt:id] exflg:EXFLG_1]; // 通常の変数代入
    [self GenerateCodePRMF4:t];              // 構造体/配列のチェック
    if (ttype != TK_NONE) {
        throw CGERROR_SYNTAX;
    }
    op = val;
    // PutCS( TK_NONE, op, 0 );
    texflag = 0;
    [self CalcCG_regmark:op];
    cg_lastcmd = CG_LASTCMD_LET;
    cg_lastval = op;
    [self GetTokenCG:GETTOKEN_DEFAULT];
    switch (op) {
        case '+': // '++'
        case '-': // '--'
            if (ttype >= TK_SEPARATE)
                return;
            if (ttype == TK_NONE) {
                if (val == op) {
                    [self GetTokenCG:GETTOKEN_DEFAULT];
                    if (ttype >= TK_SEPARATE)
                        return;
                    throw CGERROR_SYNTAX;
                }
            }
            break;
        case '=': // 変数=prm
            [self GenerateCodePRM];
            return;
        default:
            break;
    }
    if ((ttype == TK_NONE) && (val == '=')) {
        [self GetTokenCG:GETTOKEN_DEFAULT];
    }
    [self GenerateCodePRM];
}
-(void)GenerateCodePP_regcmd {
    //        HSP3Codeを展開する(regcmd)
    //
    char cmd[1024];
    char cmd2[1024];
    cg_pptype = cg_typecnt;
    cmd[0] = 0;
    [self GetTokenCG:GETTOKEN_DEFAULT];
    switch (ttype) {
        case TK_STRING:
            strcpy(cmd, cg_str);
            [self GetTokenCG:GETTOKEN_DEFAULT];
            if (ttype != TK_NONE)
                throw CGERROR_PP_NO_REGCMD;
            if (val != ',')
                throw CGERROR_PP_NO_REGCMD;
            [self GetTokenCG:GETTOKEN_DEFAULT];
            if (ttype != TK_STRING)
                throw CGERROR_PP_NO_REGCMD;
            strcpy(cmd2, cg_str);
            [self GetTokenCG:GETTOKEN_DEFAULT];
            if (ttype == TK_NONE) {
                if (val != ',')
                    throw CGERROR_PP_NO_REGCMD;
                [self GetTokenCG:GETTOKEN_DEFAULT];
                if (ttype != TK_NUM)
                    throw CGERROR_PP_NO_REGCMD;
                cg_varhpi += val;
            }
            [self PutHPI:HPIDAT_FLAG_TYPEFUNC option:0 libname:cmd2 funcname:cmd];
            cg_typecnt++;
            break;
        case TK_NUM:
            [self PutHPI:HPIDAT_FLAG_SELFFUNC option:0 libname:(char*)"" funcname:(char*)""];
            cg_pptype = val;
            break;
        default:
            throw CGERROR_PP_NO_REGCMD;
    }
    // Mesf( "#regcmd [%d][%s]",cg_pptype, cmd );
}
-(void)GenerateCodePP_cmd {
    //        HSP3Codeを展開する(cmd)
    //
    int id;
    char cmd[1024];
    if (cg_pptype < 0)
        throw CGERROR_PP_NO_REGCMD;
    [self GetTokenCG:GETTOKEN_DEFAULT];
    if (ttype != TK_OBJ)
        throw CGERROR_PP_NO_REGCMD;
    strcpy(cmd, cg_str);
    // if ( ttype != TK_NONE ) throw CGERROR_PP_NO_REGCMD;
    // if ( val != ',' ) throw CGERROR_PP_NO_REGCMD;
    // GetTokenCG( GETTOKEN_DEFAULT );
    [self GetTokenCG:GETTOKEN_DEFAULT];
    if (ttype != TK_NUM)
        throw CGERROR_PP_NO_REGCMD;
    id = val;
    [lb Regist2:cmd type:cg_pptype opt:id filename:cg_orgfile line:cg_orgline];
    // Mesf( "#%x:%d [%s]",cg_pptype, id, cmd );
}
-(void)GenerateCodePP_uselib {
    //        HSP3Codeを展開する(uselib)
    //
    [self GetTokenCG:GETTOKEN_DEFAULT];
    cg_libname[0] = 0;
    if (ttype == TK_STRING) {
        strncpy(cg_libname, cg_str, 1023);
    } else if (ttype < TK_VOID) {
        throw CGERROR_PP_NAMEREQUIRED;
    }
    cg_libmode = CG_LIBMODE_DLLNEW;
}
-(void)GenerateCodePP_usecom {
    //        HSP3Codeを展開する(usecom)
    //
    int i, prmid;
    char libname[1024];
    char clsname[128];
    char iidname[128];
    [self GetTokenCG:GETTOKEN_DEFAULT];
    if (ttype != TK_OBJ) {
        throw CGERROR_PP_NAMEREQUIRED;
    }
    strncpy(libname, cg_str, 1023);
    i = [lb Search:libname];
    if (i >= 0) {
        [self CG_MesLabelDefinition:i];
        throw CGERROR_PP_ALREADY_USE_PARAM;
    }
    [self GetTokenCG:GETTOKEN_DEFAULT];
    if (ttype != TK_STRING)
        throw CGERROR_PP_BAD_IMPORT_IID;
    strncpy(iidname, cg_str, 127);
    *clsname = 0;
    [self GetTokenCG:GETTOKEN_DEFAULT];
    if (ttype < TK_EOL) {
        if (ttype != TK_STRING)
            throw CGERROR_PP_BAD_IMPORT_IID;
        strncpy(clsname, cg_str, 127);
    }
    cg_libindex = [self PutLIB:LIBDAT_FLAG_COMOBJ name:iidname];
    if (cg_libindex < 0)
        throw CGERROR_PP_BAD_IMPORT_IID;
    [self SetLIBIID:cg_libindex clsid:clsname];
    cg_libmode = CG_LIBMODE_COM;
    [self PutStructStart];
    prmid = [self PutStructEndDll:(char*)"*" libindex:cg_libindex subid:STRUCTPRM_SUBID_COMOBJ otindex:-1];
    [lb Regist2:libname type:TYPE_DLLCTRL opt:prmid | TYPE_OFFSET_COMOBJ filename:cg_orgfile line:cg_orgline];
    // Mesf( "#usecom %s [%s][%s]",libname,clsname,iidname );
}
-(void)GenerateCodePP_func:(int)deftype {
    //        HSP3Codeを展開する(func)
    //
    int warn, i, t, subid, otflag;
    int ref;
    char fbase[1024];
    char fname[1024];
    [self GetTokenCG:GETTOKEN_DEFAULT];
    if (ttype != TK_OBJ)
        throw CGERROR_PP_NAMEREQUIRED;
    strncpy(fbase, cg_str, 1023);
    ref = -1;
    if ((hed_cmpmode & CMPMODE_OPTCODE) &&
        (tmp_lb != NULL)) { // プリプロセス情報から最適化を行なう
        i = [tmp_lb Search:fbase];
        if (i >= 0) {
            ref = [tmp_lb GetReference:i];
            // Mesf( "#func %s [use%d]", fbase, ref );
        }
    }
    warn = 0;
    otflag = deftype;
    [self GetTokenCG:GETTOKEN_DEFAULT];
    if (ttype == TK_OBJ) {
        if (strcmp(cg_str, "onexit") == 0) {
            otflag |= STRUCTDAT_OT_CLEANUP;
            [self GetTokenCG:GETTOKEN_DEFAULT];
        }
    }
    if (ref == 0 && (otflag & STRUCTDAT_OT_CLEANUP) == 0) {
        if (hed_cmpmode & CMPMODE_OPTINFO) {
            NSLog(@"#未使用の外部DLL関数の登録を削除しました %s\n", fbase);
        }
        return;
    }
    if (cg_libmode == CG_LIBMODE_DLLNEW) { // 初回はDLL名を登録する
        cg_libindex = [self PutLIB:LIBDAT_FLAG_DLL name:cg_libname];
        cg_libmode = CG_LIBMODE_DLL;
    }
    if (cg_libmode != CG_LIBMODE_DLL)
        throw CGERROR_PP_NO_USELIB;
    switch (ttype) {
        case TK_OBJ:
            sprintf(fname, "_%s@16", cg_str);
            warn = 1;
            break;
        case TK_STRING:
            strncpy(fname, cg_str, 1023);
            break;
        case TK_NONE:
            if (val == '*')
                break;
            throw CGERROR_PP_BAD_IMPORT_NAME;
        default:
            throw CGERROR_PP_BAD_IMPORT_NAME;
    }
    [self GetTokenCG:GETTOKEN_DEFAULT];
    [self PutStructStart];
    if (ttype == TK_NUM) {
        int p1, p2, p3, p4, c1;
        warn = 1;
        p1 = p2 = p3 = p4 = MPTYPE_INUM;
        c1 = val & 3;
        if (c1 == 1)
            p1 = MPTYPE_PVARPTR;
        if (c1 == 2)
            p1 = MPTYPE_PBMSCR;
        if (c1 == 3) {
            if ((val & 0x80) == 0)
                throw CGERROR_PP_INCOMPATIBLE_IMPORT;
            p1 = MPTYPE_PPVAL;
        }
        if (val & 4)
            p2 = MPTYPE_LOCALSTRING;
        if (val & 0x10)
            p4 = MPTYPE_PTR_REFSTR;
        if (val & 0x20)
            p4 = MPTYPE_PTR_DPMINFO;
        if (val & 0x100)
            otflag |= STRUCTDAT_OT_CLEANUP;
        if (val & 0x200) {
            if ((val & 3) != 2)
                throw CGERROR_PP_INCOMPATIBLE_IMPORT;
            p1 = MPTYPE_PTR_EXINFO;
            p2 = p3 = MPTYPE_NULLPTR;
            if ((val & 0x30) == 0)
                p4 = MPTYPE_NULLPTR;
        }
        //        if ( val & 0x220 ) throw CGERROR_PP_INCOMPATIBLE_IMPORT;
        //        Mesf("#oldfunc %d,%d,%d,%d",p1,p2,p3,p4);
        [self PutStructParam:p1 extype:STRUCTPRM_SUBID_STID];
        [self PutStructParam:p2 extype:STRUCTPRM_SUBID_STID];
        [self PutStructParam:p3 extype:STRUCTPRM_SUBID_STID];
        [self PutStructParam:p4 extype:STRUCTPRM_SUBID_STID];
    } else {
        while (1) {
            if (ttype >= TK_EOL)
                break;
            if (ttype != TK_OBJ)
                throw CGERROR_PP_WRONG_PARAM_NAME;
            t = [self GetParameterFuncTypeCG:cg_str];
            if (t == MPTYPE_NONE)
                throw CGERROR_PP_WRONG_PARAM_NAME;
            [self PutStructParam:t extype:STRUCTPRM_SUBID_STID];
            [self GetTokenCG:GETTOKEN_DEFAULT];
            if (ttype >= TK_EOL)
                break;
            if (ttype != TK_NONE)
                throw CGERROR_PP_WRONG_PARAM_NAME;
            if (val != ',')
                throw CGERROR_PP_WRONG_PARAM_NAME;
            [self GetTokenCG:GETTOKEN_DEFAULT];
        }
    }
    i = [lb Search:fbase];
    if (i >= 0) {
        [self CG_MesLabelDefinition:i];
        throw CGERROR_PP_ALREADY_USE_FUNCNAME;
    }
    subid = STRUCTPRM_SUBID_DLL;
    if (warn) {
        subid = STRUCTPRM_SUBID_OLDDLL;
        // Mesf( "Warning:Old func expression [%s]", fbase );
    }
    i = [self PutStructEndDll:fname libindex:cg_libindex subid:subid otindex:otflag];
    [lb Regist2:fbase type:TYPE_DLLFUNC opt:i filename:cg_orgfile line:cg_orgline];
    // Mesf( "#func [%s][%s][%d]",fbase, fname, i );
}
-(void)GenerateCodePP_comfunc {
    //        HSP3Codeを展開する(comfunc)
    //
    int i, t, subid, imp_index;
    char fbase[1024];
    if (cg_libmode != CG_LIBMODE_COM)
        throw CGERROR_PP_NO_USECOM;
    [self GetTokenCG:GETTOKEN_DEFAULT];
    if (ttype != TK_OBJ)
        throw CGERROR_PP_NAMEREQUIRED;
    strncpy(fbase, cg_str, 1023);
    [self GetTokenCG:GETTOKEN_DEFAULT];
    if (ttype != TK_NUM) {
        throw CGERROR_PP_BAD_IMPORT_INDEX;
    }
    imp_index = val;
    [self GetTokenCG:GETTOKEN_DEFAULT];
    [self PutStructStart];
    [self PutStructParam:MPTYPE_IOBJECTVAR extype:STRUCTPRM_SUBID_STID];
    while (1) {
        if (ttype >= TK_EOL)
            break;
        if (ttype != TK_OBJ)
            throw CGERROR_PP_WRONG_PARAM_NAME;
        t = [self GetParameterFuncTypeCG:cg_str];
        if (t == MPTYPE_NONE)
            throw CGERROR_PP_WRONG_PARAM_NAME;
        [self PutStructParam:t extype:STRUCTPRM_SUBID_STID];
        [self GetTokenCG:GETTOKEN_DEFAULT];
        if (ttype >= TK_EOL)
            break;
        if (ttype != TK_NONE)
            throw CGERROR_PP_WRONG_PARAM_NAME;
        if (val != ',')
            throw CGERROR_PP_WRONG_PARAM_NAME;
        [self GetTokenCG:GETTOKEN_DEFAULT];
    }
    i = [lb Search:fbase];
    if (i >= 0) {
        [self CG_MesLabelDefinition:i];
        throw CGERROR_PP_ALREADY_USE_TAGNAME;
    }
    subid = STRUCTPRM_SUBID_COMOBJ;
    i = [self PutStructEndDll:(char*)"*" libindex:cg_libindex subid:subid otindex:imp_index];
    [lb Regist2:fbase type:TYPE_DLLCTRL opt:i | TYPE_OFFSET_COMOBJ filename:cg_orgfile line:cg_orgline];
    // Mesf( "#comfunc [%s][%d][%d]",fbase, imp_index, i );
}
-(int)GetParameterTypeCG:(char*)name {
    //        パラメーター名を認識する(deffunc)
    //
    if (!strcmp(cg_str, "int"))
        return MPTYPE_INUM;
    if (!strcmp(cg_str, "var"))
        return MPTYPE_SINGLEVAR;
    if (!strcmp(cg_str, "val")) {
        NSLog(@"警告:古いdeffunc表記があります 行%d.[%s]\n", cg_orgline,name);
        return MPTYPE_SINGLEVAR;
    }
    if (!strcmp(cg_str, "str"))
        return MPTYPE_LOCALSTRING;
    if (!strcmp(cg_str, "double"))
        return MPTYPE_DNUM;
    if (!strcmp(cg_str, "label"))
        return MPTYPE_LABEL;
    if (!strcmp(cg_str, "local"))
        return MPTYPE_LOCALVAR;
    if (!strcmp(cg_str, "array"))
        return MPTYPE_ARRAYVAR;
    if (!strcmp(cg_str, "modvar"))
        return MPTYPE_MODULEVAR;
    if (!strcmp(cg_str, "modinit"))
        return MPTYPE_IMODULEVAR;
    if (!strcmp(cg_str, "modterm"))
        return MPTYPE_TMODULEVAR;
    return MPTYPE_NONE;
}
-(int)GetParameterStructTypeCG:(char*)name {
    //        パラメーター名を認識する(struct)
    //
    if (!strcmp(cg_str, "int"))
        return MPTYPE_INUM;
    if (!strcmp(cg_str, "var"))
        return MPTYPE_LOCALVAR;
    if (!strcmp(cg_str, "str"))
        return MPTYPE_LOCALSTRING;
    if (!strcmp(cg_str, "double"))
        return MPTYPE_DNUM;
    if (!strcmp(cg_str, "label"))
        return MPTYPE_LABEL;
    if (!strcmp(cg_str, "float"))
        return MPTYPE_FLOAT;
    return MPTYPE_NONE;
}
-(int)GetParameterFuncTypeCG:(char*)name {
    //        パラメーター名を認識する(func)
    //
    if (!strcmp(cg_str, "int"))
        return MPTYPE_INUM;
    if (!strcmp(cg_str, "var"))
        return MPTYPE_PVARPTR;
    if (!strcmp(cg_str, "str"))
        return MPTYPE_LOCALSTRING;
    if (!strcmp(cg_str, "double"))
        return MPTYPE_DNUM;
    //    if ( !strcmp( cg_str,"label" ) ) return MPTYPE_LABEL;
    if (!strcmp(cg_str, "float"))
        return MPTYPE_FLOAT;
    if (!strcmp(cg_str, "pval"))
        return MPTYPE_PPVAL;
    if (!strcmp(cg_str, "bmscr"))
        return MPTYPE_PBMSCR;
    if (!strcmp(cg_str, "comobj"))
        return MPTYPE_IOBJECTVAR;
    if (!strcmp(cg_str, "wstr"))
        return MPTYPE_LOCALWSTR;
    if (!strcmp(cg_str, "sptr"))
        return MPTYPE_FLEXSPTR;
    if (!strcmp(cg_str, "wptr"))
        return MPTYPE_FLEXWPTR;
    if (!strcmp(cg_str, "prefstr"))
        return MPTYPE_PTR_REFSTR;
    if (!strcmp(cg_str, "pexinfo"))
        return MPTYPE_PTR_EXINFO;
    if (!strcmp(cg_str, "nullptr"))
        return MPTYPE_NULLPTR;
    //    if ( !strcmp( cg_str,"hwnd" ) ) return MPTYPE_PTR_HWND;
    //    if ( !strcmp( cg_str,"hdc" ) ) return MPTYPE_PTR_HDC;
    //    if ( !strcmp( cg_str,"hinst" ) ) return MPTYPE_PTR_HINST;
    return MPTYPE_NONE;
}
-(int)GetParameterResTypeCG:(char*)name {
    //        戻り値のパラメーター名を認識する(defcfunc)
    //
    if (!strcmp(cg_str, "int"))
        return MPTYPE_INUM;
    if (!strcmp(cg_str, "str"))
        return MPTYPE_STRING;
    if (!strcmp(cg_str, "double"))
        return MPTYPE_DNUM;
    if (!strcmp(cg_str, "label"))
        return MPTYPE_LABEL;
    if (!strcmp(cg_str, "float"))
        return MPTYPE_FLOAT;
    return MPTYPE_NONE;
}
#define GET_FI_SIZE() ((int)([fi_buf GetSize] / sizeof(STRUCTDAT)))
#define GET_FI(n) (((STRUCTDAT*)[fi_buf GetBuffer] + (n)))
#define STRUCTDAT_INDEX_DUMMY ((short)0x8000)
-(void)GenerateCodePP_deffunc0:(int)is_command {
    //        HSP3Codeを展開する(deffunc / defcfunc)
    //
    int i, t, ot, prmid, subid;
    int index;
    int funcflag;
    int regflag;
    int prep;
    char funcname[1024];
    STRUCTPRM* prm;
    STRUCTDAT* st;
    prep = 0;
    [self GetTokenCG:GETTOKEN_DEFAULT];
    if (ttype != TK_OBJ)
        throw CGERROR_PP_NAMEREQUIRED;
    if (is_command && !strcmp(cg_str, "prep")) { // プロトタイプ宣言
        prep = 1;
        [self GetTokenCG:GETTOKEN_DEFAULT];
        if (ttype != TK_OBJ)
            throw CGERROR_PP_NAMEREQUIRED;
    }
    strncpy(funcname, cg_str, 1023);
    for (i = 0; i < cg_localcur; i++) {
        [lb SetFlag:cg_localstruct[i] val:-1]; // 以前に指定されたパラメーター名を削除する
    }
    cg_localcur = 0;
    funcflag = 0;
    regflag = 1;
    index = -1;
    int label_id = [lb Search:funcname];
    if (label_id >= 0) {
        if ([lb GetType:label_id] != TYPE_MODCMD) {
            [self CG_MesLabelDefinition:label_id];
            throw CGERROR_PP_ALREADY_USE_FUNC;
        }
        index = [lb GetOpt:label_id];
        if (index >= 0 && GET_FI(index)->index != STRUCTDAT_INDEX_DUMMY) {
            [self CG_MesLabelDefinition:label_id];
            throw CGERROR_PP_ALREADY_USE_FUNC;
        }
    }
    [self PutStructStart];
    while (1) {
        [self GetTokenCG:GETTOKEN_DEFAULT];
        if (ttype >= TK_EOL)
            break;
        if (ttype != TK_OBJ)
            throw CGERROR_PP_WRONG_PARAM_NAME;
        if (is_command && !strcmp(cg_str, "onexit")) {
            funcflag |= STRUCTDAT_FUNCFLAG_CLEANUP;
            break;
        }
        t = [self GetParameterTypeCG:cg_str];
        if (t == MPTYPE_NONE)
            throw CGERROR_PP_WRONG_PARAM_NAME;
        if ((t == MPTYPE_MODULEVAR) || (t == MPTYPE_IMODULEVAR) ||
            (t == MPTYPE_TMODULEVAR)) {
            //    モジュール名指定
            [self GetTokenCG:GETTOKEN_DEFAULT];
            if (ttype != TK_OBJ)
                throw CGERROR_PP_WRONG_PARAM_NAME;
            i = [lb Search:cg_str];
            if (i < 0)
                throw CGERROR_PP_BAD_STRUCT;
            if ([lb GetType:i] != TYPE_STRUCT)
                throw CGERROR_PP_BAD_STRUCT;
            prm = (STRUCTPRM*)[mi_buf GetBuffer];
            subid = prm[[lb GetOpt:i]].subid;
            // Mesf( "%s:struct%d",cg_str,subid );
            if (t == MPTYPE_IMODULEVAR) {
                if (prm[[lb GetOpt:i]].offset != -1)
                    throw CGERROR_PP_MODINIT_USED;
                prm[[lb GetOpt:i]].offset = GET_FI_SIZE();
                regflag = 0;
            }
            if (t == MPTYPE_TMODULEVAR) {
                st = (STRUCTDAT*)[fi_buf GetBuffer];
                if (st[subid].otindex != 0)
                    throw CGERROR_PP_MODTERM_USED;
                st[subid].otindex = GET_FI_SIZE();
                regflag = 0;
            }
            prmid = [self PutStructParam:t extype:subid];
            [self GetTokenCG:GETTOKEN_DEFAULT];
        } else {
            prmid = [self PutStructParam:t extype:STRUCTPRM_SUBID_STACK];
            // Mesf( "%d:type%d",prmid,t );
            [self GetTokenCG:GETTOKEN_DEFAULT];
            if (ttype == TK_OBJ) {
                //    引数のエイリアス
                i = [lb Search:cg_str];
                if (i >= 0) {
                    [self CG_MesLabelDefinition:i];
                    throw CGERROR_PP_ALREADY_USE_PARAM;
                }
                i = [lb Regist2:cg_str type:TYPE_STRUCT opt:prmid filename:cg_orgfile line:cg_orgline];
                cg_localstruct[cg_localcur++] = i;
                [self GetTokenCG:GETTOKEN_DEFAULT];
            }
        }
        if (ttype >= TK_EOL)
            break;
        if (ttype != TK_NONE)
            throw CGERROR_PP_WRONG_PARAM_NAME;
        if (val != ',')
            throw CGERROR_PP_WRONG_PARAM_NAME;
    }
    ot = [self PutOT:[self GetCS]];
    if (index == -1) {
        index = GET_FI_SIZE();
        [fi_buf PreparePtr:sizeof(STRUCTDAT)];
        if (regflag) {
            [lb Regist2:funcname type:TYPE_MODCMD opt:index filename:cg_orgfile line:cg_orgline];
        }
    }
    if (label_id >= 0) {
        [lb SetOpt:label_id val:index];
    }
    int dat_index = is_command ? STRUCTDAT_INDEX_FUNC : STRUCTDAT_INDEX_CFUNC;
    [self PutStructEnd_int:index name:funcname libindex:dat_index otindex:ot funcflag:funcflag];
}
-(void)GenerateCodePP_deffunc {
    [self GenerateCodePP_deffunc0:1];
}
-(void)GenerateCodePP_defcfunc {
    [self GenerateCodePP_deffunc0:0];
}
-(void)GenerateCodePP_module {
    //        HSP3Codeを展開する(module)
    //
    int i, ref;
    char* modname;
    [self GetTokenCG:GETTOKEN_DEFAULT];
    if (ttype != TK_OBJ)
        throw CGERROR_PP_NAMEREQUIRED;
    modname = cg_str;
    if ((hed_cmpmode & CMPMODE_OPTCODE) &&
        (tmp_lb != NULL)) { // プリプロセス情報から最適化を行なう
        i = [tmp_lb Search:modname];
        if (i >= 0) {
            ref = [tmp_lb GetReference:i];
            if (ref == 0) {
                cg_flag = CG_FLAG_DISABLE;
                if (hed_cmpmode & CMPMODE_OPTINFO) {
                    NSLog(@"#未使用のモジュールを削除しました %s\n", modname);
                }
                return;
            }
        }
    }
}
-(void)GenerateCodePP_struct {
    //        HSP3Codeを展開する(struct)
    //
    int i, t, prmid;
    char funcname[1024];
    [self GetTokenCG:GETTOKEN_DEFAULT];
    if (ttype != TK_OBJ)
        throw CGERROR_PP_NAMEREQUIRED;
    strncpy(funcname, cg_str, 1023);
    i = [lb Search:funcname];
    if (i >= 0) {
        [self CG_MesLabelDefinition:i];
        throw CGERROR_PP_ALREADY_USE_PARAM;
    }
    [self PutStructStart];
    prmid = [self PutStructParamTag]; // modinit用のTAG
    [lb Regist2:funcname type:TYPE_STRUCT opt:prmid filename:cg_orgfile line:cg_orgline];
    // Mesf( "%d:%s",prmid, funcname );
    while (1) {
        [self GetTokenCG:GETTOKEN_DEFAULT];
        if (ttype >= TK_EOL)
            break;
        if (ttype != TK_OBJ)
            throw CGERROR_PP_WRONG_PARAM_NAME;
        t = [self GetParameterStructTypeCG:cg_str];
        if (t == MPTYPE_NONE)
            throw CGERROR_PP_WRONG_PARAM_NAME;
        prmid = [self PutStructParam:t extype:STRUCTPRM_SUBID_STID];
        // Mesf( "%d:type%d",prmid,t );
        [self GetTokenCG:GETTOKEN_DEFAULT];
        if (ttype != TK_OBJ)
            throw CGERROR_PP_WRONG_PARAM_NAME;
        i = [lb Search:cg_str];
        if (i >= 0) {
            [self CG_MesLabelDefinition:i];
            throw CGERROR_PP_ALREADY_USE_PARAM;
        }
        [lb Regist2:cg_str type:TYPE_STRUCT opt:prmid filename:cg_orgfile line:cg_orgline];
        [self GetTokenCG:GETTOKEN_DEFAULT];
        if (ttype >= TK_EOL)
            break;
        if (ttype != TK_NONE)
            throw CGERROR_PP_WRONG_PARAM_NAME;
        if (val != ',')
            throw CGERROR_PP_WRONG_PARAM_NAME;
    }
    [self PutStructEnd:funcname libindex:STRUCTDAT_INDEX_STRUCT otindex:0 funcflag:0];
}
-(void)GenerateCodePP_defvars:(int)fixedvalue {
    //        HSP3Codeを展開する(defint,defdouble,defnone)
    //
    int id;
    int prms;
    prms = 0;
    while (1) {
        [self GetTokenCG:GETTOKEN_DEFAULT];
        if (ttype >= TK_EOL)
            break;
        if (ttype != TK_OBJ)
            throw CGERROR_WRONG_VARIABLE;
        id = [self SetVarsFixed:cg_str fixedvalue:fixedvalue];
        if ([lb GetType:id] != TYPE_VAR) {
            throw CGERROR_WRONG_VARIABLE;
        }
        prms++;
        // Mesf( "name:%s(%d) fixed:%d", cg_str, id, fixedvalue );
        [self GetTokenCG:GETTOKEN_DEFAULT];
        if (ttype >= TK_EOL)
            break;
        if (ttype != TK_NONE)
            throw CGERROR_PP_WRONG_PARAM_NAME;
        if (val != ',')
            throw CGERROR_PP_WRONG_PARAM_NAME;
    }
    if (prms == 0) {
        cg_defvarfix = fixedvalue;
    }
}
-(int)SetVarsFixed:(char*)varname fixedvalue:(int)fixedvalue {
    //        変数の固定型を設定する
    //
    int id;
    id = [lb Search:varname];
    if (id < 0) {
        id = [lb Regist2:varname type:TYPE_VAR opt:cg_valcnt filename:cg_orgfile line:cg_orgline];
        cg_valcnt++;
    }
    [lb SetForceType:id val:fixedvalue];
    return id;
}
-(void)GenerateCodePP:(char*)buf {
    //        HSP3Codeを展開する(プリプロセスコマンド)
    //
    int i;
    [self GetTokenCG:GETTOKEN_DEFAULT]; // 最初の'#'を読み飛ばし
    [self GetTokenCG:GETTOKEN_DEFAULT];
    if (ttype == TK_NONE) { // プリプロセッサから渡される行情報
        if (val != '#')
            throw CGERROR_UNKNOWN;
        [self GetTokenCG:GETTOKEN_DEFAULT];
        if (ttype != TK_NUM)
            throw CGERROR_UNKNOWN;
        cg_orgline = val;
        [self GetTokenCG:GETTOKEN_DEFAULT];
        if (ttype == TK_STRING) {
            strcpy(cg_orgfile, cg_str);
            if (cg_debug) {
                i = [self PutDSBuf:cg_str];
                [self PutDI_int:254 a:i subid:cg_orgline]; // ファイル名をデバッグ情報として登録
            }
        } else {
            if (cg_debug) {
                [self PutDI_int:254 a:0 subid:cg_orgline]; // ラインだけをデバッグ情報として登録
            }
        }
        // Mesf( "#%d [%s]",cg_orgline, cg_str );
        return;
    }
    if (ttype != TK_OBJ) { // その他はエラー
        throw CGERROR_PP_SYNTAX;
    }
    if (!strcmp(cg_str, "global")) {
        cg_flag = CG_FLAG_ENABLE;
        return;
    }
    if (cg_flag != CG_FLAG_ENABLE) { // 最適化による出力抑制
        return;
    }
    if (!strcmp(cg_str, "regcmd")) {
        [self GenerateCodePP_regcmd];
        return;
    }
    if (!strcmp(cg_str, "cmd")) {
        [self GenerateCodePP_cmd];
        return;
    }
    if (!strcmp(cg_str, "uselib")) {
        [self GenerateCodePP_uselib];
        return;
    }
    if (!strcmp(cg_str, "func")) {
        [self GenerateCodePP_func:STRUCTDAT_OT_STATEMENT | STRUCTDAT_OT_FUNCTION];
        return;
    }
    if (!strcmp(cg_str, "cfunc")) {
        [self GenerateCodePP_func:STRUCTDAT_OT_FUNCTION];
        return;
    }
    if (!strcmp(cg_str, "deffunc")) {
        [self GenerateCodePP_deffunc];
        return;
    }
    if (!strcmp(cg_str, "defcfunc")) {
        [self GenerateCodePP_defcfunc];
        return;
    }
    if (!strcmp(cg_str, "module")) {
        [self GenerateCodePP_module];
        return;
    }
    if (!strcmp(cg_str, "struct")) {
        [self GenerateCodePP_struct];
        return;
    }
    if (!strcmp(cg_str, "usecom")) {
        [self GenerateCodePP_usecom];
        return;
    }
    if (!strcmp(cg_str, "comfunc")) {
        [self GenerateCodePP_comfunc];
        return;
    }
    if (!strcmp(cg_str, "defint")) {
        [self GenerateCodePP_defvars:LAB_TYPEFIX_INT];
        return;
    }
    if (!strcmp(cg_str, "defdouble")) {
        [self GenerateCodePP_defvars:LAB_TYPEFIX_DOUBLE];
        return;
    }
    if (!strcmp(cg_str, "defnone")) {
        [self GenerateCodePP_defvars:LAB_TYPEFIX_NONE];
        return;
    }
}
-(int)GenerateCodeSub {
    //        文字列(１行単位)からHSP3Codeを展開する
    //        (エラー発生時は例外が発生します)
    //
    int i, t;
    //    char tmp[512];
    cg_errline = line;
    cg_lastcmd = CG_LASTCMD_NONE;
    if (cg_ptr == NULL)
        return TK_EOF;
    if (*cg_ptr == '#') {
        [self GenerateCodePP:cg_ptr];
        return TK_EOL;
    }
    if (cg_flag != CG_FLAG_ENABLE)
        return TK_EOL; // 最適化による出力抑制
    //    while(1) {
    //        if ( cg_ptr!=NULL ) Mes( cg_ptr );
    [self GetTokenCG:GETTOKEN_LABEL];
    if (ttype >= TK_SEPARATE)
        return ttype;
    switch (ttype) {
            //        case TK_NONE:
            //            sprintf( tmp,"#cod:%d",val );
            //            Mes( tmp );
            //            break;
            //        case TK_NUM:
            //            sprintf( tmp,"#num:%d",val );
            //            Mes( tmp );
            //            break;
            //        case TK_STRING:
            //            sprintf( tmp,"#str:%s",cg_str );
            //            Mes( tmp );
            //            break;
            //        case TK_DNUM:
            //            sprintf( tmp,"#dbl:%f",val_d );
            //            Mes( tmp );
            //            break;
        case TK_OBJ:
            cg_lastcmd = CG_LASTCMD_LET;
            i = [lb Search:cg_str];
            if (i < 0) {
                // Mesf( "[%s][%d]",cg_str, cg_valcnt );
                i = [self SetVarsFixed:cg_str fixedvalue:cg_defvarfix];
                [lb SetInitFlag:i val:LAB_INIT_DONE]; //    変数の初期化フラグをセットする
                [self GenerateCodeLET:i];
            } else {
                t = [lb GetType:i];
                switch (t) {
                    case TYPE_VAR:
                    case TYPE_STRUCT:
                        [self GenerateCodeLET:i];
                        break;
                    case TYPE_LABEL:
                    case TYPE_XLABEL:
                        throw CGERROR_LABELNAME;
                        break;
                    default:
                        [self GenerateCodeCMD:i];
                        break;
                }
            }
            //            sprintf( tmp,"#obj:%s (%d)",cg_str,i );
            //            Mes( tmp );
            break;
        case TK_LABEL:
            // Mesf( "#lab:%s",cg_str );
            if (*cg_str == '@') {
                sprintf(cg_str, "@l%d", cg_locallabel); // local label
                cg_locallabel++;
            }
            i = [lb Search:cg_str];
            if (i >= 0) {
                LABOBJ* lab;
                lab = [lb GetLabel:i];
                if (lab->type != TYPE_XLABEL)
                    throw CGERROR_LABELEXIST;
                [self SetOT:[lb GetOpt:i] value:[self GetCS]];
                lab->type = TYPE_LABEL;
            } else {
                i = [lb Regist:cg_str type:TYPE_LABEL opt:[ot_buf GetSize] / sizeof(int)];
                [self PutOT:[self GetCS]];
            }
            [self GetTokenCG:GETTOKEN_DEFAULT];
            break;
        default:
            throw CGERROR_SYNTAX;
    }
    //    }
    if (ttype < TK_SEPARATE)
        throw CGERROR_SYNTAX;
    return ttype;
}
-(char*)GetLineCG {
    //        vs_wpから１行を取得する
    //
    char* pp;
    unsigned char* p;
    unsigned char a1;
    int skip;
    p = cg_wp;
    if (p == NULL)
        return NULL;
    pp = (char*)p;
    a1 = *p;
    if (a1 == 0) {
        cg_wp = NULL;
        return NULL;
    }
    while (1) {
        a1 = *p;
        // 全角文字チェック＊
        // if (a1>=129) {
        //    if ((a1<=159)||(a1>=224)) {
        //        NSLog(@"C:%s",cg_wp);
        //        p++;
        //        if ( *p >= 32 ) { p++; continue; }
        //    }
        //}
        skip = [self SkipMultiByte:a1]; // 全角文字チェック
        if (skip) {
            p += skip + 1;
            continue;
        }
        //        uint8 c = a1;
        //        //if (c >= 0 && c < 128) { return 1; }
        //        if (c >= 128 && c < 192) { p++; if ( *p >= 32 ) { p++; continue; }
        //        }
        //        if (c >= 192 && c < 224) { p++; if ( *p >= 32 ) { p++; continue; }
        //        }
        //        if (c >= 224 && c < 240) { p++;p++; if ( *p >= 32 ) { p++;
        //        continue; } }
        //        if (c >= 240 && c < 248) { p++;p++;p++; if ( *p >= 32 ) { p++;
        //        continue; } }
        //        if (c >= 248 && c < 252) { p++;p++;p++;p++; if ( *p >= 32 ) { p++;
        //        continue; } }
        //        if (c >= 252 && c < 254) { p++;p++;p++;p++;p++; if ( *p >= 32 ) {
        //        p++; continue; } }
        //        if (c >= 254 && c <= 255) { p++;p++;p++;p++;p++;  if ( *p >= 32 )
        //        { p++; continue; } }
        //
        if (a1 == 0)
            break;
        if (a1 == 13) {
            *p = 0;
            p++;
            line++;
            if (*p == 10) {
                *p = 0;
                p++;
            }
            break;
        }
        if (a1 == 10) {
            *p = 0;
            p++;
            line++;
            break;
        }
        p++;
    }
    cg_wp = p;
    return pp;
}
-(int)GenerateCodeBlock {
    //        プロック単位でHSP3Codeを展開する
    //        (エラー発生時は例外が発生します)
    //
    int res, id, ff;
    char a1;
    char* p;
    res = [self GenerateCodeSub];
    if (res == TK_EOF)
        return res;
    if (res == TK_EOL) {
        cg_ptr = [self GetLineCG];
        if (iflev) {
            if (ifscope[iflev - 1] == CG_IFCHECK_LINE)
                [self CheckCMDIF_Fin:0]; // 'if' jump support
        }
        if (cg_debug)
            [self PutDI];
        cg_orgline++;
    }
    if (res == TK_SEPARATE) {
        a1 = cg_str[0];
        if (a1 == '{') { // when '{'
            if (iflev == 0)
                throw CGERROR_BLOCKEXP;
            if (ifscope[iflev - 1] == CG_IFCHECK_SCOPE)
                throw CGERROR_BLOCKEXP;
            ifscope[iflev - 1] = CG_IFCHECK_SCOPE;
        } else if (a1 == '}') { // when '}'
            if (iflev == 0)
                throw CGERROR_BLOCKEXP;
            if (ifscope[iflev - 1] != CG_IFCHECK_SCOPE)
                throw CGERROR_BLOCKEXP;
            ff = 0;
            p = [self GetTokenCG:cg_ptr option:GETTOKEN_DEFAULT];
            if (ttype == TK_EOL) { // 次行のコマンドがelseかどうか調べる
                if (cg_wp != NULL) {
                    p = [self GetSymbolCG:(char*)cg_wp];
                    if (p != NULL) {
                        id = [lb Search:p];
                        if (id >= 0) {
                            if (([lb GetType:id] == TYPE_CMPCMD) && ([lb GetOpt:id] == 1)) {
                                ff = 1;
                            }
                        }
                    }
                }
            } else if (ttype == TK_OBJ) { // 次のコマンドがelseかどうか調べる
                id = [lb Search:cg_str];
                if (id >= 0) {
                    if (([lb GetType:id] == TYPE_CMPCMD) && ([lb GetOpt:id] == 1)) {
                        // ifscope[iflev-1] = CG_IFCHECK_LINE;                    // line
                        // scope
                        // on
                        ff = 1;
                    }
                }
            }
            if (ff == 0)
                [self CheckCMDIF_Fin:0];
        }
    }
    return res;
}
-(void)RegisterFuncLabels {
    //        プリプロセス時のラベル情報から関数を定義
    //
    if (tmp_lb == NULL)
        return;
    int len = [tmp_lb GetCount];
    for (int i = 0; i < len; i++) {
        if ([tmp_lb GetType:i] == LAB_TYPE_PPMODFUNC && [tmp_lb GetFlag:i] >= 0) {
            char* name = [tmp_lb GetName:i];
            if ([lb Search:name] >= 0) {
                throw CGERROR_PP_ALREADY_USE_FUNC;
            }
            LABOBJ* lab = [tmp_lb GetLabel:i];
            int id = [lb Regist2:name type:TYPE_MODCMD opt:-1 filename:lab->def_file line:lab->def_line];
            [lb SetData2:id str:(char*)&i size:sizeof i];
        }
    }
}
-(int)GenerateCodeMain:(CMemBuf*)buf {
    //        ソースをHSP3Codeに展開する
    //        (ソースのバッファを書き換えるので注意)
    //
    int a;
    line = 0;
    cg_flag = CG_FLAG_ENABLE;
    cg_valcnt = 0;
    cg_typecnt = HSP3_TYPE_USER;
    cg_pptype = -1;
    cg_iflev = 0;
    cg_wp = (unsigned char*)[buf GetBuffer];
    cg_ptr = [self GetLineCG];
    cg_orgfile[0] = 0;
    cg_libindex = -1;
    cg_libmode = CG_LIBMODE_NONE;
    cg_lastcs = 0;
    cg_localcur = 0;
    cg_locallabel = 0;
    cg_varhpi = 0;
    cg_defvarfix = LAB_TYPEFIX_NONE;
    iflev = 0;
    replev = 0;
    for (a = 0; a < CG_REPLEV_MAX; a++) {
        repend[a] = -1;
    }
    try {
        [self RegisterFuncLabels];
        while (1) {
            if ([self GenerateCodeBlock] == TK_EOF)
                break;
        }
        cg_errline = -1; // エラーの行番号は該当なし
        //        コンパイル後の後始末チェック
        if (replev != 0)
            throw CGERROR_LOOP_NOTFOUND;
        //        ラベル未処理チェック
        int errend;
        errend = 0;
        for (a = 0; a < [lb GetCount]; a++) {
            if ([lb GetType:a] == TYPE_XLABEL) {
                NSLog(@"#ラベルの定義が存在しません [%s]\n",[lb GetName:a]);
                errend++;
            }
        }
        //        関数未処理チェック
        for (a = 0; a < GET_FI_SIZE(); a++) {
            if (GET_FI(a)->index == STRUCTDAT_INDEX_DUMMY) {
                NSLog(@"#関数が定義されていません [%s]\n",[lb GetName:GET_FI(a)->otindex]);
                errend++;
            }
        }
        //      ブレース対応チェック
        if (iflev > 0) {
            NSLog(@"#波括弧が閉じられていません\n");
            errend++;
        }
        if (errend)
            throw CGERROR_FATAL;
    } catch (CGERROR code) {
        return (int)code;
    }
    return 0;
}
-(void)PutCS:(int)type value:(int)value exflg:(int)exflg {
    //        Register command code
    //        (HSP ver3.3以降用)
    //            type=0-0xfff ( -1 to debug line info )
    //            val=16,32bit length supported
    //
    int a;
    unsigned int v;
    v = (unsigned int)value;
    a = (type & CSTYPE) | exflg;
    if (v < 0x10000) { // when 16bit encode
        [cs_buf Put_short:(short)(a)];
        [cs_buf Put_short:(short)(v)];
    } else { // when 32bit encode
        [cs_buf Put_short:(short)(0x8000 | a)];
        [cs_buf Put_int:(int)value];
    }
}
-(void)PutCS_double:(int)type value:(double)value exflg:(int)exflg {
    //        Register command code (double)
    //
    [self PutCS:type value:[self PutDS_double:value] exflg:exflg];
}
-(void)PutCSSymbol:(int)label_id exflag:(int)exflag {
    //        まだ定義されていない関数の呼び出しがあったら仮登録する
    //
    int type = [lb GetType:label_id];
    int value = [lb GetOpt:label_id];
    if (type == TYPE_MODCMD && value == -1) {
        int id = *(int*)[lb GetData2:label_id];
        [tmp_lb AddReference:id];
        STRUCTDAT st = { STRUCTDAT_INDEX_DUMMY };
        st.otindex = label_id;
        value = GET_FI_SIZE();
        [fi_buf PutData:&st sz:sizeof(STRUCTDAT)];
        [lb SetOpt:label_id val:value];
    }
    if (exflag & EXFLG_1 && type != TYPE_VAR && type != TYPE_STRUCT) {
        value &= 0xffff;
    }
    [self PutCS:type value:value exflg:exflag];
}
-(int)GetCS {
    //        Get current CS index
    //
    return ([cs_buf GetSize]) >> 1;
}
-(int)PutDS_double:(double)value {
    //        Register doubles to data segment
    //
    int i = [ds_buf GetSize];
#ifdef HSP_DS_POOL
    if (CG_optCode()) {
        int i_cache =
        double_literal_table.insert(std::make_pair(value, i)).first->second;
        if (i != i_cache) {
            if ([self CG_optInfo]) {
                Mesf("#実数リテラルプール %f", value);
            }
            return i_cache;
        }
    }
#endif
    [ds_buf Put_double:value];
    return i;
}
-(int)PutDS:(char*)str {
    //        Register strings to data segment (script string)
    //
    return [self PutDSStr:str converts_to_utf8:cg_utf8out != 0];
}
-(int)PutDSBuf:(char*)str {
    //        Register strings to data segment (direct)
    //
    return [self PutDSStr:str converts_to_utf8:false];
}
-(int)PutDSStr:(char*)str converts_to_utf8:(bool)converts_to_utf8 {
    //        Register strings to data segment (caching)
    char* p;
    // output as UTF8 format
    if (converts_to_utf8) {
        p = [self ExecSCNV:str opt:SCNV_OPT_SJISUTF8];
    } else {
        p = str;
    }
    int i = [ds_buf GetSize];
#ifdef HSP_DS_POOL
    if (CG_optCode()) {
        int i_cache = string_literal_table.insert(std::make_pair(std::string(p), i))
        .first->second;
        if (i != i_cache) {
            if ([self CG_optInfo]) {
                char* literal_str = to_hsp_string_literal(str);
                Mesf("#文字列プール %s", literal_str);
                free(literal_str);
            }
            return i_cache;
        }
    }
#endif
    if (converts_to_utf8) {
        [ds_buf PutData:p sz:(int)(strlen(p) + 1)];
    } else {
        [ds_buf PutStr:p];
        [ds_buf Put_char:(char)0];
    }
    return i;
}
-(int)PutDSBuf_size:(char*)str size:(int)size {
    //        Register strings to data segment (direct)
    //
    int i;
    i = [ds_buf GetSize];
    [ds_buf PutData:str sz:size];
    return i;
}
-(int)PutOT:(int)value {
    //        Register object temp
    //
    int i;
    i = [ot_buf GetSize] / sizeof(int);
    [ot_buf Put_int:value];
    return i;
}
-(void)SetOT:(int)id value:(int)value {
    //        Modify object temp
    //
    int* p;
    p = (int*)([ot_buf GetBuffer]);
    p[id] = value;
}
-(void)PutDI {
    //        Debug code register
    //
    //        mem_di formats :
    //            0-250           = offset to old mcs
    //            252,x(16)       = big offset
    //            253,x(24),y(16) = used val (x=mds ptr.)
    //            254,x(24),y(16) = new filename accepted (x=mds ptr.)
    //            255             = end of debug data
    //
    int ofs;
    ofs = (int)([self GetCS] - cg_lastcs);
    if (ofs <= 250) {
        [di_buf Put_uchar:(unsigned char)ofs];
    } else {
        [di_buf Put_uchar:(unsigned char)252];
        [di_buf Put_uchar:(unsigned char)(ofs)];
        [di_buf Put_uchar:(unsigned char)(ofs >> 8)];
    }
    cg_lastcs = [self GetCS];
}
-(void)PutDI:(int)dbg_code a:(int)a subid:(int)subid {
    //        special Debug code register
    //            in : -1=end of code
    //                254=(a=file ds ptr./subid=line num.)
    //
    if (dbg_code < 0) {
        [di_buf Put_uchar:(unsigned char)255];
        [di_buf Put_uchar:(unsigned char)255];
    } else {
        [di_buf Put_uchar:(unsigned char)dbg_code];
        [di_buf Put_uchar:(unsigned char)(a)];
        [di_buf Put_uchar:(unsigned char)(a >> 8)];
        [di_buf Put_uchar:(unsigned char)(a >> 16)];
        [di_buf Put_uchar:(unsigned char)(subid)];
        [di_buf Put_uchar:(unsigned char)(subid >> 8)];
    }
}
-(void)PutDIVars {
    //        Debug info register for vals
    //
    int a, i, id;
    LABOBJ* lab;
    char vtmpname[256];
    char* p;
    id = 0;
    strcpy(vtmpname, "I_");
    for (a = 0; a < [lb GetNumEntry]; a++) {
        lab = [lb GetLabel:a];
        if (lab->type == TK_OBJ) {
            switch (lab->typefix) {
                case LAB_TYPEFIX_INT:
                    vtmpname[0] = 'I';
                    p = vtmpname;
                    strcpy(p + 2, lab->name);
                    break;
                case LAB_TYPEFIX_DOUBLE:
                    vtmpname[0] = 'D';
                    p = vtmpname;
                    strcpy(p + 2, lab->name);
                    break;
                case LAB_TYPEFIX_NONE:
                default:
                    p = lab->name;
                    break;
            }
            i = [self PutDSBuf:p];
            [self PutDI:253 a:i subid:lab->opt];
        }
    }
}
// ラベル名の情報を出力する
-(void)PutDILabels {
    int num = [ot_buf GetSize] / sizeof(int);
    int* table = new int[num];
    for (int i = 0; i < num; i++)
        table[i] = -1;
    for (int i = 0; i < [lb GetNumEntry]; i++) {
        if ([lb GetType:i] == TYPE_LABEL) {
            int id = [lb GetOpt:i];
            table[id] = i;
        }
    }
    [di_buf Put_uchar:(unsigned char)255];
    for (int i = 0; i < num; i++) {
        if (table[i] == -1)
            continue;
        char* name = [lb GetName:table[i]];
        int dsPos = [self PutDSBuf:name];
        [self PutDI:251 a:dsPos subid:i];
    }
    delete[] table;
}
// 引数名の情報を出力する
-(void)PutDIParams {
    [di_buf Put_uchar:(unsigned char)255];
    for (int i = 0; i < [lb GetNumEntry]; i++) {
        if ([lb GetType:i] == TYPE_STRUCT) {
            int id = [lb GetOpt:i];
            if (id < 0)
                continue;
            char* name = [lb GetName:i];
            int dsPos = [self PutDSBuf:name];
            [self PutDI:251 a:dsPos subid:id];
        }
    }
}
-(char*)GetDS:(int)ptr {
    int i;
    char* p;
    i = [ds_buf GetSize];
    if (ptr >= i)
        return NULL;
    p = [ds_buf GetBuffer];
    p += ptr;
    return p;
}
/*
 rev 54
 mingw : warning : i は未初期化で使用されうる
 に対処。
 */
-(int)PutLIB:(int)flag name:(char*)name {
    int a, i = -1, p;
    LIBDAT lib;
    LIBDAT* l;
    p = [li_buf GetSize] / sizeof(LIBDAT);
    l = (LIBDAT*)[li_buf GetBuffer];
    if (flag == LIBDAT_FLAG_DLL) {
        if (*name != 0) {
            for (a = 0; a < p; a++) {
                if (l->flag == flag) {
                    if (strcmp([self GetDS:l->nameidx], name) == 0) {
                        return a;
                    }
                }
                l++;
            }
            i = [self PutDSBuf:name];
        } else {
            i = -1;
        }
    }
//    if (flag == LIBDAT_FLAG_COMOBJ) {
//        COM_GUID guid;
//        if (ConvertIID(&guid, name))
//            return -1;
//        i = PutDSBuf((char*)&guid, sizeof(COM_GUID));
//    }
    lib.flag = flag;
    lib.nameidx = i;
    lib.hlib = NULL;
    lib.clsid = -1;
    [li_buf PutData:&lib sz:sizeof(LIBDAT)];
    // Mesf( "LIB#%d:%s",flag,name );
    return p;
}
-(void)SetLIBIID:(int)id clsid:(char*)clsid {
    LIBDAT* l;
    l = (LIBDAT*)[li_buf GetBuffer];
    l += id;
    if (*clsid == 0) {
        l->clsid = -1;
    } else {
        l->clsid = [self PutDSBuf:clsid];
    }
}
-(int)PutStructParam:(short)mptype extype:(int)extype {
    int size;
    int i;
    STRUCTPRM prm;
    i = [mi_buf GetSize] / sizeof(STRUCTPRM);
    prm.mptype = mptype;
    if (extype == STRUCTPRM_SUBID_STID) {
        prm.subid = (short)GET_FI_SIZE();
    } else {
        prm.subid = extype;
    }
    prm.offset = cg_stsize;
    size = 0;
    switch (mptype) {
        case MPTYPE_INUM:
        case MPTYPE_STRUCT:
            size = sizeof(int);
            break;
        case MPTYPE_LOCALVAR:
            size = sizeof(PVal);
            break;
        case MPTYPE_DNUM:
            size = sizeof(double);
            break;
        case MPTYPE_FLOAT:
            size = sizeof(float);
            break;
        case MPTYPE_LOCALSTRING:
        case MPTYPE_STRING:
        case MPTYPE_LABEL:
        case MPTYPE_PPVAL:
        case MPTYPE_PBMSCR:
        case MPTYPE_PVARPTR:
        case MPTYPE_IOBJECTVAR:
        case MPTYPE_LOCALWSTR:
        case MPTYPE_FLEXSPTR:
        case MPTYPE_FLEXWPTR:
        case MPTYPE_PTR_REFSTR:
        case MPTYPE_PTR_EXINFO:
        case MPTYPE_PTR_DPMINFO:
        case MPTYPE_NULLPTR:
            size = sizeof(char*);
            break;
        case MPTYPE_SINGLEVAR:
        case MPTYPE_ARRAYVAR:
            size = sizeof(MPVarData);
            break;
        case MPTYPE_MODULEVAR:
        case MPTYPE_IMODULEVAR:
        case MPTYPE_TMODULEVAR:
            size = sizeof(MPModVarData);
            break;
        default:
            return i;
    }
    cg_stsize += size;
    cg_stnum++;
    [mi_buf PutData:&prm sz:sizeof(STRUCTPRM)];
    return i;
}
-(int)PutStructParamTag {
    int i;
    STRUCTPRM prm;
    i = [mi_buf GetSize] / sizeof(STRUCTPRM);
    prm.mptype = MPTYPE_STRUCTTAG;
    prm.subid = (short)GET_FI_SIZE();
    prm.offset = -1;
    cg_stnum++;
    [mi_buf PutData:&prm sz:sizeof(STRUCTPRM)];
    return i;
}
-(void)PutStructStart {
    cg_stnum = 0;
    cg_stsize = 0;
    cg_stptr = [mi_buf GetSize] / sizeof(STRUCTPRM);
}
-(int)PutStructEnd_int:(int)i name:(char*)name libindex:(int)libindex opindex:(int)otindex funcflag:(int)funcflag {
    //        STRUCTDATを登録する(モジュール用)
    //
    STRUCTDAT st;
    st.index = libindex;
    st.nameidx = [self PutDSBuf:name];
    st.subid = i;
    st.prmindex = cg_stptr;
    st.prmmax = cg_stnum;
    st.funcflag = funcflag;
    st.size = cg_stsize;
    if (otindex < 0) {
        st.otindex = 0;
        st.subid = otindex;
    } else {
        st.otindex = otindex;
    }
    *GET_FI(i) = st;
    // Mesf( "#%d : %s(LIB%d) prm%d size%d ot%d", i, name, libindex, cg_stnum,
    // cg_stsize, otindex );
    return i;
}
-(int)PutStructEnd:(char*)name libindex:(int)libindex opindex:(int)otindex funcflag:(int)funcflag {
    int i = GET_FI_SIZE();
    [fi_buf PreparePtr:sizeof(STRUCTDAT)];
    return [self PutStructEnd_int:i name:name libindex:libindex opindex:otindex funcflag:funcflag];
}
-(int)PutStructEndDll:(char*)name libindex:(int)libindex subid:(int)subid otindex:(int)otindex {
    //        STRUCTDATを登録する(DLL用)
    //
    int i;
    STRUCTDAT st;
    i = GET_FI_SIZE();
    st.index = libindex;
    if (name[0] == '*') {
        st.nameidx = -1;
    } else {
        st.nameidx = [self PutDSBuf:name];
    }
    st.subid = subid;
    st.prmindex = cg_stptr;
    st.prmmax = cg_stnum;
    st.proc = NULL;
    st.size = cg_stsize;
    st.otindex = otindex;
    [fi_buf PutData:&st sz:sizeof(STRUCTDAT)];
    // Mesf( "#%d : %s(LIB%d) prm%d size%d ot%d", i, name, libindex, cg_stnum,
    // cg_stsize, otindex );
    return i;
}
-(void)PutHPI:(short)flag option:(short)option libname:(char*)libname funcname:(char*)funcname {
    HPIDAT hpi;
    hpi.flag = flag;
    hpi.option = option;
    hpi.libname = [self PutDSBuf:libname];
    hpi.funcname = [self PutDSBuf:funcname];
    hpi.libptr = NULL;
    [hpi_buf PutData:&hpi sz:sizeof(HPIDAT)];
}
-(int)GenerateCode:(char*)fname oname:(char*)oname mode:(int)mode {
    CMemBuf* srcbuf;
    if ([srcbuf PutFile:fname] < 0) {
        // Mes( (char *)"#No file." );
        @autoreleasepool {
            NSLog(@"#No file.\n");
        }
        return -1;
    }
    return [self GenerateCode_membuf:srcbuf oname:oname mode:mode];
}
-(int)GenerateCode_membuf:(CMemBuf*)srcbuf oname:(char*)oname mode:(int)mode {
    //        ファイルをHSP3Codeに展開する
    //        mode            Debug code (0=off 1=on)
    //
    int i, orgcs, res;
    int adjsize;
    CMemBuf* optbuf; // オプション文字列用バッファ
    CMemBuf* bakbuf; // プリプロセッサソース保存用バッファ
    cs_buf = [[CMemBuf alloc] init];
    ds_buf = [[CMemBuf alloc] init];
    ot_buf = [[CMemBuf alloc] init];
    di_buf = [[CMemBuf alloc] init];
    li_buf = [[CMemBuf alloc] init];
    fi_buf = [[CMemBuf alloc] init];
    mi_buf = [[CMemBuf alloc] init];
    fi2_buf = [[CMemBuf alloc] init];
    hpi_buf = [[CMemBuf alloc] init];
    [bakbuf PutStr:[srcbuf GetBuffer]]; // プリプロセッサソースを保存する
    cg_debug = mode & COMP_MODE_DEBUG;
    cg_utf8out = mode & COMP_MODE_UTF8;
    if (pp_utf8)
        cg_utf8out = 0; // ソースコードがUTF-8の場合は変換は必要ない
    cg_putvars = hed_cmpmode & CMPMODE_PUTVARS;
    res = [self GenerateCodeMain:srcbuf];
    if (res) {
        //        エラー終了
        char tmp[512];
        CStrNote* note;
        CMemBuf* srctmp;
        // Mesf( (char *)"%s(%d) : error %d : %s (%d行目)", cg_orgfile, cg_orgline,
        // res, cg_geterror((CGERROR)res), cg_orgline );
        char* err[] = {
            (char*)"",                                               // 0
            (char*)"解釈できない文字コードです",                     // 1
            (char*)"文法が間違っています",                           // 2
            (char*)"小数の記述が間違っています",                     // 3
            (char*)"パラメーター式の記述が無効です",                 // 4
            (char*)"カッコが閉じられていません",                     // 5
            (char*)"配列の書式が間違っています",                     // 6
            (char*)"ラベル名はすでに使われています",                 // 7
            (char*)"ラベル名は指定できません",                       // 8
            (char*)"repeatのネストが深すぎます",                     // 9
            (char*)"repeatループ外でbreakが使用されました",          // 10
            (char*)"repeatループ外でcontinueが使用されました",       // 11
            (char*)"repeatループでないのにloopが使用されました",     // 12
            (char*)"repeatループが閉じられていません",               // 13
            (char*)"elseの前にifが見当たりません",                   // 14
            (char*)"{が閉じられていません",                          // 15
            (char*)"if命令以外で{〜}が使われています",               // 16
            (char*)"else命令の位置が不正です",                       // 17
            (char*)"if命令の階層が深すぎます",                       // 18
            (char*)"致命的なエラーです",                             // 19
            (char*)"プリプロセッサ命令が解釈できません",             // 20
            (char*)"コマンド登録中のエラーです",                     // 21
            (char*)"プリプロセッサは文字列のみ受け付けます",         // 22
            (char*)"パラメーター引数の指定が間違っています",         // 23
            (char*)"ライブラリ名が指定されていません",               // 24
            (char*)"命令として定義できない名前です",                 // 25
            (char*)"パラメーター引数名は使用されています",           // 26
            (char*)"モジュール変数の参照元が無効です",               // 27
            (char*)"モジュール変数の指定が無効です",                 // 28
            (char*)"外部関数のインポート名が無効です",               // 29
            (char*)"拡張命令の名前はすでに使用されています",         // 30
            (char*)"互換性のない拡張命令タイプを使用しています",     // 31
            (char*)"コンストラクタは既に登録されています",           // 32
            (char*)"デストラクタは既に登録されています",             // 33
            (char*)"複数行文字列の終端ではありません",               // 34
            (char*)"タグ名はすでに使用されています",                 // 35
            (char*)"インターフェース名が指定されていません",         // 36
            (char*)"インポートするインデックスが指定されていません", // 37
            (char*)"インポートするIID名が指定されていません",        // 38
            (char*)"未初期化変数を使用しようとしました",             // 39
            (char*)"指定できない変数名です",                         // 40
            (char*)"*"
        };
            NSString* nsstr_error_message =
            [NSString stringWithCString:err[(int)res]
                               encoding:NSUTF8StringEncoding];
            // NSLog(@"%@",nsstr_error_message);
            NSLog(@"%s(%d) : error %d : %@ (%d行目)\n",
                                cg_orgfile, cg_orgline, res,
                  nsstr_error_message, cg_orgline);
            if (cg_errline > 0) {
                [note Select:[bakbuf GetBuffer]];
                [note GetLine:tmp line:cg_errline - 1 max:510];
                NSLog(@"--> %s\n", tmp);
                NSLog(@"error %d : %@ (%d行目)\n--> %s\n", res,
                      nsstr_error_message, cg_orgline, tmp);
            } else {
                NSLog(@"error %d : %@ (%d行目)\n",
                                     res, nsstr_error_message,
                      cg_orgline);
            }
            //global.isError = YES;
    } else {
        //        正常終了
        CMemBuf* axbuf;
        HSPHED* hsphed;
        int sz_hed, sz_opt, cs_size, ds_size, ot_size, di_size;
        int li_size, fi_size, mi_size, fi2_size, hpi_size;
        orgcs = [self GetCS];
        [self PutCS:TYPE_PROGCMD value:0x11 exflg:EXFLG_1]; // 終了コードを最後に入れる
        i = [self PutOT:orgcs];
        [self PutCS:TYPE_PROGCMD value:0 exflg:EXFLG_1];
        [self PutCS:TYPE_LABEL value:i exflg:0];
        if (cg_debug) {
            [self PutDI];
        }
        if ((cg_debug) || (cg_putvars)) {
            [self PutDIVars];
        }
        if (cg_debug) {
            [self PutDILabels];
            [self PutDIParams];
        }
        [self PutDI:-1 a:0 subid:0]; // デバッグ情報終端
        sz_hed = sizeof(HSPHED);
        memset(&hsphed, 0, sz_hed);
        hsphed->bootoption = 0;
        hsphed->runtime = 0;
        if (hed_option & HEDINFO_RUNTIME) {
            [optbuf PutStr:hed_runtime];
        }
        sz_opt = [optbuf GetSize];
        if (sz_opt) {
            while (1) {
                adjsize = (sz_opt + 15) & 0xfff0;
                if (adjsize == sz_opt)
                    break;
                [optbuf Put_char:(char)0];
                sz_opt = [optbuf GetSize];
            }
            hsphed->bootoption |= HSPHED_BOOTOPT_RUNTIME;
            hsphed->runtime = sz_hed;
            sz_hed += sz_opt;
        }
        //        デバッグウインドゥ表示
        if (mode & COMP_MODE_DEBUGWIN)
            hsphed->bootoption |= HSPHED_BOOTOPT_DEBUGWIN;
        //        起動オプションの設定
        if (hed_autoopt_timer >= 0) {
            // awaitが使用されていない場合はマルチメディアタイマーを無効にする(自動設定)
            if (hed_autoopt_timer == 0)
                hsphed->bootoption |= HSPHED_BOOTOPT_NOMMTIMER;
        } else {
            // 設定されたオプションに従ってマルチメディアタイマーを無効にする
            if (hed_option & HEDINFO_NOMMTIMER)
                hsphed->bootoption |= HSPHED_BOOTOPT_NOMMTIMER;
        }
        if (hed_option & HEDINFO_NOGDIP)
            hsphed->bootoption |= HSPHED_BOOTOPT_NOGDIP; // GDI+による描画を無効にする
        if (hed_option & HEDINFO_FLOAT32)
            hsphed->bootoption |=
            HSPHED_BOOTOPT_FLOAT32; // 実数を32bit floatとして処理する
        if (hed_option & HEDINFO_ORGRND)
            hsphed->bootoption |= HSPHED_BOOTOPT_ORGRND; // 標準の乱数発生を使用する
        cs_size = [cs_buf GetSize];
        ds_size = [ds_buf GetSize];
        ot_size = [ot_buf GetSize];
        di_size = [di_buf GetSize];
        li_size = [li_buf GetSize];
        fi_size = [fi_buf GetSize];
        mi_size = [mi_buf GetSize];
        fi2_size = [fi2_buf GetSize];
        hpi_size = [hpi_buf GetSize];
        hsphed->h1 = 'H';
        hsphed->h2 = 'S';
        hsphed->h3 = 'P';
        hsphed->h4 = '3';
        hsphed->version = 0x0350;    // version3.5
        hsphed->max_val = cg_valcnt; // max count of VAL Object
        hsphed->allsize = sz_hed + cs_size + ds_size + ot_size + di_size;
        hsphed->allsize += li_size + fi_size + mi_size + fi2_size + hpi_size;
        hsphed->pt_cs = sz_hed;                    // ptr to Code Segment
        hsphed->max_cs = cs_size;                  // size of CS
        hsphed->pt_ds = sz_hed + cs_size;          // ptr to Data Segment
        hsphed->max_ds = ds_size;                  // size of DS
        hsphed->pt_ot = hsphed->pt_ds + ds_size;    // ptr to Object Temp
        hsphed->max_ot = ot_size;                  // size of OT
        hsphed->pt_dinfo = hsphed->pt_ot + ot_size; // ptr to Debug Info
        hsphed->max_dinfo = di_size;               // size of DI
        hsphed->pt_linfo = hsphed->pt_dinfo + di_size; // ptr to Debug Info
        hsphed->max_linfo = li_size;                  // size of LINFO
        hsphed->pt_finfo = hsphed->pt_linfo + li_size; // ptr to Debug Info
        hsphed->max_finfo = fi_size;                  // size of FINFO
        hsphed->pt_minfo = hsphed->pt_finfo + fi_size; // ptr to Debug Info
        hsphed->max_minfo = mi_size;                  // size of MINFO
        hsphed->pt_finfo2 = hsphed->pt_minfo + mi_size; // ptr to Debug Info
        hsphed->max_finfo2 = fi2_size;                 // size of FINFO2
        hsphed->pt_hpidat = hsphed->pt_finfo2 + fi2_size; // ptr to Debug Info
        hsphed->max_hpi = hpi_size;                      // size of HPIDAT
        hsphed->max_varhpi = cg_varhpi;                  // Num of Vartype Plugins
        hsphed->pt_sr = sizeof(HSPHED); // ptr to Option Segment
        hsphed->max_sr = sz_opt;        // size of Option Segment
        hsphed->opt1 = 0;
        hsphed->opt2 = 0;
        [axbuf PutData:&hsphed sz:sizeof(HSPHED)];
        if (sz_opt)
            [axbuf PutData:[optbuf GetBuffer] sz:sz_opt];
        if (cs_size)
            [axbuf PutData:[cs_buf GetBuffer] sz:cs_size];
        if (ds_size)
            [axbuf PutData:[ds_buf GetBuffer] sz:ds_size];
        if (ot_size)
            [axbuf PutData:[ot_buf GetBuffer] sz:ot_size];
        if (di_size)
            [axbuf PutData:[di_buf GetBuffer] sz:di_size];
        if (li_size)
            [axbuf PutData:[li_buf GetBuffer] sz:li_size];
        if (fi_size)
            [axbuf PutData:[fi_buf GetBuffer] sz:fi_size];
        if (mi_size)
            [axbuf PutData:[mi_buf GetBuffer] sz:mi_size];
        if (fi2_size)
            [axbuf PutData:[fi2_buf GetBuffer] sz:fi2_size];
        if (hpi_size)
            [axbuf PutData:[hpi_buf GetBuffer] sz:hpi_size];
        res = [axbuf SaveFile:oname];
        if (res < 0) {
            NSLog(@"#出力ファイルを書き込めません\n");
        } else {
            int n_mod, n_hpi;
            n_hpi = [hpi_buf GetSize] / sizeof(HPIDAT);
            n_mod = [fi_buf GetSize] / sizeof(STRUCTDAT);
            @autoreleasepool {
                NSLog(@"# Code size (%d) String data size (%d) param size (%d)\n",
                                    cs_size, ds_size, [mi_buf GetSize]);
                NSLog(@"# Vars (%d) Labels (%d) Modules (%d) "
                                    @"Libs (%d) Plugins (%d)\n",
                                    cg_valcnt, ot_size >> 2, n_mod, li_size,
                                    n_hpi);
               NSLog(@"# No error detected. (total %d bytes)\n",
                                    hsphed->allsize);
               NSLog(@"\n");
            }
            // Mesf( (char *)"#Code size (%d) String data size (%d) param size
            // (%d)",cs_size,ds_size,mi_buf->GetSize() );
            // Mesf( (char *)"#Vars (%d) Labels (%d) Modules (%d) Libs (%d) Plugins
            // (%d)",cg_valcnt,ot_size>>2,n_mod,li_size,n_hpi );
            // Mesf( (char *)"#No error detected. (total %d bytes)",hsphed.allsize );
            res = 0;
        }
    }
    hpi_buf = NULL;
    fi2_buf = NULL;
    mi_buf = NULL;
    fi_buf = NULL;
    li_buf = NULL;
    di_buf = NULL;
    ot_buf = NULL;
    ds_buf = NULL;
    cs_buf = NULL;
    return res;
}
-(void)CG_MesLabelDefinition:(int)label_id {
    if (!cg_debug)
        return;
    LABOBJ* const labobj = [lb GetLabel:label_id];
    if (labobj->def_file) {
            NSLog(@"#識別子「%s」の定義位置: line %d in [%s]\n",
                                [lb GetName:label_id], labobj->def_line, labobj->def_file);
    }
}
@end
