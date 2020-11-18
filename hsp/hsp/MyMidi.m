//
//  MyMidi.m
//
#import <Foundation/Foundation.h>
#import "MyMidi.h"
static void
MIDIInputProc(const MIDIPacketList *pktlist,
              void *readProcRefCon, void *srcConnRefCon)
{
    @autoreleasepool {
        AppDelegate* global = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        if(global.is_start_midi_event) {
            MIDIPacket *packet = (MIDIPacket *)&(pktlist->packet[0]); //MIDIパケットリストの先頭のMIDIPacketのポインタを取得
            UInt32 packetCount = pktlist->numPackets; //パケットリストからパケットの数を取得
            for (NSInteger i = 0; i < packetCount; i++) {
                Byte mes = packet->data[0] & 0xF0; //data[0]からメッセージの種類とチャンネルを分けて取得する
                Byte ch = packet->data[0] & 0x0F;
                if ((mes == 0x90) && (packet->data[2] != 0)) { //メッセージの種類に応じてログに表示
                    [global.midi_events addObject:@"noteon"];
                    [global.midi_events addObject:[NSNumber numberWithUnsignedInt:packet->data[1]]];
                    [global.midi_events addObject:[NSNumber numberWithUnsignedInt:packet->data[2]]];
                    [global.midi_events addObject:[NSNumber numberWithUnsignedInt:ch]];
                }
                else if (mes == 0x80 || mes == 0x90) {
                    [global.midi_events addObject:@"noteoff"];
                    [global.midi_events addObject:[NSNumber numberWithUnsignedInt:packet->data[1]]];
                    [global.midi_events addObject:[NSNumber numberWithUnsignedInt:packet->data[2]]];
                    [global.midi_events addObject:[NSNumber numberWithUnsignedInt:ch]];
                }
                else if (mes == 0xB0) {
                    [global.midi_events addObject:@"cc"];
                    [global.midi_events addObject:[NSNumber numberWithUnsignedInt:packet->data[1]]];
                    [global.midi_events addObject:[NSNumber numberWithUnsignedInt:packet->data[2]]];
                    [global.midi_events addObject:[NSNumber numberWithUnsignedInt:packet->data[3]]];
                }
                else {}
                packet = MIDIPacketNext(packet); //次のパケットへ進む
            }
        }
    }
}
@implementation MyMidi
- (instancetype)init
{
    self = [super init];
    if (self) {
        //
        global = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        global.midi_events = [NSMutableArray arrayWithCapacity:0];
        global.is_start_midi_event = NO;
        // Do any additional setup after loading the view.
        OSStatus err;
        MIDIClientRef clientRef;
        MIDIPortRef inputPortRef;
        //MIDIクライアントを作成する
        NSString *clientName = @"inputClient";
        err = MIDIClientCreate((__bridge CFStringRef)clientName, NULL, NULL, &clientRef);
        if (err != noErr) {
            NSLog(@"MIDIClientCreate err = %d", err);
            return nil;
        }
        //MIDIポートを作成する
        NSString *inputPortName = @"inputPort";
        err = MIDIInputPortCreate(
                                  clientRef, (__bridge CFStringRef)inputPortName,
                                  MIDIInputProc, NULL, &inputPortRef);
        if (err != noErr) {
            NSLog(@"MIDIInputPortCreate err = %d", err);
            return nil;
        }
        //MIDIエンドポイントを取得し、MIDIポートに接続する
        ItemCount sourceCount = MIDIGetNumberOfSources();
        for (ItemCount i = 0; i < sourceCount; i++) {
            MIDIEndpointRef sourcePointRef = MIDIGetSource(i);
            err = MIDIPortConnectSource(inputPortRef, sourcePointRef, NULL);
            if (err != noErr) {
                NSLog(@"MIDIPortConnectSource err = %d", err);
                return nil;
            }
        }
    }
    return self;
}
@end
