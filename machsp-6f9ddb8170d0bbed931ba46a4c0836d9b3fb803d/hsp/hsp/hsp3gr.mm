//
//	HSP3 graphics command
//	(GUI関連コマンド・関数処理)
//	onion software/onitama 2004/6
//

#import "hsp3gr.h"
#import "hspvar_double.h"
#import "hspvar_int.h"
#import "hspvar_label.h"
#import "hspvar_str.h"
#import "hspvar_struct.h"
#import "utility_string.h"

@implementation ViewController (hsp3gr)

//----hsp system support

/// dirinfo命令の内容をstmpに設定する
///
- (char *)getdir:(int)id {
    char *p = hsp3gr_ctx->stmp;
    *p = 0;

    switch (id) {
        case 0: // カレント(現在の)ディレクトリ
            p = (char *)[global.current_directory_path UTF8String];
            break;
        case 1: // HSPの実行ファイルがあるディレクトリ
            p = (char *)[[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent] UTF8String];
            break;
        case 2: // Homeディレクトリ
            p = (char *)[NSHomeDirectory() UTF8String];
            break;
        case 3: // Desktopディレクトリ
            p = (char *)[[NSHomeDirectory() stringByAppendingString:@"/Desktop"] UTF8String];
            break;
        case 4: // Documentsディレクトリ
            p = (char *)[[NSHomeDirectory() stringByAppendingString:@"/Documents"] UTF8String];
            break;
        case 5:
            break;
        case 6:
            break;
        case 7:
            break;
        case 8:
            break;
        default:
            @throw [self make_nsexception:HSPERR_ILLEGAL_FUNCTION];
    }
    return p;
}

/// System strings get
///
- (int)sysinfo:(int)p2 {
    int f = HSPVAR_FLAG_INT;
    char *p = hsp3gr_ctx->stmp;
    *p = 0;
    return f;
}

- (void *)ex_getbmscr:(int)wid {
    return NULL;
}

- (void)ex_mref:(PVal *)pval prm:(int)prm {
    int t = HSPVAR_FLAG_INT;
    int size = 4;
    void *ptr;
    const int GETBM = 0x60;
    if (prm >= GETBM) {
        @throw [self make_nsexception:HSPERR_UNSUPPORTED_FUNCTION];
    } else {
        switch (prm) {
            case 0x40:
                ptr = &hsp3gr_ctx->stat;
                break;
            case 0x41:
                ptr = hsp3gr_ctx->refstr;
                t = HSPVAR_FLAG_STR;
                size = 1024;
                break;
            case 0x44: {
                ptr = hsp3gr_ctx;
                size = sizeof(HSPContext);
                break;
            }
            default: {
                @throw [self make_nsexception:HSPERR_UNSUPPORTED_FUNCTION];
            }
        }
    }
    HspVarCoreDupPtr(pval, t, ptr, size);
}

//------------------------------------------------------------
// interface
//------------------------------------------------------------

/// cmdfunc : TYPE_EXTCMD
/// (内蔵GUIコマンド)
///
- (int)cmdfunc_extcmd:(int)cmd {
    [self code_next];  // 次のコードを取得(最初に必ず必要です)
    switch (cmd) {  // サブコマンドごとの分岐
        case 0x00:
            [self cmdfunc_button];
            break;  // button
        case 0x01:
            [self cmdfunc_chgdisp];
            break;  // chgdisp
        case 0x02:
            [self cmdfunc_exec];
            break;  // exec
        case 0x03:
            [self cmdfunc_dialog];
            break;  // dialog
        case 0x08:
            [self cmdfunc_mmload];
            break;  // mmload
        case 0x09:
            [self cmdfunc_mmplay];
            break;  // mmplay
        case 0x0a:
            [self cmdfunc_mmstop];
            break;  // mmstop
        case 0x0b:
            [self cmdfunc_mci];
            break;  // mci
        case 0x0c:
            [self cmdfunc_pset];
            break;  // pset
        case 0x0d:
            [self cmdfunc_pget];
            break;  // pget
        case 0x0e:
            [self cmdfunc_syscolor];
            break;  // syscolor
        case 0x0f:
            [self cmdfunc_mes];
            break;  // mes,print
        case 0x10:
            [self cmdfunc_title];
            break;  // title
        case 0x11:
            [self cmdfunc_pos];
            break;  // pos
        case 0x12:
            [self cmdfunc_circle];
            break;  // circle
        case 0x13:
            [self cmdfunc_cls];
            break;  // cls
        case 0x14:
            [self cmdfunc_font];
            break;  // font
        case 0x15:
            [self cmdfunc_sysfont];
            break;  // sysfont
        case 0x16:
            [self cmdfunc_objsize];
            break;  // objsize
        case 0x17:
            [self cmdfunc_picload];
            break;  // picload
        case 0x18:
            [self cmdfunc_color];
            break;  // color
        case 0x19:
            [self cmdfunc_palcolor];
            break;  // palcolor
        case 0x1a:
            [self cmdfunc_palette];
            break;  // palette
        case 0x1b:
            [self cmdfunc_redraw];
            break;  // redraw
        case 0x1c:
            [self cmdfunc_width];
            break;  // width
        case 0x1d:
            [self cmdfunc_gsel];
            break;  // gsel
        case 0x1e:
            [self cmdfunc_gcopy];
            break;  // gcopy
        case 0x1f:
            [self cmdfunc_gzoom];
            break;  // gzoom
        case 0x20:
            [self cmdfunc_gmode];
            break;  // gmode
        case 0x21:
            [self cmdfunc_bmpsave];
            break;  // bmpsave
        case 0x22:
            [self cmdfunc_hsvcolor];
            break;  // hsvcolor
        case 0x23:
            [self cmdfunc_getkey];
            break;  // getkey
        case 0x25:
            [self cmdfunc_chkbox];
            break;  // chkbox
        case 0x24:
            [self cmdfunc_listbox];
            break;  // listbox
        case 0x26:
            [self cmdfunc_combox];
            break;  // combox
        case 0x27:
            [self cmdfunc_input];
            break;  // input (console)
        case 0x28:
            [self cmdfunc_mesbox];
            break;  // mesbox
        case 0x29:
            [self cmdfunc_buffer];
            break;  // buffer
        case 0x2a:
            [self cmdfunc_screen];
            break;  // screen
        case 0x2b:
            [self cmdfunc_bgscr];
            break;  // bgscr
        case 0x2c:
            [self cmdfunc_mouse];
            break;  // mouse
        case 0x2d:
            [self cmdfunc_objsel];
            break;  // objsel
        case 0x2e:
            [self cmdfunc_groll];
            break;  // groll
        case 0x2f:
            [self cmdfunc_line];
            break;  // line
        case 0x30:
            [self cmdfunc_clrobj];
            break;  // clrobj
        case 0x31:
            [self cmdfunc_boxf];
            break;  // boxf
        case 0x32:
            [self cmdfunc_objprm];
            break;  // objprm
        case 0x33:
            [self cmdfunc_objmode];
            break;  // objmode (ver2.5 enhanced )
        case 0x34:
            [self cmdfunc_stick];
            break;  // stick
        case 0x35:
            [self cmdfunc_grect];
            break;  // grect
        case 0x36:
            [self cmdfunc_grotate];
            break;  // grotate
        case 0x37:
            [self cmdfunc_gsquare];
            break;  // gsquare
        case 0x38:
            [self cmdfunc_gradf];
            break;  // gradf
        case 0x39:
            [self cmdfunc_objimage];
            break;  // objimage
        case 0x3a:
            [self cmdfunc_objskip];
            break;  // objskip
        case 0x3b:
            [self cmdfunc_objenable];
            break;  // objenable
        case 0x3c:
            [self cmdfunc_celload];
            break;  // celload
        case 0x3d:
            [self cmdfunc_celdiv];
            break;  // celdiv
        case 0x3e:
            [self cmdfunc_celput];
            break;  // celput
        case 0x3f:
            [self cmdfunc_gfilter];
            break;  // gfilter
        case 0x40:
            [self cmdfunc_setreq];
            break;  // setreq
        case 0x41:
            [self cmdfunc_getreq];
            break;  // getreq
        case 0x42:
            [self cmdfunc_mmvol];
            break;  // mmvol
        case 0x43:
            [self cmdfunc_mmpan];
            break;  // mmpan
        case 0x44:
            [self cmdfunc_mmstat];
            break;  // mmstat
        case 0x45:
            [self cmdfunc_mtlist];
            break;  // mtlist
        case 0x46:
            [self cmdfunc_mtinfo];
            break;  // mtinfo
        case 0x47:
            [self cmdfunc_devinfo];
            break;  // devinfo
        case 0x48:
            [self cmdfunc_devinfoi];
            break;  // devinfoi
        case 0x49:
            [self cmdfunc_devprm];
            break;  // devprm
        case 0x4a:
            [self cmdfunc_devcontrol];
            break;  // devcontrol
        case 0x90:
            break;  //>>>mac版拡張
        case 0x91:
            [self cmdfunc_qins];
            break;  // qins //音声関連
        case 0x92:
            [self cmdfunc_qpush];
            break;  // qpush
        case 0x93:
            [self cmdfunc_qstart];
            break;  // qstart
        case 0x94:
            [self cmdfunc_qend];
            break;  // qend
        case 0x95:
            [self cmdfunc_qplay];
            break;  // qplay
        case 0x96:
            [self cmdfunc_qstop];
            break;  // qstop
        case 0x97:
            [self cmdfunc_qvol];
            break;  // qvol
        case 0x98:
            break;
        case 0xa0:
            [self cmdfunc_slider];
            break;  // slider //オブジェクト関連
        case 0xa1:
            [self cmdfunc_onmidi];
            break;  // onmidi
        case 0xb0:
            [self cmdfunc_box];
            break;  // box
        case 0xc0:
            [self cmdfunc_antialiasing];
            break;  // antialiasing
        case 0xc1:
            [self cmdfunc_smooth];
            break;  // smooth //描画関連
        case 0xd0:
            [self cmdfunc_setcam];
            break;  // setcam //3D関連 //<<<mac版拡張
        default: {
             @throw [self make_nsexception:HSPERR_UNSUPPORTED_FUNCTION];
        }
    }
    return RUNMODE_RUN;
}

