//
//  ViewController.h
//

#import "AppDelegate.h"
#import "MyAudio.h"
#import "MyCALayer.h"
#import "MyMidi.h"
#import "MyView.h"
#import "MyWindow.h"
#import "SineWave.h"
#import "debug_message.h"
#import "hsp3config.h"
#import "hsp3struct_debug.h"
#import "hsp3struct.h"
#import <Cocoa/Cocoa.h>

#define HSP3_AXTYPE_NONE 0
#define HSP3_AXTYPE_ENCRYPT 1

@interface ViewController : NSViewController <NSTextFieldDelegate> { // NSTextFieldのデリゲートのため
@public
    AppDelegate *global;
    BOOL isInitialized;
    BOOL isSmooth; //アンチエイリアシングは有効か（初期値：無効=NO）

    //----オブジェクト関連
    //ボタン
    int myButtonIndex;                 //現在のボタンのインデックス
    unsigned short *myButtonLabel[64]; //ボタンを押した時のラベル
    NSMutableArray *myButtons;         //ボタンを格納する可変配列
    NSButton *myButton;                //ボタン

    //スライダー
    int mySliderIndex;
    unsigned short *mySliderLabel[64];
    NSMutableArray *mySliders;
    NSSlider *mySlider;

    //チェックボックス
    int myCheckBoxIndex;
    value_t *myCheckBoxPval[64];
    int myCheckBoxAptr[64];
    NSMutableArray *myCheckBoxs;
    NSButton *myCheckBox; //チェックボックス

    //テキストフィールド（インプット）
    int myTextFieldIndex;
    value_t *myTextFieldPval[64];
    int myTextFieldAptr[64];
    NSMutableArray *myTextFields;
    NSTextField *myTextField; //チェックボックス

    // MIDIのデータ受け渡し用変数
    unsigned short *myMidiEventLabel;
    value_t *myMidiEventTypePval;
    value_t *myMidiEventNumberPval;
    value_t *myMidiEventVelocityPval;
    value_t *myMidiEventChannelPval;
    int myMidiEventTypeAptr;
    int myMidiEventNumberAptr;
    int myMidiEventVelocityAptr;
    int myMidiEventChannelAptr;

    // UI関連
    NSWindow *myWindow;
    NSViewController *myViewController;
    MyView *myView;
    MyCALayer *myLayer;
    SineWave *qAudio;
    MyAudio *myAudio;
    MyMidi *myMidi;

    //----view_controller
    //共有
    value_t *mpval; // code_getで使用されたテンポラリ変 //hsp.mm hsp3gr.mm hsp3int.mm
    HSPContext *
            vc_hspctx; // vcに意味はない //ViewController.m hsp3cl.mm hsp3int.mm
    HSPContext
            abc_hspctx; // abcに意味はない //hsp.mm(111) hsp3cl.mm(24) hsp3int.mm(3)

    // hsp.mm
    int hsp_current_type_info_id; // Current type info ID
    int hsp_hspevent_opt;         // Event enable flag
    int hsp_funcres;              // 関数の戻り値型
    int hsp_srcname;
    int hsp_exflg;
    int hsp_type_tmp;
    int hsp_val_tmp;
    int hsp_reffunc_intfunc_ivalue;
    int hsp_sptr_res;
    int hsp_arrayobj_flag;
    int hsp_error_dummy; // 2.61互換のためのダミー値
    char *hsp_dirlist_target;
    short hsp_csvalue;
    double hsp_reffunc_intfunc_value;
    unsigned char *hsp_mem_di_val; // Debug VALS info ptr
    unsigned short *hsp_mcs;       // Current PC ptr
    unsigned short *hsp_mcsbak;
    value_t *hsp_plugin_pval; // プラグインに渡される変数ポインタの実態
    value_t *hsp_mpval_int; // code_getで使用されたテンポラリ変数(int用)
    hsp_extra_info_t hsp_mem_exinfo; // HSP_ExtraInfomation本体
    multi_param_module_var_data_t hsp_modvar_init;
    HSPContext *hsp_hspctx;      // Current Context
    hsp_type_info_t *hsp_hsp3tinfo; // HSP3 type info structure (strbuf)
#ifdef FLAG_HSPDEBUG
    int hsp_dbgmode;
    char *hsp_dbgbuf;
    hspdebug_t hsp_dbginfo;
#endif

    // hsp3cl.mm
    int hsp3cl_hsp_sum;
    int hsp3cl_hsp_dec;
    int hsp3cl_maxvar;
    int hsp3cl_axtype; // axファイルの設定(hsp3imp用)
    char *hsp3cl_axname;
    char *hsp3cl_axfile;

    // hsp3gr.mm
    int hsp3gr_cur_window;
    int hsp3gr_reffunc_intfunc_ivalue;
    int *hsp3gr_type;
    int *hsp3gr_val;
    HSPContext *hsp3gr_ctx;

    // hsp3int.mm
    int hsp3int_lastcr; // CR/LFで終了している
    int hsp3int_data_tmp_size;
    int hsp3int_reffunc_intfunc_ivalue;
    int *hsp3int_type;
    int *hsp3int_val;
    char hsp3int_lastcode;
    char hsp3int_nulltmp[4];
    char *hsp3int_nn; //先頭ポインタ
    char *hsp3int_lastnn;
    char *hsp3int_base;
    char *hsp3int_baseline;
    double hsp3int_reffunc_intfunc_value;
    DATA *hsp3int_data_temp;
    HSPContext *hsp3int_ctx;             // Current Context
    hsp_extra_info_t *hsp3int_exinfo; // Info for Plugins
    int hsp3int_ease_type;               //---->easing
    int hsp3int_ease_reverse;
    double hsp3int_ease_start;
    double hsp3int_ease_diff;
    double hsp3int_ease_4096;
    double hsp3int_ease_org_start;
    double hsp3int_ease_org_diff; //<----easing
}

- (void)show_alert_dialog:(NSString *)message;

- (NSException *)make_nsexception:(int)hsp_error_type;

- (void)sliderEvent:(id)sender;

@end
