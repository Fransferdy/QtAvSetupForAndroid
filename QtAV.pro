include(root.pri)

TEMPLATE = subdirs
CONFIG -= ordered
CONFIG += static_ffmpeg static_openal
SUBDIRS = libqtav tools
libqtav.file = src/libQtAV.pro
!no-widgets {
  SUBDIRS += libqtavwidgets
  libqtavwidgets.file = widgets/libQtAVWidgets.pro
  libqtavwidgets.depends = libqtav
  examples.depends += libqtavwidgets #TODO: enable widgets based examples
}
greaterThan(QT_MAJOR_VERSION, 4) {
  # qtHaveModule does not exist in Qt5.0
  isEqual(QT_MINOR_VERSION, 0)|qtHaveModule(quick) {
    SUBDIRS += libqmlav
    libqmlav.file = qml/libQmlAV.pro
    libqmlav.depends += libqtav
    examples.depends += libqmlav
  }
}
!no-examples {
  SUBDIRS += examples
  examples.depends += libqtav
}
!cross_compile:!no-tests {
  SUBDIRS += tests
  tests.depends += libqtav libqtavwidgets
}
OTHER_FILES += README.md TODO.txt Changelog
OTHER_FILES += templates/vo.h templates/vo.cpp templates/COPYRIGHT.h templates/mkclass.sh
OTHER_FILES += \
	templates/base.h templates/base.cpp templates/base_p.h \
	templates/derived.h templates/derived.cpp templates/derived_p.h \
	templates/final.h templates/final.cpp
#OTHER_FILES += config.test/mktest.sh
EssentialDepends = avutil avcodec avformat swscale
winrt: CONFIG *= no-avdevice no-openal no-portaudio no-dsound no-gdiplus
OptionalDepends = swresample avresample
!no-avfilter: OptionalDepends *= avfilter
!no-avdevice: OptionalDepends *= avdevice
# QtOpenGL module. In Qt5 we can disable it and still have opengl support
contains(QT_CONFIG, opengl):!no-gl:!no-widgets {
  greaterThan(QT_MAJOR_VERSION, 4):qtHaveModule(opengl):!config_gl {
    GL=config_gl done_config_gl
    cache(CONFIG, add, GL)
  } else {
    OptionalDepends *= gl
  }
}
## sse2 sse4_1 may be defined in Qt5 qmodule.pri but is not included. Qt4 defines sse and sse2
#configure.prf always use simulator
!iphoneos:!no-sse4_1:!sse4_1: OptionalDepends *= sse4_1
# no-xxx can set in $$PWD/user.conf
!no-openal:!mac:!ios: OptionalDepends *= openal #FIXME: ios openal header not found in qtCompileTest but fine if manually make
!no-libass: OptionalDepends *= libass
!no-uchardet: OptionalDepends *= uchardet
win32:macx:!android:!winrt:!no-portaudio: OptionalDepends *= portaudio
win32 {
  OptionalDepends *= dx
  !no-xaudio2: OptionalDepends *= xaudio2
  !no-direct2d:!no-widgets: OptionalDepends *= direct2d
  !no-dxva: OptionalDepends *= dxva
  !no-d3d11va: OptionalDepends *= d3d11va
  !no-dsound: OptionalDepends *= dsound
  !no-gdiplus:!no-widgets: OptionalDepends *= gdiplus
}
unix:!mac {
  !android {
    !no-pulseaudio: OptionalDepends *= pulseaudio
    !no-x11:!no-widgets: OptionalDepends *= x11
    !no-xv:!no-widgets: OptionalDepends *= xv
    !no-vaapi: OptionalDepends *= vaapi
  }
  !no-cedarv: OptionalDepends *= libcedarv
}
mac|ios {
  !no-videotoolbox: OptionalDepends *= videotoolbox
}

android:contains(ANDROID_TARGET_ARCH, armeabi-v7a):LIBS += $$PWD/openssl-1.1.1android/lib/armeabi-v7a/libcrypto_1_1.so
android:contains(ANDROID_TARGET_ARCH, armeabi-v7a):LIBS += $$PWD/openssl-1.1.1android/lib/armeabi-v7a/libssl_1_1.so

android:contains(ANDROID_TARGET_ARCH, arm64-v8a):LIBS += $$PWD/openssl-1.1.1android/lib/arm64-v8a/libcrypto_1_1.so
android:contains(ANDROID_TARGET_ARCH, arm64-v8a):LIBS += $$PWD/openssl-1.1.1android/lib/arm64-v8a/libssl_1_1.so

android:contains(ANDROID_TARGET_ARCH, x86):LIBS += $$PWD/openssl-1.1.1android/lib/x86/libcrypto_1_1.so
android:contains(ANDROID_TARGET_ARCH, x86):LIBS += $$PWD/openssl-1.1.1android/lib/x86/libssl_1_1.so

android:contains(ANDROID_TARGET_ARCH, x86_64):LIBS += $$PWD/openssl-1.1.1android/lib/x86_64/libcrypto_1_1.so
android:contains(ANDROID_TARGET_ARCH, x86_64):LIBS += $$PWD/openssl-1.1.1android/lib/x86_64/libssl_1_1.so

win32:CONFIG(release, debug|release): LIBS += -L$$PWD/openssl-1.1.1ewindows/openssl-1.1/x64/lib/ -llibcrypto
win32:CONFIG(release, debug|release): LIBS += -L$$PWD/openssl-1.1.1ewindows/openssl-1.1/x64/lib/ -llibssl

runConfigTests()
!config_avresample:!config_swresample {
  error("libavresample or libswresample is required. Setup your environment correctly then delete $$BUILD_DIR/.qmake.conf and run qmake again")
}

PACKAGE_VERSION = $$QTAV_VERSION
PACKAGE_NAME= QtAV
include(pack.pri)
#packageSet($$QTAV_VERSION, QtAV)
