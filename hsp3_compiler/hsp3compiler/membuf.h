//@
//
//	membuf.cpp structures
//
#ifndef __membuf_h
#define __membuf_h
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
//  growmem class
/*
	rev 53
	mingw : warning : クラスは仮想関数を持つのに仮想デストラクタでない。
	に対処。
 */
@interface CMemBuf : NSObject {
    //        Data
    //
    int        limit_size;            // Separate size
    int        size;                // Main Buffer Size
    int        cur;                // Current Size
    char    *mem_buf;            // Main Buffer
    int        idxflag;            // index Mode Flag
    int        *idxbuf;            // Index Buffer
    int        idxmax;                // Index Buffer Max
    int        curidx;                // Current Index
    char    name[256];            // File Name
}
//CMemBuf();
//CMemBuf( int sz );
//virtual ~CMemBuf();
-(void)AddIndexBuffer;
-(void)AddIndexBuffer:(int)sz;
-(char*)GetBuffer;
-(int)GetBufferSize;
-(int*)GetIndexBuffer;
-(void)SetIndex:(int)idx val:(int)val;
-(int)GetIndex:(int)idx;
-(int)GetIndexBufferSize;
-(int)SearchIndexValue:(int)val;
-(void)RegistIndex:(int)val;
-(void)Index;
-(void)Put_int:(int)data;
-(void)Put_short:(short)data;
-(void)Put_char:(char)data;
-(void)Put_uchar:(unsigned char)data;
-(void)Put_float:(float)data;
-(void)Put_double:(double)data;
-(void)PutStr:(char*)data;
-(void)PutStrDQ:(char*)data;
-(void)PutStrBlock:(char*)data;
-(void)PutCR;
-(void)PutData:(void*)data sz:(int)sz;
-(void)PutStrf:(char*)format, ...;
//-(void)PutStrf_file:(char*)format, (char*)fname;
-(int)PutFile:(char*)fname;
-(int)SaveFile:(char*)fname;
-(char*)GetFileName;
-(int)GetSize; //{ return cur; }
-(void)ReduceSize:(int)new_cur;
-(char*)PreparePtr:(int)sz;
//private:
-(void)InitMemBuf:(int)sz;
-(void)InitIndexBuf:(int)sz;
@end
#endif
