
//	strnote.cpp functions
#ifndef __strnote_h
#define __strnote_h
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
@interface CStrNote : NSObject {
    char *base;
    int lastcr;
    char *nn;
    char *lastnn;
    char lastcode;
    char nulltmp[4];
}
-(void)Select:(char*)str;
-(int)GetSize;
-(char*)GetStr;
-(int)GetMaxLine;
-(int)GetLine:(char*)nres line:(int)line;
-(int)GetLine:(char*)nres line:(int)line max:(int)max;
-(int)PutLine:(char*)nstr line:(int)line ovr:(int)ovr;
-(char*)GetLineDirect:(int)line;
-(void)ResumeLineDirect;
//private:
-(int)nnget:(char*)nbase line:(int)line;
@end
#endif
