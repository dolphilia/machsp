//
//  MyAudio.h
//

#ifndef MyAudio_h
#define MyAudio_h

#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"
#include "debug_message.h"

@interface MyAudio : NSObject {
    AppDelegate *global;
}

//
@property(readwrite, nonatomic) NSMutableArray *audioFiles;
@property(readwrite, nonatomic) NSMutableArray *audioPCMBuffers;
@property(readwrite, nonatomic) NSMutableArray *playerNodes;

//
@property(nonatomic) AVAudioEngine *audioEngine;
@property(nonatomic) AVAudioFile *audioFile;
@property(nonatomic) AVAudioPCMBuffer *audioPCMBuffer;
@property(nonatomic) AVAudioPlayerNode *playerNode;
@property(nonatomic) AVAudioUnitReverb *reverbNode;

- (void)loadWithFilename:(NSString *)filename index:(int)index;// withExtension:(NSString*)extension;
- (void)loadWithFilenameReverb:(NSString *)filename withExtension:(NSString *)extension;

- (void)changeVolume:(float)value index:(int)index;

- (void)changePan:(float)value index:(int)index;

- (void)play:(int)index;

- (void)loop:(int)index;

- (void)stop:(int)index;

@end


#endif /* MyAudio_h */
