//
//  logMessage.m
//  hsed
//
//  Created by dolphilia on 2016/03/21.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "logMessage.h"
#import "AppDelegate.h"
//#include <stdarg.h>

@implementation LogMessage

-(void)logMessage:(NSString *)str {
    
}

-(void)logMessage:(NSString *)str p1:(const char *)p1 {
    
}

-(void)logMessage:(NSString *)str p1:(const char *)p1 p2:(const char *)p2 {
    
}

@end


void logMessage(char *str) {
    @autoreleasepool {
        AppDelegate* global = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        NSString* nsstr = [NSString stringWithCString:str encoding:NSUTF8StringEncoding];
        global.logString = [global.logString stringByAppendingString:nsstr];
    }
}
void logMessageC(const char *str, const char *p1) {
    @autoreleasepool {
        AppDelegate* global = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        NSString* nsstr = [NSString stringWithCString:str encoding:NSUTF8StringEncoding];
        global.logString = [global.logString stringByAppendingFormat:nsstr,p1];
    }
}
void logMessageCC(const char *str, const char *p1, const char *p2) {
    @autoreleasepool {
        AppDelegate* global = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        NSString* nsstr = [NSString stringWithCString:str encoding:NSUTF8StringEncoding];
        global.logString = [global.logString stringByAppendingFormat:nsstr,p1,p2];
    }
}
void logMessageCCC(const char *str, const char *p1, const char *p2, const char *p3) {
    @autoreleasepool {
        AppDelegate* global = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        NSString* nsstr = [NSString stringWithCString:str encoding:NSUTF8StringEncoding];
        global.logString = [global.logString stringByAppendingFormat:nsstr,p1,p2,p3];
    }
}
void logMessageCCCC(const char *str, const char *p1, const char *p2, const char *p3, const char *p4) {
    @autoreleasepool {
        AppDelegate* global = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        NSString* nsstr = [NSString stringWithCString:str encoding:NSUTF8StringEncoding];
        global.logString = [global.logString stringByAppendingFormat:nsstr,p1,p2,p3,p4];
    }
}
void logMessageI(const char *str, int *p1) {
    @autoreleasepool {
        AppDelegate* global = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        NSString* nsstr = [NSString stringWithCString:str encoding:NSUTF8StringEncoding];
        global.logString = [global.logString stringByAppendingFormat:nsstr,p1];
    }
}
void logMessageII(const char *str, int *p1, int *p2) {
    @autoreleasepool {
        AppDelegate* global = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        NSString* nsstr = [NSString stringWithCString:str encoding:NSUTF8StringEncoding];
        global.logString = [global.logString stringByAppendingFormat:nsstr,p1,p2];
    }
}
void logMessageIII(const char *str, int *p1, int *p2, int *p3) {
    @autoreleasepool {
        AppDelegate* global = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        NSString* nsstr = [NSString stringWithCString:str encoding:NSUTF8StringEncoding];
        global.logString = [global.logString stringByAppendingFormat:nsstr,p1,p2,p3];
    }
}
void logMessageIIII(const char *str, int *p1, int *p2, int *p3, int p4) {
    @autoreleasepool {
        AppDelegate* global = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        NSString* nsstr = [NSString stringWithCString:str encoding:NSUTF8StringEncoding];
        global.logString = [global.logString stringByAppendingFormat:nsstr,p1,p2,p3,p4];
    }
}