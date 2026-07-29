# CMake toolchain file for cross-compiling MMS from Linux to Windows (MinGW-w64)
set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR x86_64)

set(MINGW_ROOT "/home/z/mingw/usr")
set(CMAKE_C_COMPILER   "${MINGW_ROOT}/bin/x86_64-w64-mingw32-gcc")
set(CMAKE_CXX_COMPILER "${MINGW_ROOT}/bin/x86_64-w64-mingw32-g++")
set(CMAKE_RC_COMPILER  "${MINGW_ROOT}/bin/x86_64-w64-mingw32-windres")

set(CMAKE_FIND_ROOT_PATH
    "${MINGW_ROOT}/x86_64-w64-mingw32"
    "/home/z/Qt-win/6.8.0/mingw_64"
    "/home/z/openssl-win/mingw64"
)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

set(Qt6_DIR "/home/z/Qt-win/6.8.0/mingw_64/lib/cmake/Qt6")

# MinGW-specific compile flags
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++20 -static-libgcc -static-libstdc++ -finput-charset=UTF-8 -fexec-charset=UTF-8")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static-libgcc -static-libstdc++ -Wl,--enable-auto-import")
