//
//  string_utility.c
//

#include "utility_string.h"

bool isEqualString(char *s1, char *s2) {
    if (strcmp(s1, s2) == 0) {
        return true;
    } else {
        return false;
    }
}
