cmake_minimum_required(VERSION 3.26)
project(hsp_editor_lite)

set(CMAKE_CXX_STANDARD 17)

add_executable(hsp_editor_lite
        src/main.cpp
        src/static/static_global.cpp
        src/util/utility_stack.cpp
        src/util/utility_string.cpp
        src/util/utility_time.cpp
        src/util/utility_errmsg.cpp
        src/util/utility.cpp
        src/util/utility_com.cpp
        src/compiler/hsc3.cpp
        src/compiler/label.cpp
        src/compiler/membuf.cpp
        src/compiler/token.cpp
        src/util/vec.c
        src/compiler/hspcmd.c
        src/compiler/codegen.cpp
        src/util/str.c)
