# NAME must contain only lowercase letters, numbers, or underscores.
NAME:=		love2d_camera_demo

MAKEFILE:=	$(firstword $(MAKEFILE_LIST))
MAKEDIR:=	$(shell cd $(dir $(MAKEFILE)) && pwd)
DIR:=		$(MAKEDIR)/$(NAME)-android

BUILD_TOOLS_VERSION:= $(shell \
	sed -n -e 's/ *buildToolsVersion = .\([0-9.]*\)./\1/p' < build.gradle \
)
BUILD_TOOLS_PATH:= $(ANDROIDHOME)/sdk/build-tools/$(BUILD_TOOLS_VERSION)
BUILD_TOOLS_ENV:= PATH="$(BUILD_TOOLS_PATH):$(PATH)"

JKS_PATH?= $(HOME)/Library/Mobile\ Documents/com~apple~CloudDocs
JKS_FILE?= ca.redpandatea.release.jks
JKS_PASS?= ca.redpandatea.release.jks.password.txt
JKS_ALIAS?= ca.redpandatea.release

APP_VERSION:= $(shell \
    sed -n -e 's/.*versionName .\([0-9.]*\)./\1/p' < app/build.gradle \
)
APK:= $(NAME)-$(APP_VERSION).apk
AAB:= $(NAME)-$(APP_VERSION).aab

ABIS:=		armeabi-v7a arm64-v8a
API:=		24
LIBS:=		c c++_shared dl log m z GLESv1_CM GLESv2 OpenSLES

ifeq ("$(ABI)","armeabi-v7a")
TARGET:=	arm-linux-androideabi
endif
ifeq ("$(ABI)","arm64-v8a")
TARGET:=	aarch64-linux-android
endif

love-11.4-android-src.tar.gz:
	curl -L -O https://github.com/love2d/love/releases/download/11.4/love-11.4-android-src.tar.gz

$(DIR): love-11.4-android-src.tar.gz
	gunzip < love-11.4-android-src.tar.gz | tar -f - -x
	patch -p0 -d love-11.4-android/love/src/jni/love \
		< $(MAKEDIR)/../patches/patch-love-11.4
	patch -p0 -d love-11.4-android \
		< $(MAKEDIR)/patches/patch-love-11.4-android
	mv love-11.4-android $(DIR)
	cp -f build.gradle $(DIR)/
	cp -f app/build.gradle $(DIR)/app/
	cp -f app/src/main/AndroidManifest.xml $(DIR)/app/src/main/
	cp -f app/src/main/res/values/styles.xml $(DIR)/app/src/main/res/values/
	cp -f love/build.gradle $(DIR)/love/
	cp -f love/src/jni/Application.mk $(DIR)/love/src/jni/
	cp -f love/src/main/java/org/love2d/android/GameActivity.java \
		$(DIR)/love/src/main/java/org/love2d/android/
	find $(NAME)-android/love/src/jni | while read f; do \
		(file $$f | grep ELF && rm -f $$f) || true; \
	done
	cd $(DIR) && ./gradlew clean

lib/$(ABI)/libluajit.a: ../build-luajit.sh
	cd .. && "$(MAKE)" LuaJIT
	env ABI=$(ABI) DESTDIR="$(MAKEDIR)/" LIBDIR="lib/$(ABI)" \
		python -m androidenv sh ../build-luajit.sh

.PHONY: lib
lib:
	cd .. && "$(MAKE)" aluminium-library
	cd ../aluminium-library \
		&& "$(MAKE)" -f android/Makefile so \
		&& env DESTDIR=$(MAKEDIR) PREFIX= LIBDIR= \
			"$(MAKE)" -f android/Makefile install