- (void)cmdfunc_button {
    char *ps = [self code_gets];
    unsigned short *sbr = [self code_getlb];
    [self code_next];
    int posx = [myLayer get_current_point_x];
    int posy = [myLayer get_current_point_y];
    [[myButtons objectAtIndex:myButtonIndex] setFrameOrigin:NSMakePoint(posx, myLayer->buf_height[myLayer->buf_index] - posy - 32)];
    [[myButtons objectAtIndex:myButtonIndex] setTitle:[NSString stringWithCString:ps encoding:NSUTF8StringEncoding]];
    myButtonLabel[myButtonIndex] = sbr;  //ラベルを設定する
    hsp3gr_ctx->stat = myButtonIndex;    //ボタンのIDを返す
    [myLayer set_current_point:posx point_y:posy + 32];  //カレントポジションのyをずらす
    myButtonIndex++;  //ボタンのインデックスを次に
    if (myButtonIndex >= 64) {
        myButtonIndex = 64;
    }
}

- (void)cmdfunc_chgdisp {
    [self show_alert_dialog:@"chgdisp命令は未実装です"];
}

- (void)cmdfunc_exec {
    [self show_alert_dialog:@"exec命令は未実装です"];
    // char *ps;
    // char fname[HSP_MAX_PATH];
    // strncpy( fname, [self code_gets], HSP_MAX_PATH-1 );
    // p1 = [self code_getdi:0];
    // ps = [self code_getds:""];
    // ExecFile( fname, ps, p1 );
}

- (void)cmdfunc_dialog {
    char *message_string = [self code_gets];
    int alert_style = [self code_getdi:0];
    char *title_string = [self code_getds:""];
    NSString *ns_message_string = [NSString stringWithCString:message_string encoding:NSUTF8StringEncoding];
    NSString *ns_title_string = [NSString stringWithCString:title_string encoding:NSUTF8StringEncoding];
    NSAlert *alert = [[NSAlert alloc] init];
    
    [alert setMessageText:ns_title_string];
    [alert setInformativeText:ns_message_string];
    hsp3gr_ctx->stat = 0;
    
    switch (alert_style) {
        case 0: {
            [alert setAlertStyle:NSAlertStyleInformational];
            [alert addButtonWithTitle:@"OK"];
            NSModalResponse returnCode = [alert runModal];
            if (returnCode == NSAlertFirstButtonReturn) {
                hsp3gr_ctx->stat = 1;
            }
            break;
        }
        case 1: {
            [alert setAlertStyle:NSAlertStyleWarning];
            [alert addButtonWithTitle:@"OK"];
            NSModalResponse returnCode = [alert runModal];
            if (returnCode == NSAlertFirstButtonReturn) {
                hsp3gr_ctx->stat = 1;
            }
            break;
        }
        case 2: {
            [alert setAlertStyle:NSAlertStyleInformational];
            [alert addButtonWithTitle:@"OK"];
            [alert addButtonWithTitle:@"キャンセル"];
            NSModalResponse returnCode = [alert runModal];
            if (returnCode == NSAlertFirstButtonReturn) {
                hsp3gr_ctx->stat = 6;
            } else {
                hsp3gr_ctx->stat = 7;
            }
            break;
        }
        case 3: {
            [alert setAlertStyle:NSAlertStyleWarning];
            [alert addButtonWithTitle:@"OK"];
            [alert addButtonWithTitle:@"キャンセル"];
            NSModalResponse returnCode = [alert runModal];
            if (returnCode == NSAlertFirstButtonReturn) {
                hsp3gr_ctx->stat = 6;
            } else {
                hsp3gr_ctx->stat = 7;
            }
            break;
        }
        default:
            [self show_alert_dialog:@"dialog命令のタイプ設定0〜3以外は未実装です"];
            break;
    }
}

- (void)cmdfunc_mmload {
    char *p1 = [self code_gets];
    int p2 = [self code_getdi:0];
    [self code_getdi:0];
    [myAudio loadWithFilename:[NSString stringWithCString:p1 encoding:NSUTF8StringEncoding] index:p2];
}

- (void)cmdfunc_mmplay {
    int p1 = [self code_getdi:0];
    [myAudio play:p1];
}

- (void)cmdfunc_mmstop {
    int p1 = [self code_getdi:-1];
    [myAudio stop:p1];
}

- (void)cmdfunc_mci {
    [self show_alert_dialog:@"mci命令は未実装です"];
}

- (void)cmdfunc_pset {
    int p1 = [self code_getdi:0];        // X座標
    int p2 = [self code_getdi:0];        // Y座標
    int p3 = [self code_getdi:INT_MIN];  // X座標
    if (p3 == INT_MIN) {                 //初期値であれば
        [myLayer set_pixel_rgba:p1 point_y:p2];
    } else {
        [myLayer d3pset:p1 y:p2 z:p3];
    }
}

- (void)cmdfunc_pget {
    int p1 = [self code_getdi:INT_MIN];  // X座標
    int p2 = [self code_getdi:INT_MIN];  // Y座標
    if (p1 == INT_MIN && p2 == INT_MIN) {
        [myLayer get_pixel_color:[myLayer get_current_point_x]
                         point_y:[myLayer get_current_point_y]];
    } else {
        [myLayer get_pixel_color:p1 point_y:p2];
    }
}

