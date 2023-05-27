//
//  MyView.m
//  objc-calayer-example
//
//  Created by dolphilia on 2016/02/01.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyView.h"

@implementation MyView

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        mylayer = [[MyCALayer alloc] init];
        self.wantsLayer = true;
        self.layer.delegate = (id)self;
        self.layer = mylayer;
    }
    return self;
}

//keyDown keyUpを受け取れるようにする
- (BOOL)acceptsFirstResponder {
    [[self window] makeFirstResponder:self];
    return YES;
}

- (BOOL)becomeFirstResponder {
    return YES;
}

-(void)awakeFromNib {
}

-(MyCALayer*)getMyCALayer {
    return mylayer;
}

-(int)getScreenWidth {
    NSScreen *mainScreen = [NSScreen mainScreen];
    return (int)mainScreen.frame.size.width;
}

-(int)getScreenHeight {
    NSScreen *mainScreen = [NSScreen mainScreen];
    return (int)mainScreen.frame.size.height;
}

-(int)getMouseX {
    NSPoint screenPoint = [NSEvent mouseLocation];
    NSRect rect = [[self window] convertRectFromScreen:NSMakeRect(screenPoint.x, screenPoint.y, 0, 0)];
    NSPoint windowPoint = rect.origin;
    NSPoint point = [self convertPoint:windowPoint fromView:nil];
    return (int)point.x;
}

-(int)getMouseY {
    NSPoint screenPoint = [NSEvent mouseLocation];
    NSRect rect = [[self window] convertRectFromScreen:NSMakeRect(screenPoint.x, screenPoint.y, 0, 0)];
    NSPoint windowPoint = rect.origin;
    NSPoint point = [self convertPoint:windowPoint fromView:nil];
    return (int)((point.y-self.frame.size.height) * -1.0);
}

