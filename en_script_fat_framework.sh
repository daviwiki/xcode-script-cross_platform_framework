#!/bin/sh
# Based in cromandini script: https://gist.github.com/cromandini/1a9c4aeab27ca84f5d79

# You can uncomment next line to force and error if any process of this script fails
# set -e

# Avoid infinite recursion with this condition
if [ "true" == ${ALREADYINVOKED:-false} ]
then
echo "RECURSION: I am NOT the root invocation, so I'm NOT going to recurse"
else

export ALREADYINVOKED="true"

# Define the target name. Remember you could use the xcode-alias ${TARGET_NAME}
# if you are including this script into the target that will generate your framework.
# If you include this script into an "Aggregate" simply include your target name
# manually
TARGET=<Put_your_target_name_here>

# the directory where 'fat'-framework will be stored
UNIVERSAL_OUTPUTFOLDER=${BUILD_DIR}/${CONFIGURATION}-universal

# make sure the output directory exists
mkdir -p "${UNIVERSAL_OUTPUTFOLDER}"

# Step 1. Build Device (first line) and Simulator (second one) versions
xcodebuild -target "${TARGET}" ONLY_ACTIVE_ARCH=NO -configuration ${CONFIGURATION} -sdk iphoneos  BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}" clean build
xcodebuild -target "${TARGET}" -configuration ${CONFIGURATION} -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}" clean build

# Step 2. Copy the framework structure (from iphoneos build) to the universal folder
cp -R "${BUILD_DIR}/${CONFIGURATION}-iphoneos/${TARGET}.framework" "${UNIVERSAL_OUTPUTFOLDER}/"

# Step 3. Copy Swift modules from iphonesimulator build (if it exists) to the copied framework directory
SIMULATOR_SWIFT_MODULES_DIR="${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/${TARGET}.framework/Modules/${TARGET}.swiftmodule/."
if [ -d "${SIMULATOR_SWIFT_MODULES_DIR}" ]; then
cp -R "${SIMULATOR_SWIFT_MODULES_DIR}" "${UNIVERSAL_OUTPUTFOLDER}/${TARGET}.framework/Modules/${TARGET}.swiftmodule"
fi

# Step 4. Create universal binary file using lipo and place the combined executable in the copied framework directory.
# In this step the iphoneos archs (arm64+armv7) will be combined with iphonesimulator archs (i386+x86_64) and
# an unique fat library file will be created with this four architectures
# More information: https://ss64.com/osx/lipo.html
lipo -create -output "${UNIVERSAL_OUTPUTFOLDER}/${TARGET}.framework/${TARGET}" "${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/${TARGET}.framework/${TARGET}" "${BUILD_DIR}/${CONFIGURATION}-iphoneos/${TARGET}.framework/${TARGET}"

# Step 5. Convenience step to open the project's directory in Finder
open "${UNIVERSAL_OUTPUTFOLDER}"
fi
