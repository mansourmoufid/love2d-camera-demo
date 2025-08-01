APP_STL := c++_shared
APP_ABI := armeabi-v7a arm64-v8a
APP_CPPFLAGS += -DNDEBUG
APP_CPPFLAGS += -D_FORTIFY_SOURCE=1
APP_CFLAGS += -fno-builtin
APP_CFLAGS += -fno-common
APP_CFLAGS += -fno-delete-null-pointer-checks
APP_CFLAGS += -fno-strict-aliasing
APP_CFLAGS += -fno-strict-overflow
APP_CFLAGS += -fpic
APP_CFLAGS += -fwrapv
APP_CFLAGS += -Os
APP_CFLAGS += -Wno-macro-redefined
APP_CXXFLAGS += -fno-builtin
APP_CXXFLAGS += -fno-common
APP_CXXFLAGS += -fno-delete-null-pointer-checks
APP_CXXFLAGS += -fno-strict-aliasing
APP_CXXFLAGS += -fno-strict-overflow
APP_CXXFLAGS += -fpic
APP_CXXFLAGS += -fwrapv
APP_CXXFLAGS += -Os
APP_CXXFLAGS += -Wno-macro-redefined
APP_CXXFLAGS += -frtti
APP_LDFLAGS := -llog -landroid -lz -fuse-ld=lld
APP_LDFLAGS += -Wl,-z,relro
APP_LDFLAGS += -Wl,-z,noexecstack
APP_LDFLAGS += -Wl,-S
APP_PLATFORM := 19
NDK_TOOLCHAIN_VERSION := clang

# Fix for building on Windows
# http://stackoverflow.com/questions/12598933/ndk-build-createprocess-make-e-87-the-parameter-is-incorrect
APP_SHORT_COMMANDS := true

# APP_OPTIM := debug