- (void)cmdfunc_syscolor {
    int p1 = [self code_geti];  //設定するシステムカラーインデックス
    NSColor *color = [[NSColor alloc] init];
    switch (p1) {
        case 0:
            color = [NSColor alternateSelectedControlColor];
            break;
        case 1:
            color = [NSColor alternateSelectedControlTextColor];
            break;
        case 2:
            color = [NSColor colorForControlTint:[NSColor currentControlTint]];
            break;
        case 3:
            color = [NSColor controlBackgroundColor];
            break;
        case 4:
            color = [NSColor controlColor];
            break;
        case 5:
            color = [NSColor controlAlternatingRowBackgroundColors][1];
            break;
        case 6:
            color = [NSColor controlHighlightColor];
            break;
        case 7:
            color = [NSColor controlLightHighlightColor];
            break;
        case 8:
            color = [NSColor controlShadowColor];
            break;
        case 9:
            color = [NSColor controlDarkShadowColor];
            break;
        case 10:
            color = [NSColor controlTextColor];
            break;
        case 11:
            color = [NSColor disabledControlTextColor];
            break;
        case 12:
            color = [NSColor gridColor];
            break;
        case 13:
            color = [NSColor headerColor];
            break;
        case 14:
            color = [NSColor headerTextColor];
            break;
        case 15:
            color = [NSColor highlightColor];
            break;
        case 16:
            color = [NSColor keyboardFocusIndicatorColor];
            break;
        case 17:
            color = [NSColor knobColor];
            break;
        case 18:
            color = [NSColor scrollBarColor];
            break;
        case 19:
            color = [NSColor secondarySelectedControlColor];
            break;
        case 20:
            color = [NSColor selectedControlColor];
            break;
        case 21:
            color = [NSColor selectedControlTextColor];
            break;
        case 22:
            color = [NSColor selectedMenuItemColor];
            break;
        case 23:
            color = [NSColor selectedMenuItemTextColor];
            break;
        case 24:
            color = [NSColor selectedTextBackgroundColor];
            break;
        case 25:
            color = [NSColor selectedTextColor];
            break;
        case 26:
            color = [NSColor selectedKnobColor];
            break;
        case 27:
            color = [NSColor shadowColor];
            break;
        case 28:
            color = [NSColor textBackgroundColor];
            break;
        case 29:
            color = [NSColor textColor];
            break;
        case 30:
            color = [NSColor windowBackgroundColor];
            break;
        case 31:
            color = [NSColor windowFrameColor];
            break;
        case 32:
            color = [NSColor windowFrameTextColor];
            break;
        case 33:
            color = [NSColor underPageBackgroundColor];
            break;
        case 34:
            color = [NSColor labelColor];
            break;
        case 35:
            color = [NSColor secondaryLabelColor];
            break;
        case 36:
            color = [NSColor tertiaryLabelColor];
            break;
        case 37:
            color = [NSColor quaternaryLabelColor];
            break;
    }
    color = [color colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]];
    int r = (int)(color.redComponent * 255.0);
    int g = (int)(color.greenComponent * 255.0);
    int b = (int)(color.blueComponent * 255.0);
    [myLayer set_color_rgba:r green:g blue:b alpha:255];
}

- (void)cmdfunc_mes {
    char *ptr;
    int chk = [self code_get];
    if (chk <= PARAM_END) {
        printf("\n");
        return;
    }
    PDAT *dst;
    if (strcmp(hspvarproc[(mpval)->flag].vartype_name, "int") == 0) {  //整数のFree
        dst = HspVarInt_GetPtr(mpval);
    } else if (strcmp(hspvarproc[(mpval)->flag].vartype_name, "double") == 0) {  //実数のFree
        dst = HspVarDouble_GetPtr(mpval);
    } else if (strcmp(hspvarproc[(mpval)->flag].vartype_name, "str") == 0) {  //文字列のFree
        dst = HspVarStr_GetPtr(mpval);
    } else if (strcmp(hspvarproc[(mpval)->flag].vartype_name, "label") == 0) {  //ラベルのFree
        dst = HspVarLabel_GetPtr(mpval);
    } else if (strcmp(hspvarproc[(mpval)->flag].vartype_name, "struct") == 0) {  // structのFree
        dst = HspVarLabel_GetPtr(mpval);
    } else {
        @throw [self make_nsexception:HSPERR_SYNTAX];
    }
    ptr = (char *)dst;  //(HspVarCorePtr(mpval));
    if (mpval->flag != HSPVAR_FLAG_STR) {
        if (strcmp(hspvarproc[HSPVAR_FLAG_STR].vartype_name, "int") == 0) {  //整数のCnv
            ptr = (char *)HspVarInt_Cnv(ptr, mpval->flag);
        } else if (strcmp(hspvarproc[HSPVAR_FLAG_STR].vartype_name, "double") == 0) {  //実数のCnv
            ptr = (char *)HspVarDouble_Cnv(ptr, mpval->flag);
        } else if (strcmp(hspvarproc[HSPVAR_FLAG_STR].vartype_name, "str") == 0) {  //文字列のCnv
            ptr = (char *)HspVarStr_Cnv(ptr, mpval->flag);
        } else {
            @throw [self make_nsexception:HSPERR_SYNTAX];
        }
        // ptr = (char *)HspVarCoreCnv( mpval->flag, HSPVAR_FLAG_STR, ptr );	//
        // 型が一致しない場合は変換
    }
    // printf( "%s\n",ptr );
    NSString *p1 = [NSString stringWithCString:ptr encoding:NSUTF8StringEncoding];
    if (![p1 isEqual:@""]) {
        [myLayer mes:p1];
    }
    // strsp_ini();
    // while(1) {
    //	chk = strsp_get( ptr, stmp, 0, 1022 );
    //	printf( "%s\n",stmp );
    //	if ( chk == 0 ) break;
    //}
    
}

- (void)cmdfunc_title {
    char *p1;
    p1 = [self code_gets];
    global.title_text = [NSString stringWithCString:p1 encoding:NSUTF8StringEncoding];
}

- (void)cmdfunc_pos {
    int p1 = [self code_getdi:0];
    int p2 = [self code_getdi:0];
    int p3 = [self code_getdi:INT_MIN];
    if (p3 == INT_MIN) {  //初期値であれば
        [myLayer set_current_point:p1 point_y:p2];
    } else {
        [myLayer d3pos:p1 y:p2 z:p3];
    }
}

- (void)cmdfunc_circle {
    int p1 = [self code_getdi:0];
    int p2 = [self code_getdi:0];
    int p3 = [self code_getdi:0];
    int p4 = [self code_getdi:0];
    int p5 = [self code_getdi:1];
    if (p5 == 0) {
        [myLayer set_circle_rgba:p1 y1:p2 x2:p3 y2:p4];
    } else {  //塗りつぶし
        [myLayer fill_circle_rgba:p1 y1:p2 x2:p3 y2:p4];
    }
}

- (void)cmdfunc_cls {
    int p1 = [self code_getdi:0];
    [myLayer clear_canvas:p1];
    
    //ボタンを画面外に
    for (int i = 0; i < 64; i++) {
        [[myButtons objectAtIndex:i] setFrameOrigin:NSMakePoint(0, -9999)];
    }
    myButtonIndex = 0;  //ボタンのインデックスを初期化
    //スライダーを画面外に
    for (int i = 0; i < 64; i++) {
        [[mySliders objectAtIndex:i] setFrameOrigin:NSMakePoint(0, -9999)];
    }
    mySliderIndex = 0;
    //チェックボックスを画面外に
    for (int i = 0; i < 64; i++) {
        [[myCheckBoxs objectAtIndex:i] setFrameOrigin:NSMakePoint(0, -9999)];
    }
    myCheckBoxIndex = 0;
    //テキストフィールドを画面外に
    for (int i = 0; i < 64; i++) {
        [[myTextFields objectAtIndex:i] setFrameOrigin:NSMakePoint(0, -9999)];
        //[[myTextFields objectAtIndex:myTextFieldIndex] setEnabled:NO];
        //[[myTextFields objectAtIndex:myTextFieldIndex] setEditable:NO];
    }
    myTextFieldIndex = 0;
}

