#!/bin/bash

###############################################################################
# Bash helper functions (github.com/alanlivio/bash_helper_functions)
# update by: wget raw.githubusercontent.com/alanlivio/bash_helper_functions/master/bash_helper_functions.sh
###############################################################################

###############################################################################
# log functions 
###############################################################################

function aux-print() { echo -e "$1" | fold -w100 -s | sed '2~1s/^/  /'; }
function log-error() { aux-print "\033[00;31m---> $1 fail\033[00m"; }
function log-msg()   { aux-print "\033[00;33m---> $1\033[00m"; }
function log-done()  { aux-print "\033[00;32m---> $1 done\033[00m"; }
function log-ok()    { aux-print "\033[00;32m---> OK\033[00m"; }
function TRY()       { "$@"; if test $? -ne 0; then log-error "$1" && exit 1; fi;}

###############################################################################
# audio functions
###############################################################################

function mybash-audio-create-empty() {
  # gst-launch-1.0 audiotestsrc wave=4 ! audioconvert ! lamemp3enc ! id3v2mux ! filesink location=file.mp3
  : ${1?an argument is required}
  gst-launch-1.0 audiotestsrc wave=4 ! audioconvert ! lamemp3enc ! id3v2mux ! filesink location="$1"
}

function mybash-audio-compress() {
  : ${1?an argument is required}
  lame -b 32  "$1".mp3 compressed"$1".mp3
}

###############################################################################
# video functions
###############################################################################

function mybash-video-create-by-image() {
  : ${1?an argument is required}
  ffmpeg -loop_input -i "$1".png -t 5 "$1".mp4
}

function mybash-video-cut() {
  : ${1?an argument is required}
  ${1?an second argument is required}
  # ffmpeg -i saida.mp4 -vcodec copy -acodec copy -ss 00:16:03 -t 00:09:34 -f mp4 "1.1-vai-antonio.mp4"
  ffmpeg -i "$1"  -vcodec copy -acodec copy -ss "$2"  -t "$3"  -f mp4 cuted-$1
}

###############################################################################
# pygmentize functions
###############################################################################

function mybash-pygmentize-files-by-extensions-to-image() {
  : ${1?an argument is required}
  find . -maxdepth 1 -name "*.$1" | while read -r i
  do
    pygmentize -f jpeg -l xml -o $i.jpg $i
  done
}

function mybash-pygmentize-files-by-extensions-to-rtf() {
  : ${1?an argument is required}
   find . -maxdepth 1 -name "*.$1" | while read -r i
  do
    pygmentize -f jpeg -l xml -o $i.jpg $i
    pygmentize -P fontsize=16 -P fontface=consolas -l -o $i.rtf $i
  done
}

function mybash-pygmentize-files-by-extensions-to-html() {
  : ${1?an argument is required}
   find . -maxdepth 1 -name "*.$1" | while read -r i
  do
    pygmentize -O full,style=default -f html -l xml -o $i.html $i
  done
}

###############################################################################
# gdb functions
###############################################################################

function mybash-gdb-run-bt() {
  : ${1?an argument is required}
  gdb -batch -ex=r -ex=bt --args "$1"
}

function mybash-gdb-run-bt-all-threads() {
  : ${1?an argument is required}
  gdb -batch -ex=r -ex="thread apply all bt" --args "$1"
}

###############################################################################
# git functions
###############################################################################

function mybash-git-create-gitignore() {
  : ${1?an argument is required}
  curl -L -s "https://www.gitignore.io/api/$1"
}

function mybash-git-create-gitignore-editors() {
  mybash-git-gitignore linux,windows,osx,qt,vimc,make,git,eclipse,notepadpp
}

function mybash-git-create-gitignore-editors() {
  mybash-git-gitignore c,c++,autotools
}

function mybash-git-find-folders-reset-clean-uninstall {
  find -iname .git | while read -r i
  do
    cd "$(dirname $i)" || exit
    make clean
    make uninstall
    git reset --hard
    git clean -df
    cd -
  done
}

function mybash-git-commit-formated() {
  echo -e "\n" > /tmp/commit.txt
  for i in $(git status -s|cut -c4-); do
    echo -e "* $i: Likewise.">>  /tmp/commit.txt
  done
  git commit -t /tmp/commit.txt
}

function mybash-git-list-large-files() {
  git verify-pack -v .git/objects/pack/*.idx | sort -k 3 -n | tail -3
}

###############################################################################
# editors functions
###############################################################################


function mybash-qtcreator-project-from-git() {
  project_name="${PWD##*/}"
  touch "$project_name.config"
  echo -e "[General]\n" > "$project_name.creator"
  echo -e "src\n" > "$project_name.includes"
  git ls-files > "$project_name.files"
}

function mybash-atom-copy-tern-project(){
  cp ~/gdrive/env/apps/.tern-project .
}

function mybash-eclipse-list-installed() {
  /opt/eclipse/eclipse \
  -consolelog -noSplash \
  -application org.eclipse.equinox.p2.director \
  -listInstalledRoots
}

###############################################################################
# android functions
###############################################################################

