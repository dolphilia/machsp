//
//	supio.cpp functions (linux)
//
#import "ViewController.h"
@interface
ViewController (supio_hsp3) {
}
-(void)_splitpath:(char*)path p_drive:(char*)p_drive dir:(char*)dir fname:(char*)fname ext:(char*)ext;
-(int)wildcard:(char*)text wc:(char*)wc;
-(char*) mem_ini:(int)size;
-(void) mem_bye:(void*)ptr;
-(int) mem_save:(char*)fname mem:(void*)mem msize:(int)msize seekofs:(int)seekofs;
-(void) strcase:(char*)str;
-(int) strcpy2:(char*)str1 str2:(char*)str2;
-(int) strcat2:(char*)str1 str2:(char*)str2;
-(char*) strstr2:(char*)target src:(char*)src;
-(char*) strchr2:(char*)target code:(char)code;
-(void) getpath:(char*)stmp outbuf:(char*)outbuf p2:(int)p2;
-(int) makedir:(char*)name;
-(int) changedir:(char*)name;
-(int) delfile:(char*)name;
-(int) dirlist:(char*)fname target:(char**)target p3:(int)p3;
-(int) gettime:(int)index;
-(void) strsp_ini;
-(int) strsp_getptr;
-(int) strsp_get:(char*)srcstr dststr:(char*)dststr splitchr:(char)splitchr len:(int)len;
-(int) GetLimit:(int)num min:(int)min max:(int)max;
-(void) CutLastChr:(char*)p code:(char)code;
-(char*) strsp_cmds:(char*) srcstr;
-(int) htoi:(char*)str; //
//-(int) SecurityCheck:(char*) name;
-(char*) strchr3:(char*)target code:(int)code sw:(int)sw findptr:(char**)findptr;
-(void) TrimCode:(char*)p code:(int)code;
-(void) TrimCodeL:(char*)p code:(int)code;
-(void) TrimCodeR:(char*)p code:(int)code;
//-(void) Alert:(char*)mes;
//-(void) AlertV:(char*)mes val:(int)val;
//-(void) Alertf:(char*)format, ...;
@end
