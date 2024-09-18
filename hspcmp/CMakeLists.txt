cmake_minimum_required(VERSION 3.0)
project(hsp_compiler)

cmake_minimum_required(VERSION 3.10)

project(MyProject)

if(WIN32)
    list(APPEND includedir "/mingw/include" "/mingw/include/c++/3.4.2")
    list(APPEND libdir "/mingw/lib")
    set(HSP_SOURCES
            ahtmodel.cpp
            ahtobj.cpp
            codegen.cpp
            comutil.cpp
            errormsg.cpp
            hsc3.cpp
            hspcmd.cpp
            label.cpp
            localinfo.cpp
            membuf.cpp
            tagstack.cpp
            token.cpp
            win32/supio_win.cpp
            win32dll/hspcmp3.cpp
    )
    set(LIBS ole32)
    add_definitions(-DWINVER=0x0400 -D_WIN32_IE=0x0500 -DHSPWIN)
    set(COMPILE_OPTIONS -Wall -Wno-unused -fexceptions -fsigned-char -finput-charset=utf-8 -fexec-charset=utf-8 -mdll)
    set(LINK_FLAGS "--def win32dll/hspcmp3.def")
elseif(UNIX OR APPLE)
    set(HSP_SOURCES
            ahtmodel.cpp
            ahtobj.cpp
            codegen.cpp
            comutil.cpp
            errormsg.cpp
            hsc3.cpp
            hspcmd.cpp
            label.cpp
            localinfo.cpp
            main.cpp
            membuf.cpp
            tagstack.cpp
            token.cpp
            hsmanager.cpp
            #linux/supio_linux.cpp
            ../hsp3/strnote.cpp
            ../hsp3/linux/supio_linux.cpp
            ../hsp3/strbuf.cpp
    )
    set(LIBS m stdc++)
    add_definitions(-DHSPLINUX)
    set(COMPILE_OPTIONS -Wall -finput-charset=utf-8 -fexec-charset=utf-8)
    set(LINK_FLAGS "")
else()
    message(FATAL_ERROR "Unknown HSP_PLATFORM: ${HSP_PLATFORM}")
endif()

# 通常のビルド処理
add_executable(MyApp main.cpp)

# リリースビルドの設定
if(CMAKE_BUILD_TYPE STREQUAL "Release")
    list(APPEND COMPILE_OPTIONS -O3 -DNDEBUG)
    if(HSP_PLATFORM MATCHES "win32")
        list(APPEND LINK_FLAGS -s)
    endif()
endif()

# インクルードディレクトリとライブラリディレクトリを設定
include_directories(${includedir} . ../hsp3)
link_directories(${libdir})

# ターゲットの設定
if(HSP_PLATFORM STREQUAL "win32dll_mingw")
    add_library(hspcmp SHARED ${HSP_SOURCES})
else()
    add_executable(hspcmp ${HSP_SOURCES})
endif()

# コンパイルオプションとリンクオプションを設定
target_compile_options(hspcmp PRIVATE ${COMPILE_OPTIONS})
target_link_libraries(hspcmp ${LIBS})
set_target_properties(hspcmp PROPERTIES LINK_FLAGS "${LINK_FLAGS}")
