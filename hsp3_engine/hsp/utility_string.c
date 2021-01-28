//
//  string_utility.c
//
#include "utility_string.h"
bool isEqualString(char *s1, char *s2) {
    if(strcmp(s1,s2) == 0) {
        return true;
    }
    else {
        return false;
    }
}

//func isEqualString(_ s1: UnsafeMutablePointer<Int8>?, _ s2: UnsafeMutablePointer<Int8>?) -> Bool {
//    if strcmp(s1, s2) == 0 {
//        return true
//    } else {
//        return false
//    }
//}
