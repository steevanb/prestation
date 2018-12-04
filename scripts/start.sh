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

echo -en "\033[42m\033[1;37m Everything is started. \033[0m\n"
echo -e "url: \e[4mhttp://prestation.loc:8083\e[0m"
echo "nginx port: 8083"

source "$(dirname $0)/docker-web-bash.sh"