-(BOOL)getIsMouseDown {return isMouseDown;}
-(BOOL)getIsRightMouseDown {return isRightMouseDown;}
//
-(BOOL)getIsKeyDown_Left{return isKeyDown_Left;}
-(BOOL)getIsKeyDown_Up{return isKeyDown_Up;}
-(BOOL)getIsKeyDown_Right{return isKeyDown_Right;}
-(BOOL)getIsKeyDown_Down{return isKeyDown_Down;}
-(BOOL)getIsKeyDown_Space{return isKeyDown_Space;}
-(BOOL)getIsKeyDown_Enter{return isKeyDown_Enter;}
-(BOOL)getIsKeyDown_Escape{return isKeyDown_Escape;}
-(BOOL)getIsKeyDown_Tab{return isKeyDown_Tab;}
//
-(BOOL)getIsKeyDown_BackSpace{return isKeyDown_BackSpace;}
-(BOOL)getIsKeyDown_0{return isKeyDown_0;}
-(BOOL)getIsKeyDown_1{return isKeyDown_1;}
-(BOOL)getIsKeyDown_2{return isKeyDown_2;}
-(BOOL)getIsKeyDown_3{return isKeyDown_3;}
-(BOOL)getIsKeyDown_4{return isKeyDown_4;}
-(BOOL)getIsKeyDown_5{return isKeyDown_5;}
-(BOOL)getIsKeyDown_6{return isKeyDown_6;}
-(BOOL)getIsKeyDown_7{return isKeyDown_7;}
-(BOOL)getIsKeyDown_8{return isKeyDown_8;}
-(BOOL)getIsKeyDown_9{return isKeyDown_9;}
-(BOOL)getIsKeyDown_Ten0{return isKeyDown_Ten0;}
-(BOOL)getIsKeyDown_Ten1{return isKeyDown_Ten1;}
-(BOOL)getIsKeyDown_Ten2{return isKeyDown_Ten2;}
-(BOOL)getIsKeyDown_Ten3{return isKeyDown_Ten3;}
-(BOOL)getIsKeyDown_Ten4{return isKeyDown_Ten4;}
-(BOOL)getIsKeyDown_Ten5{return isKeyDown_Ten5;}
-(BOOL)getIsKeyDown_Ten6{return isKeyDown_Ten6;}
-(BOOL)getIsKeyDown_Ten7{return isKeyDown_Ten7;}
-(BOOL)getIsKeyDown_Ten8{return isKeyDown_Ten8;}
-(BOOL)getIsKeyDown_Ten9{return isKeyDown_Ten9;}
-(BOOL)getIsKeyDown_TenDot{return isKeyDown_TenDot;}
-(BOOL)getIsKeyDown_TenEnter{return isKeyDown_TenEnter;}
-(BOOL)getIsKeyDown_TenPlus{return isKeyDown_TenPlus;}
-(BOOL)getIsKeyDown_TenMinus{return isKeyDown_TenMinus;}
-(BOOL)getIsKeyDown_TenMul{return isKeyDown_TenMul;}
-(BOOL)getIsKeyDown_TenDiv{return isKeyDown_TenDiv;}
-(BOOL)getIsKeyDown_NumLock{return isKeyDown_NumLock;}
-(BOOL)getIsKeyDown_F1{return isKeyDown_F1;}
-(BOOL)getIsKeyDown_F2{return isKeyDown_F2;}
-(BOOL)getIsKeyDown_F3{return isKeyDown_F3;}
-(BOOL)getIsKeyDown_F4{return isKeyDown_F4;}
-(BOOL)getIsKeyDown_F5{return isKeyDown_F5;}
-(BOOL)getIsKeyDown_F6{return isKeyDown_F6;}
-(BOOL)getIsKeyDown_F7{return isKeyDown_F7;}
-(BOOL)getIsKeyDown_F8{return isKeyDown_F8;}
-(BOOL)getIsKeyDown_F9{return isKeyDown_F9;}
-(BOOL)getIsKeyDown_F10{return isKeyDown_F10;}
-(BOOL)getIsKeyDown_F11{return isKeyDown_F11;}
-(BOOL)getIsKeyDown_F12{return isKeyDown_F12;}
-(BOOL)getIsKeyDown_Delete{return isKeyDown_Delete;}
-(BOOL)getIsKeyDown_Insert{return isKeyDown_Insert;}
-(BOOL)getIsKeyDown_PauseBreak{return isKeyDown_PauseBreak;}
-(BOOL)getIsKeyDown_PrtScSysRq{return isKeyDown_PrtScSysRq;}
-(BOOL)getIsKeyDown_HankakuZenkaku{return isKeyDown_HankakuZenkaku;}
//
-(BOOL)getIsKeyDown_A{return isKeyDown_A;}
-(BOOL)getIsKeyDown_B{return isKeyDown_B;}
-(BOOL)getIsKeyDown_C{return isKeyDown_C;}
-(BOOL)getIsKeyDown_D{return isKeyDown_D;}
-(BOOL)getIsKeyDown_E{return isKeyDown_E;}
-(BOOL)getIsKeyDown_F{return isKeyDown_F;}
-(BOOL)getIsKeyDown_G{return isKeyDown_G;}
-(BOOL)getIsKeyDown_H{return isKeyDown_H;}
-(BOOL)getIsKeyDown_I{return isKeyDown_I;}
-(BOOL)getIsKeyDown_J{return isKeyDown_J;}
-(BOOL)getIsKeyDown_K{return isKeyDown_K;}
-(BOOL)getIsKeyDown_L{return isKeyDown_L;}
-(BOOL)getIsKeyDown_M{return isKeyDown_M;}
-(BOOL)getIsKeyDown_N{return isKeyDown_N;}
-(BOOL)getIsKeyDown_O{return isKeyDown_O;}
-(BOOL)getIsKeyDown_P{return isKeyDown_P;}
-(BOOL)getIsKeyDown_Q{return isKeyDown_Q;}
-(BOOL)getIsKeyDown_R{return isKeyDown_R;}
-(BOOL)getIsKeyDown_S{return isKeyDown_S;}
-(BOOL)getIsKeyDown_T{return isKeyDown_T;}
-(BOOL)getIsKeyDown_U{return isKeyDown_U;}
-(BOOL)getIsKeyDown_V{return isKeyDown_V;}
-(BOOL)getIsKeyDown_W{return isKeyDown_W;}
-(BOOL)getIsKeyDown_X{return isKeyDown_X;}
-(BOOL)getIsKeyDown_Y{return isKeyDown_Y;}
-(BOOL)getIsKeyDown_Z{return isKeyDown_Z;}

