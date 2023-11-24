//
// Created by dolphilia on 2023/11/24.
//
#include <string>
#include <vector>
#include "static_global.h"

static int runtimeAccessNumber; //実行時のアクセスナンバー
static bool isError; //エラーがあったか
static std::string *logString;
static std::string *currentPath; //現在のスクリプトファイルのあるパス
static std::vector<std::string> *currentPaths;
static std::vector<std::string> *globalTitles;
static std::vector<std::string> *globalTexts;