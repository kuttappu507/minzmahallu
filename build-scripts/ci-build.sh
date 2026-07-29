#!/usr/bin/env bash
# =============================================================================
# ci-build.sh — Single source of truth for building MMS.exe
#
# Used by:
#   - GitHub Actions (.github/workflows/build-windows.yml)
#   - Local Linux cross-compile builds
#
# Reproduces the exact build pipeline:
#   1. Use Linux moc/rcc to generate moc_*.cpp and qrc_mms.cpp
#      (because CMake's AUTOMOC would invoke the Windows moc.exe which
#       cannot run on Linux)
#   2. Cross-compile every .cpp with x86_64-w64-mingw32-g++
#   3. Link the final MMS.exe with Qt6EntryPoint + Qt6 + OpenSSL
#
# Environment variables (with sensible defaults for local builds):
#   PROJ          — project root (default: directory containing this script's parent)
#   QT_LINUX_BIN  — path to Linux Qt bin/ (with moc, rcc)
#   QT_WIN        — path to Windows Qt mingw_64/
#   MINGW_BIN     — path to MinGW bin/ (with x86_64-w64-mingw32-g++)
#   OPENSSL       — path to OpenSSL mingw64/
# =============================================================================
set -euo pipefail

# ---------------------------------------------------------------------------
# Resolve paths
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJ="${PROJ:-$(cd "$SCRIPT_DIR/.." && pwd)}"
BUILD="${BUILD:-$PROJ/build-win}"
GEN="$BUILD/generated"
SRC="$PROJ/src"

# Default tool paths — match the symlinks created by the workflow
QT_LINUX_BIN="${QT_LINUX_BIN:-/home/z/Qt-linux/6.8.0/gcc_64/bin}"
QT_WIN="${QT_WIN:-/home/z/Qt-win/6.8.0/mingw_64}"
MINGW_BIN="${MINGW_BIN:-/home/z/mingw/usr/bin}"
OPENSSL="${OPENSSL:-/home/z/openssl-win/mingw64}"

export PATH="$QT_LINUX_BIN:$MINGW_BIN:$PATH"
export LD_LIBRARY_PATH="/home/z/mingw/usr/lib/x86_64-linux-gnu:${LD_LIBRARY_PATH:-}"

CXX="$MINGW_BIN/x86_64-w64-mingw32-g++"

mkdir -p "$BUILD/obj" "$GEN"

# ---------------------------------------------------------------------------
# Qt include flags
# ---------------------------------------------------------------------------
QT_MODULES="Core Gui Widgets Sql Charts PrintSupport Svg Network"
QT_CFLAGS=""
for m in $QT_MODULES; do
    QT_CFLAGS+=" -I$QT_WIN/include/Qt$m"
done
QT_CFLAGS+=" -I$QT_WIN/include -I$QT_WIN/mkspecs/win32-g++"

INCLUDES="-I$SRC -I$SRC/core -I$SRC/models -I$SRC/repositories -I$SRC/services -I$SRC/viewmodels -I$SRC/views -I$SRC/utils -I$OPENSSL/include -I$GEN $QT_CFLAGS"

# ---------------------------------------------------------------------------
# Defines (single-quoted so spaces in APP_COMPANY_STR survive bash word-splitting)
# ---------------------------------------------------------------------------
DEFINES=(
    '-DAPP_NAME_STR="MMS"'
    '-DAPP_VERSION_STR="1.0.0"'
    '-DAPP_COMPANY_STR="Mahallu Management System"'
    -DQT_CORE_LIB -DQT_GUI_LIB -DQT_WIDGETS_LIB -DQT_SQL_LIB
    -DQT_CHARTS_LIB -DQT_PRINTSUPPORT_LIB -DQT_SVG_LIB -DQT_NETWORK_LIB
    -DQT_NO_DEBUG -DQT_DEPRECATED_WARNINGS -DQT_DISABLE_DEPRECATED_BEFORE=0x060000
    -DUNICODE -D_UNICODE -DWIN32 -DWIN64 -D_WIN64
    -DMINGW_HAS_SECURE_API=1 -D_ENABLE_EXTENDED_ALIGNED_STORAGE -DQT_NEEDS_QMAIN
)

CXXFLAGS="-std=c++20 -O2 -Wall -Wno-unused-parameter -Wno-unused-variable -Wno-deprecated-declarations -finput-charset=UTF-8 -fexec-charset=UTF-8 -static-libgcc -static-libstdc++ -frtti -fexceptions -pthread"

# ---------------------------------------------------------------------------
# Step 1: Generate moc_*.cpp for every Q_OBJECT header (Linux moc)
# ---------------------------------------------------------------------------
echo "::group::Step 1: Generate moc files"
MOC_HEADERS=$(grep -rl 'Q_OBJECT' "$SRC" | sort)
moc_count=0
for h in $MOC_HEADERS; do
    out="$GEN/moc_$(basename "$h" .h).cpp"
    # Skip if moc output is newer than header (incremental)
    if [ -f "$out" ] && [ "$out" -nt "$h" ]; then
        moc_count=$((moc_count + 1))
        continue
    fi
    if ! "$QT_LINUX_BIN/moc" "$h" -o "$out" $INCLUDES "${DEFINES[@]}" 2>/dev/null; then
        echo "MOC FAILED: $h" >&2
        "$QT_LINUX_BIN/moc" "$h" -o "$out" $INCLUDES "${DEFINES[@]}" 2>&1 | head -10 >&2
        exit 1
    fi
    moc_count=$((moc_count + 1))