- (void)cmdfunc_font {
    char *p1 = [self code_gets];
    int p2 = [self code_getdi:12];
    int p3 = [self code_getdi:0];
    [myLayer set_font:[NSString stringWithCString:p1 encoding:NSUTF8StringEncoding] size:p2 style:p3];
}

- (void)cmdfunc_sysfont {
    [self show_alert_dialog:@"sysfont命令は未実装です"];
}

- (void)cmdfunc_objsize {
    [self show_alert_dialog:@"objsize命令は未実装です"];
}

- (void)cmdfunc_picload {
    char *p1 = [self code_gets];
    int p2 = [self code_getdi:0];
    [myLayer picload:[NSString stringWithCString:p1 encoding:NSUTF8StringEncoding] mode:p2];
}

- (void)cmdfunc_color {
    int p1 = [self code_getdi:0];
    int p2 = [self code_getdi:0];
    int p3 = [self code_getdi:0];
    int p4 = [self code_getdi:-1];
    if (p4 == -1) {
        [myLayer set_color_rgba:p1 green:p2 blue:p3 alpha:255];
    } else {
        [myLayer set_color_rgba:p1 green:p2 blue:p3 alpha:p4];
    }
}

- (void)cmdfunc_palcolor {
    [self show_alert_dialog:@"palcolor命令は未実装です"];
}

- (void)cmdfunc_palette {
    [self show_alert_dialog:@"palette命令は未実装です"];
}

- (void)cmdfunc_redraw {
    int p1 = [self code_getdi:0];
    [myLayer set_redraw_flag:(BOOL)p1];
    [myLayer redraw];
}

- (void)cmdfunc_width {
    [self show_alert_dialog:@"width命令は未実装です"];
}

- (void)cmdfunc_gsel {
    int p1 = [self code_getdi:0];
    myLayer->buf_index = p1;
}

- (void)cmdfunc_gcopy {
    int p1 = [self code_getdi:0];
    int p2 = [self code_getdi:0];
    int p3 = [self code_getdi:0];
    int p4 = [self code_getdi:-1];
    int p5 = [self code_getdi:-1];
    [myLayer gcopy:p1 px:p2 py:p3 sx:p4 sy:p5];
}

- (void)cmdfunc_gzoom {
    [self show_alert_dialog:@"gzoom命令は未実装です"];
}

- (void)cmdfunc_gmode {
    int p1 = [self code_getdi:0];
    int p2 = [self code_getdi:32];
    int p3 = [self code_getdi:32];
    int p4 = [self code_getdi:0];
    [myLayer set_current_blend_mode:p1];
    if (p2 >= 0) {
        [myLayer set_current_copy_width:p2];
    }
    if (p3 >= 0) {
        [myLayer set_current_copy_height:p3];
    }
    [myLayer set_current_blend_opacity:p4];
}

- (void)cmdfunc_bmpsave {
    [self show_alert_dialog:@"bmpsave命令は未実装です"];
}

- (void)cmdfunc_hsvcolor {
    int p1 = [self code_getdi:0];
    int p2 = [self code_getdi:0];
    int p3 = [self code_getdi:0];
    [myLayer set_color_hsv:p1 saturation:p2 brightness:p3];
}

- (void)cmdfunc_getkey {
    PVal *pval;
    APTR aptr = [self code_getva:&pval];
    int res = 0;
    int p1 = [self code_getdi:0];
    int ckey = 0;
    int cklast = 0, cktrg;

    switch (p1) {
        case 1:
            if ([myView getIsMouseDown]) {
                ckey = 1;
            }
            break;  // LeftMouseDown
        case 2:
            if ([myView getIsRightMouseDown]) {
                ckey = 1;
            }
            break;
        case 8:
            if ([myView getIsKeyDown_BackSpace]) {
                ckey = 1;
            }
            break;
        case 9:
            if ([myView getIsKeyDown_Tab]) {
                ckey = 1;
            }
            break;
        case 13:
            if ([myView getIsKeyDown_Enter]) {
                ckey = 1;
            }
            break;
        case 27:
            if ([myView getIsKeyDown_Escape]) {
                ckey = 1;
            }
            break;
        case 32:
            if ([myView getIsKeyDown_Space]) {
                ckey = 1;
            }
            break;
        case 37:
            if ([myView getIsKeyDown_Left]) {
                ckey = 1;
            }
            break;
        case 38:
            if ([myView getIsKeyDown_Up]) {
                ckey = 1;
            }
            break;
        case 39:
            if ([myView getIsKeyDown_Right]) {
                ckey = 1;
            }
            break;
        case 40:
            if ([myView getIsKeyDown_Down]) {
                ckey = 1;
            }
            break;
        case 48:
            if ([myView getIsKeyDown_0]) {
                ckey = 1;
            }
            break;
        case 49:
            if ([myView getIsKeyDown_1]) {
                ckey = 1;
            }
            break;
        case 50:
            if ([myView getIsKeyDown_2]) {
                ckey = 1;
            }
            break;
        case 51:
            if ([myView getIsKeyDown_3]) {
                ckey = 1;
            }
            break;
        case 52:
            if ([myView getIsKeyDown_4]) {
                ckey = 1;
            }
            break;
        case 53:
            if ([myView getIsKeyDown_5]) {
                ckey = 1;
            }
            break;
        case 54:
            if ([myView getIsKeyDown_6]) {
                ckey = 1;
            }
            break;
        case 55:
            if ([myView getIsKeyDown_7]) {
                ckey = 1;
            }
            break;
        case 56:
            if ([myView getIsKeyDown_8]) {
                ckey = 1;
            }
            break;
        case 57:
            if ([myView getIsKeyDown_9]) {
                ckey = 1;
            }
            break;
        case 65:
            if ([myView getIsKeyDown_A]) {
                ckey = 1;
            }
            break;
        case 66:
            if ([myView getIsKeyDown_B]) {
                ckey = 1;
            }
            break;
        case 67:
            if ([myView getIsKeyDown_C]) {
                ckey = 1;
            }
            break;
        case 68:
            if ([myView getIsKeyDown_D]) {
                ckey = 1;
            }
            break;
        case 69:
            if ([myView getIsKeyDown_E]) {
                ckey = 1;
            }
            break;
        case 70:
            if ([myView getIsKeyDown_F]) {
                ckey = 1;
            }
            break;
        case 71:
            if ([myView getIsKeyDown_G]) {
                ckey = 1;
            }
            break;
        case 72:
            if ([myView getIsKeyDown_H]) {
                ckey = 1;
            }
            break;
        case 73:
            if ([myView getIsKeyDown_I]) {
                ckey = 1;
            }
            break;
        case 74:
            if ([myView getIsKeyDown_J]) {
                ckey = 1;
            }
            break;
        case 75:
            if ([myView getIsKeyDown_K]) {
                ckey = 1;
            }
            break;
        case 76:
            if ([myView getIsKeyDown_L]) {
                ckey = 1;
            }
            break;
        case 77:
            if ([myView getIsKeyDown_M]) {
                ckey = 1;
            }
            break;
        case 78:
            if ([myView getIsKeyDown_N]) {
                ckey = 1;
            }
            break;
        case 79:
            if ([myView getIsKeyDown_O]) {
                ckey = 1;
            }
            break;
        case 80:
            if ([myView getIsKeyDown_P]) {
                ckey = 1;
            }
            break;
        case 81:
            if ([myView getIsKeyDown_Q]) {
                ckey = 1;
            }
            break;
        case 82:
            if ([myView getIsKeyDown_R]) {
                ckey = 1;
            }
            break;
        case 83:
            if ([myView getIsKeyDown_S]) {
                ckey = 1;
            }
            break;
        case 84:
            if ([myView getIsKeyDown_T]) {
                ckey = 1;
            }
            break;
        case 85:
            if ([myView getIsKeyDown_U]) {
                ckey = 1;
            }
            break;
        case 86:
            if ([myView getIsKeyDown_V]) {
                ckey = 1;
            }
            break;
        case 87:
            if ([myView getIsKeyDown_W]) {
                ckey = 1;
            }
            break;
        case 88:
            if ([myView getIsKeyDown_X]) {
                ckey = 1;
            }
            break;
        case 89:
            if ([myView getIsKeyDown_Y]) {
                ckey = 1;
            }
            break;
        case 90:
            if ([myView getIsKeyDown_Z]) {
                ckey = 1;
            }
            break;
        case 96:
            if ([myView getIsKeyDown_Ten0]) {
                ckey = 1;
            }
            break;
        case 97:
            if ([myView getIsKeyDown_Ten1]) {
                ckey = 1;
            }
            break;
        case 98:
            if ([myView getIsKeyDown_Ten2]) {
                ckey = 1;
            }
            break;
        case 99:
            if ([myView getIsKeyDown_Ten3]) {
                ckey = 1;
            }
            break;
        case 100:
            if ([myView getIsKeyDown_Ten4]) {
                ckey = 1;
            }
            break;
        case 101:
            if ([myView getIsKeyDown_Ten5]) {
                ckey = 1;
            }
            break;
        case 102:
            if ([myView getIsKeyDown_Ten6]) {
                ckey = 1;
            }
            break;
        case 103:
            if ([myView getIsKeyDown_Ten7]) {
                ckey = 1;
            }
            break;
        case 104:
            if ([myView getIsKeyDown_Ten8]) {
                ckey = 1;
            }
            break;
        case 105:
            if ([myView getIsKeyDown_Ten9]) {
                ckey = 1;
            }
            break;
        case 112:
            if ([myView getIsKeyDown_F1]) {
                ckey = 1;
            }
            break;
        case 113:
            if ([myView getIsKeyDown_F2]) {
                ckey = 1;
            }
            break;
        case 114:
            if ([myView getIsKeyDown_F3]) {
                ckey = 1;
            }
            break;
        case 115:
            if ([myView getIsKeyDown_F4]) {
                ckey = 1;
            }
            break;
        case 116:
            if ([myView getIsKeyDown_F5]) {
                ckey = 1;
            }
            break;
        case 117:
            if ([myView getIsKeyDown_F6]) {
                ckey = 1;
            }
            break;
        case 118:
            if ([myView getIsKeyDown_F7]) {
                ckey = 1;
            }
            break;
        case 119:
            if ([myView getIsKeyDown_F8]) {
                ckey = 1;
            }
            break;
        case 120:
            if ([myView getIsKeyDown_F9]) {
                ckey = 1;
            }
            break;
        case 121:
            if ([myView getIsKeyDown_F10]) {
                ckey = 1;
            }
            break;
        default:
            break;
    }

    cktrg = (ckey ^ cklast) & ckey;
    cklast = ckey;
    res = cktrg;  //|(ckey&p1);
    // = 255;
    [self code_setva:pval aptr:aptr type:TYPE_INUM ptr:&res];
}

