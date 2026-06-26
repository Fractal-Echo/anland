#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

find_ndk_dir() {
    for env_var in ANDROID_NDK_HOME ANDROID_NDK_ROOT; do
        candidate="${!env_var:-}"
        if [ -n "$candidate" ] && [ -f "$candidate/build/cmake/android.toolchain.cmake" ]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done

    for candidate in \
        "${ANDROID_HOME:-}/ndk/30.0.14904198" \
        "${ANDROID_SDK_ROOT:-}/ndk/30.0.14904198" \
        "$HOME/.android/sdk/ndk/30.0.14904198" \
        "$HOME/.android/sdk/ndk/29.0.13113456" \
        "$SCRIPT_DIR/build_tools/android-sdk/ndk/29.0.13113456" \
        "/mnt/c/Users/${USER:-richtofen}/AppData/Local/Android/Sdk/ndk/30.0.14904198" \
        "/mnt/c/Users/adriano/AppData/Local/Android/Sdk/ndk/30.0.14904198"; do
        if [ -n "$candidate" ] && [ -f "$candidate/build/cmake/android.toolchain.cmake" ]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done

    return 1
}

NDK_DIR="$(find_ndk_dir || true)"
BUILD_DIR="$SCRIPT_DIR/build_daemon_android"

if [ ! -f "$NDK_DIR/build/cmake/android.toolchain.cmake" ]; then
    echo "Android NDK not found at: $NDK_DIR" >&2
    echo "Set ANDROID_NDK_HOME or install the bundled NDK." >&2
    exit 1
fi

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

cmake -S "$SCRIPT_DIR" -B "$BUILD_DIR" \
    -DCMAKE_TOOLCHAIN_FILE="$NDK_DIR/build/cmake/android.toolchain.cmake" \
    -DANDROID_ABI=arm64-v8a \
    -DANDROID_PLATFORM=android-30 \
    -DCMAKE_BUILD_TYPE=Release

cmake --build "$BUILD_DIR" --target display_daemon -j"$(nproc)"

echo "Built: $BUILD_DIR/display_daemon"
