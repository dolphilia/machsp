//
//  SineWave.h
//  SineWaveExample
//
//  Created by dolphilia on 2016/02/14.
//  Copyright © 2016年 dolphilia. All rights reserved.
//
// 参考
// http://web.dormousesf.com/prog/SinWave/page.html

#ifndef SineWave_h
#define SineWave_h

#import <Cocoa/Cocoa.h>
#import <AudioUnit/AudioUnit.h>
#import "SineWaveData.h"
#import "AppDelegate.h"
#include "debug_message.h"

@interface SineWave : NSObject {
@public
    AppDelegate *global;
    AudioUnit mOutUnit;        // Audio Unit(Default Output)
    Float64 mSamplingRate;    // サンプリングレート
    Float32 mVolume;        // 音量
    BOOL mPlaying;        // 再生中フラグ
    BOOL isInitialized;  //初期化したか
    double qAudioSource[4096];
    double outSampleRate; //サンプリング周波数（外部アクセス用）
    SineWaveData *sineWaveData;
}
- (id)initWithFrequency:(double)dFreq volume:(float)fVol;

- (void)setVolume:(float)fVol;

- (void)start;

- (void)end;

- (void)play;

- (void)stop;

- (void)dealloc;

@end

#endif /* SineWave_h */
