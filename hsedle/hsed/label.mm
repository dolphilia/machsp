//
//		Label Manager class
//			onion software/onitama 2002/2
//
#import <stdio.h>
#import <stdlib.h>
#import <string.h>
#import <ctype.h>
#import "label.h"
@implementation CLabel : NSObject
- (instancetype)init
{
    self = [super init];
    if (self) {
        int i;
        maxsymbol = def_maxsymbol;
        maxlab = def_maxlab;
        mem_lab = (LABOBJ *)malloc( sizeof(LABOBJ)*maxlab );
        for(i=0;i<def_maxblock;i++) { symblock[i] = NULL; }
        [self Reset];
    }
    return self;
}
//CLabel::CLabel( int symmax, int worksize )
//{
//    int i;
//    maxsymbol = worksize;
//    maxlab = symmax;
//    mem_lab = (LABOBJ *)malloc( sizeof(LABOBJ)*maxlab );
//    for(i=0;i<def_maxblock;i++) { symblock[i] = NULL; }
//    Reset();
//}
- (void)dealloc
{
    [self DisposeSymbolBuffer];
    if ( mem_lab != NULL ) free( mem_lab );
}
-(int)StrCase:(char*)str {
    //	string case to lower
    //
    int hash;
    unsigned char a1;
    unsigned char a2;
    unsigned char *ss;
    hash = 0;
    if ( casemode ) {			// 大文字小文字を区別する
        return [self GetHash:str];
    }
    ss = (unsigned char *)str;
    while(1) {
        a1=*ss;
        if (a1==0) break;
        if (a1>=0x80) {
            ss++;
            a1=*ss++;
            if (a1==0) break;
            hash += (int)a1;
        }
        else {
            a2 = tolower(a1);
            hash += (int)a2;
            *ss++ = a2;
        }
    }
    return hash;
}
-(int)GetHash:(char*)str {
    //		HUSH値を得る
    //
    int hash;
    unsigned char a1;
    unsigned char *ss;
    hash = 0;
    ss = (unsigned char *)str;
    while(1) {
        a1=*ss;
        if (a1==0) break;
        if (a1>=0x80) {
            ss++;
            a1=*ss++;
            if (a1==0) break;
            hash += (int)a1;
        }
        else {
            hash += (int)a1;
            ss++;
        }
    }
    return hash;
}
-(int)StrCmp:(char*)str1 str2:(char*)str2 {
    //	string compare (0=not same/-1=same)
    //  (case sensitive)
    int ap;
    char as;
    ap=0;
    while(1) {
        as=str1[ap];
        if (as!=str2[ap]) return 0;
        if (as==0) break;
        ap++;
    }
    return -1;
}
-(int)Regist:(char*)name type:(int)type opt:(int)opt {
    return [self Regist2:name type:type opt:opt filename:NULL line:-1];
}
-(int)Regist2:(char*)name type:(int)type opt:(int)opt filename:(char const*)filename line:(int)line {
    if ( name[0]==0 ) return -1;
    if ( cur>=maxlab ) {				// ラベルバッファ拡張
        LABOBJ *tmp;
        int i,oldsize;
        oldsize = sizeof(LABOBJ)*maxlab;
        maxlab += def_maxlab;
        tmp = (LABOBJ *)malloc( sizeof(LABOBJ)*maxlab );
        for(i=0;i<maxlab;i++) { tmp[i].flag = -1; }
        memcpy( (char *)tmp, (char *)mem_lab, oldsize );
        free( mem_lab );
        mem_lab = tmp;
    }
    int label_id = cur;
    LABOBJ *lab=&mem_lab[cur++];
    lab->flag = 1;
    lab->type = type;
    lab->opt  = opt;
    lab->eternal = 0;
    lab->ref = 0;
    lab->name = [self RegistSymbol:name];
    lab->data = NULL;
    lab->data2 = NULL;
    lab->hash = [self StrCase:lab->name];
    lab->rel = NULL;
    lab->init = LAB_INIT_NO;
    lab->typefix = LAB_TYPEFIX_NONE;
    [self SetDefinition:label_id filename:filename line:line];
    labels.insert(std::make_pair(lab->name, label_id));
    return label_id;
}
-(void)SetEternal:(int)id {
    //		set eternal flag
    //
    mem_lab[id].eternal=1;
}
-(int)GetEternal:(int)id {
    //		set eternal flag
    //
    return mem_lab[id].eternal;
}
-(void)SetFlag:(int)id val:(int)val {
    //		set eternal flag
    //
    mem_lab[id].flag = val;
}
-(void)SetOpt:(int)id val:(int)val {
    //		set option
    //
    mem_lab[id].opt = val;
}
-(void)SetData:(int)id str:(char*)str {
    //		set data
    //
    LABOBJ *lab=&mem_lab[id];
    if ( str == NULL ) {
        lab->data = NULL;
        return;
    }
    lab->data = [self RegistTable:str size:(int)strlen(str)+1];
}
-(void)SetData2:(int)id str:(char*)str size:(int)size {
    //		set data
    //
    LABOBJ *lab=&mem_lab[id];
    if ( str == NULL ) {
        lab->data2 = NULL;
        return;
    }
    lab->data2 = [self RegistTable:str size:size];
}
-(void)SetInitFlag:(int)id val:(int)val {
    //		set init flag
    //
    mem_lab[id].init = (short)val;
}
-(void)SetForceType:(int)id val:(int)val {
    //		set force type
    //
    mem_lab[id].typefix = (short)val;
}
-(int)Search:(char*)oname {
    //		object name search
    //
    if (cur==0) return -1;    //int hash =
    [self StrCase:oname];
    if (*oname != 0) {
        std::pair<LabelMap::iterator, LabelMap::iterator> r = labels.equal_range( oname );
        for(LabelMap::iterator it = r.first; it != r.second; ++it) {
            LABOBJ *lab = mem_lab + it->second;
            if ( lab->flag >= 0 ) {
                return it->second;
            }
        }
    }
    return -1;
}
-(int)SearchLocal:(char*)oname loname:(char*)loname {
    //		object name search ( for local )
    //
    int hash, hash2;
    if (cur == 0) return -1;
    hash = [self StrCase:oname];
    hash2 = [self GetHash:loname];
    if (*oname != 0) {
        std::pair<LabelMap::iterator, LabelMap::iterator> r = labels.equal_range( oname );
        for(LabelMap::iterator it = r.first; it != r.second; ++it) {
            LABOBJ *lab = mem_lab + it->second;
            if (lab->flag >= 0 && lab->eternal) {
                return it->second;
            }
        }
        std::pair<LabelMap::iterator, LabelMap::iterator> r2 = labels.equal_range( loname );
        for(LabelMap::iterator it = r2.first; it != r2.second; ++it) {
            LABOBJ *lab = mem_lab + it->second;
            if (lab->flag >= 0 && !lab->eternal) {
                return it->second;
            }
        }
    }
    return -1;
}
-(void)Reset {
    int i;
    cur = 0;
    labels.clear();
    filenames.clear();
    for(i=0;i<maxlab;i++) { mem_lab[i].flag = -1; }
    [self DisposeSymbolBuffer];
    [self MakeSymbolBuffer];
    casemode = 0;
}
-(void)MakeSymbolBuffer {
    symbol = (char *)malloc( maxsymbol );
    symblock[curblock] = symbol;
    curblock++;
    symcur = 0;
}
-(void)DisposeSymbolBuffer {
    int i;
    for(i=0;i<def_maxblock;i++) {
        if ( symblock[i] != NULL ) {
            free( symblock[i] );
            symblock[i] = NULL;
        }
    }
    curblock = 0;
}
-(char*)ExpandSymbolBuffer:(int)size {
    char *p;
    int nsize = ((size + 7) >> 3)  << 3;
    size = nsize;
    p = symbol + symcur;
    symcur += size;
    if ( symcur >= maxsymbol ) {
        [self MakeSymbolBuffer];
        symcur += size;
        return symbol;
    }
    return p;
}
-(int)GetCount {
    return cur;
}
-(int)GetSymbolSize {
    return ((maxsymbol * (curblock-1))+symcur);
}
-(int)GetFlag:(int)id {
    return mem_lab[id].flag;
}
-(int)GetOpt:(int)id {
    return mem_lab[id].opt;
}
-(int)GetType:(int)id {
    return mem_lab[id].type;
}
-(char*)GetName:(int)id {
    return mem_lab[id].name;
}
-(char*)GetData:(int)id {
    return mem_lab[id].data;
}
-(char*)GetData2:(int)id {
    return mem_lab[id].data2;
}
-(LABOBJ*)GetLabel:(int)id {
    return &mem_lab[id];
}
-(int)GetInitFlag:(int)id {
    return (int)mem_lab[id].init;
}
-(char*)RegistSymbol:(char*)str {
    //		シンボルテーブルに文字列を登録
    //
    char *p;
    char *pmaster;
    char *src;
    char a1,a2;
    int i;
    //int hush;
    i = 0;
    p = [self ExpandSymbolBuffer:(int)strlen(str)+1];
    pmaster = p;
    src = str;
    a2 = *src;
    while(1) {
        a1=*src++;
        *p++ = a1;
        if ( a1 == 0 ) break;
        if ( i >= (maxname-1) ) { *p=0; i++; break; }
        i++;
    }
    //if (i) a1 = str[i-1];
    //symcur+=i+1;
    //hush = (a1+a2+i)&31;
    //return hush;
    return pmaster;
}
-(char*)RegistTable:(char*)str size:(int)size {
    //		シンボルテーブルにテーブルデータを登録
    //
    char *p;
    char *src;
    src = str;
    p = [self ExpandSymbolBuffer:size];
    memcpy( p, src, size );
    return p;
}
-(char*)GetListToken:(char*)str {
    char *p;
    char *dst;
    char a1;
    p = str;
    while(1) {
        a1=*p;if ( a1!=32 ) break;
        p++;
    }
    dst = token;
    while(1) {
        a1=*p;if (( a1==0 )||( a1==32 )) break;
        *dst++=a1;
        p++;
    }
    *dst=0;
    return p;
}
-(int)RegistList:(char**)list modname:(char*)modname {
    //		キーワードリストを登録する
    //
    char *p;
    char **plist;
    char tmp[256];
    int id,i,type,opt;
    i = 1;
    plist = list;
    while(1) {
        p = tmp;
        strcpy( p, plist[i++] );
        if (p[0]!='$') break;
        p++;
        p = [self GetListToken:p];
        opt = [self HtoI];
        p = [self GetListToken:p];
        type = atoi( token );
        p = [self GetListToken:p];
        strcat( token, modname );
        id = [self Regist:token type:type opt:opt];
        [self SetEternal:id];
    }
    return 0;
}
-(int)RegistList2:(char**)list modname:(char*)modname {
    //		キーワードリストをword@modnameの代替マクロとして登録する
    //
    char *p;
    char **plist;
    char tmp[256];
    int id,i,type,opt;
    i = 1;
    plist = list;
    while(1) {
        p = tmp;
        strcpy( p, plist[i++] );
        if (p[0]!='$') break;
        p++;
        p = [self GetListToken:p];
        opt = [self HtoI];
        p = [self GetListToken:p];
        type = atoi( token );
        p = [self GetListToken:p];
        //id = Regist( token, type, opt );
        id = [self Regist:token type:LAB_TYPE_PPINTMAC opt:0];		// 内部マクロとして定義
        strcat( token, modname );
        [self SetData:id str:token];
        [self SetEternal:id];
    }
    return 0;
}
-(int)RegistList3:(char**)list {
    //		キーワードリストを色分けテーブル用に登録する
    //
    char *p;
    char **plist;
    char tmp[256];
    int id,i,type,opt;
    static int kwcnv[]={
        LAB_TYPE_PPEX_PRECMD,	//TYPE_MARK 0
        LAB_TYPE_PPMAC,			//TYPE_VAR 1
        LAB_TYPE_PPEX_INTCMD,	//TYPE_STRING 2
        LAB_TYPE_PPEX_INTCMD,	//TYPE_DNUM 3
        LAB_TYPE_PPEX_INTCMD,	//TYPE_INUM 4
        LAB_TYPE_PPEX_INTCMD,	//TYPE_STRUCT 5
        LAB_TYPE_PPEX_INTCMD,	//TYPE_XLABEL 6
        LAB_TYPE_PPEX_INTCMD,	//TYPE_LABEL 7
        LAB_TYPE_PPEX_INTCMD,	//TYPE_INTCMD 8
        LAB_TYPE_PPEX_INTCMD,	//TYPE_EXTCMD 9
        LAB_TYPE_PPEX_INTCMD,	//TYPE_EXTSYSVAR 10
        LAB_TYPE_PPEX_INTCMD,	//TYPE_CMPCMD 11
        LAB_TYPE_PPEX_INTCMD,	//TYPE_MODCMD 12
        LAB_TYPE_PPEX_INTCMD,	//TYPE_INTFUNC 13
        LAB_TYPE_PPEX_INTCMD,	//TYPE_SYSVAR 14
        LAB_TYPE_PPEX_INTCMD,	//TYPE_PROGCMD 15
        LAB_TYPE_PPEX_INTCMD,	//TYPE_DLLFUNC 16
        LAB_TYPE_PPEX_EXTCMD,	//TYPE_DLLCTRL 17
        LAB_TYPE_PPEX_INTCMD,	//TYPE_USERDEF 18
        
    };
    i = 1;
    plist = list;
    while(1) {
        p = tmp;
        strcpy( p, plist[i++] );
        if (p[0]!='$') break;
        p++;
        p = [self GetListToken:p];
        opt = [self HtoI];
        p = [self GetListToken:p];
        type = atoi( token );
        p = [self GetListToken:p];
        id = [self Regist:token type:kwcnv[type] opt:opt];
        [self SetEternal:id];
    }
    return 0;
}
-(char*)Prt:(char*)str str2:(char*)str2 {
    char *p;
    p = str;
    strcpy( str, str2 );
    p+=strlen(str2);
    *p++=13;
    *p++=10;
    return p;
}
-(int)HtoI {
    //	Convert token(hex) to int
    char *wp;
    char a1;
    int val,b;
    val=0;
    wp = token;
    while(1) {
        a1=toupper(*wp);b=-1;
        if (a1==0) { wp=NULL;break; }
        if ((a1>=0x30)&&(a1<=0x39)) b=a1-0x30;
        if ((a1>=0x41)&&(a1<=0x46)) b=a1-55;
        if (a1=='_') b=-2;
        if (b==-1) break;
        if (b>=0) { val=(val<<4)+b; }
        wp++;
    }
    return val;
}
-(void)DumpLabel:(char*)str {
    char tmp[256];
    char *p;
    int a;
    p = str;
    p=[self Prt:p str2:(char *)"#Debug dump"];
    sprintf( tmp,"#Labels:%d",cur );
    p=[self Prt:p str2:tmp];
    for(a=0;a<cur;a++) {
        LABOBJ *lab=&mem_lab[a];
        sprintf( tmp,"#ID:%d (%s) flag:%d  type:%d  opt:%x",a,lab->name,lab->flag,lab->type,lab->opt );
        p=[self Prt:p str2:tmp];
        //		lab = GetLabel( Search( lab->name) );
        //		sprintf( tmp,"#ID:%d (%s) flag:%d  type:%d  opt:%x",a,lab->name,lab->flag,lab->type,lab->opt );
        //		p=Prt( p,tmp );
    }
    *p=0;
}
-(void)DumpHSPLabel:(char*)str option:(int)option maxsize:(int)maxsize {
    char tmp[256];
    char *typem;
    //	char optm[256];
    char *p;
    char *p_limit;
    int a;
    p = str;
    p_limit = p + maxsize;
    for(a=0;a<cur;a++) {
        if ( p >= p_limit )
            break;
        LABOBJ *lab=&mem_lab[a];
        typem = NULL;
        switch( lab->type ) {
            case LAB_TYPE_PPEX_PRECMD:
                if ( option & LAB_DUMPMODE_RESCMD ) typem = (char *)"pre|func";
                break;
            case LAB_TYPE_PPEX_EXTCMD:
                if ( option & LAB_DUMPMODE_RESCMD ) typem = (char *)"sys|func|1";
                break;
            case LAB_TYPE_PPDLLFUNC:
                if ( option & LAB_DUMPMODE_DLLCMD ) typem = (char *)"sys|func|2";
                break;
            case LAB_TYPE_PPMODFUNC:
                if ( option & LAB_DUMPMODE_DLLCMD ) typem = (char *)"sys|func|3";
                break;
            case LAB_TYPE_PPMAC:
            case LAB_TYPE_PPVAL:
                if ( option & LAB_DUMPMODE_RESCMD ) typem = (char *)"sys|macro";
                break;
            default:
                if ( option & LAB_DUMPMODE_RESCMD ) typem = (char *)"sys|func";
                break;
        }
        /*
         if ( lab->opt >= 0x100 ) {
         if (( lab->opt & 0xff )<0x10 ) {
         optm[0]='|';
         optm[1]=48+(lab->opt>>8); optm[2]=0;
         strcat( typem,optm );
         }
         }
         */
        if ( typem != NULL ) {
            sprintf( tmp,"%s¥t,%s",lab->name,typem );
            p=[self Prt:p str2:tmp];
        }
    }
    *p=0;
}
-(void)AddReference:(int)id {
    //		参照回数を+1する
    //
    LABOBJ *lab=&mem_lab[id];
    lab->ref++;
}
-(int)GetReference:(int)id {
    //		参照回数を取得する(依存関係も含める)
    //
    int total;
    LABREL *rel;
    LABOBJ *lab=&mem_lab[id];
    total = lab->ref;
    rel = lab->rel;
    if ( rel != NULL ) {
        while(1) {
            total += [self GetReference:rel->rel_id];
            if ( rel->link == NULL ) break;
            rel = rel->link;
        }
    }
    return total;
}
-(int)SearchRelation:(int)id rel_id:(int)rel_id {
    //		ラベル依存の特定IDデータがあるかを検索
    //		(0=なし/1=あり)
    //
    LABREL *tmp;
    LABOBJ *lab=&mem_lab[id];
    tmp = lab->rel;
    if ( tmp == NULL ) return 0;
    while(1) {
        if ( tmp->link == NULL ) break;
        if ( tmp->rel_id == rel_id ) return 1;
        tmp = tmp->link;
    }
    return 0;
}
-(void)AddRelation:(int)id rel_id:(int)rel_id {
    //		ラベル依存のIDデータを追加する
    //
    LABREL *rel;
    LABREL *tmp;
    if ( id == rel_id ) return;				// 循環するようなデータは登録しない
    rel = (LABREL *)[self ExpandSymbolBuffer:sizeof(LABREL)];
    rel->link = NULL;
    rel->rel_id = rel_id;
    LABOBJ *lab=&mem_lab[id];
    if ( lab->rel == NULL ) {
        lab->rel = rel;
        return;
    }
    tmp = lab->rel;
    while(1) {
        if ( tmp->link == NULL ) break;
        tmp = tmp->link;
    }
    tmp->link = rel;
}
-(void)AddRelation2:(char*)name rel_id:(int)rel_id {
    int i;
    i = [self Search:name];
    if ( i < 0 ) return;
    [self AddRelation:i rel_id:rel_id];
}
-(void)SetCaseMode:(int)flag {
    casemode = flag;
}
-(void)SetDefinition:(int)id filename:(char const*)filename line:(int)line {
    if ( !(filename != NULL && line >= 0) ) return;
    LABOBJ* const it = [self GetLabel:id];
    it->def_file = filenames.insert(filename).first->c_str();
    it->def_line = line;
}
@end