-(void)keyDown:(NSEvent *)theEvent {
    switch([theEvent keyCode]) {
        case 123:isKeyDown_Left=YES;break;
        case 126:isKeyDown_Up=YES;break;
        case 124:isKeyDown_Right=YES;break;
        case 125:isKeyDown_Down=YES;break;
        case 49:isKeyDown_Space=YES;break;
        case 36:isKeyDown_Enter=YES;break;
        case 53:isKeyDown_Escape=YES;break;
        case 48:isKeyDown_Tab=YES;break;
        case 51:isKeyDown_BackSpace=YES;break;
        case 29:isKeyDown_0=YES;break;
        case 18:isKeyDown_1=YES;break;
        case 19:isKeyDown_2=YES;break;
        case 20:isKeyDown_3=YES;break;
        case 21:isKeyDown_4=YES;break;
        case 23:isKeyDown_5=YES;break;
        case 22:isKeyDown_6=YES;break;
        case 26:isKeyDown_7=YES;break;
        case 28:isKeyDown_8=YES;break;
        case 25:isKeyDown_9=YES;break;
        case 82:isKeyDown_Ten0=YES;break;
        case 83:isKeyDown_Ten1=YES;break;
        case 84:isKeyDown_Ten2=YES;break;
        case 85:isKeyDown_Ten3=YES;break;
        case 86:isKeyDown_Ten4=YES;break;
        case 87:isKeyDown_Ten5=YES;break;
        case 88:isKeyDown_Ten6=YES;break;
        case 89:isKeyDown_Ten7=YES;break;
        case 91:isKeyDown_Ten8=YES;break;
        case 92:isKeyDown_Ten9=YES;break;
        case 65:isKeyDown_TenDot=YES;break;
        case 76:isKeyDown_TenEnter=YES;break;
        case 69:isKeyDown_TenPlus=YES;break;
        case 78:isKeyDown_TenMinus=YES;break;
        case 67:isKeyDown_TenMul=YES;break;
        case 75:isKeyDown_TenDiv=YES;break;
        case 71:isKeyDown_NumLock=YES;break;
        case 122:isKeyDown_F1=YES;break;
        case 120:isKeyDown_F2=YES;break;
        case 99:isKeyDown_F3=YES;break;
        case 118:isKeyDown_F4=YES;break;
        case 96:isKeyDown_F5=YES;break;
        case 97:isKeyDown_F6=YES;break;
        case 98:isKeyDown_F7=YES;break;
        case 100:isKeyDown_F8=YES;break;
        case 101:isKeyDown_F9=YES;break;
        case 109:isKeyDown_F10=YES;break;
        case 103:isKeyDown_F11=YES;break;
        case 111:isKeyDown_F12=YES;break;
        case 117:isKeyDown_Delete=YES;break;
        case 114:isKeyDown_Insert=YES;break;
        case 113:isKeyDown_PauseBreak=YES;break;
        case 105:isKeyDown_PrtScSysRq=YES;break;
        case 50:isKeyDown_HankakuZenkaku=YES;break;
        case 0:isKeyDown_A=YES;break;
        case 11:isKeyDown_B=YES;break;
        case 8:isKeyDown_C=YES;break;
        case 2:isKeyDown_D=YES;break;
        case 14:isKeyDown_E=YES;break;
        case 3:isKeyDown_F=YES;break;
        case 5:isKeyDown_G=YES;break;
        case 4:isKeyDown_H=YES;break;
        case 34:isKeyDown_I=YES;break;
        case 38:isKeyDown_J=YES;break;
        case 40:isKeyDown_K=YES;break;
        case 37:isKeyDown_L=YES;break;
        case 46:isKeyDown_M=YES;break;
        case 45:isKeyDown_N=YES;break;
        case 31:isKeyDown_O=YES;break;
        case 35:isKeyDown_P=YES;break;
        case 12:isKeyDown_Q=YES;break;
        case 15:isKeyDown_R=YES;break;
        case 1:isKeyDown_S=YES;break;
        case 17:isKeyDown_T=YES;break;
        case 32:isKeyDown_U=YES;break;
        case 9:isKeyDown_V=YES;break;
        case 13:isKeyDown_W=YES;break;
        case 7:isKeyDown_X=YES;break;
        case 16:isKeyDown_Y=YES;break;
        case 6:isKeyDown_Z=YES;break;
    }
}

