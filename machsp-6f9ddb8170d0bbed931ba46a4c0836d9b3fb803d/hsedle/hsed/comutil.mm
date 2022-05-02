
//
//	HSP3 COM support
//	onion software/onitama 2005/4
//

#include "hsp3config.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "comutil.h"

/*------------------------------------------------------------*/
/*
 interface
 */
/*------------------------------------------------------------*/

//        SJIS文字列 IID から IID 構造体を得る
//        (COMサポート場合は変換が必要)
int ConvertIID( COM_GUID *guid, char *name ) {
    return 0;
}