.PHONY: clean-lib
clean-lib:
	for abi in $(ABIS); do \
		rm -f $(MAKEDIR)/lib/$$abi/*.so; \
	done

.PHONY: luajit
luajit:
	for abi in $(ABIS); do \
		mkdir -p lib/$$abi; \
		(ABI=$$abi "$(MAKE)" lib/$$abi/libluajit.a || true); \
	done

.PHONY: clean-luajit
clean-luajit:
	cd ../LuaJIT && "$(MAKE)" clean
#	for abi in $(ABIS); do \
#		rm -f lib/$$abi/libluajit.*; \
#	done

.PHONY: apk-icon
apk-icon: $(DIR)
	cd $(MAKEDIR)/icon && "$(MAKE)" apk-icon
	cd $(MAKEDIR)/icon && for x in mdpi hdpi xhdpi xxhdpi xxxhdpi; do \
		cp -f $(NAME)-$$x.png \
			$(DIR)/app/src/main/res/drawable-$$x/$(NAME).png; \
	done

.PHONY: clean-apk-icon
clean-apk-icon:
	for x in mdpi hdpi xhdpi xxhdpi xxxhdpi; do \
		rm -f $(DIR)/app/src/main/res/drawable-$$x/*.png; \
	done

.PHONY: love
love:
	cd $(MAKEDIR)/.. && MOBILE=true "$(MAKE)" $(NAME).love
	cp -f $(MAKEDIR)/../$(NAME).love $(MAKEDIR)/

.PHONY: clean-love
clean-love:
	rm -f $(MAKEDIR)/$(NAME).love

.PHONY: debug-apk
debug-apk: app-embed-debug.apk

.PHONY: apk-depends
apk-depends: $(DIR) apk-icon love luajit lib
	mkdir -p $(DIR)/app/src/embed/assets
	cp -f $(NAME).love $(DIR)/app/src/embed/assets/game.love
	for abi in $(ABIS); do \
		mkdir -p $(DIR)/love/src/jni/LuaJIT-2.1/android/$$abi; \
		cp -f $(MAKEDIR)/lib/$$abi/libluajit.a \
			$(DIR)/love/src/jni/LuaJIT-2.1/android/$$abi/; \
	done
	for abi in $(ABIS); do \
		ABI=$$abi API=$(API) python -m androidenv --find-library $(LIBS) \
		| while read f; do cp -f "$$f" "$(MAKEDIR)/lib/$$abi/"; done; \
	done
	for abi in $(ABIS); do \
		mkdir -p $(DIR)/app/src/main/jniLibs/$$abi; \
		cp -f $(MAKEDIR)/lib/$$abi/*.so $(DIR)/app/src/main/jniLibs/$$abi/; \
	done

app-embed-debug.apk: apk-depends
	cd $(DIR) && ./gradlew assembleDebug
	cp $(DIR)/app/build/outputs/apk/embed/debug/app-embed-debug.apk $(MAKEDIR)/

.PHONY: release-apk
release-apk: app-embed-release-unsigned.apk

app-embed-release-unsigned.apk: apk-depends
	cd $(DIR) && ./gradlew assembleRelease
	cp $(DIR)/app/build/outputs/apk/embed/release/app-embed-release-unsigned.apk $(MAKEDIR)/

app-embed-release.aab: apk-depends
	cd $(DIR) && ./gradlew bundleRelease
	cp $(DIR)/app/build/outputs/bundle/embedRelease/app-embed-release.aab $(MAKEDIR)/

KS_OPT:= --ks $(JKS_PATH)/$(JKS_FILE) --ks-pass file:$(JKS_PATH)/$(JKS_PASS)

.PHONY: sign-apk
sign-apk: app-embed-release-unsigned.apk $(JKS_PATH)/$(JKS_FILE)
	env $(BUILD_TOOLS_ENV) \
		zipalign -p -f -v 4 app-embed-release-unsigned.apk $(APK)
	env $(BUILD_TOOLS_ENV) zipalign -c -v 4 $(APK)
	env $(BUILD_TOOLS_ENV) apksigner sign $(KS_OPT) $(APK)

.PHONY: check-sign-apk
check-sign-apk:
	env $(BUILD_TOOLS_ENV) apksigner verify --verbose --print-certs $(APK)

.PHONY: sign-aab
sign-aab: app-embed-release.aab $(JKS_PATH)/$(JKS_FILE)
	env $(BUILD_TOOLS_ENV) \
		zipalign -p -f -v 4 app-embed-release.aab $(AAB)
	env $(BUILD_TOOLS_ENV) zipalign -c -v 4 $(AAB)
	jarsigner -keystore $(JKS_PATH)/$(JKS_FILE) \
		-storepass :file $(JKS_PATH)/$(JKS_PASS) $(AAB) $(JKS_ALIAS)

.PHONY: check-sign-aab
check-sign-aab:
	jarsigner -verify $(AAB)

.PHONY: sign
sign:

$(APK):
	"$(MAKE)" app-embed-release-unsigned.apk
	"$(MAKE)" sign-apk check-sign-apk

$(AAB):
	"$(MAKE)" app-embed-release.aab
	"$(MAKE)" sign-aab check-sign-aab

.PHONY: apk
apk: $(APK)

.PHONY: aab
aab: $(AAB)

.PHONY: release
release:
	"$(MAKE)" apk check-apk
	"$(MAKE)" aab check-aab

.PHONY: check-apk
check-apk:
	test -f $(APK) && env $(BUILD_TOOLS_ENV) aapt dump badging $(APK)

.PHONY: check-aab
check-aab:
#	test -f $(AAB) && env $(BUILD_TOOLS_ENV) aapt dump badging $(AAB)

.PHONY: clean-apk
clean-apk: clean-apk-icon clean-love clean-luajit clean-lib
	for abi in $(ABIS); do \
		rm -f $(DIR)/love/src/jni/LuaJIT-2.1/android/$$abi/libluajit.*; \
		rm -f $(DIR)/app/src/main/jniLibs/$$abi/*.so; \
	done
	rm -f $(DIR)/app/src/embed/assets/game.love
	rm -f app-embed-debug.apk
	rm -f app-embed-release-unsigned.apk
#	rm -f $(APK)
	rm -f $(APK).idsig

.PHONY: clean-aab
clean-aab:
	rm -f app-embed-release.aab
	rm -f $(AAB)

.PHONY: cleanup
cleanup:
	rm -rf love-11.4-android

.PHONY: clean
clean: cleanup clean-apk clean-aab clean-lib clean-love
	rm -rf $(DIR)
	rm -rf .classpath .externalToolBuilders .gradle .idea .settings
	dot_clean .
	find . -name .DS_Store | xargs rm -f
