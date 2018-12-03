#!/usr/bin/env bash
source "$(dirname $0)/functions.sh"

function addHost() {
    local host=$1
    if [ "$(cat /etc/hosts | grep $host)" == "" ]; then
        echo ""
        echoCmd "echo '127.0.0.1       $host' >> /etc/hosts"
        sudo bash -c "echo '127.0.0.1       $host' >> /etc/hosts"
        [ "$?" != "0" ] && cancelScript "Error while adding host $host."
    fi
}

execCmdHideOutput "docker-compose up --build -d" "Error while starting docker."
execCmd "docker-compose ps"

addHost "prestation.loc"

echo -e "Everything is started, you can go to \e[4mhttp://prestation.loc\e[0m."

source "$(dirname $0)/docker-web-bash.sh"
