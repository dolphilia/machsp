//
//  utility_time.c
//  hsp3compiler
//
//  Created by dolphilia on 2021/11/20.
//

#include "utility_time.h"

char curtime[16];
char curdate[16];

/*
 Get system time entries
 index :
    0 wYear
    1 wMonth
    2 wDayOfWeek
    3 wDay
    4 wHour
    5 wMinute
    6 wSecond
    7 wMilliseconds
 */
int get_time(int index) {
    struct timeval tv;
    struct tm *lt;
    gettimeofday(&tv, NULL);    // MinGWだとVerによって通りません
    lt = localtime(&tv.tv_sec);
    switch( index ) {
        case 0:
            return lt->tm_year + 1900;
        case 1:
            return lt->tm_mon + 1;
        case 2:
            return lt->tm_wday;
        case 3:
            return lt->tm_mday;
        case 4:
            return lt->tm_hour;
        case 5:
            return lt->tm_min;
        case 6:
            return lt->tm_sec;
        case 7:
            return (int)tv.tv_usec / 10000;
        case 8:
            /*    一応マイクロ秒まで取れる    */
            return (int)tv.tv_usec % 10000;
    }
    return 0;
}

char* get_current_time() {
    sprintf(curtime, "\"%02d:%02d:%02d\"", get_time(4), get_time(5), get_time(6));
    return curtime;
}

char* get_current_date(void) {
    sprintf(curdate, "\"%04d/%02d/%02d\"", get_time(0), get_time(1), get_time(3));
    return curdate;
}
