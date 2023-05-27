//
//  ViewController.m
//  hsp
//
//  Created by 半澤 聡 on 2016/09/12.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#import "ViewController.h"
#import "hsp.h"
#import "hsp3cl.h"
#import <Foundation/Foundation.h>

@implementation ViewController

- (void)show_alert_dialog:(NSString *)message {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"エラー"];
    [alert setInformativeText:message];
    [alert addButtonWithTitle:@"OK"];
    [alert runModal];
}

- (NSException *)make_nsexception:(int)hsp_error_type {
    NSString *error_str = [NSString stringWithFormat:@"%d", hsp_error_type];
    return [NSException exceptionWithName:@"" reason:error_str userInfo:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    isInitialized = NO;

    global = (AppDelegate *) [[NSApplication sharedApplication] delegate];

    //主要なオブジェクト集の初期化
    // NSStoryboard *storyBoard = [NSStoryboard storyboardWithName:@"Main"
    // bundle:nil]; // get a reference to the storyboard
    // NSWindowController *myWindowController = [storyBoard
    // instantiateControllerWithIdentifier:@"MyWindowController"]; // instantiate
    // your window controller

    myWindow = self.view.window; // NULLの可能性がある
    myViewController = self;
    myView = (MyView *) self.view;
    myLayer = (MyCALayer *) self.view.layer;

    //その他のグローバル変数の初期化
    if (global.title_text == nil) {
        global.title_text = @"Window";
    }
    global.is_app_run = NO;
    global.q_audio_source = [NSMutableArray arrayWithCapacity:4096];
    global.q_audio_buffer = [global.q_audio_source mutableCopy];
    global.q_audio_count = 0;
    global.is_startax_in_resource = NO;

    //
    global.is_start_midi_event = NO;

    //現在のパスをpath.txtから取得する
    //もしリソースにstart.axがあったら
    BOOL isDir = NO;
    BOOL isExists = NO;
    NSFileManager *filemanager = [NSFileManager defaultManager];
    NSString *path = [[NSBundle mainBundle].resourcePath stringByAppendingString:@"/start.ax"];
    isExists = [filemanager fileExistsAtPath:path isDirectory:&isDir];
    if (isExists && isDir == NO) { // start.axがリソースに存在する
        global.is_startax_in_resource = YES;
        global.current_script_path = [NSBundle mainBundle].resourcePath;
        global.current_script_url = [NSURL URLWithString:global.current_script_path];
    } else {
        path = [[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent] stringByAppendingString:@"/start.ax"];
        isExists = [filemanager fileExistsAtPath:path isDirectory:&isDir];
        if (isExists && isDir == NO) {
            global.is_startax_in_resource = NO;
            global.current_script_path = [[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent];
            global.current_script_url = [NSURL URLWithString:global.current_script_path];
        } else {
            path = [NSHomeDirectory() stringByAppendingString:@"/Documents/hsptmp/path.txt"];
            isExists = [filemanager fileExistsAtPath:path isDirectory:&isDir];
            if (isExists && isDir == NO) { // path.txtファイルが存在する
                global.current_script_path = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
                global.current_script_url = [NSURL URLWithString:global.current_script_path];
            } else {
                global.current_script_path = @"";
                global.current_script_url = [NSURL URLWithString:global.current_script_path];
            }
        }
    }

    //カレントディレクトリを設定
    if ([global.current_script_path isEqual:@""]) {
        global.current_directory_path = NSHomeDirectory();
    } else {
        global.current_directory_path = global.current_script_path;
    }
    chdir([global.current_directory_path UTF8String]);

    // start.axを読み込んで実行（並列処理）
    [self runStartax];

    qAudio = [[SineWave alloc] initWithFrequency:440 volume:0.1]; // QueAudioの初期化
    myAudio = [[MyAudio alloc] init];                      // AVAudioの初期化
    myMidi = [[MyMidi alloc] init];

    //オブジェクトの初期化
    myButtons = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0; i < 64; i++) {
        [myButtons addObject:[[NSButton alloc] initWithFrame:NSMakeRect(0, -9999, 81, 32)]]; //あらかじめ画面の表示範囲外に設置しておく
        myButton = [myButtons objectAtIndex:i];
        [myButton setButtonType:NSMomentaryLightButton];
        [myButton setBezelStyle:NSRoundedBezelStyle];
        [myButton setTarget:self];
        [myButton setTag:i];
        [myButton setAction:@selector(buttonEvent:)];
        [myButton setTitle:@"button"];
        [myView addSubview:myButton];
    }

    mySliders = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0; i < 64; i++) {
        [mySliders addObject:[[NSSlider alloc] initWithFrame:NSMakeRect(0, -9999, 96, 21)]];
        mySlider = [mySliders objectAtIndex:i];
        [mySlider setTag:i];
        [mySlider setMinValue:0.0];
        [mySlider setMaxValue:1.0];
        [mySlider setDoubleValue:0.0];
        [mySlider setTarget:self];
        [mySlider setAction:@selector(sliderEvent:)];
        [myView addSubview:mySlider];
    }

    myCheckBoxs = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0; i < 64; i++) {
        [myCheckBoxs addObject:[[NSButton alloc] initWithFrame:NSMakeRect(0, -9999, 100, 18)]];
        myCheckBox = [myCheckBoxs objectAtIndex:i];
        [myCheckBox setButtonType:NSSwitchButton];
        [myCheckBox setBezelStyle:0];
        [myCheckBox setTitle:@"checkbox"];
        [myCheckBox setTag:i];
        [myCheckBox setState:NSOffState];
        [myCheckBox setAction:@selector(checkEvent:)];
        [myView addSubview:myCheckBox];
    }

    //リストボックス（テーブルビュー）
    // NSTableView* tableView = [[NSTableView alloc] initWithFrame:NSMakeRect(0,
    // 0, 200, 200)];
    //[myView addSubview:tableView];

    //テキストエリア（テキストビュー）
    // NSTextView* textView = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0,
    // 200, 200)];
    //[myView addSubview:textView];

    //コンボボックス
    //        //
    //        NSComboBox* comboBox = [[NSComboBox alloc]
    //        initWithFrame:NSMakeRect(0, 0, 200, 20)];
    //        comboBox.focusRingType = NSFocusRingTypeNone;
    //        [comboBox insertItemWithObjectValue:@"Red" atIndex:[comboBox
    //        numberOfItems]];
    //        //[comboBox setUsesDataSource:YES];
    //        //[comboBox removeItemAtIndex:0];
    //        //[comboBox setNumberOfVisibleItems:1];
    //        NSLog(@"%ld",(long)comboBox.indexOfSelectedItem);
    //        [comboBox setTag:1];
    //        [comboBox objectValueOfSelectedItem];
    //        [comboBox indexOfSelectedItem];
    //        //[comboBox setStringValue:@"Red"];
    //        [comboBox setTarget:self];
    //        [comboBox setAction:@selector(comboEvent:)];
    //        [myView addSubview:comboBox];

    myTextFields = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0; i < 64; i++) {
        [myTextFields addObject:[[NSTextField alloc] initWithFrame:NSMakeRect(0, -9999, 96, 22)]];
        myTextField = [myTextFields objectAtIndex:i];
        myTextField.focusRingType = NSFocusRingTypeNone;
        [myTextField setDelegate:self]; //デリゲートを自身に設定（NSTextFieldDelegateを実装すること）
        [myTextField setIdentifier:@"TextField"]; //識別番号
        [myTextField setTag:i];
        [myTextField setEnabled:NO];
        [myTextField setEditable:NO];
        [myView addSubview:myTextField];
    }

    // NSTextField* textField = [[NSTextField alloc] initWithFrame:NSMakeRect(0,
    // 0, 96, 22)];
    // textField.focusRingType = NSFocusRingTypeNone;
    //[textField setDelegate:self];
    ////デリゲートを自身に設定（NSTextFieldDelegateを実装すること）
    //[textField setIdentifier:@"TextField"];//識別番号
    //[textField setTag:0];
    //[myView addSubview:textField];

    //タイトルバーの変更を監視
    NSTimer *myTimer = [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
    [myTimer fire];

    // MIDIの変更を監視
    NSTimer *myTimerMidiEvent = [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(onTimerMidiEvent:) userInfo:nil repeats:YES];
    [myTimerMidiEvent fire];

    global.is_app_run = YES;
    isInitialized = YES;

}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    // Update the view, if already loaded.
}

