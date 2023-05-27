
//
//	membuf.cpp structures
//
#ifndef __membuf_h
#define __membuf_h

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <assert.h>

//  メモリ生成クラス
//
class CMemBuf {
public:
    CMemBuf();
    CMemBuf( int sz );
    virtual ~CMemBuf();
    void AddIndexBuffer( void );
    void AddIndexBuffer( int sz );
    
    char *GetBuffer( void );
    int GetBufferSize( void );
    int *GetIndexBuffer( void );
    void SetIndex( int idx, int val );
    int GetIndex( int idx );
    int GetIndexBufferSize( void );
    int SearchIndexValue( int val );
    
    void RegistIndex( int val );
    void Index( void );
    void Put( int data );
    void Put( short data );
    void Put( char data );
    void Put( unsigned char data );
    void Put( float data );
    void Put( double data );
    void PutStr( char *data );
    void PutStrDQ( char *data );
    void PutStrBlock( char *data );
    void PutCR( void );
    void PutData( void *data, int sz );
    void PutStrf( char *format, ... );
    int PutFile( char *fname );
    int SaveFile( char *fname );
    char *GetFileName( void );
    int GetSize( void ) { return cur; }
    void ReduceSize( int new_cur );
    char *PreparePtr( int sz );
    
private:
    virtual void InitMemBuf( int sz );
    virtual void InitIndexBuf( int sz );
    
    // データ
    //
    int		limit_size;			// セパレートサイズ
    int		size;				// メインバッファサイズ
    int		cur;				// 現在のサイズ
    char	*mem_buf;			// メインバッファ
    
    int		idxflag;			// インデックスモードフラグ
    int		*idxbuf;			// インデックスバッファ
    int		idxmax;				// インデックスバッファの最大値
    int		curidx;				// 現在のインデックス
    
    char	name[256];			// ファイル名
};


#endif