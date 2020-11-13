//
//  MyAudio.m
//  avaudioenginetest
//
//  Created by dolphilia on 2016/02/13.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyAudio.h"

#define MAX_VALUE_AUDIO_BUFFER 16

@implementation MyAudio

- (instancetype)init
{
    self = [super init];
    if (self) {
        global = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        self.audioEngine = [[AVAudioEngine alloc] init]; //AVAudioEngineを初期化する
        
        self.audioFiles = [[NSMutableArray alloc] initWithCapacity:0];
        for (int i=0; i<MAX_VALUE_AUDIO_BUFFER; i++) {
            [self.audioFiles addObject:[[AVAudioFile alloc] init]];
        }
        self.audioPCMBuffers = [[NSMutableArray alloc] initWithCapacity:0];
        for (int i=0; i<MAX_VALUE_AUDIO_BUFFER; i++) {
            [self.audioPCMBuffers addObject:[[AVAudioPCMBuffer alloc] init]];
        }
        self.playerNodes = [[NSMutableArray alloc] initWithCapacity:0];
        for (int i=0; i<MAX_VALUE_AUDIO_BUFFER; i++) {
            [self.playerNodes addObject:[[AVAudioPlayerNode alloc] init]];
        }
    }
    return self;
}

- (void)loadWithFilename:(NSString*)filename index:(int)index
{
    if(index >= MAX_VALUE_AUDIO_BUFFER) {
        return;
    }
    NSURL* fileURL = [NSURL URLWithString:[self chooseCurrentFilePath:filename]];
    
    //オーディオファイルを読み込んで生成する
    [self.audioFiles replaceObjectAtIndex:index withObject:[self generateAVAudioFileWithNSURL:fileURL]];
    //self.audioFile = [self generateAVAudioFileWithNSURL:fileURL];
    if ([self.audioFiles[index] isEqual:nil]) {
        return;
    }

    [self.audioPCMBuffers replaceObjectAtIndex:index withObject:[self generateAVAudioPCMBuffer]]; //オーディオバッファを初期化する
    
    //オーディオバッファをファイルに読み込む
    [self.audioFiles[index] readIntoBuffer:self.audioPCMBuffers[index] error:nil];
    
    //ノードを生成・接続する
    AVAudioMixerNode *mixerNode = [self.audioEngine mainMixerNode]; //メインミキサーノードを取得する
    [self.playerNodes replaceObjectAtIndex:index withObject:[[AVAudioPlayerNode alloc] init]]; //プレーヤーノードを生成する
    [self.audioEngine attachNode:self.playerNodes[index]]; //オブジェクトを準備する
    [self.audioEngine connect:self.playerNodes[index] to:mixerNode format:[self.audioFiles[index] processingFormat]]; //ノード同士を接続する

    [self startAVAudioEngine]; //AVAudioEngineを開始する
}

- (NSString*)chooseCurrentFilePath:(NSString*)filename
{
    //最適なファイルパスを選び、ファイル名と結合したNSString文字列を返す
    NSString * path;
    if (global.is_startax_in_resource) { //リソース内にstart.axがある場合
        path = [NSBundle mainBundle].resourcePath; //リソースディレクトリ
        path = [path stringByAppendingString:@"/"];
        path = [path stringByAppendingString:filename];
    }
    else if( ![global.current_script_path isEqual:@""] ) { //ソースコードのあるディレクトリ
        path = global.current_script_path;
    }
    else { //hsptmp
        path = [NSHomeDirectory() stringByAppendingString:@"/Documents/hsptmp"];
    }
    path = [path stringByAppendingString:@"/"];
    path = [path stringByAppendingString:filename];
    return path;
}

- (AVAudioFile*)generateAVAudioFileWithNSURL:(NSURL*)fileURL
{
    NSError *error = nil;
    AVAudioFile* audioFile = [[AVAudioFile alloc] initForReading:fileURL error:&error];
    if (error) {
        NSLog(@"オーディオファイルの読み込み／生成でエラーが発生しました");
        return nil;
    }
    return audioFile;
}

