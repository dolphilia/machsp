//
//  hspvar_core.h
//

#ifndef hspvar_core_h
#define hspvar_core_h

#import "hsp3struct_var.h"

//	typefunc
//	基本タイプ HSPVAR_FLAG_STR 〜 HSPVAR_FLAG_DOUBLE
//	拡張タイプ HSPVAR_FLAG_USERDEF 以降
//	式の評価でpval->ptを参照するため、常に配列0のポイントはpval->ptが指し示す必要がある。

// コアシステムメイン関数
void HspVarCoreInit(void);
void HspVarCoreBye(void);
void HspVarCoreResetVartype(int expand);
int HspVarCoreAddType();
void HspVarCoreRegisterType(int flag, char *vartype_name);
HspVarProc *HspVarCoreSeekProc(const char *name);

// 低レベルサポート関数
void HspVarCoreDup(PVal *pval, PVal *arg, APTR aptr);
void HspVarCoreDupPtr(PVal *pval, int flag, void *ptr, int size);
void HspVarCoreClear(PVal *pval, int flag);
void HspVarCoreClearTemp(PVal *pval, int flag);
void HspVarCoreDim(PVal *pval, int flag, int len1, int len2, int len3, int len4);
void HspVarCoreDimFlex(PVal *pval, int flag, int len0, int len1, int len2, int len3, int len4);
void HspVarCoreReDim(PVal *pval, int lenid, int len);
void *HspVarCoreCnvPtr(PVal *pval, int flag);
PDAT *HspVarCorePtrAPTR(PVal *pv, APTR ofs);
void HspVarCoreArray(PVal *pval, int offset);
PDAT *HspVarCorePtrAPTR(PVal *pv, APTR ofs);

// PVal用マクロ
#define HspVarCoreGetProc(flag) (&hspvarproc[flag])
#define HspVarCoreReset(pv) ((pv)->offset = 0, (pv)->arraycnt = 0)
#define HspVarCoreGetAPTR(pv) ((pv)->offset)
#define HspVarCoreCopyArrayInfo(pv, src)                                       \
(pv)->arraycnt = (src)->arraycnt;                                            \
(pv)->offset = (src)->offset;                                                \
(pv)->arraymul = (src)->arraymul;
//#define HspVarCoreDispose( pv ) hspvarproc[(pv)->flag].Free(pv)
//#define HspVarCorePtr( pv ) (hspvarproc[(pv)->flag].GetPtr(pv))
//#define HspVarCoreArrayObject( pv,in )
//(hspvarproc[(pv)->flag].ArrayObject(pv,in))	//
//配列の要素を指定する(最初にResetを呼んでおくこと)
//#define HspVarCoreSet( pv,in ) hspvarproc[(pv)->flag].Set( pv, in )
//#define HspVarCoreCnv( in1,in2,in3 ) hspvarproc[in2].Cnv( in3,in1 )
//// in1->in2の型にin3ポインタを変換する
//#define HspVarCoreGetBlockSize( pv,in1,out )
//hspvarproc[(pv)->flag].GetBlockSize( pv,in1,out )
//#define HspVarCoreAllocBlock( pv,in1,in2 ) hspvarproc[(pv)->flag].AllocBlock(
//pv,in1,in2 )
//#define HspVarCoreGetUsing( pv,in1 ) hspvarproc[(pv)->flag].GetUsing( in1 )


#endif /* hspvar_core_h */
