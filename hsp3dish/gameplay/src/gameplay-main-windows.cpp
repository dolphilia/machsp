#ifndef GP_NO_PLATFORM
#ifdef WIN32

#include "gameplay.h"

using namespace gameplay;

#ifndef _WINDOWS_
    #define WIN32_LEAN_AND_MEAN
    #include <windows.h>
#endif

#ifndef HSPDISH
/**
 * Main entry point.
 */
extern "C" int APIENTRY WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR cmdLine, int cmdShow)
{
    Game* game = Game::getInstance();
    Platform* platform = Platform::create(game);
    GP_ASSERT(platform);
    int result = platform->enterMessagePump();
    delete platform;
    return result;
}
#endif

#endif
#endif
