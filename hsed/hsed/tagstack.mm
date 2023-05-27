
//
//		stack buffer with tag class
//			onion software/onitama 2002/10
//
#include "tagstack.h"
#include <stdio.h>
#include <string.h>

//-------------------------------------------------------------
//		Routines
//-------------------------------------------------------------

int
CTagStack::StrCmp(char *str1, char *str2) {
    //	string compare (0=not same/-1=same)
    //  (case sensitive)
    int ap;
    char as;
    ap = 0;
    while (1) {
        as = str1[ap];
        if (as != str2[ap])
            return 0;
        if (as == 0)
            break;
        ap++;
    }
    return -1;
}

int
CTagStack::SearchTagID(char *tag) {
    //		É^ÉOÇåüçı
    //
    int i;
    if (tagent == 0)
        return -1;
    for (i = 0; i < tagent; i++) {
        if (StrCmp(mem_tag[i].name, tag))
            return i;
    }
    return -1;
}

int
CTagStack::RegistTagID(char *tag) {
    //		É^ÉOÇìoò^
    //
    int i, len;
    if (tagent >= TAGSTK_TAGMAX)
        return -1;
    i = tagent;
    tagent++;
    len = (int) strlen(tag);
    if (len >= TAGSTK_TAGSIZE)
        tag[TAGSTK_TAGSIZE - 1] = 0;
    strcpy(mem_tag[i].name, tag);
    return i;
}

void
CTagStack::GetTagUniqueName(int tagid, char *outname) {
    //		É^ÉOIDÇ…ëŒâûÇµÇΩÉÜÉjÅ[ÉNñºÇéÊìæ
    //
    TAGINF *t;
    if ((tagid < 0) || (tagid >= TAGSTK_TAGMAX)) {
        sprintf(outname, "TagErr%04x", gcount++);
    } else {
        t = &mem_tag[tagid];
        sprintf(outname, "_%s_%04x", t->name, t->uid++);
    }
}

int
CTagStack::GetTagID(char *tag) {
    //		É^ÉOñº->É^ÉOID Ç…ïœä∑Ç∑ÇÈ
    //
    int i;
    i = SearchTagID(tag);
    if (i < 0) {
        i = RegistTagID(tag);
    }
    return i;
}

char *
CTagStack::GetTagName(int tagid) {
    //		É^ÉOID->É^ÉOñº Ç…ïœä∑Ç∑ÇÈ
    //
    if ((tagid < 0) || (tagid >= TAGSTK_TAGMAX))
        return tagerr;
    return mem_tag[tagid].name;
}

int
CTagStack::StackCheck(char *res) {
    //		Ç∑Ç◊ÇƒÇÃÉXÉ^ÉbÉNÇ™âåàÇ≥ÇÍÇƒÇ¢ÇÈÇ©ÇÉ`ÉFÉbÉN
    //			0=OK/1>=NG (resÇ…ÉGÉâÅ[ÉXÉ^ÉbÉNÇä‹ÇﬁÉ^ÉOàÍóó)
    //
    int i, n;
    TAGDATA *t;
    strcpy(res, "\t");
    for (i = 0; i < TAGSTK_TAGMAX; i++) {
        mem_tag[i].check = 0;
    }
    if (lastidx < 1)
        return 0;
    i = lastidx;
    while (1) {
        i--;
        if (i < 0)
            break;
        t = &mem_buf[i];
        if (t->tagid >= 0)
            mem_tag[t->tagid].check = -1;
    }
    n = 0;
    for (i = 0; i < TAGSTK_TAGMAX; i++) {
        if (mem_tag[i].check) {
            if (n)
                strcat(res, ", ");
            strcat(res, mem_tag[i].name);
            n++;
        }
    }
    return n;
}

int
CTagStack::PushTag(int tagid, char *str) {
    //		É^ÉOID,strÇÉXÉ^ÉbÉNÇ…ì¸ÇÍÇÈ
    //
    int i, len;
    TAGDATA *t;
    if ((tagid < 0) || (tagid >= TAGSTK_TAGMAX))
        return -1;
    if (lastidx >= TAGSTK_MAX)
        return -1;
    i = lastidx;
    lastidx++;
    t = &mem_buf[i];
    t->tagid = tagid;
    len = (int) strlen(str);
    if (len >= TAGSTK_SIZE)
        str[TAGSTK_SIZE - 1] = 0;
    strcpy(t->data, str);
    return i;
}

char *
CTagStack::PopTag(int tagid) {
    //		É^ÉOIDÇ…ëŒâûÇµÇΩÉXÉ^ÉbÉNstrÇéÊÇËèoÇ∑
    //
    int i;
    TAGDATA *t;
    char *p;
    if ((tagid < 0) || (tagid >= TAGSTK_TAGMAX))
        return NULL;
    if (lastidx < 1)
        return NULL;
    i = lastidx;
    while (1) { // ÉXÉ^ÉbÉNÇíHÇÈ
        i--;
        if (i < 0)
            return NULL;
        t = &mem_buf[i];
        if (t->tagid == tagid)
            break;
    }
    p = t->data;
    t->tagid = -1;
    i = lastidx - 1;
    while (1) {
        if (i < 0)
            break;
        if (mem_buf[i].tagid != -1)
            break;
        lastidx = i;
        i--;
    }
    return p;
}

char *
CTagStack::LookupTag(int tagid, int level) {
    //		É^ÉOIDÇ…ëŒâûÇµÇΩÉXÉ^ÉbÉNstrÇéÊÇËèoÇ∑(POPÇµÇ»Ç¢)
    //				(level=ÉXÉ^ÉbÉNíiêî0,1,2Åc)
    //
    int i, lv;
    TAGDATA *t;
    if ((tagid < 0) || (tagid >= TAGSTK_TAGMAX))
        return NULL;
    if (lastidx < 1)
        return NULL;
    lv = level;
    i = lastidx;
    while (1) { // ÉXÉ^ÉbÉNÇíHÇÈ
        i--;
        if (i < 0)
            return NULL;
        t = &mem_buf[i];
        if (t->tagid == tagid) {
            if (lv == 0)
                break;
            lv--;
        }
    }
    return t->data;
}

//-------------------------------------------------------------
//		Interfaces
//-------------------------------------------------------------

CTagStack::CTagStack() {
    int i;
    for (i = 0; i < TAGSTK_TAGMAX; i++) {
        mem_tag[i].name[0] = 0;
        mem_tag[i].uid = 0;
    }
    for (i = 0; i < TAGSTK_MAX; i++) {
        mem_buf[i].data[0] = 0;
        mem_buf[i].tagid = -1;
    }
    tagent = 0;
    lastidx = 0;
    gcount = 0;
    strcpy(tagerr, "%err%");
}

CTagStack::~CTagStack() {
}
