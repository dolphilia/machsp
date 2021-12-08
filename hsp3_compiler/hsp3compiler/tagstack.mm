//@
//
//		stack buffer with tag class
//			onion software/onitama 2002/10
//
#import <stdio.h>
#import <stdlib.h>
#import <string.h>
#import "tagstack.h"

@implementation CTagStack : NSObject

- (instancetype)init {
    self = [super init];
    if (self) {
        int i;
        for(i = 0; i < TAGSTK_TAGMAX; i++) {
            mem_tag[i].name[0] = 0;
            mem_tag[i].uid = 0;
        }
        for(i = 0; i < TAGSTK_MAX; i++) {
            mem_buf[i].data[0] = 0;
            mem_buf[i].tagid = -1;
        }
        tagent = 0;
        lastidx = 0;
        gcount = 0;
        strcpy(tagerr, "%err%");
    }
    return self;
}

- (void)dealloc {
}

//    文字列比較 (0=not same/-1=same)
//  (大文字小文字の区別)
-(int)StrCmp:(char*)str1 str2:(char*)str2 {
    int ap;
    char as;
    ap = 0;
    while(1) {
        as = str1[ap];
        if (as != str2[ap])
            return 0;
        if (as == 0)
            break;
        ap++;
    }
    return -1;
}

-(int)SearchTagID:(char*)tag {
    int i;
    if (tagent == 0)
        return -1;
    for(i = 0; i < tagent; i++) {
        if ([self StrCmp:mem_tag[i].name str2:tag])
            return i;
    }
    return -1;
}

-(int)RegistTagID:(char*)tag {
    int i, len;
    if (tagent >= TAGSTK_TAGMAX)
        return -1;
    i = tagent;
    tagent++;
    len = (int)strlen( tag );
    if (len >= TAGSTK_TAGSIZE)
        tag[TAGSTK_TAGSIZE - 1] = 0;
    strcpy(mem_tag[i].name, tag);
    return i;
}

-(void)GetTagUniqueName:(int)tagid outname:(char*)outname {
    TAGINF *t;
    if ((tagid < 0 ) || ( tagid >= TAGSTK_TAGMAX)) {
        sprintf(outname, "TagErr%04x", gcount++);
    } else {
        t = &mem_tag[tagid];
        sprintf(outname,"_%s_%04x", t->name, t->uid++);
    }
}

-(int)GetTagID:(char*)tag {
    int i;
    i = [self SearchTagID:tag];
    if (i < 0) {
        i = [self RegistTagID:tag];
    }
    return i;
}

-(char*)GetTagName:(int)tagid {
    if ((tagid < 0) || (tagid >= TAGSTK_TAGMAX))
        return tagerr;
    return mem_tag[tagid].name;
}

-(int)StackCheck:(char*)res {
    int i, n;
    TAGDATA *t;
    strcpy (res, "\t");
    for(i = 0; i < TAGSTK_TAGMAX; i++) {
        mem_tag[i].check = 0;
    }
    if (lastidx < 1 )
        return 0;
    i = lastidx;
    while(1) {
        i--;
        if (i < 0)
            break;
        t = &mem_buf[i];
        if (t->tagid >= 0 )
            mem_tag[t->tagid].check = -1;
    }
    n = 0;
    for(i = 0; i < TAGSTK_TAGMAX; i++) {
        if (mem_tag[i].check) {
            if (n)
                strcat(res, ", ");
            strcat(res, mem_tag[i].name);
            n++;
        }
    }
    return n;
}

-(int)PushTag:(int)tagid str:(char*)str {
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
    len = (int)strlen( str );
    if (len >= TAGSTK_SIZE)
        str[TAGSTK_SIZE - 1] = 0;
    strcpy(t->data, str);
    return i;
}

-(char*)PopTag:(int)tagid {
    int i;
    TAGDATA *t;
    char *p;
    if ((tagid < 0) || (tagid >= TAGSTK_TAGMAX))
        return NULL;
    if (lastidx < 1)
        return NULL;
    i = lastidx;
    while(1) {							// ÉXÉ^ÉbÉNÇíHÇÈ
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
    while(1) {
        if (i < 0)
            break;
        if (mem_buf[i].tagid != -1)
            break;
        lastidx = i;
        i--;
    }
    return p;
}

-(char*)LookupTag:(int)tagid level:(int)level {
    int i, lv;
    TAGDATA *t;
    if ((tagid < 0) || (tagid >= TAGSTK_TAGMAX))
        return NULL;
    if (lastidx < 1 )
        return NULL;
    lv = level;
    i = lastidx;
    while(1) {							// ÉXÉ^ÉbÉNÇíHÇÈ
        i--;
        if (i < 0 )
            return NULL;
        t = &mem_buf[i];
        if (t->tagid == tagid) {
            if (lv == 0 )
                break;
            lv--;
        }
    }
    return t->data;
}

@end