- (void)awakeFromNib {
}

- (void)onTimerMidiEvent:(NSTimer *)timer {
    DEBUG_TIMER_IN;
    @autoreleasepool {
        if (global.midi_events != nil && global.is_start_midi_event == YES) {
            if (global.midi_events.count > 0 && global.midi_events.count % 4 == 0) {
                while (global.midi_events.count > 0 && global.midi_events.count % 4 == 0) {
                    int number = [global.midi_events[1] intValue];
                    int velocity = [global.midi_events[2] intValue];
                    int channel = [global.midi_events[3] intValue];

                    [self code_setva:myMidiEventNumberPval aptr:myMidiEventNumberAptr type:TYPE_INUM ptr:&number];
                    [self code_setva:myMidiEventVelocityPval aptr:myMidiEventVelocityAptr type:TYPE_INUM ptr:&velocity];
                    [self code_setva:myMidiEventChannelPval aptr:myMidiEventChannelAptr type:TYPE_INUM ptr:&channel];

                    if ([global.midi_events[0] isEqual:@"noteon"]) {
                        int type = 1;
                        [self code_setva:myMidiEventTypePval aptr:myMidiEventTypeAptr type:TYPE_INUM ptr:&type];
                    } else if ([global.midi_events[0] isEqual:@"noteoff"]) {
                        int type = 2;
                        [self code_setva:myMidiEventTypePval aptr:myMidiEventTypeAptr type:TYPE_INUM ptr:&type];
                    } else if ([global.midi_events[0] isEqual:@"cc"]) {
                        int type = 3;
                        [self code_setva:myMidiEventTypePval aptr:myMidiEventTypeAptr type:TYPE_INUM ptr:&type];
                    } else {
                        int type = 0;
                        [self code_setva:myMidiEventTypePval aptr:myMidiEventTypeAptr type:TYPE_INUM ptr:&type];
                    }

                    [global.midi_events removeObjectAtIndex:0];
                    [global.midi_events removeObjectAtIndex:0];
                    [global.midi_events removeObjectAtIndex:0];
                    [global.midi_events removeObjectAtIndex:0];
                }
                [self cmdfunc_gosub:myMidiEventLabel];
            }
        }
    }
    DEBUG_TIMER_OUT;
}

