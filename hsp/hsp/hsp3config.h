//
//		Configure for HSP3
//
#ifndef __hsp3config_h
#define __hsp3config_h

// システム関連ラベル
#define HSP_VERSION "3.5beta3"
#define MINOR_VERSION_CODE 3       // マイナーバージョンコード
#define VERSION_CODE 0x3503        // バージョンコード
#define HSP_MAX_PATH 256

//コンパイルフラグ
#define FLAG_HSP_ERROR_HANDLE      // HSPエラー例外を有効にします
#define FLAG_SYSTEM_ERROR_HANDLE   // システムエラー例外を有効にします
#define FLAG_HSPDEBUG              // デバッグバージョンフラグ

#endif
