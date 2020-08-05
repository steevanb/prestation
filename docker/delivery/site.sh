#!/usr/bin/env bash

set -eu

echo -en "\e[44m Are you sure you want to deliver admin in PROD [y/N]? \e[0m "
read confirm
if [ "$confirm" != "Y" ] && [ "$confirm" != "y" ]; then
    echo -e "\e[41m Delivery canceled. \e[0m"
    exit 1
fi

readonly ROOT_DIR="/tmp/delivery"
readonly OUTPUT_REDIRECT="/tmp/delivery.log"
#readonly OUTPUT_REDIRECT="/proc/self/fd/0"
readonly ZIP_FILE="/tmp/delivery.zip"
readonly SERVER_URL="infodroid@sephidev.net"
readonly SERVER_INSTALLATION_ROOT_DIR="/data/www/prestation"

function rmLogFile()
{
    if [ -f "${OUTPUT_REDIRECT}" ]; then
        rm "${OUTPUT_REDIRECT}"
    fi
}

function onError()
{
    if [ -f "$OUTPUT_REDIRECT" ]; then
        cat $OUTPUT_REDIRECT
        rmLogFile
    fi

    echo -e "\e[41m Delivery canceled. \e[0m"
}

trap onError ERR

function echoTitle() {
    echo -e "\e[46m $1 \e[0m"
}

function echoAction() {
    echo "  $1"
}

function prepareFiles() {
    trap onError ERR

    echoTitle "Prepare files"

    echoAction "Clone repository."
    mkdir -p $ROOT_DIR
    cd $ROOT_DIR
    git clone --single-branch --branch=${GIT_TAG} git@github.com:info-droid/prestation.git . > $OUTPUT_REDIRECT 2>&1
    rmLogFile

    echoAction "Remove useless files."
    rm -rf \
        .git \
        .gitignore \
        bin/start \
        delivery \
        docker

    composer install --no-dev --classmap-authoritative > $OUTPUT_REDIRECT 2>&1
    rmLogFile
}

function copyFilesToTheServer() {
    trap onError ERR

    echoTitle "Copy files to the server"

    echoAction "ZIP files."
    cd $ROOT_DIR
    zip -9 -r "$ZIP_FILE" . > $OUTPUT_REDIRECT 2>&1
    rmLogFile

    echoAction "Copy files to the server."
    ssh $SERVER_URL "mkdir $SERVER_INSTALLATION_VERSION_DIR" > $OUTPUT_REDIRECT 2>&1
    rmLogFile
    scp "$ZIP_FILE" $SERVER_URL:$SERVER_INSTALLATION_VERSION_DIR/delivery.zip > $OUTPUT_REDIRECT 2>&1
    rmLogFile
    ssh $SERVER_URL "cd $SERVER_INSTALLATION_VERSION_DIR && unzip delivery.zip && rm delivery.zip" > $OUTPUT_REDIRECT 2>&1
    rmLogFile

    echoAction "Change \"current\" symlink."
    ssh $SERVER_URL "rm -rf $SERVER_INSTALLATION_ROOT_DIR/current && ln -s $SERVER_INSTALLATION_VERSION_DIR $SERVER_INSTALLATION_ROOT_DIR/current" > $OUTPUT_REDIRECT 2>&1
    rmLogFile
}

function reloadNginx() {
    trap onError ERR

    echoTitle "Reload nginx"
    ssh $SERVER_URL "sudo /usr/sbin/service nginx reload" > $OUTPUT_REDIRECT 2>&1
    rmLogFile
}

echo -en "\e[44m Tag to deliver? \e[0m "
read GIT_TAG
readonly SERVER_INSTALLATION_VERSION_DIR="$SERVER_INSTALLATION_ROOT_DIR/delivery_$(date +%Y-%m-%d_%H-%M-%S)__tag_$GIT_TAG"

prepareFiles
copyFilesToTheServer
reloadNginx

echo ""
echo -e "\e[42m Delivery terminated. \e[0m"