//タイトルバーの変更を監視
- (void)onTimer:(NSTimer *)timer {
    DEBUG_TIMER_IN;
    if (myWindow == NULL) {
        myWindow = self.view.window;
        return;
    }
    if (isInitialized == NO) {
        DEBUG_TIMER_OUT;
        return;
    }
    //タイトルを監視
    if ([myWindow.title isEqual:global.title_text]) {
    } else {
        [self.view.window setTitle:global.title_text];
    }
    //ウィンドウサイズを監視
    if (myLayer->buf_width != nil && myLayer->buf_height != nil) {
        CGFloat titlebarHeight =
                myWindow.frame.size.height - myWindow.contentView.frame.size.height;
        if (myWindow.frame.size.width != myLayer->buf_width[0] ||
                myWindow.frame.size.height - titlebarHeight != myLayer->buf_height[0]) {
            CGFloat x = myWindow.frame.origin.x;
            CGFloat y = myWindow.frame.origin.y;
            CGFloat w = (CGFloat) myLayer->buf_width[0];
            CGFloat h = (CGFloat) myLayer->buf_height[0] + titlebarHeight;
            // NSLog(@"%f,%f,%f,%f\n",x,y,w,h);
            [myWindow setFrame:NSMakeRect(x, y, w, h) display:YES];
        }
    }
    //ウィンドウの枠を監視
    if (global.now_window_border != global.old_window_border) {
        if (global.now_window_border == 0) {
            myWindow.backgroundColor = [NSColor whiteColor]; //背景を透明に
            myWindow.opaque = YES; //ウィンドウを透明に
            myWindow.titleVisibility = NSWindowTitleVisible; //タイトルを非表示に
            [myWindow setStyleMask:NSTitledWindowMask /*|NSResizableWindowMask*/ |
                    NSMiniaturizableWindowMask |
                    NSClosableWindowMask]; //タイトルバーを消す
            myWindow.movableByWindowBackground = NO; //ドラッグ移動を有効に
            myWindow.hasShadow = YES;                //影を消す
        } else {
            myWindow.backgroundColor = [NSColor clearColor]; //背景を透明に
            myWindow.opaque = NO; //ウィンドウを透明に
            myWindow.titleVisibility = NSWindowTitleHidden; //タイトルを非表示に
            [myWindow setStyleMask:NSBorderlessWindowMask]; //タイトルバーを消す
            myWindow.movableByWindowBackground = YES; //ドラッグ移動を有効に
            myWindow.hasShadow = NO;                  //影を消す
        }
        global.old_window_border = global.now_window_border;
    }
    DEBUG_TIMER_OUT;
}