- (void)cmdfunc_chkbox {
    int posx = [myLayer get_current_point_x];
    int posy = [myLayer get_current_point_y];
    [[myCheckBoxs objectAtIndex:myCheckBoxIndex] setFrameOrigin:NSMakePoint(posx, myLayer->buf_height[myLayer->buf_index] - posy - 18)];
    char *ps = [self code_gets];
    [[myCheckBoxs objectAtIndex:myCheckBoxIndex] setTitle:[NSString stringWithCString:ps encoding:NSUTF8StringEncoding]];
    myCheckBoxAptr[myCheckBoxIndex] = [self code_getva:&myCheckBoxPval[myCheckBoxIndex]];
    
    hsp3gr_ctx->stat = myCheckBoxIndex;  //ボタンのIDを返す
    
    [myLayer set_current_point:posx point_y:posy + 18];
    
    myCheckBoxIndex++;  //ボタンのインデックスを次に
    if (myCheckBoxIndex >= 64) {
        myCheckBoxIndex = 64;
    }
}

- (void)cmdfunc_listbox {
    [self show_alert_dialog:@"listbox命令は未実装です"];
}

- (void)cmdfunc_combox {
    [self show_alert_dialog:@"combox命令は未実装です"];
}

- (void)cmdfunc_input {
    int posx = [myLayer get_current_point_x];
    int posy = [myLayer get_current_point_y];
    
    // char* ps;
    // ps = [self code_gets];
    //[[myTextFields objectAtIndex:myTextFieldIndex] setTitle:[NSString
    //stringWithCString:ps encoding:NSUTF8StringEncoding]];
    
    myTextFieldAptr[myTextFieldIndex] = [self code_getva:&myTextFieldPval[myTextFieldIndex]];
    
    int p2 = [self code_getdi:96];
    int p3 = [self code_getdi:22];
    [self code_getdi:0];
    [[myTextFields objectAtIndex:myTextFieldIndex] setFrameOrigin:NSMakePoint(posx, myLayer->buf_height[myLayer->buf_index] - posy - p3)];
    [[myTextFields objectAtIndex:myTextFieldIndex] setFrameSize:NSMakeSize(p2, p3)];
    [[myTextFields objectAtIndex:myTextFieldIndex] setEnabled:YES];
    [[myTextFields objectAtIndex:myTextFieldIndex] setEditable:YES];
    
    hsp3gr_ctx->stat = myTextFieldIndex;  //ボタンのIDを返す
    
    myTextFieldIndex++;  //ボタンのインデックスを次に
    if (myTextFieldIndex >= 64) {
        myTextFieldIndex = 64;
    }
    
    [myLayer set_current_point:posx point_y:posy + p3];
    
    /*
     PVal *pval;
     APTR aptr;
     char *pp2;
     char *vptr;
     int strsize;
     int a;
     strsize = 0;
     aptr = [self code_getva:&pval];
     //pp2 = code_getvptr( &pval, &size );
     p2 = [self code_getdi:0x4000];
     p3 = [self code_getdi:0];
     
     if ( p2 < 64 ) p2 = 64;
     pp2 = code_stmp( p2+1 );
     
     switch( p3 & 15 ) {
     case 0:
     while(1) {
     if ( p2<=0 ) break;
     a = getchar();
     if ( a==EOF ) break;
     *pp2++ = a;
     p2--;
     strsize++;
     }
     break;
     case 1:
     while(1) {
     if ( p2<=0 ) break;
     a = getchar();
     if (( a==EOF )||( a=='\n' )) break;
     *pp2++ = a;
     p2--;
     strsize++;
     }
     break;
     case 2:
     while(1) {
     if ( p2<=0 ) break;
     a = getchar();
     if ( a == '\r' ) {
     int c = getchar();
     if( c != '\n' ) {
     ungetc(c, stdin);
     }
     break;
     }
     if (( a==EOF )||( a=='\n' )) break;
     *pp2++ = a;
     p2--;
     strsize++;
     }
     break;
     }
     
     *pp2 = 0;
     hsp3gr_ctx->strsize = strsize + 1;
     
     if ( p3 & 16 ) {
     if (( pval->support & HSPVAR_SUPPORT_FLEXSTORAGE ) == 0 ) throw
     HSPERR_TYPE_MISMATCH;
     //HspVarCoreAllocBlock( pval, (PDAT *)vptr, strsize );
     vptr = (char *)HspVarCorePtrAPTR( pval, aptr );
     memcpy( vptr, hsp3gr_ctx->stmp, strsize );
     } else {
     
     [self code_setva:pval aptr:aptr type:TYPE_STRING ptr:hsp3gr_ctx->stmp];
     }
     */
    
}

