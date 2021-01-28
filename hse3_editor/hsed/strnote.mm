//@
/*----------------------------------------------------------------*/
//		notepad object related routines
//		(Linux対応のためCR/LFだけでなくLFにも対応した版)
/*----------------------------------------------------------------*/
#import <string.h>
#import "strnote.h"
@implementation CStrNote : NSObject
- (instancetype)init {
    self = [super init];
    if (self) {
        base = NULL;
        nulltmp[0] = 0;
    }
    return self;
}
- (void)dealloc {
}
-(void)Select:(char*)str {
    base = str;
}
-(int)GetSize {
    return (int)strlen( base );
}
-(int)nnget:(char*)nbase line:(int)line {
    int a,i;
    char a1;
    a=0;
    lastcr=0;
    nn=nbase;
    if (line<0) {
        i=(int)strlen(nbase);
        if (i==0) return 0;
        nn+=i;a1=*(nn-1);
        if ((a1==10)||(a1==13)) lastcr++;
        return 0;
    }
    if (line) {
        while(1) {
            a1=*nn;if (a1==0) return 1;
            nn++;
            if (a1==10) {
                a++;if (a==line) break;
            }
            if (a1==13) {
                if (*nn==10) nn++;
                a++;if (a==line) break;
            }
        }
    }
    lastcr++;
    return 0;
}
-(int)GetLine:(char*)nres line:(int)line {
    //		Get specified line from note
    //				result:0=ok/1=no line
    //
    char a1;
    char *pp;
    pp=nres;
    if ( [self nnget:base line:line] )
        return 1;
    if (*nn==0)
        return 1;
    while(1) {
        a1=*nn++;
        if ((a1==0)||(a1==13))
            break;
        if (a1==10)
            break;
        *pp++=a1;
    }
    *pp=0;
    return 0;
}
-(int)GetLine:(char*)nres line:(int)line max:(int)max {
    //		Get specified line from note
    //				result:0=ok/1=no line
    //
    char a1;
    char *pp;
    int cnt;
    pp=nres;
    cnt = 0;
    if ( [self nnget:base line:line] )
        return 1;
    if (*nn==0)
        return 1;
    while(1) {
        if ( cnt>=max )
            break;
        a1=*nn++;
        if ((a1==0)||(a1==13))
            break;
        if (a1==10)
            break;
        *pp++=a1;
        cnt++;
    }
    *pp=0;
    return 0;
}
-(char*)GetLineDirect:(int)line {
    //		Get specified line from note
    //
    char a1;
    if ( [self nnget:base line:line] )
        nn = nulltmp;
    lastnn = nn;
    while(1) {
        a1=*lastnn;
        if ((a1==0)||(a1==13)) break;
        if (a1==10) break;
        lastnn++;
    }
    lastcode = a1;
    *lastnn = 0;
    return nn;
}
-(void)ResumeLineDirect {
    //		Resume last GetLineDirect function
    //
    *lastnn = lastcode;
}
-(int)GetMaxLine {
    int a,b;
    char a1;
    a=1;b=0;
    nn=base;
    while(1) {
        a1=*nn++;if (a1==0) break;
        if ((a1==13)||(a1==10)) {
            a++;b=0;
        }
        else b++;
    }
    if (b==0) a--;
    return a;
}
/*
 rev 54
 mingw : warning : a は未初期化で使用されうる
 問題なさそう、一応対処。
 */
-(int)PutLine:(char*)nstr2 line:(int)line ovr:(int)ovr {
    //		Pet specified line to note
    //				result:0=ok/1=no line
    //
    int a = 0,ln,la,lw;
    char a1;
    char *pp;
    char *p1;
    char *p2;
    char *nstr;
    if ( [self nnget:base line:line] )
        return 1;
    if (lastcr==0) {
        if ( nn != base ) {
            strcat( base,"¥r¥n" );
            nn+=2;
        }
    }
    nstr = nstr2;
    if ( nstr == NULL ) {
        nstr=(char *)"";
    }
    pp=nstr;
    if ( nstr2 != NULL ) strcat(nstr,"¥r¥n");
    ln=(int)strlen(nstr);			// base new str + cr/lf
    la=(int)strlen(base);
    lw=la-(int)(nn-base)+1;
    //
    if (ovr) {						// when overwrite mode
        p1=nn;a=0;
        while(1) {
            a1=*p1++;if (a1==0) break;
            a++;
            if ((a1==13)||(a1==10)) {
                    break;
                }
            }
            ln=ln-a;
            lw=lw-a;if (lw<1) lw=1;
        }
    //
    if (ln>=0) {
        p1=base+la+ln; p2=base+la;
        for(a=0;a<lw;a++) { *p1--=*p2--; }
    }
    else {
        p1=nn+a+ln;p2=nn+a;
        for(a=0;a<lw;a++) { *p1++=*p2++; }
    }
    //
    while(1) {
        a1=*pp++;if (a1==0) break;
        *nn++=a1;
    }
    return 0;
}
@end
