//
//  MyMidi.h
//

#ifndef MyMidi_h
#define MyMidi_h

#import <Cocoa/Cocoa.h>
#import <CoreMIDI/CoreMIDI.h>
#import "AppDelegate.h"
#include "debug_message.h"

@interface MyMidi : NSObject {
    AppDelegate *global;
}

@end

#endif /* MyMidi_h */
