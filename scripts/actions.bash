#!/usr/bin/env bash

function execute_action(){
  action=$1
  for service in "${services[@]}"
  do
    $action "$service.${BASE_DOMAIN}"
  done
}

function add_host_entries(){
  execute_action "add"
}

function remove_host_entries(){
  backup
  execute_action "remove"
}

function verify_certificates(){
  execute_action "wait_for_url"
}

function display_app_status(){
    echo "Apps Status"
    execute_action "display_url_status"
}