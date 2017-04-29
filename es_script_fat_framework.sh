#!/bin/sh
# Basado en el script del usuario cromandini: https://gist.github.com/cromandini/1a9c4aeab27ca84f5d79

# Puedes descomentar la siguiente línea para forzar que, si algún punto de este
# script falla, todo el script se marcará como fallido dando errores de ejecución.
# set -e

# Prevenir un bucle infinito (recursivo) generado por el propio xcode
if [ "true" == ${ALREADYINVOKED:-false} ]
then
echo "RECURSION: I am NOT the root invocation, so I'm NOT going to recurse"
else

export ALREADYINVOKED="true"

# Escribe el nombre del target sobre el que quieres generar el framework universal.
# Puedes usar el alias ${TARGET_NAME} si colocas este script dentro del propio framework.
# Si por ejemplo lo usas estando dentro de un "Aggregate" indica simplemente el nombre
# del framework que quieres generar.
TARGET=<Put_your_target_name_here>

# Alias donde el fat-framework se guardará.
UNIVERSAL_OUTPUTFOLDER=${BUILD_DIR}/${CONFIGURATION}-universal

# Crear el directorio destino (para evitar errores)
mkdir -p "${UNIVERSAL_OUTPUTFOLDER}"

# Paso 1. Compilar para dispositivo (iphoneos) y para simulador (iphonesimulator)
xcodebuild -target "${TARGET}" ONLY_ACTIVE_ARCH=NO -configuration ${CONFIGURATION} -sdk iphoneos  BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}" clean build
xcodebuild -target "${TARGET}" -configuration ${CONFIGURATION} -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}" clean build

# Paso 2. Copias la estructura del framework de dispositivo (iphoneos) al directorio destino
cp -R "${BUILD_DIR}/${CONFIGURATION}-iphoneos/${TARGET}.framework" "${UNIVERSAL_OUTPUTFOLDER}/"

# Paso 3. Copiar los modulos de Swift para iphonesimulator (si existen) al directorio destino
SIMULATOR_SWIFT_MODULES_DIR="${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/${TARGET}.framework/Modules/${TARGET}.swiftmodule/."
if [ -d "${SIMULATOR_SWIFT_MODULES_DIR}" ]; then
cp -R "${SIMULATOR_SWIFT_MODULES_DIR}" "${UNIVERSAL_OUTPUTFOLDER}/${TARGET}.framework/Modules/${TARGET}.swiftmodule"
fi

# Paso 4. Crear el framework universal usando 'lipo'. Con él se mezclará la librería iphoneos
# con arquitecturas arm64+armv7 con las i386+x86_64 correspondientes a iphonesimulator. Esto
# generará como salida una única librería con las cuatro arquitecturas.
# Más informacion: https://ss64.com/osx/lipo.html
lipo -create -output "${UNIVERSAL_OUTPUTFOLDER}/${TARGET}.framework/${TARGET}" "${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/${TARGET}.framework/${TARGET}" "${BUILD_DIR}/${CONFIGURATION}-iphoneos/${TARGET}.framework/${TARGET}"

# Paso 5. (Opcional) Abrir en una ventana de Finder el directorio destino
open "${UNIVERSAL_OUTPUTFOLDER}"
fi