- (AVAudioPCMBuffer*)generateAVAudioPCMBuffer
{
    AVAudioFormat *audioFormat = [self.audioFiles[0] processingFormat]; //オーディオバッファを用意する（ループ再生のため）
    AVAudioFrameCount length = (AVAudioFrameCount)[self.audioFiles[0] length];
    return [[AVAudioPCMBuffer alloc] initWithPCMFormat:audioFormat frameCapacity:length];
}

- (BOOL)startAVAudioEngine
{
    NSError *error = nil;
    if (![self.audioEngine startAndReturnError:&error]) {
        NSLog(@"AudioEngineの開始でエラーが発生しました");
        return NO;
    }
    return YES;
}

- (void)loadWithFilenameReverb:(NSString*)filename withExtension:(NSString*)extension
{
    //オーディオファイルを読み込んで生成する
    NSError *error = nil;
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:filename withExtension:extension];
    self.audioFile = [[AVAudioFile alloc] initForReading:fileURL error:&error];
    if (error) {
        NSLog(@"オーディオファイルの読み込み／生成でエラーが発生しました");
        return;
    }
    
    //オーディオバッファを初期化する
    AVAudioFormat *audioFormat = self.audioFile.processingFormat; //オーディオバッファを用意する（ループ再生のため）
    AVAudioFrameCount length = (AVAudioFrameCount)self.audioFile.length;
    self.audioPCMBuffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:audioFormat frameCapacity:length];
    [self.audioFile readIntoBuffer:self.audioPCMBuffer error:nil];
    
    //ノードを生成する
    AVAudioMixerNode *mixerNode = [self.audioEngine mainMixerNode]; //メインミキサーノードを取得する
    self.playerNode = [[AVAudioPlayerNode alloc] init]; //プレーヤーノードを生成する
    [self.audioEngine attachNode:self.playerNode]; //オブジェクトを準備する
    
    //リバーブエフェクトノードの生成する
    self.reverbNode = [[AVAudioUnitReverb alloc] init];
    [self.reverbNode loadFactoryPreset:AVAudioUnitReverbPresetLargeHall];
    self.reverbNode.wetDryMix = 30.0f;
    [self.audioEngine attachNode:self.reverbNode];
    
    //ノードを接続する
    [self.audioEngine connect:self.playerNode to:self.reverbNode format:self.audioFile.processingFormat];
    [self.audioEngine connect:self.reverbNode to:mixerNode format:self.audioFile.processingFormat];
    
    //AVAudioEngineを開始する
    if (![self.audioEngine startAndReturnError:&error]) {
        NSLog(@"AudioEngineの初期化エラー");
        return;
    }
}

- (void)changeVolume:(float)value index:(int)index
{
    if(index >= MAX_VALUE_AUDIO_BUFFER) {
        return;
    }
    [self.playerNodes[index] setVolume:value];
}

- (void)changePan:(float)value index:(int)index
{
    if(index >= MAX_VALUE_AUDIO_BUFFER) {
        return;
    }
    [self.playerNodes[index] setPan:value];
}

- (void)play:(int)index
{
    if(index >= MAX_VALUE_AUDIO_BUFFER) {
        return;
    }
    [self.playerNodes[index] scheduleFile:self.audioFiles[index] atTime:nil completionHandler:nil];// オーディオファイルの再生をスケジュールする
    [(AVAudioPlayerNode*)self.playerNodes[index] play]; // オーディオプレイヤーノードの開始
}

- (void)loop:(int)index
{
    if(index >= MAX_VALUE_AUDIO_BUFFER) {
        return;
    }
    [self.playerNodes[index] scheduleBuffer:self.audioPCMBuffer atTime:nil options:AVAudioPlayerNodeBufferLoops completionHandler:nil];//オーディオバッファの再生をスケジュールする
    [(AVAudioPlayerNode*)self.playerNodes[index] play];
}

- (void)stop:(int)index
{
    if(index >= MAX_VALUE_AUDIO_BUFFER) {
        return;
    }
    if(index < 0) {
        for (int i=0; i<MAX_VALUE_AUDIO_BUFFER; i++) {
            [(AVAudioPlayerNode*)self.playerNodes[i] stop];
        }
    }
    else {
        [(AVAudioPlayerNode*)self.playerNodes[index] stop];
    }
}

@end