//
//	hgtex.cpp header
//
#ifndef __hgtex_h
#define __hgtex_h

// テクスチャ情報
typedef struct
{
short mode;			// mode
short opt;			// option
short sx;			// x-size
short sy;			// y-size
short width;		// real x-size
short height;		// real y-size
int texid;			// OpenGL TexID(GLuint)
float ratex;		// 1/sx
float ratey;		// 1/sy
} TEXINF;

enum {
TEXMODE_NONE = 0,
TEXMODE_NORMAL,
TEXMODE_MES8,
TEXMODE_MES4,
TEXMODE_BUFFER,
TEXMODE_MAX,
};


TEXINF *GetTex( int id );
void TexInit( void );
void TexReset( void );
void TexTerm( void );
void ChangeTex( int id );
void DeleteTex( int id );
void DeleteTexInf( TEXINF *t );

void TexProc( void );

int RegistTexMem( unsigned char *ptr, int size );
int RegistTex( char *fname );
int MakeEmptyTex( int width, int height );
int MakeEmptyTexBuffer( int width, int height );

int GetCacheMesTextureID( char *msg, int font_size, int font_style );

int TexFontInit( char *path, int size );
void TexFontTerm( void );

int UpdateTexStar(int texid, int mode);
int UpdateTex32(int texid, char* srcptr, int mode);

#endif