-(void)keyUp:(NSEvent *)theEvent {
    switch([theEvent keyCode]) {
        case 123:isKeyDown_Left=NO;break;
        case 126:isKeyDown_Up=NO;break;
        case 124:isKeyDown_Right=NO;break;
        case 125:isKeyDown_Down=NO;break;
        case 49:isKeyDown_Space=NO;break;
        case 36:isKeyDown_Enter=NO;break;
        case 53:isKeyDown_Escape=NO;break;
        case 48:isKeyDown_Tab=NO;break;
        case 51:isKeyDown_BackSpace=NO;break;
        case 29:isKeyDown_0=NO;break;
        case 18:isKeyDown_1=NO;break;
        case 19:isKeyDown_2=NO;break;
        case 20:isKeyDown_3=NO;break;
        case 21:isKeyDown_4=NO;break;
        case 23:isKeyDown_5=NO;break;
        case 22:isKeyDown_6=NO;break;
        case 26:isKeyDown_7=NO;break;
        case 28:isKeyDown_8=NO;break;
        case 25:isKeyDown_9=NO;break;
        case 82:isKeyDown_Ten0=NO;break;
        case 83:isKeyDown_Ten1=NO;break;
        case 84:isKeyDown_Ten2=NO;break;
        case 85:isKeyDown_Ten3=NO;break;
        case 86:isKeyDown_Ten4=NO;break;
        case 87:isKeyDown_Ten5=NO;break;
        case 88:isKeyDown_Ten6=NO;break;
        case 89:isKeyDown_Ten7=NO;break;
        case 91:isKeyDown_Ten8=NO;break;
        case 92:isKeyDown_Ten9=NO;break;
        case 65:isKeyDown_TenDot=NO;break;
        case 76:isKeyDown_TenEnter=NO;break;
        case 69:isKeyDown_TenPlus=NO;break;
        case 78:isKeyDown_TenMinus=NO;break;
        case 67:isKeyDown_TenMul=NO;break;
        case 75:isKeyDown_TenDiv=NO;break;
        case 71:isKeyDown_NumLock=NO;break;
        case 122:isKeyDown_F1=NO;break;
        case 120:isKeyDown_F2=NO;break;
        case 99:isKeyDown_F3=NO;break;
        case 118:isKeyDown_F4=NO;break;
        case 96:isKeyDown_F5=NO;break;
        case 97:isKeyDown_F6=NO;break;
        case 98:isKeyDown_F7=NO;break;
        case 100:isKeyDown_F8=NO;break;
        case 101:isKeyDown_F9=NO;break;
        case 109:isKeyDown_F10=NO;break;
        case 103:isKeyDown_F11=NO;break;
        case 111:isKeyDown_F12=NO;break;
        case 117:isKeyDown_Delete=NO;break;
        case 114:isKeyDown_Insert=NO;break;
        case 113:isKeyDown_PauseBreak=NO;break;
        case 105:isKeyDown_PrtScSysRq=NO;break;
        case 50:isKeyDown_HankakuZenkaku=NO;break;
        case 0:isKeyDown_A=NO;break;
        case 11:isKeyDown_B=NO;break;
        case 8:isKeyDown_C=NO;break;
        case 2:isKeyDown_D=NO;break;
        case 14:isKeyDown_E=NO;break;
        case 3:isKeyDown_F=NO;break;
        case 5:isKeyDown_G=NO;break;
        case 4:isKeyDown_H=NO;break;
        case 34:isKeyDown_I=NO;break;
        case 38:isKeyDown_J=NO;break;
        case 40:isKeyDown_K=NO;break;
        case 37:isKeyDown_L=NO;break;
        case 46:isKeyDown_M=NO;break;
        case 45:isKeyDown_N=NO;break;
        case 31:isKeyDown_O=NO;break;
        case 35:isKeyDown_P=NO;break;
        case 12:isKeyDown_Q=NO;break;
        case 15:isKeyDown_R=NO;break;
        case 1:isKeyDown_S=NO;break;
        case 17:isKeyDown_T=NO;break;
        case 32:isKeyDown_U=NO;break;
        case 9:isKeyDown_V=NO;break;
        case 13:isKeyDown_W=NO;break;
        case 7:isKeyDown_X=NO;break;
        case 16:isKeyDown_Y=NO;break;
        case 6:isKeyDown_Z=NO;break;
    }
}

-(void)mouseEntered:(NSEvent *)theEvent {
}

-(void)mouseMoved:(NSEvent *)theEvent {
}

- (void)mouseDown:(NSEvent *)theEvent {
    isMouseDown = YES;
    isMouseUp = NO;
}

- (void)mouseUp:(NSEvent*)theEvent {
    isMouseUp = YES;
    isMouseDown = NO;
    isMouseDragged = NO;
    if([theEvent clickCount] == 2) { //DoubleClick
        
    }
}

- (void)mouseDragged:(NSEvent*)theEvent {
    isMouseDragged = YES;
}

-(void)rightMouseDown:(NSEvent *)theEvent {
    isRightMouseDown = YES;
    isRightMouseUp = NO;
}

-(void)rightMouseUp:(NSEvent *)theEvent {
    isRightMouseUp = YES;
    isRightMouseDown = NO;
    isRightMouseDragged = NO;
    
    if([theEvent clickCount] == 2) {
        // Double click
    }
}

-(void)rightMouseDragged:(NSEvent *)theEvent {
}

- (void)layout {
    [super layout];
}

//- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
//{
//    [super drawLayer:layer inContext:ctx];
//}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}
@end
