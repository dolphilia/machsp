//
//  logMessage.h
//  hsed
//
//  Created by dolphilia on 2016/03/21.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#ifndef logMessage_h
#define logMessage_h

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

@interface LogMessage : NSString

- (void)logMessage:(NSString *)str;

- (void)logMessage:(NSString *)str p1:(const char *)p1;

- (void)logMessage:(NSString *)str p1:(const char *)p1 p2:(const char *)p2;

@end

void logMessage(char *str);

void logMessageC(const char *str, const char *p1);

void logMessageCC(const char *str, const char *p1, const char *p2);

void logMessageCCC(const char *str, const char *p1, const char *p2, const char *p3);

void logMessageCCCC(const char *str, const char *p1, const char *p2, const char *p3, const char *p4);

void logMessageI(const char *str, int *p1);

void logMessageII(const char *str, int *p1, int *p2);

void logMessageIII(const char *str, int *p1, int *p2, int *p3);

void logMessageIIII(const char *str, int *p1, int *p2, int *p3, int p4);

#endif /* logMessage_h */
