#!/bin/bash
# 打包,发布

APP_NAME="ClashX"
INFOPLIST_FILE="Info.plist"
BASE_DIR=/Users/nanamao/Projects/${APP_NAME}
BUILD_DIR=${BASE_DIR}/Build
APP_DEBUG_DIR=${BUILD_DIR}/Products/Debug
APP_ARCHIVE=${BUILD_DIR}/${APP_NAME}.xcarchive
APP_RELEASE=${BUILD_DIR}/release
APP_Version=$(sed -n '/MARKETING_VERSION/{s/MARKETING_VERSION = //;s/;//;s/^[[:space:]]*//;p;q;}' ../${APP_NAME}.xcodeproj/project.pbxproj)
DMG_FINAL="${APP_NAME}_v${APP_Version}.dmg"
APP_TITLE="${APP_NAME}_${APP_Version}"

function createFolder() {
    mkdir ${APP_RELEASE}
    cp -r ${APP_DEBUG_DIR}/${APP_NAME}.app ${APP_RELEASE}/${APP_NAME}.app
}

function createDmg() {
    umount "/Volumes/${APP_NAME}"

    ############# 1 #############
    APP_PATH="${APP_RELEASE}/${APP_NAME}.app"
    DMG_BACKGROUND_IMG="dmg-bg@2x.png"

    DMG_TMP="${APP_NAME}-temp.dmg"

    # 清理文件夹
    echo "createDmg start."
    rm -rf "${DMG_TMP}" "${DMG_FINAL}"
    # 创建文件夹，拷贝，计算
    SIZE=`du -sh "${APP_PATH}" | sed 's/\([0-9\.]*\)M\(.*\)/\1/'`
    SIZE=`echo "${SIZE} + 1.0" | bc | awk '{print int($1+0.5)}'`
    # 容错处理
    if [ $? -ne 0 ]; then
       echo "Error: Cannot compute size of staging dir"
       exit
    fi
    # 创建临时dmg文件
    hdiutil create -srcfolder "${APP_PATH}" -volname "${APP_NAME}" -fs HFS+ \
          -fsargs "-c c=64,a=16,e=16" -format UDRW -size ${SIZE}M "${DMG_TMP}"
    echo "Created DMG: ${DMG_TMP}"

    ############# 2 #############
    DEVICE=$(hdiutil attach -readwrite -noverify "${DMG_TMP}"| egrep '^/dev/' | sed 1q | awk '{print $1}')

    # 拷贝背景图片
    mkdir /Volumes/"${APP_NAME}"/.background
    cp "${BUILD_DIR}/${DMG_BACKGROUND_IMG}" /Volumes/"${APP_NAME}"/.background/
    # 使用applescript设置一系列的窗口属性
    echo '
       tell application "Finder"
         tell disk "'${APP_NAME}'"
               open
               set current view of container window to icon view
               set toolbar visible of container window to false
               set statusbar visible of container window to false
               set the bounds of container window to {0, 0, 500, 297}
               set viewOptions to the icon view options of container window
               set arrangement of viewOptions to not arranged
               set icon size of viewOptions to 80
               set background picture of viewOptions to file ".background:'${DMG_BACKGROUND_IMG}'"
               make new alias file at container window to POSIX file "/Applications" with properties {name:"Applications"}
               delay 1
               set position of item "'${APP_NAME}'.app" of container window to {120, 120}
               set position of item "Applications" of container window to {380, 120}
               close
               open
               update without registering applications
               delay 2
         end tell
       end tell
    ' | osascript

    sync
    # 卸载
    hdiutil detach "${DEVICE}"

    ############# 3 #############
    echo "Creating compressed image"
    hdiutil convert "${DMG_TMP}" -format UDZO -imagekey zlib-level=9 -o "${DMG_FINAL}"

    # appcast sign update
    ${BASE_DIR}/Pods/Sparkle/bin/sign_update ${DMG_FINAL}

    umount "/Volumes/${APP_NAME}"
}


function makeDmg() {
    echo "正在打包版本: "${APP_Version}
    read -n1 -r -p "請確認版本號是否正確？ [Y/N]? " answer
    case ${answer} in
    Y | y ) echo
    echo "您選擇了 Y";;
    N | n ) echo
    echo ""
    echo "OK, goodbye"
    exit;;
    *)
    echo ""
    echo "請輸入 [Y|N]"
    exit;;
    esac

    createFolder
    createDmg
    #rm -fr ${DMG_FINAL} ${APP_RELEASE}
    rm -rf "${DMG_TMP}" ${APP_RELEASE}
    
}

makeDmg
echo 'done'
