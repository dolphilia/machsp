
//
//		Label Manager class
//			onion software/onitama 2002/2
//
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include "label.h"

//-------------------------------------------------------------
//		Routines
//-------------------------------------------------------------

/// string case to lower
///
int CLabel::StrCase( char *str ) {
    int hash = 0;
    unsigned char cur_char;
    unsigned char tmp;
    unsigned char *ptr;
    
    if (casemode) { // 大文字小文字を区別する
        return GetHash(str);
    }
    
    ptr = (unsigned char *)str;
    while(1) {
        cur_char = *ptr;
        if (cur_char == 0)
            break;
        if (cur_char >= 0x80) {
            ptr++;
            cur_char = *ptr++;
            if (cur_char == 0)
                break;
            hash += (int)cur_char;
        }
        else {
            tmp = tolower(cur_char);
            hash += (int)tmp;
            *ptr++ = tmp;
        }
    }
    return hash;
}

/// HUSH値を得る
///
int CLabel::GetHash( char *str ) {
    int hash = 0;
    unsigned char *ptr = (unsigned char *)str;
    unsigned char cur_char;
    while(1) {
        cur_char = *ptr;
        if (cur_char == 0)
            break;
        if (cur_char >= 0x80) {
            ptr++;
            cur_char = *ptr++;
            if (cur_char == 0)
                break;
            hash += (int)cur_char;
        }
        else {
            hash += (int)cur_char;
            ptr++;
        }
    }
    return hash;
}

/// string compare (0=not same/-1=same)
/// (case sensitive)
int CLabel::StrCmp( char *str1, char *str2 ) {
    char cur_char;
    int i = 0;
    while(1) {
        cur_char = str1[i];
        if (cur_char != str2[i])
            return 0;
        if (cur_char == 0)
            break;
        i++;
    }
    return -1;
}

int CLabel::Regist( char *name, int type, int opt ) {
    return Regist(name, type, opt, NULL, -1);
}

int CLabel::Regist( char *name, int type, int opt, char const *filename, int line ) {
    if (name[0] == 0)
        return -1;
    if (cur >= maxlab) { // ラベルバッファ拡張
        int oldsize = sizeof(LABOBJ)*maxlab;
        maxlab += def_maxlab;
        LABOBJ *tmp = (LABOBJ *)malloc(sizeof(LABOBJ)*maxlab);
        for(int i = 0; i < maxlab; i++) {
            tmp[i].flag = -1;
        }
        memcpy((char *)tmp, (char *)mem_lab, oldsize);
        free(mem_lab);
        mem_lab = tmp;
    }
    
    int label_id = cur;
    LABOBJ *lab = &mem_lab[cur++];
    lab->flag = 1;
    lab->type = type;
    lab->opt  = opt;
    lab->eternal = 0;
    lab->ref = 0;
    lab->name = RegistSymbol( name );
    lab->data = NULL;
    lab->data2 = NULL;
    lab->hash = StrCase( lab->name );
    lab->rel = NULL;
    lab->init = LAB_INIT_NO;
    lab->typefix = LAB_TYPEFIX_NONE;
    SetDefinition(label_id, filename, line);
    
    labels.insert(std::make_pair(lab->name, label_id));
    return label_id;
}

/// set eternal flag
///
void CLabel::SetEternal( int id ) {
    mem_lab[id].eternal=1;
}

/// set eternal flag
///
int CLabel::GetEternal( int id ) {
    return mem_lab[id].eternal;
}

//        set eternal flag
//
void CLabel::SetFlag( int id, int val ) {
    mem_lab[id].flag = val;
}

//        set option
//
void CLabel::SetOpt( int id, int val ) {
    mem_lab[id].opt = val;
}

//        set data
//
void CLabel::SetData( int id, char *str ) {
    LABOBJ *lab = &mem_lab[id];
    if (str == NULL) {
        lab->data = NULL;
        return;
    }
    lab->data = RegistTable(str, (int)strlen(str) + 1);
}

//        set data
//
void CLabel::SetData2(int id, char *str, int size) {
    LABOBJ *lab = &mem_lab[id];
    if (str == NULL) {
        lab->data2 = NULL;
        return;
    }
    lab->data2 = RegistTable(str, size);
}