//テキストフィールドのイベント　関連

// Enterが押された時
- (void)controlTextDidEndEditing:(NSNotification *)notification {
}

- (void)controlTextDidChange:(NSNotification *)notification { //内容が変更された時
    NSTextField *textField = [notification object];
    NSString *identifier = [textField identifier];
    if ([identifier isEqualToString:@"TextField"]) {
        char *state = (char *) [textField.stringValue UTF8String];
        [self code_setva:myTextFieldPval[textField.tag] aptr:myTextFieldAptr[textField.tag] type:TYPE_STRING ptr:state];
    }
}

- (void)checkEvent:(id)sender {
    int state;
    if ([sender state] == NSOnState) {
        state = 1;
        [self code_setva:myCheckBoxPval[[sender tag]] aptr:myCheckBoxAptr[[sender tag]] type:TYPE_INUM ptr:&state];
    } else {
        state = 0;
        [self code_setva:myCheckBoxPval[[sender tag]] aptr:myCheckBoxAptr[[sender tag]] type:TYPE_INUM ptr:&state];
    }
}

- (void)sliderEvent:(id)sender {
    vc_hspctx->iparam = (int) [sender tag];
    vc_hspctx->refdval = [[mySliders objectAtIndex:[sender tag]] doubleValue];
    [self cmdfunc_gosub:mySliderLabel[[sender tag]]];
}

- (void)buttonEvent:(id)sender {
    [self cmdfunc_gosub:myButtonLabel[[sender tag]]];
}

- (void)runStartax {
    NSString *path; // = NSHomeDirectory();
    //ファイルの有無の確認 順序 -> resourcePath/start.ax -> Documents/hsptmp/start.ax -> Home/start.ax -> Desktop/start.ax
    BOOL isDir = NO;
    BOOL isExists = NO;
    NSFileManager *filemanager = [NSFileManager defaultManager];
    // 0.
    path = [[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent] stringByAppendingString:@"/start.ax"];
    isExists = [filemanager fileExistsAtPath:path isDirectory:&isDir];
    if (isExists && isDir == NO) {
    } else {
        // 1.
        path =
                [[NSBundle mainBundle].resourcePath stringByAppendingString:@"/start.ax"];
        isExists = [filemanager fileExistsAtPath:path isDirectory:&isDir];
        if (isExists && isDir == NO) {
        } else {
            // 2.
            path = [NSHomeDirectory() stringByAppendingString:@"/Documents/hsptmp/start.ax"];
            isExists = [filemanager fileExistsAtPath:path isDirectory:&isDir];
            if (isExists && isDir == NO) {
            } else {
                // 3.
                path = [NSHomeDirectory() stringByAppendingString:@"/start.ax"];
                isExists = [filemanager fileExistsAtPath:path isDirectory:&isDir];
                if (isExists && isDir == NO) {
                } else {
                    // 4.
                    path =
                            [NSHomeDirectory() stringByAppendingString:@"/Desktop/start.ax"];
                    isExists = [filemanager fileExistsAtPath:path isDirectory:&isDir];
                    if (isExists && isDir == NO) {
                    } else {
                    }
                }
            }
        }
    }

    [self hsp3cl_init:(char *) path.UTF8String];
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        while (1) { //実行できる状態になるまで待つ
            if (global.is_app_run) {
                break;
            }
            usleep(1000);
        }
        [self hsp3cl_exec];
    }];
}

@end