- (void)cmdfunc_mesbox {
    [self show_alert_dialog:@"mesbox命令は未実装です"];
}

- (void)cmdfunc_buffer {
    int p1 = [self code_getdi:0];
    int p2 = [self code_getdi:640];
    int p3 = [self code_getdi:480];
    myLayer->buf_index = p1;
    myLayer->buf_width[myLayer->buf_index] = p2;
    myLayer->buf_height[myLayer->buf_index] = p3;
    [myLayer clear_canvas:0];
}

- (void)cmdfunc_screen {
    int p1 = [self code_getdi:0];
    int p2 = [self code_getdi:640];
    int p3 = [self code_getdi:480];
    [self code_getdi:0];
    if (p1 == 0) {
        global.now_window_border = 0;
    } else {
        [self show_alert_dialog:@"このバージョンのMac版HSPでは、screen命令のp1に0以外を指定することはできません。"];
    }
    myLayer->buf_index = p1;
    myLayer->buf_width[myLayer->buf_index] = p2;
    myLayer->buf_height[myLayer->buf_index] = p3;
    [myLayer clear_canvas:0];
}

- (void)cmdfunc_bgscr {
    int p1 = [self code_getdi:0];
    int p2 = [self code_getdi:640];
    int p3 = [self code_getdi:480];
    if (p1 == 0) {
        global.now_window_border = 1;
    }
    myLayer->buf_index = p1;
    myLayer->buf_width[myLayer->buf_index] = p2;
    myLayer->buf_height[myLayer->buf_index] = p3;
    [myLayer clear_canvas:0];
}

- (void)cmdfunc_mouse {
    [self show_alert_dialog:@"mouse命令は未実装です"];
}

- (void)cmdfunc_objsel {
    [self show_alert_dialog:@"objsel命令は未実装です"];
}

- (void)cmdfunc_groll {
    [self show_alert_dialog:@"groll命令は未実装です"];
}

- (void)cmdfunc_line {
    int p1 = [self code_getdi:0];
    int p2 = [self code_getdi:0];
    int p3 = [self code_getdi:0];
    int p4 = [self code_getdi:0];
    int p5 = [self code_getdi:INT_MIN];
    int p6 = [self code_getdi:INT_MIN];
    if (p5 == INT_MIN && p6 == INT_MIN) {
        if (isSmooth) {
            [myLayer set_line_rgba_smooth:p1 start_point_y:p2 end_point_x:p3 end_point_y:p4];
        } else {
            [myLayer set_line_rgba:p1 start_point_y:p2 end_point_x:p3 end_point_y:p4];
        }
    } else {
        if (isSmooth) {
            [myLayer d3lineSmooth:p1 sy:p2 sz:p3 ex:p4 ey:p5 ez:p6];
        } else {
            [myLayer d3line:p1 sy:p2 sz:p3 ex:p4 ey:p5 ez:p6];
        }
    }
    
}

- (void)cmdfunc_clrobj {
    //ボタンを画面外に
    for (int i = 0; i < 64; i++) {
        [[myButtons objectAtIndex:i] setFrameOrigin:NSMakePoint(0, -9999)];
    }
    myButtonIndex = 0;  //ボタンのインデックスを初期化
    //スライダーを画面外に
    for (int i = 0; i < 64; i++) {
        [[mySliders objectAtIndex:i] setFrameOrigin:NSMakePoint(0, -9999)];
    }
    mySliderIndex = 0;
}

- (void)cmdfunc_boxf {
    int p1 = [self code_getdi:0];
    int p2 = [self code_getdi:0];
    int p3 = [self code_getdi:myLayer->buf_width[myLayer->buf_index]];
    int p4 = [self code_getdi:myLayer->buf_height[myLayer->buf_index]];
    [myLayer fill_rect_rgba:p1 y1:p2 x2:p3 y2:p4];
}

- (void)cmdfunc_objprm {
    [self show_alert_dialog:@"objprm命令は未実装です"];
}

- (void)cmdfunc_objmode {
    [self show_alert_dialog:@"objmode命令は未実装です"];
}

- (void)cmdfunc_stick {
    PVal *pval;
    APTR aptr;
    int res;
    aptr = [self code_getva:&pval];
    int p1 = [self code_getdi:0];
    [self code_getdi:1];
    int ckey, cklast, cktrg;
    ckey = 0;
    res = 0;
    
    // BOOL a = ;
    
    // NSLog(@"%d",myView->isMouseDown);
    
    //            if (p2) {
    //                if ( wnd->GetActive() < 0 ) {
    //                    code_setva( pval, aptr, TYPE_INUM, &res );
    //                    break;
    //                }
    //            }
    
    if ([myView getIsKeyDown_Left]) {
        ckey |= 1;
    }  // if ( GetAsyncKeyState(37)&0x8000 ) ckey|=1;		// [left]
    if ([myView getIsKeyDown_Up]) {
        ckey |= 2;
    }  // if ( GetAsyncKeyState(38)&0x8000 ) ckey|=2;		// [up]
    if ([myView getIsKeyDown_Right]) {
        ckey |= 4;
    }  // if ( GetAsyncKeyState(39)&0x8000 ) ckey|=4;		// [right]
    if ([myView getIsKeyDown_Down]) {
        ckey |= 8;
    }  // if ( GetAsyncKeyState(40)&0x8000 ) ckey|=8;		// [down]
    if ([myView getIsKeyDown_Space]) {
        ckey |= 16;
    }  // if ( GetAsyncKeyState(32)&0x8000 ) ckey|=16;	// [spc]
    if ([myView getIsKeyDown_Enter]) {
        ckey |= 32;
    }  // if ( GetAsyncKeyState(13)&0x8000 ) ckey|=32;	// [ent]
    // if ( GetAsyncKeyState(17)&0x8000 ) ckey|=64;	// [ctrl]
    if ([myView getIsKeyDown_Escape]) {
        ckey |= 128;
    }  // if ( GetAsyncKeyState(27)&0x8000 ) ckey|=128;	// [esc]
    if ([myView getIsMouseDown]) {
        ckey |= 256;
    }  // mouse_l /*GetAsyncKeyState(1)&0x8000*/
    if ([myView getIsRightMouseDown]) {
        ckey |= 512;
    }  // mouse_r GetAsyncKeyState(2)&0x8000
    if ([myView getIsKeyDown_Tab]) {
        ckey |= 1024;
    }  // if ( GetAsyncKeyState(9)&0x8000 )  ckey|=1024;	// [tab]
    cktrg = (ckey ^ cklast) & ckey;
    cklast = ckey;
    res = cktrg | (ckey & p1);
    // = 255;
    [self code_setva:pval aptr:aptr type:TYPE_INUM ptr:&res];
    //[self code_event:HSPEVENT_STICK prm1:TYPE_INUM prm2:aptr prm3:&res];
    //[self code_event:HSPEVENT_FNAME prm1:0 prm2:0 prm3:[self code_gets]];
}

- (void)cmdfunc_grect {
    [self show_alert_dialog:@"grect命令は未実装です"];
}

- (void)cmdfunc_grotate {
    [self show_alert_dialog:@"grotate命令は未実装です"];
}

- (void)cmdfunc_gsquare {
    [self show_alert_dialog:@"gsquare命令は未実装です"];
}

typedef unsigned long DWORD;
typedef DWORD COLORREF;
#define RGB(r, g, b)                                               \
((unsigned long)(((unsigned char)(r) |                           \
((unsigned short)((unsigned char)(g)) << 8)) | \
(((unsigned long)(unsigned char)(b)) << 16)))

