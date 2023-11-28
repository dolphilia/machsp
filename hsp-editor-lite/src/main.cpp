//
//  main.m
//  hsed
//
//  Created by dolphilia on 2016/03/12.
//  Copyright © 2016年 dolphilia. All rights reserved.
//

#import <iostream>
#include "compiler/hsc3.h"
#include "compiler/hsp3config.h"
#include "util/utility.h"

static void usage() {
    static char *p[] = {
        (char *) "usage: hspcmp [options] [filename]",
        (char *) "       -o??? set output file to ???",
        (char *) "       -d    add debug information",
        (char *) "       -p    preprocessor only",
        (char *) "       -c    HSP2.55 compatible mode",
        (char *) "       -i    input UTF-8 source code",
        (char *) "       -u    output UTF-8 strings",
        (char *) "       -w    force debug window on",
        (char *) "       --compath=??? set common path to ???",
        nullptr
    };
}

int main(int argc, const char *argv[]) {
    int result = 0;
    int compile_option = 0;
    int preprocess_option = HSC3_OPT_UTF8_IN;
    int utf8_option = 1;
    int preprocess_only = 0;
    char file_name[HSP_PATH_LENGTH_MAX];
    char file_name2[HSP_PATH_LENGTH_MAX];
    char obj_name[HSP_PATH_LENGTH_MAX];
    char common_path[HSP_PATH_LENGTH_MAX];


    if (argc < 2) { // check switch and prm
        usage();
        return -1;
    }

    file_name[0] = 0;
    file_name2[0] = 0;
    obj_name[0] = 0;

    strcpy(common_path, "common/");

    for (int i = 1; i < argc; i++) {
        if (*argv[i] != '-') {
            strcpy(file_name, argv[i]);
        } else {
            if (strncmp(argv[i], "--common_path=", 10) == 0) {
                strcpy(common_path, argv[i] + 10);
                continue;
            }
            switch (tolower(*(argv[i] + 1))) {
                case 'c':
                    preprocess_option |= HSC3_OPT_NO_HSPDEF;
                    break;
                case 'p':
                    preprocess_only = 1;
                    break;
                case 'd':
                    preprocess_option |= HSC3_OPT_DEBUG_MODE;
                    compile_option |= HSC3_MODE_DEBUG;
                    break;
                case 'i':
                    preprocess_option |= HSC3_OPT_UTF8_IN;
                    utf8_option = 1;
                    compile_option |= HSC3_MODE_UTF8;
                    break;
                case 'u':
                    utf8_option = 1;
                    compile_option |= HSC3_MODE_UTF8;
                    break;
                case 'w':
                    compile_option |= HSC3_MODE_DEBUG_WIN;
                    break;
                case 'o':
                    strcpy(obj_name, argv[i] + 2);
                    break;
                default:
                    result = 1;
                    break;
            }
        }
    }

    if (obj_name[0] == 0) {
        strcpy(obj_name, file_name);
        cutext(obj_name);
        addext(obj_name, "ax");
    }
    strcpy(file_name2, file_name);
    cutext(file_name2);
    addext(file_name2, "i");
    addext(file_name, "hsp"); // 拡張子がなければ追加する

    HspCompiler *hsc3 = new HspCompiler;
    hsc3->set_common_path(common_path);
    result = hsc3->preprocess(file_name, file_name2, preprocess_option, file_name);
    if ((compile_option < 2) && (result == 0)) {
        result = hsc3->compile(file_name2, obj_name, compile_option);
    }
    puts(hsc3->get_error());
    hsc3->end_preprocess();
    delete hsc3;
    return result;
}
