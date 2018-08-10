
//
//	HSP3 debug support
//	(エラー処理およびデバッグ支援)
//	onion software/onitama 2004/6
//

#import <stdio.h>
#import <stdlib.h>
#import <string.h>
#import "hsp3config.h"
#import "hsp3debug.h"
#import "debug_message.h"
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@implementation ViewController (hsp3debug)

/*------------------------------------------------------------*/
/*
 system data
 */
/*------------------------------------------------------------*/


/*------------------------------------------------------------*/
/*
 interface
 */
/*------------------------------------------------------------*/

#ifdef FLAG_HSPDEBUG
static char *error_message[] = {
    (char *)"",												// 0
    (char *)"システムエラーが発生しました",					// 1
    (char *)"文法が間違っています",							// 2
    (char *)"パラメータの値が異常です",						// 3
    (char *)"計算式でエラーが発生しました",					// 4
    (char *)"パラメータの省略はできません",					// 5
    (char *)"パラメータの型が違います",						// 6
    (char *)"配列の要素が無効です",							// 7
    (char *)"有効なラベルが指定されていません",				// 8
    (char *)"サブルーチンやループのネストが深すぎます",		// 9
    (char *)"サブルーチン外のreturnは無効です",				// 10
    (char *)"repeat外でのloopは無効です",					// 11
    (char *)"ファイルが見つからないか無効な名前です",		// 12
    (char *)"画像ファイルがありません",						// 13
    (char *)"外部ファイル呼び出し中のエラーです",			// 14
    (char *)"計算式でカッコの記述が違います",				// 15
    (char *)"パラメータの数が多すぎます",					// 16
    (char *)"文字列式で扱える文字数を越えました",			// 17
    (char *)"代入できない変数名を指定しています",			// 18
    (char *)"0で除算しました",								// 19
    (char *)"バッファオーバーフローが発生しました",			// 20
    (char *)"サポートされない機能を選択しました",			// 21
    (char *)"計算式のカッコが深すぎます",					// 22
    (char *)"変数名が指定されていません",					// 23
    (char *)"整数以外が指定されています",					// 24
    (char *)"配列の要素書式が間違っています",				// 25
    (char *)"メモリの確保ができませんでした",				// 26
    (char *)"タイプの初期化に失敗しました",					// 27
    (char *)"関数に引数が設定されていません",				// 28
    (char *)"スタック領域のオーバーフローです",				// 29
    (char *)"無効な名前がパラメーターに指定されています",	// 30
    (char *)"異なる型を持つ配列変数に代入しました",			// 31
    (char *)"関数のパラメーター記述が不正です",				// 32
    (char *)"オブジェクト数が多すぎます",					// 33
    (char *)"配列・関数として使用できない型です",			// 34
    (char *)"モジュール変数が指定されていません",			// 35
    (char *)"モジュール変数の指定が無効です",				// 36
    (char *)"変数型の変換に失敗しました",					// 37
    (char *)"外部DLLの呼び出しに失敗しました",				// 38
    (char *)"外部オブジェクトの呼び出しに失敗しました",		// 39
    (char *)"関数の戻り値が設定されていません。",			// 40
    (char *)"関数を命令として記述しています。\n(HSP2から関数化された名前を使用している可能性があります)",			// 41
    (char *)"*"
};

static char errmsg[256];

char *
hspd_geterror( HSPERROR error )
{
    DEBUG_IN;
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"内部エラーが発生しました"];
    NSString* nsstr_error_message = [NSString stringWithCString:error_message[(int)error] encoding:NSUTF8StringEncoding];
    [alert setInformativeText:nsstr_error_message];
    [alert addButtonWithTitle:@"OK"];
    [alert runModal];
    sprintf( errmsg, "内部エラーが発生しました(%d)", (int)error );
    DEBUG_OUT;
    return errmsg;
}
#else
static char errmsg[256];

char *
hspd_geterror( HSPERROR error )
{
    DEBUG_IN;
    sprintf( errmsg, "内部エラーが発生しました(%d)", (int)error );
    DEBUG_OUT;
    return errmsg;
}
#endif

@end