//        set init flag
//
void CLabel::SetInitFlag(int id, int val) {
    mem_lab[id].init = (short)val;
}

//        set force type
//
void CLabel::SetForceType(int id, int val) {
    mem_lab[id].typefix = (short)val;
}

//        object name search
//
int CLabel::Search(char *oname) {
    if (cur == 0)
        return -1;
    //int hash =
    StrCase(oname);
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

//        object name search ( for local )
//
int CLabel::SearchLocal( char *oname, char *loname ) {
    int hash, hash2;
    if (cur == 0)
        return -1;
    
    hash = StrCase(oname);
    hash2 = GetHash(loname);
    
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


//-------------------------------------------------------------
//		Interfaces
//-------------------------------------------------------------

CLabel::CLabel( void ) {
    maxsymbol = def_maxsymbol;
    maxlab = def_maxlab;
    mem_lab = (LABOBJ *)malloc( sizeof(LABOBJ)*maxlab );
    for(int i = 0; i < def_maxblock; i++) {
        symblock[i] = NULL;
    }
    Reset();
}

CLabel::CLabel( int symmax, int worksize ) {
    maxsymbol = worksize;
    maxlab = symmax;
    mem_lab = (LABOBJ *)malloc( sizeof(LABOBJ)*maxlab );
    for(int i = 0; i < def_maxblock; i++) {
        symblock[i] = NULL;
    }
    Reset();
}

CLabel::~CLabel( void ) {
    DisposeSymbolBuffer();
    if ( mem_lab != NULL ) free( mem_lab );
}

void CLabel::Reset( void ) {
    cur = 0;
    labels.clear();
    filenames.clear();
    for(int i = 0; i < maxlab; i++) {
        mem_lab[i].flag = -1;
    }
    DisposeSymbolBuffer();
    MakeSymbolBuffer();
    casemode = 0;
}

void CLabel::MakeSymbolBuffer( void ) {
    symbol = (char *)malloc( maxsymbol );
    symblock[curblock] = symbol;
    curblock++;
    symcur = 0;
}

void CLabel::DisposeSymbolBuffer( void ) {
    for(int i = 0; i < def_maxblock; i++) {
        if ( symblock[i] != NULL ) {
            free( symblock[i] );
            symblock[i] = NULL;
        }
    }
    curblock = 0;
}

char *CLabel::ExpandSymbolBuffer( int size ) {
    char *p;
    int nsize = ((size + 7) >> 3)  << 3;
    size = nsize;
    p = symbol + symcur;
    symcur += size;
    if ( symcur >= maxsymbol ) {
        MakeSymbolBuffer();
        symcur += size;
        return symbol;
    }
    return p;
}

int CLabel::GetCount( void ) {
    return cur;
}

int CLabel::GetSymbolSize( void ) {
    return ((maxsymbol * (curblock-1))+symcur);
}

int CLabel::GetFlag( int id ) {
    return mem_lab[id].flag;
}

int CLabel::GetOpt( int id ) {
    return mem_lab[id].opt;
}

int CLabel::GetType( int id ) {
    return mem_lab[id].type;
}

char *CLabel::GetName( int id ) {
    return mem_lab[id].name;
}

char *CLabel::GetData( int id ) {
    return mem_lab[id].data;
}

char *CLabel::GetData2( int id ) {
    return mem_lab[id].data2;
}

LABOBJ *CLabel::GetLabel( int id ) {
    return &mem_lab[id];
}

int CLabel::GetInitFlag( int id ) {
    return (int)mem_lab[id].init;
}

/// シンボルテーブルに文字列を登録
///
char *CLabel::RegistSymbol( char *str ) {
    char *p = ExpandSymbolBuffer( (int)strlen(str)+1 );
    char *pmaster = p;
    char *src = str;
    char cur_char;
    char a2 = *src;
    int i = 0;
    //int hush;
    while(1) {
        cur_char = *src++;
        *p++ = cur_char;
        if (cur_char == 0)
            break;
        if (i >= (maxname-1)) {
            *p = 0;
            i++;
            break;
        }
        i++;
    }
    //if (i) a1 = str[i-1];
    //symcur+=i+1;
    //hush = (a1+a2+i)&31;
    //return hush;
    return pmaster;
}

/// シンボルテーブルにテーブルデータを登録
///
char *CLabel::RegistTable(char *str, int size) {
    char *p = ExpandSymbolBuffer(size);
    char *src = str;
    memcpy(p, src, size);
    return p;
}

char *CLabel::GetListToken(char *str) {
    char *ptr = str;
    char *dst;
    char cur_char;
    while(1) {
        cur_char = *ptr;
        if (cur_char != 32)
            break;
        ptr++;
    }
    dst = token;
    while(1) {
        cur_char = *ptr;
        if ((cur_char == 0) || (cur_char == 32))
            break;
        *dst++ = cur_char;
        ptr++;
    }
    *dst = 0;
    return ptr;
}

/// キーワードリストを登録する
///
int CLabel::RegistList(char **list, char *modname) {
    char *p;
    char **plist = list;
    char tmp[256];
    int id;
    int i = 1;
    int type;
    int opt;
    while(1) {
        p = tmp;
        strcpy(p, plist[i++]);
        if (p[0] != '$')
            break;
        p++;
        p = GetListToken(p);
        opt = HtoI();
        p = GetListToken(p);
        type = atoi(token);
        p = GetListToken(p);
        strcat(token, modname);
        id = Regist(token, type, opt);
        SetEternal(id);
    }
    return 0;
}

/// キーワードリストをword@modnameの代替マクロとして登録する
///
int CLabel::RegistList2( char **list, char *modname ) {
    char *p;
    char **plist;
    char tmp[256];
    int id,i,type,opt;
    i = 1;
    plist = list;
    while(1) {
        p = tmp;
        strcpy(p, plist[i++]);
        if (p[0] != '$')
            break;
        p++;
        p = GetListToken( p );
        opt = HtoI();
        p = GetListToken( p );
        type = atoi( token );
        p = GetListToken( p );
        //id = Regist( token, type, opt );
        
        id = Regist( token, LAB_TYPE_PPINTMAC, 0 );		// 内部マクロとして定義
        strcat( token, modname );
        SetData( id, token );
        SetEternal( id );
    }
    return 0;
}

/// キーワードリストを色分けテーブル用に登録する
///
int CLabel::RegistList3( char **list ) {
    char *p;
    char **plist;
    char tmp[256];
    int id, i, type, opt;
    static int kwcnv[] = {
        
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
        p = GetListToken( p );
        opt = HtoI();
        p = GetListToken( p );
        type = atoi( token );
        p = GetListToken( p );
        id = Regist( token, kwcnv[ type ], opt );
        SetEternal( id );
    }
    return 0;
}


//-------------------------------------------------------------
//		For debug
//-------------------------------------------------------------

char *CLabel::Prt( char *str, char *str2 ) {
    char *p;
    p = str;
    strcpy( str, str2 );
    p+=strlen(str2);
    *p++=13;
    *p++=10;
    return p;
}

/// Convert token(hex) to int
///
int CLabel::HtoI( void ) {
    char *wp;
    char a1;
    int val, b;
    val = 0;
    wp = token;
    while(1) {
        a1 = toupper(*wp);
        b = -1;
        if (a1 == 0) {
            wp = NULL;
            break;
        }
        if ((a1 >= 0x30) && (a1 <= 0x39))
            b = a1 - 0x30;
        if ((a1 >= 0x41) && (a1 <= 0x46))
            b = a1 - 55;
        if (a1 == '_')
            b = -2;
        if (b == -1)
            break;
        if (b >= 0) {
            val = (val << 4) + b;
        }
        wp++;
    }
    return val;
}

void CLabel::DumpLabel( char *str ) {
    char tmp[256];
    char *p;
    p = str;
    p = Prt( p,(char *)"#Debug dump" );
    sprintf( tmp, "#Labels:%d", cur );
    p = Prt( p,tmp );
    for(int i = 0; i < cur; i++) {
        LABOBJ *lab=&mem_lab[i];
        sprintf(tmp, "#ID:%d (%s) flag:%d  type:%d  opt:%x", i, lab->name, lab->flag, lab->type, lab->opt);
        p = Prt(p, tmp);
        //		lab = GetLabel( Search( lab->name) );
        //		sprintf( tmp,"#ID:%d (%s) flag:%d  type:%d  opt:%x",a,lab->name,lab->flag,lab->type,lab->opt );
        //		p=Prt( p,tmp );
    }
    *p = 0;
}

void CLabel::DumpHSPLabel(char *str, int option, int maxsize) {
    char tmp[256];
    char *typem;
    //	char optm[256];
    char *p;
    char *p_limit;
    p = str;
    p_limit = p + maxsize;
    
    for(int i = 0; i < cur; i++) {
        if ( p >= p_limit )
            break;
        
        LABOBJ *lab = &mem_lab[i];
        typem = NULL;
        switch( lab->type ) {
            case LAB_TYPE_PPEX_PRECMD:
                if ( option & LAB_DUMPMODE_RESCMD )
                    typem = (char *)"pre|func";
                break;
            case LAB_TYPE_PPEX_EXTCMD:
                if ( option & LAB_DUMPMODE_RESCMD )
                    typem = (char *)"sys|func|1";
                break;
            case LAB_TYPE_PPDLLFUNC:
                if ( option & LAB_DUMPMODE_DLLCMD )
                    typem = (char *)"sys|func|2";
                break;
            case LAB_TYPE_PPMODFUNC:
                if ( option & LAB_DUMPMODE_DLLCMD )
                    typem = (char *)"sys|func|3";
                break;
            case LAB_TYPE_PPMAC:
            case LAB_TYPE_PPVAL:
                if ( option & LAB_DUMPMODE_RESCMD )
                    typem = (char *)"sys|macro";
                break;
            default:
                if ( option & LAB_DUMPMODE_RESCMD )
                    typem = (char *)"sys|func";
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
            sprintf( tmp, "%s¥t,%s", lab->name, typem );
            p = Prt( p, tmp );
        }
    }
    *p = 0;
}

/// 参照回数を+1する
///
void CLabel::AddReference( int id ) {
    LABOBJ *lab=&mem_lab[id];
    lab->ref++;
}

/// 参照回数を取得する(依存関係も含める)
///
int CLabel::GetReference( int id ) {
    int total;
    LABREL *rel;
    LABOBJ *lab=&mem_lab[id];
    total = lab->ref;
    rel = lab->rel;
    if ( rel != NULL ) {
        while(1) {
            total += GetReference( rel->rel_id );
            if ( rel->link == NULL ) break;
            rel = rel->link;
        }
    }
    return total;
}

/// ラベル依存の特定IDデータがあるかを検索
/// (0=なし/1=あり)
///
int CLabel::SearchRelation( int id, int rel_id ) {
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

/// ラベル依存のIDデータを追加する
///
void CLabel::AddRelation( int id, int rel_id ) {
    LABREL *rel;
    LABREL *tmp;
    
    if ( id == rel_id )
        return;				// 循環するようなデータは登録しない
    
    rel = (LABREL *)ExpandSymbolBuffer( sizeof(LABREL) );
    rel->link = NULL;
    rel->rel_id = rel_id;
    
    LABOBJ *lab=&mem_lab[id];
    if ( lab->rel == NULL ) {
        lab->rel = rel;
        return;
    }
    tmp = lab->rel;
    while(1) {
        if ( tmp->link == NULL )
            break;
        tmp = tmp->link;
    }
    tmp->link = rel;
}

void CLabel::AddRelation( char *name, int rel_id ) {
    int i = Search( name );
    if ( i < 0 )
        return;
    AddRelation( i, rel_id );
}

void CLabel::SetCaseMode( int flag ) {
    casemode = flag;
}

void CLabel::SetDefinition(int id, char const* filename, int line) {
    if ( !(filename != NULL && line >= 0) )
        return;
    LABOBJ* const it = GetLabel(id);
    it->def_file = filenames.insert(filename).first->c_str();
    it->def_line = line;
}
