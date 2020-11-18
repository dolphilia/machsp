//
//  MyView.h
//  objc-calayer-example
//
//  Created by dolphilia on 2016/02/01.
//  Copyright © 2016年 dolphilia. All rights reserved.
//
#ifndef MyView_h
#define MyView_h
#import <Cocoa/Cocoa.h>
#import "MyCALayer.h"
#include "debug_message.h"
@interface MyView : NSView {
    NSImage* image;
    MyCALayer* mylayer;
@public
    //mouse
    BOOL isMouseDown;
    BOOL isMouseUp;
    BOOL isMouseDragged;
    BOOL isRightMouseDown;
    BOOL isRightMouseUp;
    BOOL isRightMouseDragged;
    //key
    BOOL isKeyDown_Left;    // 123
    BOOL isKeyDown_Up;      // 126
    BOOL isKeyDown_Right;   // 124
    BOOL isKeyDown_Down;    // 125
    BOOL isKeyDown_Space;   // 49
    BOOL isKeyDown_Enter;   // 36
    BOOL isKeyDown_Control; // NSControlKeyMask
    BOOL isKeyDown_Escape;  // 53
    BOOL isKeyDown_Tab;     // 48
    //
    BOOL isKeyDown_BackSpace;
    BOOL isKeyDown_0;
    BOOL isKeyDown_1;
    BOOL isKeyDown_2;
    BOOL isKeyDown_3;
    BOOL isKeyDown_4;
    BOOL isKeyDown_5;
    BOOL isKeyDown_6;
    BOOL isKeyDown_7;
    BOOL isKeyDown_8;
    BOOL isKeyDown_9;
    BOOL isKeyDown_Ten0;
    BOOL isKeyDown_Ten1;
    BOOL isKeyDown_Ten2;
    BOOL isKeyDown_Ten3;
    BOOL isKeyDown_Ten4;
    BOOL isKeyDown_Ten5;
    BOOL isKeyDown_Ten6;
    BOOL isKeyDown_Ten7;
    BOOL isKeyDown_Ten8;
    BOOL isKeyDown_Ten9;
    BOOL isKeyDown_TenDot;
    BOOL isKeyDown_TenEnter;
    BOOL isKeyDown_TenPlus;
    BOOL isKeyDown_TenMinus;
    BOOL isKeyDown_TenMul;
    BOOL isKeyDown_TenDiv;
    BOOL isKeyDown_NumLock;
    BOOL isKeyDown_F1;
    BOOL isKeyDown_F2;
    BOOL isKeyDown_F3;
    BOOL isKeyDown_F4;
    BOOL isKeyDown_F5;
    BOOL isKeyDown_F6;
    BOOL isKeyDown_F7;
    BOOL isKeyDown_F8;
    BOOL isKeyDown_F9;
    BOOL isKeyDown_F10;
    BOOL isKeyDown_F11;
    BOOL isKeyDown_F12;
    BOOL isKeyDown_Delete;
    BOOL isKeyDown_Insert;
    BOOL isKeyDown_PauseBreak;
    BOOL isKeyDown_PrtScSysRq;
    BOOL isKeyDown_HankakuZenkaku;
    //
    BOOL isKeyDown_A;
    BOOL isKeyDown_B;
    BOOL isKeyDown_C;
    BOOL isKeyDown_D;
    BOOL isKeyDown_E;
    BOOL isKeyDown_F;
    BOOL isKeyDown_G;
    BOOL isKeyDown_H;
    BOOL isKeyDown_I;
    BOOL isKeyDown_J;
    BOOL isKeyDown_K;
    BOOL isKeyDown_L;
    BOOL isKeyDown_M;
    BOOL isKeyDown_N;
    BOOL isKeyDown_O;
    BOOL isKeyDown_P;
    BOOL isKeyDown_Q;
    BOOL isKeyDown_R;
    BOOL isKeyDown_S;
    BOOL isKeyDown_T;
    BOOL isKeyDown_U;
    BOOL isKeyDown_V;
    BOOL isKeyDown_W;
    BOOL isKeyDown_X;
    BOOL isKeyDown_Y;
    BOOL isKeyDown_Z;
}
-(MyCALayer*)getMyCALayer;
//
-(int)getMouseX;
-(int)getMouseY;
//
-(BOOL)getIsMouseDown;
-(BOOL)getIsRightMouseDown;
-(BOOL)getIsKeyDown_Left;
-(BOOL)getIsKeyDown_Up;
-(BOOL)getIsKeyDown_Right;
-(BOOL)getIsKeyDown_Down;
-(BOOL)getIsKeyDown_Space;
-(BOOL)getIsKeyDown_Enter;
-(BOOL)getIsKeyDown_Escape;
-(BOOL)getIsKeyDown_Tab;
//
-(BOOL)getIsKeyDown_BackSpace;
-(BOOL)getIsKeyDown_0;
-(BOOL)getIsKeyDown_1;
-(BOOL)getIsKeyDown_2;
-(BOOL)getIsKeyDown_3;
-(BOOL)getIsKeyDown_4;
-(BOOL)getIsKeyDown_5;
-(BOOL)getIsKeyDown_6;
-(BOOL)getIsKeyDown_7;
-(BOOL)getIsKeyDown_8;
-(BOOL)getIsKeyDown_9;
-(BOOL)getIsKeyDown_Ten0;
-(BOOL)getIsKeyDown_Ten1;
-(BOOL)getIsKeyDown_Ten2;
-(BOOL)getIsKeyDown_Ten3;
-(BOOL)getIsKeyDown_Ten4;
-(BOOL)getIsKeyDown_Ten5;
-(BOOL)getIsKeyDown_Ten6;
-(BOOL)getIsKeyDown_Ten7;
-(BOOL)getIsKeyDown_Ten8;
-(BOOL)getIsKeyDown_Ten9;
-(BOOL)getIsKeyDown_TenDot;
-(BOOL)getIsKeyDown_TenEnter;
-(BOOL)getIsKeyDown_TenPlus;
-(BOOL)getIsKeyDown_TenMinus;
-(BOOL)getIsKeyDown_TenMul;
-(BOOL)getIsKeyDown_TenDiv;
-(BOOL)getIsKeyDown_NumLock;
-(BOOL)getIsKeyDown_F1;
-(BOOL)getIsKeyDown_F2;
-(BOOL)getIsKeyDown_F3;
-(BOOL)getIsKeyDown_F4;
-(BOOL)getIsKeyDown_F5;
-(BOOL)getIsKeyDown_F6;
-(BOOL)getIsKeyDown_F7;
-(BOOL)getIsKeyDown_F8;
-(BOOL)getIsKeyDown_F9;
-(BOOL)getIsKeyDown_F10;
-(BOOL)getIsKeyDown_F11;
-(BOOL)getIsKeyDown_F12;
-(BOOL)getIsKeyDown_Delete;
-(BOOL)getIsKeyDown_Insert;
-(BOOL)getIsKeyDown_PauseBreak;
-(BOOL)getIsKeyDown_PrtScSysRq;
-(BOOL)getIsKeyDown_HankakuZenkaku;
//
-(BOOL)getIsKeyDown_A;
-(BOOL)getIsKeyDown_B;
-(BOOL)getIsKeyDown_C;
-(BOOL)getIsKeyDown_D;
-(BOOL)getIsKeyDown_E;
-(BOOL)getIsKeyDown_F;
-(BOOL)getIsKeyDown_G;
-(BOOL)getIsKeyDown_H;
-(BOOL)getIsKeyDown_I;
-(BOOL)getIsKeyDown_J;
-(BOOL)getIsKeyDown_K;
-(BOOL)getIsKeyDown_L;
-(BOOL)getIsKeyDown_M;
-(BOOL)getIsKeyDown_N;
-(BOOL)getIsKeyDown_O;
-(BOOL)getIsKeyDown_P;
-(BOOL)getIsKeyDown_Q;
-(BOOL)getIsKeyDown_R;
-(BOOL)getIsKeyDown_S;
-(BOOL)getIsKeyDown_T;
-(BOOL)getIsKeyDown_U;
-(BOOL)getIsKeyDown_V;
-(BOOL)getIsKeyDown_W;
-(BOOL)getIsKeyDown_X;
-(BOOL)getIsKeyDown_Y;
-(BOOL)getIsKeyDown_Z;
@end
#endif /* MyView_h */
