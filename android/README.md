# Requirements

 - [Android Studio][] and SDK;
 - Python;
 - [androidenv][];


# Building

Install Android Studio and the SDK.

Set these environment variables according to your installation:

    export ANDROIDHOME="$HOME/Library/Android"
    export ANDROID_SDK_ROOT=$ANDROIDHOME/sdk
    export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
    export PATH="$ANDROIDHOME/sdk/platform-tools:$PATH"
    export PATH="$ANDROIDHOME/sdk/tools/bin:$PATH"

[Generate an APK signing key][apk-key], then edit the file `android/Makefile`
and change the environment variables:
`JKS_FILE`, `JKS_PATH`, `JKS_PASS` and `JKS_ALIAS`.

Change the application ID in the files `app/build.gradle` and
`app/src/main/AndroidManifest.xml`.

Edit the version number in the file `app/build.gradle`.

Then,

    make apk


[Android Studio]: https://developer.android.com/studio
[androidenv]: https://github.com/mansourmoufid/python-androidenv
[apk-key]: https://developer.android.com/studio/publish/app-signing
