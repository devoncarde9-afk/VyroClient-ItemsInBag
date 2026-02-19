name: Build

on:
  workflow_dispatch:

jobs:
  build:
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v4
    - run: brew install ldid dpkg
    - run: |
        git clone --recursive https://github.com/theos/theos.git $HOME/theos
        cd $HOME/theos
        curl -LO https://github.com/theos/sdks/archive/master.zip
        unzip master.zip
        mv sdks-master/iPhoneOS*.sdk sdks/
    - run: |
        cat > $HOME/theos/vendor/include/substrate.h << 'EOF'
        #import <objc/runtime.h>
        #import <objc/message.h>
        void MSHookMessageEx(Class c, SEL m, IMP h, IMP *o);
        EOF
        cat > /tmp/s.m << 'EOF'
        #import <objc/runtime.h>
        void MSHookMessageEx(Class c, SEL m, IMP h, IMP *o) {
            Method method = class_getInstanceMethod(c, m);
            if (o) *o = (IMP)method_getImplementation(method);
            method_setImplementation(method, h);
        }
        EOF
    - run: |
        export THEOS=$HOME/theos
        X=$(find . -name "*ItemsInBag*.x" | head -n 1)
        $THEOS/bin/logos.pl "$X" > m.m
        xcrun -sdk iphoneos clang -arch arm64 -isysroot $(xcrun -sdk iphoneos --show-sdk-path) -miphoneos-version-min=14.0 -fobjc-arc -I$THEOS/include -I$THEOS/vendor/include -Wno-everything -c m.m -o m.o
        xcrun -sdk iphoneos clang -arch arm64 -isysroot $(xcrun -sdk iphoneos --show-sdk-path) -fobjc-arc -c /tmp/s.m -o /tmp/s.o
        xcrun -sdk iphoneos clang -arch arm64 -isysroot $(xcrun -sdk iphoneos --show-sdk-path) -dynamiclib -o VyroClient_ItemsInBag.dylib m.o /tmp/s.o -framework Foundation -framework UIKit -framework CoreGraphics -Wl,-undefined,dynamic_lookup
        ldid -S VyroClient_ItemsInBag.dylib
    - run: |
        mkdir -p p/DEBIAN p/Library/MobileSubstrate/DynamicLibraries
        cp VyroClient_ItemsInBag.dylib p/Library/MobileSubstrate/DynamicLibraries/
        find . -name "*.plist" | head -n 1 | xargs -I{} cp {} p/Library/MobileSubstrate/DynamicLibraries/VyroClient_ItemsInBag.plist
        echo -e "Package: com.vyro.itemsinbag\nName: VyroClient Items in Bag\nVersion: 1.0.0\nArchitecture: iphoneos-arm64\nDescription: Addon\nMaintainer: Me\nSection: Tweaks" > p/DEBIAN/control
        dpkg-deb -b p VyroClient_ItemsInBag.deb
        ls -lh VyroClient_ItemsInBag.deb
    - uses: actions/upload-artifact@v4
      with:
        name: DOWNLOAD_THIS
        path: VyroClient_ItemsInBag.deb
