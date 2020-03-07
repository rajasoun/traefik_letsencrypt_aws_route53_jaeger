#!/usr/bin/env bash

set -eo pipefail
source "scripts/etc_hosts.bash"

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
  add "whoami.${BASE_DOMAIN}"
  add "traefik.${BASE_DOMAIN}"
  add "jaeger.${BASE_DOMAIN}"
}

function remove_host_entries(){
  export $(cat .env)
  backup
  remove "whoami.${BASE_DOMAIN}"
  remove "traefik.${BASE_DOMAIN}"
  remove "jaeger.${BASE_DOMAIN}"
}

opt="$1"
choice=$( tr '[:upper:]' '[:lower:]' <<<"$opt" )
case $choice in
    up)
      echo "Bring Up Application Stack"
      export $(cat .env)
      docker-compose ${SERVICES} up -d
      echo "Adding Host Enteries...  "
      add_host_entries
      echo "Goto following Links  "
      echo "https://traefik.${BASE_DOMAIN}/dashboard/#/    ->  Traefic Dashboard"
      echo "https://jaeger.${BASE_DOMAIN}                 ->  (jaeger) Distributed Tracing "
      echo "https://whoami.${BASE_DOMAIN}                 ->  Sample App"      
      ;;
    down)
      echo "Destroy Application Stack & Services"
      docker-compose ${SERVICES} down
      echo "Removing Host Enteries & Log files...  "
      remove_host_entries
      rm -fr logs/*.log
      ;;
    status)
      echo "Containers Status..."
      docker-compose ${SERVICES} ps
      ;;
    logs)
      echo "Containers Log..."
      tail -f logs/traefik.log
      ;;
    *)  help ;;
esac