- (void)cmdfunc_gradf {
    int p1 = [self code_getdi:0];
    int p2 = [self code_getdi:0];
    int p3 = [self code_getdi:myLayer->buf_width[myLayer->buf_index]];
    int p4 = [self code_getdi:myLayer->buf_height[myLayer->buf_index]];
    int gradmode = [self code_getdi:0];
    int r = [myLayer get_current_color_r];
    int g = [myLayer get_current_color_g];
    int b = [myLayer get_current_color_b];
    int color = (int)RGB(r, g, b);
    int res = 0;
    res = color & 0x00ff00;
    res |= (color >> 16) & 0xff;
    res |= (color & 0xff) << 16;
    int p5 = [self code_getdi:color];
    int p6 = [self code_getdi:color];
    UInt8 color_a[3];
    UInt8 color_b[3];
    memcpy(color_a, &p5, sizeof(int));
    memcpy(color_b, &p6, sizeof(int));
    [myLayer fillGradation:p1 pos_y:p2 size_w:p3 size_h:p4 direction:gradmode color_red_a:color_a[0] color_green_a:color_a[1] color_blue_a:color_a[2] color_red_b:color_b[0] color_green_b:color_b[1] color_blue_b:color_b[2]];
    
}

- (void)cmdfunc_objimage {
    [self show_alert_dialog:@"objimage命令は未実装です"];
}

- (void)cmdfunc_objskip {
    [self show_alert_dialog:@"命令はobjskip未実装です"];
}

- (void)cmdfunc_objenable {
    [self show_alert_dialog:@"objenable命令は未実装です"];
}

- (void)cmdfunc_celload {
    [self cmdfunc_picload];
}

- (void)cmdfunc_celdiv {
    [self show_alert_dialog:@"celdiv命令は未実装です"];
}

- (void)cmdfunc_celput {
    [self show_alert_dialog:@"celput命令は未実装です"];
}

- (void)cmdfunc_gfilter {
    [self show_alert_dialog:@"gfilter命令は未実装です"];
}

- (void)cmdfunc_setreq {
    [self show_alert_dialog:@"setreq命令は未実装です"];
}

- (void)cmdfunc_getreq {
    [self show_alert_dialog:@"getreq命令は未実装です"];
}

- (void)cmdfunc_mmvol {
    [self show_alert_dialog:@"mmvol命令は未実装です"];
}

- (void)cmdfunc_mmpan {
    [self show_alert_dialog:@"mmpan命令は未実装です"];
}

- (void)cmdfunc_mmstat {
    [self show_alert_dialog:@"mmstat命令は未実装です"];
}

- (void)cmdfunc_mtlist {
    [self show_alert_dialog:@"mtlist命令は未実装です"];
}

- (void)cmdfunc_mtinfo {
    [self show_alert_dialog:@"mtinfo命令は未実装です"];
}

- (void)cmdfunc_devinfo {
    [self show_alert_dialog:@"devinfo命令は未実装です"];
}

- (void)cmdfunc_devinfoi {
    [self show_alert_dialog:@"devinfoi命令は未実装です"];
}

- (void)cmdfunc_devprm {
    [self show_alert_dialog:@"devprm命令は未実装です"];
}

- (void)cmdfunc_devcontrol {
    [self show_alert_dialog:@"devcontrol命令は未実装です"];
}

- (void)cmdfunc_qins {
    // qAudioがスタートしているか
    if (qAudio->isInitialized != YES) {
        [qAudio start];
    }
    // qAudioのinNumberFramesが初期化されているか
    while (1) {
        if (global.in_number_frames == 0) {
            usleep(1000);
            continue;
        } else {
            break;
        }
    }
    @autoreleasepool {
        double p1 = [self code_getdd:0];
        double d = p1;
        if (d <= -1.0) {
            d = -1.0;
        }
        if (d >= 1.0) {
            d = 1.0;
        }
        int n = global.q_audio_count;
        global.q_audio_source[n] = [NSNumber numberWithDouble:d];
        global.q_audio_count++;
        if (global.q_audio_count > global.in_number_frames) {
            global.q_audio_count = 0;
            NSMutableArray *m = [global.q_audio_source mutableCopy];  //メモリに注意
            [global.q_audio_buffer addObject:m];
        }
    }
    
}

- (void)cmdfunc_qpush {
    // qAudioがスタートしているか
    if (qAudio->isInitialized != YES) {
        [qAudio start];
    }
    // qAudioのinNumberFramesが初期化されているか
    while (1) {
        if (global.in_number_frames == 0) {
            usleep(1000);
            continue;
        } else {
            break;
        }
    }
    @autoreleasepool {
        union _t {
            double d;
            char c[1];
        } union_data;
        char *union_pointer;
        union_pointer = union_data.c;
        PVal *pval;
        int vsize;
        char *ptr = [self code_getvptr:&pval size:&vsize];
        int size = [self code_geti];
        int cnt = 0;
        double d = 0.0;
        for (int n = 0; n < size; n++) {
            for (int i = 0; i < sizeof(double); i++) {
                *union_pointer = ptr[cnt];
                union_pointer++;
                cnt++;
            }
            d = union_data.d;
            if (d <= -1.0) {
                d = -1.0;
            }
            if (d >= 1.0) {
                d = 1.0;
            }
            
            global.q_audio_source[global.q_audio_count] =
            [NSNumber numberWithDouble:d];
            union_pointer = union_pointer - sizeof(double);
            
            global.q_audio_count++;
            if (global.q_audio_count > global.in_number_frames) {
                global.q_audio_count = 0;
                NSMutableArray *m = [global.q_audio_source mutableCopy];  //メモリに注意
                [global.q_audio_buffer addObject:m];
            }
        }
    }
}

- (void)cmdfunc_qstart {
    [qAudio start];
}

- (void)cmdfunc_qend {
    [qAudio end];
}

- (void)cmdfunc_qplay {
    if (qAudio->isInitialized != YES) {
        [qAudio start];
    }
    [qAudio play];
}

- (void)cmdfunc_qstop {
    [qAudio stop];
}

- (void)cmdfunc_qvol {
    double vol = [self code_getd];
    [qAudio setVolume:vol];
}

// p1 = 初期値(double)
// p2 = 最小値(double)
// p3 = 最大値(double)
// p4 = 縦か横か(int: 0 or 1)
// p5 = ラベル(label)
//
- (void)cmdfunc_slider {
    double p1 = [self code_getdd:0.0];
    double p2 = [self code_getdd:0.0];
    double p3 = [self code_getdd:1.0];
    int p4 = [self code_getdi:0];
    unsigned short *sbr;
    sbr = [self code_getlb];
    
    [self code_next];
    
    int posx = [myLayer get_current_point_x];
    int posy = [myLayer get_current_point_y];
    
    if (p4 == 0) {
        [[mySliders objectAtIndex:mySliderIndex] setFrameOrigin:NSMakePoint(posx, myLayer->buf_height[myLayer->buf_index] - posy - 21)];
        [[mySliders objectAtIndex:mySliderIndex] setFrameSize:NSMakeSize(96, 21)];
        [myLayer set_current_point:posx point_y:posy + 21];
    } else {
        [[mySliders objectAtIndex:mySliderIndex] setFrameOrigin:NSMakePoint(posx, myLayer->buf_height[myLayer->buf_index] - posy - 96)];
        [[mySliders objectAtIndex:mySliderIndex] setFrameSize:NSMakeSize(21, 96)];
        [myLayer set_current_point:posx + 21 point_y:posy];
    }
    [[mySliders objectAtIndex:mySliderIndex] setDoubleValue:p1];
    [[mySliders objectAtIndex:mySliderIndex] setMinValue:p2];
    [[mySliders objectAtIndex:mySliderIndex] setMaxValue:p3];
    
    mySliderLabel[mySliderIndex] = sbr;  //ラベルを設定する
    hsp3gr_ctx->stat = mySliderIndex;    // IDを返す
    
    mySliderIndex++;  //インデックスを次に
    if (mySliderIndex >= 64) {
        mySliderIndex = 64;
    }
}

