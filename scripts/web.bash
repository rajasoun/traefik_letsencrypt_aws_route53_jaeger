#!/usr/bin/env bash

function display_url_status(){
    HOST=$1
    if [[ "$(curl -s -o /dev/null -L -w ''%{http_code}'' ${HOST})" != "200" ]] ; then 
        echo "$HOST  -> Down"
    else
        echo "$HOST  -> Up"
    fi
}

function wait_for_url() {
    echo "If thsi the first time, Certificate generation takes around a min..."
    HOST=$1
    echo "Testing $1"
    timeout -s TERM 45 bash -c \
    'while [[ "$(curl -s -o /dev/null -L -w ''%{http_code}'' ${0})" != "200" ]];\
    do echo "Waiting for ${0}" && sleep 2;\
    done' ${1}
    echo "OK!" 
    #curl -I $1
}