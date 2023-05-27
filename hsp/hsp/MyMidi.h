//
//  MyMidi.h
//  hsp
//
//  Created by 半澤 聡 on 2016/07/03.
//  Copyright © 2016年 dolphilia. All rights reserved.
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
