#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
find_ndk_dir() {
    if [ -n "${ANDROID_NDK_HOME:-}" ]; then
        printf '%s\n' "$ANDROID_NDK_HOME"
        return
    fi

    for sdk_root in \
        "${ANDROID_SDK_ROOT:-}" \
        "${ANDROID_HOME:-}" \
        "$HOME/.android/sdk" \
        "$SCRIPT_DIR/build_tools/android-sdk"; do
        if [ -n "$sdk_root" ] && [ -d "$sdk_root/ndk/29.0.13113456" ]; then
            printf '%s\n' "$sdk_root/ndk/29.0.13113456"
            return
        fi
    done

    printf '%s\n' "$SCRIPT_DIR/build_tools/android-sdk/ndk/29.0.13113456"
}

NDK_DIR="$(find_ndk_dir)"
BUILD_DIR="$SCRIPT_DIR/build_daemon_android"

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

cmake -S "$SCRIPT_DIR" -B "$BUILD_DIR" \
    -DCMAKE_TOOLCHAIN_FILE="$NDK_DIR/build/cmake/android.toolchain.cmake" \
    -DANDROID_ABI=arm64-v8a \
    -DANDROID_PLATFORM=android-30 \
    -DCMAKE_BUILD_TYPE=Release

cmake --build "$BUILD_DIR" --target display_daemon -j$(nproc)

echo "Built: $BUILD_DIR/display_daemon"
