//
//  SineWave.m
//
#import <Foundation/Foundation.h>
#import "SineWave.h"
// コールバック関数
OSStatus
RenderCallback(void *inRefCon,
               AudioUnitRenderActionFlags *ioActionFlags,
               const AudioTimeStamp *inTimeStamp,
               UInt32 inBusNumber,
               UInt32 inNumberFrames,
               AudioBufferList *ioData)
{
    @autoreleasepool {
        AppDelegate* global = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        global.in_number_frames = inNumberFrames;
        float *outL = ioData->mBuffers[0].mData;
        float *outR = ioData->mBuffers[1].mData;
        if(global.q_audio_buffer.count > 0 && global.is_que_playing) {
            for (int i=0; i< inNumberFrames; i++) {
                float wave = [global.q_audio_buffer[0][i] floatValue];
                *outL++ = wave;
                *outR++ = wave;
            }
            [global.q_audio_buffer removeObjectAtIndex:0];
        }
        else { //停止中は無音を挿入する
            for (int i=0; i< inNumberFrames; i++) {
                float wave = 0;
                *outL++ = wave;
                *outR++ = wave;
            }
        }
    }
    return noErr;
}
@implementation SineWave
// 初期化する
- (id)initWithFrequency:(double)dFreq volume:(float)fVol
{
    self = [super init];
    if ( self == nil ) {
        return nil;
    }
    for (int i=0;i<4096;i++) { //Queオーディオバッファを初期化する
        qAudioSource[i]=0.0;
    }
    isInitialized = NO;
    //デフォルト出力のAudio Unitを取得する
    AudioComponentDescription cd;
    cd.componentType = kAudioUnitType_Output;
    cd.componentSubType = kAudioUnitSubType_DefaultOutput;
    cd.componentManufacturer = kAudioUnitManufacturer_Apple;
    cd.componentFlags = 0;
    cd.componentFlagsMask = 0;
    AudioComponent ac = AudioComponentFindNext(NULL, &cd);
    AudioComponentInstanceNew(ac, &mOutUnit);
    //サンプリングレートを取得する
    AudioStreamBasicDescription tASBD;
    UInt32 nSize = sizeof(tASBD);
    OSStatus err = AudioUnitGetProperty( mOutUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &tASBD, &nSize );
    if ( err != noErr ) {
        NSLog( @"AudioUnitGetProperty(kAudioUnitProperty_StreamFormat) failed. err=%d\n", err );
        return self;
    }
    mSamplingRate = tASBD.mSampleRate;
    global = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    sineWaveData = [[SineWaveData alloc] init];
    // コールバック関数の登録
    AURenderCallbackStruct input;
    input.inputProc = RenderCallback;
    input.inputProcRefCon = &sineWaveData;
    AudioUnitSetProperty (mOutUnit,
                          kAudioUnitProperty_SetRenderCallback,
                          kAudioUnitScope_Input,
                          0,
                          &input,
                          sizeof(input));
    //サンプリングレートを取得する
    Float64 _outSampleRate = 0.0;
    UInt32 size = sizeof(Float64);
    AudioUnitGetProperty (mOutUnit,
                          kAudioUnitProperty_SampleRate,
                          kAudioUnitScope_Output,
                          0,
                          &_outSampleRate,
                          &size);
    outSampleRate = (double)_outSampleRate;
    // Audio Unitの初期化
    AudioUnitInitialize(mOutUnit);
    global.is_que_playing = NO;
    [self setVolume:fVol];
    return self;
}
// 後処理
- (void)dealloc
{
    AudioUnitUninitialize(mOutUnit);
    AudioComponentInstanceDispose(mOutUnit);
}
// 音量を設定する
- (void)setVolume:(float)fVol
{
    mVolume = fVol;
    OSStatus err = AudioUnitSetParameter( mOutUnit,
                                         kHALOutputParam_Volume,
                                         kAudioUnitScope_Global,
                                         0,
                                         mVolume,
                                         0 );
    if ( err != noErr ) {
        NSLog( @"AudioUnitSetParameter(kHALOutputParam_Volume) failed. err=%d\n", err );
    }
}
- (void)start {
    AudioOutputUnitStart(mOutUnit); //再生する
    isInitialized = YES;
}
- (void)end {
    AudioOutputUnitStop(mOutUnit);
}
- (void)play //再生する
{
    global.is_que_playing = YES;
}
- (void)stop //停止
{
    global.is_que_playing = NO;
}
@end
