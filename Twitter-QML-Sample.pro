TEMPLATE = app

QT += qml quick
CONFIG += c++11

SOURCES += main.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
        common/TwitterQML.h

android {
    QT += androidextras
    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android/project
    SOURCES += \
        android/TwitterQML.cpp
    HEADERS += \
        android/AndroidGlobals.h 
}

ios {
    QT += gui-private
    CONFIG -= bitcode
    QMAKE_IOS_DEPLOYMENT_TARGET = 8.0
    QMAKE_INFO_PLIST = $$PWD/ios/project/Project-Info.plist
    OTHER_FILES += $$QMAKE_INFO_PLIST
    TwitterKit.files = $$PWD/ios/project/TwitterKit.framework/Resources/TwitterKitResources.bundle
    QMAKE_BUNDLE_DATA += TwitterKit
    OBJECTIVE_SOURCES += \
        ios/TwitterQML.mm
    LIBS += -F$$PWD/ios/project -framework Fabric -framework TwitterKit -framework TwitterCore -framework UIKit
    LIBS += -framework CoreData -framework Foundation -framework Social -framework Accounts -framework SafariServices
}

DISTFILES += \
    android/project/AndroidManifest.xml \
    android/project/gradle/wrapper/gradle-wrapper.jar \
    android/project/gradlew \
    android/project/res/values/libs.xml \
    android/project/build.gradle \
    android/project/gradle/wrapper/gradle-wrapper.properties \
    android/project/gradlew.bat
    android/project/src/me/mnafees/TwitterQMLSample/TwitterQMLHelperActivity.java
