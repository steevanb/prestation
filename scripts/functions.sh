#!/bin/bash

function block() {
    local titleLength=${#2}
    echo -en "\n\033[$1m\033[1;37m    "
    for x in $(seq 1 $titleLength); do echo -en " "; done ;
    echo -en "\033[0m\n"

    echo -en "\033[$1m\033[1;37m  $2  \033[0m\n"
    echo -en "\033[$1m\033[1;37m    "
    for x in $(seq 1 $titleLength); do echo -en " "; done ;
    echo -en "\033[0m\n\n"
}

function title() {
    block 46 "$1"
}

function cancelScript() {
    if [ "$1" = "" ]; then
        message="Script canceled, error occured."
    else
        message=$1
    fi
    echo -en "\n\n"
    block 41 "$message"
    exit 1
}

function echoCmd() {
    echo -en "\033[45m\033[1;37m$ $1\033[0m\n"
}

function execCmd() {
    echoCmd "$1"
    $1
    [ "$?" != "0" ] && cancelScript "$2"
    echo ""
}

function execCmdHideOutput() {
    local cmdLogFile="/tmp/phpbenchmarks-cmd.log"
    echoCmd "$1"

    $1 &>$cmdLogFile
    [ "$?" != "0" ] && cat $cmdLogFile && rm $cmdLogFile && cancelScript "$2"

    rm $cmdLogFile
    echo ""
}
