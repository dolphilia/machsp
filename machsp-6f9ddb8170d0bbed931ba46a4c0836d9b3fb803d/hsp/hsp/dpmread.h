//	dpmread.c functions

#import "ViewController.h"
#import "hsp.h"

@interface ViewController (dpmread) {
}

- (int)dpmchk:(char *)fname;
- (int)dpm_chkmemf:(char *)fname;
- (FILE *)dpm_open:(char *)fname;
- (void)dpm_close;
- (int)dpm_fread:(void *)mem size:(int)size stream:(FILE *)stream;
//
- (int)dpm_ini:(char *)dpmfile
        dpmofs:(long)dpmofs
        chksum:(int)chksum
        deckey:(int)deckey;
- (void)dpm_bye;
- (int)dpm_read:(char *)fname
        readmem:(void *)readmem
           rlen:(int)rlen
        seekofs:(int)seekofs;
- (int)dpm_exist:(char *)fname;
- (int)dpm_filebase:(char *)fname;
- (void)dpm_getinf:(char *)inf;
- (int)dpm_filecopy:(char *)fname sname:(char *)sname;
- (void)dpm_memfile:(void *)mem size:(int)size;
- (char *)dpm_readalloc:(char *)fname;

@end