done
echo "Generated $moc_count moc files"
echo "::endgroup::"

# ---------------------------------------------------------------------------
# Step 2: Generate qrc_mms.cpp with rcc (use -no-zstd for Qt 6.8 compat)
# ---------------------------------------------------------------------------
echo "::group::Step 2: Generate qrc_mms.cpp"
"$QT_LINUX_BIN/rcc" -no-zstd "$PROJ/resources/mms.qrc" -o "$GEN/qrc_mms.cpp" -name mms
echo "Generated qrc_mms.cpp ($(du -h "$GEN/qrc_mms.cpp" | cut -f1))"
echo "::endgroup::"

# ---------------------------------------------------------------------------
# Step 3a: Compile the libssp shim (provides __stack_chk_fail / __stack_chk_guard
# needed by Qt6EntryPoint.a, since Ubuntu mingw-w64 doesn't ship libssp).
# ---------------------------------------------------------------------------
echo "::group::Step 3a: Compile libssp shim"
SSP_SHIM="$PROJ/build-scripts/ssp_shim.c"
SSP_OBJ="$BUILD/obj/ssp_shim.o"
if ! $CXX $CXXFLAGS "${DEFINES[@]}" $INCLUDES -c "$SSP_SHIM" -o "$SSP_OBJ" 2>/tmp/cc_err.log; then
    echo "::error::Failed to compile ssp_shim.c"
    cat /tmp/cc_err.log
    exit 1
fi
echo "  Compiled ssp_shim.o"
echo "::endgroup::"

# ---------------------------------------------------------------------------
# Step 3: Compile every .cpp file (incremental — skip up-to-date objects)
# ---------------------------------------------------------------------------
echo "::group::Step 3: Compile sources"
ALL_CPPS=$(find "$SRC" -name "*.cpp" | sort)
ALL_CPPS+=" $(find "$GEN" -name 'moc_*.cpp' | sort)"
ALL_CPPS+=" $GEN/qrc_mms.cpp"

total=$(echo "$ALL_CPPS" | wc -w)
i=0
ok=0
skipped=0
failed=0
for cpp in $ALL_CPPS; do
    i=$((i + 1))
    rel="${cpp#$PROJ/}"
    obj="$BUILD/obj/$(echo "$cpp" | sed 's|/|_|g; s|\.cpp$|.o|')"

    if [ -f "$obj" ] && [ "$obj" -nt "$cpp" ]; then
        skipped=$((skipped + 1))
        continue
    fi

    printf "  [%d/%d] %s ... " "$i" "$total" "$rel"
    if $CXX $CXXFLAGS "${DEFINES[@]}" $INCLUDES -c "$cpp" -o "$obj" 2>/tmp/cc_err.log; then
        echo "OK"
        ok=$((ok + 1))
    else
        echo "FAIL"
        head -15 /tmp/cc_err.log >&2
        failed=$((failed + 1))
    fi
done
echo "Compiled: $ok new, $skipped cached, $failed failed (total $total)"
if [ "$failed" -gt 0 ]; then
    echo "::error::$failed file(s) failed to compile"
    exit 1
fi
echo "::endgroup::"

# ---------------------------------------------------------------------------
# Step 4: Link MMS.exe
# ---------------------------------------------------------------------------
echo "::group::Step 4: Link MMS.exe"
QT_LIBS=""
for m in $QT_MODULES; do
    QT_LIBS+=" -lQt6$m"
done

LDFLAGS="-static-libgcc -static-libstdc++ -Wl,--enable-auto-import -Wl,-s -mwindows"
LDFLAGS+=" -L$QT_WIN/lib -L$OPENSSL/lib -L/home/z/mingw/x86_64-w64-mingw32/lib"
LIBS="$QT_LIBS -lopengl32 -lws2_32 -luser32 -lgdi32 -ladvapi32 -lshell32 -lole32 -loleaut32 -limm32 -lwinmm -ldwmapi -lsetupapi -lversion"
LIBS+=" -lssl -lcrypto -lz -lpthread -Wl,--whole-archive -lQt6EntryPoint -Wl,--no-whole-archive"

OBJS=$(find "$BUILD/obj" -name "*.o" | sort)
OBJS="$OBP_SSP_SHIM $OBJS"
# Prepend ssp_shim.o so its symbols are available to Qt6EntryPoint
OBJS="$BUILD/obj/ssp_shim.o $(find "$BUILD/obj" -name "*.o" ! -name "ssp_shim.o" | sort)"
echo "Linking $(echo "$OBJS" | wc -w) object files..."
if $CXX $LDFLAGS -o "$BUILD/MMS.exe" $OBJS $LIBS; then
    echo "OK: MMS.exe ($(du -h "$BUILD/MMS.exe" | cut -f1))"
else
    echo "::error::Link failed"
    exit 1
fi
echo "::endgroup::"

# ---------------------------------------------------------------------------
# Final summary
# ---------------------------------------------------------------------------
echo ""
echo "=========================================="
echo " BUILD COMPLETE"
echo "=========================================="
echo " Output:    $BUILD/MMS.exe"
echo " Size:      $(du -h "$BUILD/MMS.exe" | cut -f1)"
echo " Objects:   $(find "$BUILD/obj" -name '*.o' | wc -l)"
echo " Moc files: $moc_count"
file "$BUILD/MMS.exe" || true
