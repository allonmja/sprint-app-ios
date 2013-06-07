#!/usr/bin/env bash

# Build local variables
#XcodeAppName=Xcode
#BUILD_NUMBER=1
#WORKSPACE=/Users/mibmrg0/.jenkins/jobs/jenkinstest-ios
#Config=AutobuildRelease
#Target=NameOfTarget
#Scheme=NameOfScheme


# Set the DEVELOPER_DIR for xcode for project
export DEVELOPER_DIR=/Applications/${XcodeAppName}.app/Contents/Developer

# move into source directory
#cd LesMasions

# Clean the project
xcodebuild clean

# set the project/target version number and build number to current (jenkins) build number index
agvtool new-version -all ${BUILD_NUMBER}

# Build project
xcodebuild -target ${Target} -scheme ${Scheme} -configuration ${Config} DSTROOT=$WORKSPACE/build.dst OBJROOT=$WORKSPACE/build.obj \
SYMROOT=$WORKSPACE/build.sym SHARED_PRECOMPS_DIR=$WORKSPACE/build.pch

# Sign and export
if [ "$Target" == "SPRINT" ]; then
    if [ "$Config" == "Debug" ]; then
        /usr/bin/xcrun -sdk iphoneos PackageApplication -v $WORKSPACE/build.sym/${Config}-iphoneos/${Target}.app -o $WORKSPACE/build.sym/${Config}-iphoneos/${Target}.ipa --sign "iPhone Developer" --embed ${WORKSPACE}/autobuild/iOSTeam.mobileprovision

    fi
    if [ "$Config" == "Release" ]; then
        /usr/bin/xcrun -sdk iphoneos PackageApplication -v $WORKSPACE/build.sym/${Config}-iphoneos/${Target}.app -o $WORKSPACE/build.sym/${Config}-iphoneos/${Target}.ipa --sign "iPhone Distribution: Compuware Corporation" --embed ~/Downloads/Enterprise.mobileprovision
        mv $WORKSPACE/build.sym/${Config}-iphoneos/${Target}.ipa $WORKSPACE/${Target}.ipa

    fi
    # If you created a configuration for each environment (development, test, customer production)
    # You may need a separate configuration created to build against our internal servers (or for any specific environment)
    if [ "$Config" == "AutobuildRelease" ]; then
        /usr/bin/xcrun -sdk iphoneos PackageApplication -v $WORKSPACE/build.sym/${Config}-iphoneos/${Target}.app -o $WORKSPACE/build.sym/${Config}-iphoneos/${Target}.ipa --sign "iPhone Distribution: Compuware Corporation" --embed ~/Downloads/Enterprise.mobileprovision
    fi
fi

# Test project
# xcodebuild -target ${UnitTestTarget} -sdk iphonesimulator -configuration ${Config} TEST_AFTER_BUILD=YES clean build | $WORKSPACE/autobuild/ocunit2junit.rb

# move back to workspace
cd $WORKSPACE






