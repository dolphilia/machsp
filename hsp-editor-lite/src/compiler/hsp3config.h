
//
// HSP3の設定
//

#ifndef __hsp3config_h
#define __hsp3config_h

//		システム関連ラベル
//
#define HSP_TITLE "Hot Soup Processor ver."
#define hspver "3.5beta3"
#define mvscode 3        // マイナーバージョンコード
#define HSP_VERSION_CODE 0x3503    // バージョンコード

#define HSPERR_HANDLE        // HSPエラー例外を有効にします
#define SYSERR_HANDLE        // システムエラー例外を有効にします

//		移植用のラベル
//
#define JPN            // IME使用フラグ
#define HSP_JP_MESSAGE        // 日本語メッセージフラグ

//	デバッグモード機能
//
//#define HSPDEBUGLOG    // デバッグログのバージョン

// デバッグウィンドウのメッセージバッファサイズ
//
//#define dbsel_size 0x10000
//#define dbmes_size 0x10000

// 環境フラグ
// 以下のラベルはコンパイルオプションで設定されます
//
//#define HSPWIN		// Windows(WIN32) version flag
//#define HSPMAC		// Macintosh version flag
//#define HSPLINUX        // Linux(CLI) version flag
//#define HSPIOS		// iOS version flag
//#define HSPNDK		// android NDK version flag
//#define HSPDISH		// HSP3Dish flag
//#define HSPDISHGP		// HSP3Dish(HGIMG4) flag
//#define HSPEMBED		// HSP3 Embed runtime flag
//#define HSPEMSCRIPTEN	// EMSCRIPTEN version flag
//#define HSP64			// 64bit compile flag

//
//		環境フラグに付加されるオプション
//
//#define HSPWINGUI		// Windows/GUI (WIN32) version flag
//#define HSPWINDISH	// Windows/DISH (WIN32) version flag
//#define HSPLINUXGUI	// Linux(GUI) version flag

//#define HSPDEBUG	// Debug version flag

//		HSPが使用する実数型
//
//#define HSPREAL double

//		HSPが使用する64bit整数値型
//
//#ifdef HSP64
//#define HSPLPTR long
//#else
//#define HSPLPTR int
//#endif


//
//		gcc使用のチェック
//
//#if defined(HSPMAC)|defined(HSPIOS)|defined(HSPNDK)|defined(HSPLINUX)|defined(HSPEMSCRIPTEN)
//#define HSPGCC            // GCC使用フラグ
//#define HSPUTF8            // UTF8使用フラグ
//#endif

//#if defined(HSPEMSCRIPTEN)
//#define HSPRANDMT // Use std::mt19937
//#endif

//#ifdef HSPEMSCRIPTEN
//#define HSP_ALIGN_DOUBLE __attribute__ ((aligned (8)))
//#else
//#define HSP_ALIGN_DOUBLE
//#endif

//
//		移植用の定数
//
//#ifdef HSPGCC
#define HSP_PATH_LENGTH_MAX 256
//#define HSP_PATH_SEPARATOR '/'
//#endif

#endif
