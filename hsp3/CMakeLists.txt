cmake_minimum_required(VERSION 3.0)
project(hsp3)

# ソースファイルの設定
set(SOURCES
    hsp3.cpp
    hsp3code.cpp
    hsp3debug.cpp
    hsp3int.cpp
    hspvar_core.cpp
    hspvar_double.cpp
    hspvar_int.cpp
    hsp3crypt.cpp
    hsp3utfcnv.cpp
    filepack.cpp
    hspvar_label.cpp
    hspvar_str.cpp
    hspvar_struct.cpp
    stack.cpp
    strbuf.cpp
    strnote.cpp
    dpmread.cpp
    linux/main.cpp
    linux/supio_linux.cpp
    linux/hsp3cl.cpp
    linux/hsp3ext_linux.cpp
    linux/hsp3gr_linux.cpp
    linux/hsp3ext_sock.cpp
)

# 実行ファイルの生成
add_executable(hsp3 ${SOURCES})

# コンパイル定義の設定
target_compile_definitions(hsp3 PRIVATE HSPLINUX $<$<CONFIG:Debug>:HSPDEBUG>)
target_compile_options(hsp3 PRIVATE -UDEVCTRL_IO)

# コンパイルオプションの設定
#target_compile_options(hsp3 PRIVATE -Wall --input-charset=utf-8 --exec-charset=cp932)

# リンクオプションの設定（リリースビルドで-stripオプションを追加）
if (CMAKE_VERSION VERSION_GREATER_EQUAL "3.13")
    target_link_options(hsp3 PRIVATE $<$<CONFIG:Release>:-s>)
else()
    set_target_properties(hsp3 PROPERTIES LINK_FLAGS "$<$<CONFIG:Release>:-s>")
endif()

# リンクライブラリの設定
target_link_libraries(hsp3 m stdc++)