function mybash-android-start-activity () {
  #adb shell am start -a android.intent.action.MAIN -n com.android.browser/.BrowserActivity
  #adb shell am start -a android.intent.action.MAIN -n org.libsdl.app/org.libsdl.app.SDLActivity
  : ${1?an argument is required}
  adb shell am start -a android.intent.action.MAIN -n "$1"
}
function mybash-android-restart-adb (){
  sudo adb kill-server && sudo adb start-server
}

function mybash-android-get-ip(){
  adb shell netcfg
  adb shell ifconfig wlan0
}

function mybash-android-enable-stdout-stderr-output(){
  adb shell stop
  adb shell setprop log.redirect-stdio true
  adb shell start
}

function mybash-android-get-printscreen (){
  adb shell /system/bin/screencap -p /sdcard/screenshot.png
  adb pull /sdcard/screenshot.png screenshot.png
  adb pull /sdcard/screenshot.png screenshot.png
}

function mybash-android-installed-package (){
  : ${1?an argument is required}
  adb shell pm list packages | grep ginga
}

function mybash-android-uninstall-package() {
  # adb uninstall org.libsdl.app
  : ${1?an argument is required}
  adb uninstall $1
}
function mybash-android-install-package() {
  : ${1?an argument is required}
  adb install $1
}

###############################################################################
# folder functions
###############################################################################

function mybash-folder-size() {
  du -ahd 1| sort -h
}

function mybash-folder-delete-latex-files () {
  find -print0 -iname "*-converted-to.pdf" -or -iname "*.aux" -or -iname "*.log" -or -iname "*.nav" -or -iname "*.out" -or -iname "*.snm" "*.synctex.gz" -or -iname "*.toc" | xargs rm
}

function mybash-folder-delete-cmake-files() {
  rm -rf CMakeFiles/ CMakeCache.txt cmake-install.cmake  Makefile CPack* CPack* CTest* "*.cbp"
}

function mybash-folder-delete-binary-files() {
  find -print0 -iname "*.a" -or -iname "*.o" -or -iname "*.so" -or -iname "*.Plo" -or -iname "*.la" -or -iname "*.log" -or -iname "*.tmp"| xargs rm
}

function mybash-folder-find-cpp-files() {
  find . -print0 -iname "*.h" -or -iname "*.cc" -or -iname "*.cpp" -or -iname "*.c"
}

function mybash-folder-find-autotools-files() {
  find . -print0 -iname "*.am" -or -iname "*.ac"
}

###############################################################################
# image functions
###############################################################################

function mybash-image-reconize-text() {
  : ${1?an argument is required}
  tesseract -l eng "$1"  "$1.txt"
}

function mybash-imagem-compress() {
  : ${1?an argument is required}
  pngquant "$1"   --force --quality=70-80 -o "compressed-$1"
}

function mybash-imagem-compress2() {
  : ${1?an argument is required}
  jpegoptim -d . $1.jpeg
}

###############################################################################
# pdf functions
###############################################################################

function mybash-pdf-remove-password() {
  : ${1?an argument is required}
  qpdf --decrypt "$1"  "unlocked-$1"
}

function mybash-pdf-remove-watermark() {
  : ${1?an argument is required}
  sed -e "s/THISISTHEWATERMARK/ /g" < "$1"  > nowatermark.pdf
  pdftk nowatermark.pdf output repaired.pdf
  mv repaired.pdf nowatermark.pdf
}

function mybash-pdf-compress() {
  : ${1?an argument is required}
  gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dNOPAUSE -dQUIET -dBATCH -sOutputFile=compressed$1.pdf  $1
}


function mybash-pdf-convert-to() {
  : ${1?an argument is required}
  soffice --headless --convert-to pdf "$1"
}

###############################################################################
# rename functions
###############################################################################

function mybash-rename-lowercase-dash() {
  : ${1?an argument is required}
  rename 'y/A-Z/a-z/;s/_/-/g;s/\./-/g;s/ /-/g;s/---/-/g;s/-pdf/.pdf/g' "$@" &> /dev/null
}

###############################################################################
# network functions
###############################################################################

function mybash-network-arp-scan() {
  sudo arp-scan 139.82.95.26/24
}

###############################################################################
# virtualbox functions
###############################################################################

function mybash-virtualbox-compact() {
  : ${1?an argument is required}
  #VBoxManage modifyhd /opt/win7/win7.vdi compact
  VBoxManage modifyhd "$1" compact
}

function mybash-virtualbox-resize() {
  : ${1?an argument is required}
  #VBoxManage modifyhd /opt/win7/win7.vdi --resize 200000
  VBoxManage modifyhd "$1" --resize 200000
}

###############################################################################
# user functions
###############################################################################

function mybash-user-reload-bashrc() {
  source ~/.bashrc
}

function mybash-user-fix-ssh-permissions() {
  sudo chmod  700 ~/.ssh/ &&\
  sudo chmod  755 ~/.ssh/* &&\
  sudo chmod  600 ~/.ssh/id_rsa &&\
  sudo chmod  644 ~/.ssh/id_rsa.pub
}

function mybash-user-send-ssh-keys() {
  : ${1?an argument is required}
  ssh "$1" 'cat - >> ~/.ssh/authorized_keys' < ~/.ssh/id_rsa.pub
}