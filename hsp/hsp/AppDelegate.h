//
//  AppDelegate.h
//  hsp
//
//  Created by 半澤 聡 on 2016/09/12.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#import "debug_message.h"
#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
}

//
@property(nonatomic, readwrite) BOOL is_app_run; //アプリが実行開始可能かどうか
@property(nonatomic, readwrite) int now_window_border; // 0=標準、1=枠無し
@property(nonatomic, readwrite) int old_window_border; // 0=標準、1=枠無し 比較用
@property(nonatomic, readwrite) BOOL is_startax_in_resource; //リソース内にstart.axがあるか
@property(nonatomic, readwrite) CGFloat backing_scale_factor; // Retinaの比率
@property(nonatomic, readwrite) NSString *title_text; //タイトルバーの文字列
@property(nonatomic, readwrite) NSString *current_directory_path; //実行中のカレントディレクトリ
@property(nonatomic, readwrite) NSString *current_script_path; //スクリプトファイルのあるディレクトリのパス
@property(nonatomic, readwrite) NSURL *current_script_url; //スクリプトファイルのあるディレクトリのURL

// q_audio
@property(readwrite, nonatomic) int q_audio_count;   //入れたサンプル数
@property(readwrite, nonatomic) BOOL is_que_playing; //再生中か
@property(readwrite, nonatomic) UInt32 in_number_frames; //フレーム数
@property(readwrite, nonatomic) NSMutableArray *q_audio_source;
@property(readwrite, nonatomic) NSMutableArray *q_audio_buffer;

// midi
@property(readwrite, nonatomic) NSMutableArray *midi_events;
@property(nonatomic, readwrite) BOOL is_start_midi_event;

@end
