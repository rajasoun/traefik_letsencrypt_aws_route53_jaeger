#!/usr/bin/env bash

set -eo pipefail
source "scripts/os.bash"
source "scripts/web.bash"

SERVICES=" -f router.yml -f tracer.yml -f whoami.yml"

function help(){
    echo "Usage: $0  {up|down|status|logs}" >&2
    echo
    echo "   up               Provision, Configure, Validate Application Stack"
    echo "   down             Destroy Application Stack"
    echo "   status           Displays Status of Application Stack"
    echo "   logs             Application Stack Logs"
    echo
    return 1
}

function add_host_entries(){
  add "router.${BASE_DOMAIN}"
  add "tracer.${BASE_DOMAIN}"
  add "whoami1.${BASE_DOMAIN}"
}

function remove_host_entries(){
  backup
  remove "router.${BASE_DOMAIN}"
  remove "tracer.${BASE_DOMAIN}"
  remove "whoami1.${BASE_DOMAIN}"
}

function verify_certificates(){
  wait_for_url "http://router.${BASE_DOMAIN}"
  wait_for_url "http://tracer.${BASE_DOMAIN}"
  wait_for_url "http://whoami1.${BASE_DOMAIN}"
}

function display_app_status(){
    echo "Apps Status"
    display_url_status "https://router.${BASE_DOMAIN}/dashboard/#/"
    display_url_status "https://tracer.${BASE_DOMAIN}"
    display_url_status "https://whoami1.${BASE_DOMAIN}"
}

opt="$1"
choice=$( tr '[:upper:]' '[:lower:]' <<<"$opt" )
export $(cat .env)
case $choice in
    up)
      echo "Bring Up Application Stack"
      docker-compose ${SERVICES} up -d
      echo "Adding Host Enteries...  "
      add_host_entries
      verify_certificates
      display_app_status
      ;;
    down)
      echo "Destroy Application Stack & Services"
      docker-compose ${SERVICES} down
      echo "Removing Host Enteries & Log files...  "
      remove_host_entries
      rm -fr logs/*.log
      ;;
    status)
      display_app_status
      echo -e "\nContainers Status..."
      docker-compose ${SERVICES} ps
      ;;
    logs)
      echo "Containers Log..."
      tail -f logs/traefik.log
      ;;
    *)  help ;;
esac