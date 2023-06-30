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
void hspvar_core_init(void);
void hspvar_core_bye(void);
void hspvar_core_reset_var_type(int expand);
int hspvar_core_add_type();
void hspvar_core_register_type(int flag, char *vartype_name);
hspvar_proc_t *hspvar_core_seek_proc(const char *name);

// 低レベルサポート関数
void HspVarCoreDup(value_t *pval, value_t *arg, int aptr);
void HspVarCoreDupPtr(value_t *pval, int flag, void *ptr, int size);
void HspVarCoreClear(value_t *pval, int flag);
void HspVarCoreClearTemp(value_t *pval, int flag);
void HspVarCoreDim(value_t *pval, int flag, int len1, int len2, int len3, int len4);
void HspVarCoreDimFlex(value_t *pval, int flag, int len0, int len1, int len2, int len3, int len4);
void HspVarCoreReDim(value_t *pval, int lenid, int len);
void *HspVarCoreCnvPtr(value_t *pval, int flag);
void *HspVarCorePtrAPTR(value_t *pv, int ofs);
void HspVarCoreArray(value_t *pval, int offset);
void *HspVarCorePtrAPTR(value_t *pv, int ofs);

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
