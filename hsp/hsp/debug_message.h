//
//  debug_message.h
//  crowbar-xcode
//
//  Created by dolphilia on 2016/06/16.
//  Copyright © 2016年 dolphilia. All rights reserved.
//
#ifndef debug_message_h
#define debug_message_h
#define DEBUG_MESSAGE 0
#if defined(DEBUG_MESSAGE) && DEBUG_MESSAGE > 0
#define DEBUG_PRINT(fmt, args...) fprintf(stderr, "\nDEBUG:\n    File:%s\n    Line:%d\n    Func:%s()\n    \n" fmt, \
__FILE__, __LINE__, __func__, ##args)
#else
#define DEBUG_PRINT(fmt, args...) /* Don't do anything in release builds */
#endif
#if defined(DEBUG_MESSAGE) && DEBUG_MESSAGE > 0
#define DEBUG_IN fprintf(stderr, "I: %s() in %d from %s\n" , __func__, __LINE__, __FILE__)
#else
#define DEBUG_IN /* Don't do anything in release builds */
#endif
#if defined(DEBUG_MESSAGE) && DEBUG_MESSAGE > 0
#define DEBUG_OUT fprintf(stderr, "O: %s() in %d from %s\n" , __func__, __LINE__, __FILE__)
#else
#define DEBUG_OUT /* Don't do anything in release builds */
#endif
#if defined(DEBUG_MESSAGE) && DEBUG_MESSAGE > 3
#define DEBUG_TIMER_IN fprintf(stderr, "I: %s() in %d from %s\n" , __func__, __LINE__, __FILE__)
#else
#define DEBUG_TIMER_IN /* Don't do anything in release builds */
#endif
#if defined(DEBUG_MESSAGE) && DEBUG_MESSAGE > 3
#define DEBUG_TIMER_OUT fprintf(stderr, "O: %s() in %d from %s\n" , __func__, __LINE__, __FILE__)
#else
#define DEBUG_TIMER_OUT /* Don't do anything in release builds */
#endif
#if defined(DEBUG_MESSAGE) && DEBUG_MESSAGE > 0
#define DEBUG_EXIT fprintf(stderr, "E: %s() in %d from %s\n" , __func__, __LINE__, __FILE__)
#else
#define DEBUG_EXIT /* Don't do anything in release builds */
#endif
#endif /* debug_message_h */