- (void)cmdfunc_onmidi {
    myMidiEventTypeAptr = [self code_getva:&myMidiEventTypePval];
    myMidiEventNumberAptr = [self code_getva:&myMidiEventNumberPval];
    myMidiEventVelocityAptr = [self code_getva:&myMidiEventVelocityPval];
    myMidiEventChannelAptr = [self code_getva:&myMidiEventChannelPval];
    myMidiEventLabel = [self code_getlb];
    [self code_next];
    global.is_start_midi_event = YES;
}

- (void)cmdfunc_box {
    int p1 = [self code_getdi:0];
    int p2 = [self code_getdi:0];
    int p3 = [self code_getdi:0];
    int p4 = [self code_getdi:0];
    int p5 = [self code_getdi:INT_MIN];
    int p6 = [self code_getdi:INT_MIN];
    if (p5 == INT_MIN && p6 == INT_MIN) {
        if (isSmooth) {
            [myLayer set_rect_line_rgba_smooth:p1 y1:p2 x2:p3 y2:p4];
        } else {
            [myLayer set_rect_line_rgba:p1 y1:p2 x2:p3 y2:p4];
        }
    } else {
        if (isSmooth) {
            [myLayer d3boxSmooth:p1 sy:p2 sz:p3 ex:p4 ey:p5 ez:p6];
        } else {
            [myLayer d3box:p1 sy:p2 sz:p3 ex:p4 ey:p5 ez:p6];
        }
    }
}

- (void)cmdfunc_antialiasing {
    if ([self code_getdi:0] == 0) {
        isSmooth = NO;
    } else {
        isSmooth = YES;
    }
}

- (void)cmdfunc_smooth {
    if ([self code_getdi:1] == 1) {
        isSmooth = YES;
    } else {
        isSmooth = NO;
    }
}

- (void)cmdfunc_setcam {
    double x1 = [self code_getdd:500];
    double y1 = [self code_getdd:500];
    double z1 = [self code_getdd:500];
    double x2 = [self code_getdd:0];
    double y2 = [self code_getdd:0];
    double z2 = [self code_getdd:0];
    [myLayer d3setcam:x1 y1:y1 z1:z1 x2:x2 y2:y2 z2:z2];
}

- (void *)reffunc_function:(int *)type_res arg:(int)arg {
    void *ptr;
    //		返値のタイプを設定する
    //
    *type_res = HSPVAR_FLAG_INT;           // 返値のタイプを指定する
    ptr = &hsp3gr_reffunc_intfunc_ivalue;  // 返値のポインタ
    //			'('で始まるかを調べる
    //
    //
    if (*hsp3gr_type != TYPE_MARK) {  // 0
        // NSLog(@"%d",*type);
        // if ( *type == TYPE_EXTCMD ) { //9
        //    NSLog(@"aiueo");
        //    NSLog(@"%d",arg);
        //}
        // else {
        //    throw HSPERR_INVALID_FUNCPARAM;
        //}
    }
    
    if (*hsp3gr_val != '(') {
        // NSLog(@"aiueo");
        // '('がない場合は拡張システム変数とみなす
        
        return [self reffunc_sysvar:type_res arg:arg];
        
        // throw HSPERR_INVALID_FUNCPARAM;
    }
    
    [self code_next];
    
    switch (arg & 0xff) {
            //	int function
        case 0x000:
            break;  // ginfo
        case 0x001:
            break;     // objinfo
        case 0x002:  // dirinfo
        {
            int p1 = [self code_geti];
            ptr = [self getdir:p1];
            *type_res = HSPVAR_FLAG_STR;
            break;
        }
        case 0x003:  // sysinfo
        {
            int p1 = [self code_geti];
            *type_res = [self sysinfo:p1];
            ptr = hsp3gr_ctx->stmp;
            break;
        }
        default: {
             @throw [self make_nsexception:HSPERR_UNSUPPORTED_FUNCTION];
        }
    }
    
    //			')'で終わるかを調べる
    //
    if (*hsp3gr_type != TYPE_MARK) {
         @throw [self make_nsexception:HSPERR_INVALID_FUNCPARAM];
    }
    if (*hsp3gr_val != ')') {
         @throw [self make_nsexception:HSPERR_INVALID_FUNCPARAM];
    }
    [self code_next];
    return ptr;
}

//        reffunc : TYPE_EXTSYSVAR
//        (拡張システム変数)
//
- (void *)reffunc_sysvar:(int *)type_res arg:(int)arg {
    void *ptr;
    if (arg & 0x100) {
        return [self reffunc_function:type_res arg:arg];
    }
    
    //		返値のタイプを設定する
    //
    *type_res = HSPVAR_FLAG_INT;           // 返値のタイプを指定する
    ptr = &hsp3gr_reffunc_intfunc_ivalue;  // 返値のポインタ
    
    switch (arg) {
            //	int function
        case 0x000:  // mousex
            // NSLog(@"mousex");
            hsp3gr_reffunc_intfunc_ivalue =
            [myView getMouseX];  // bmscr->savepos[ BMSCR_SAVEPOS_MOSUEX ];
            break;
        case 0x001:  // mousey
            hsp3gr_reffunc_intfunc_ivalue = [myView getMouseY];
            // hsp3gr_reffunc_intfunc_ivalue = bmscr->savepos[ BMSCR_SAVEPOS_MOSUEY ];
            break;
        case 0x002:  // mousew
            // hsp3gr_reffunc_intfunc_ivalue = bmscr->savepos[ BMSCR_SAVEPOS_MOSUEW ];
            // bmscr->savepos[ BMSCR_SAVEPOS_MOSUEW ] = 0;
            break;
        case 0x003:  // hwnd
            // ptr = (void *)(&(bmscr->hwnd));
            break;
        case 0x004:  // hinstance
            // ptr = (void *)(&(bmscr->hInst));
            break;
        case 0x005:  // hdc
            // ptr = (void *)(&(bmscr->hdc));
            break;
            
        default: {
             @throw [self make_nsexception:HSPERR_UNSUPPORTED_FUNCTION];
        }
    }
    
    return ptr;
}

//        termfunc : TYPE_EXTCMD
//        (内蔵GUI)
//
- (int)termfunc_extcmd:(int)option {
    return 0;
}

- (void)hsp3typeinit_cl_extcmd:(HSP3TYPEINFO *)info {
    HSP_ExtraInfomation *exinfo;  // Info for Plugins
    
    hsp3gr_ctx = info->hspctx;
    exinfo = info->hspexinfo;
    hsp3gr_type = exinfo->nptype;
    hsp3gr_val = exinfo->npval;
    
    //		function register
    //
    // info->cmdfunc = cmdfunc_extcmd;
    info->cmdfuncNumber = 7;  //内蔵GUIコマンド memo.md
    // info->termfunc = termfunc_extcmd;
    
    //		HSP_ExtraInfomationに関数を登録する
    //
    exinfo->actscr = &hsp3gr_cur_window;  // Active Window ID
    // exinfo->HspFunc_getbmscr = ex_getbmscr;
    // exinfo->HspFunc_mref = ex_mref;
    
    //		バイナリモードを設定
    //
    //_setmode( _fileno(stdin),  _O_BINARY );
}

- (void)hsp3typeinit_cl_extfunc:(HSP3TYPEINFO *)info {
    info->reffuncNumber = 4;  // reffunc_function;
}

@end
