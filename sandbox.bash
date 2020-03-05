#!/usr/bin/env bash

set -eo pipefail

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

opt="$1"
choice=$( tr '[:upper:]' '[:lower:]' <<<"$opt" )
case $choice in
    up)
      echo "Bring Up Application Stack"
      docker-compose ${SERVICES} up -d 
      export $(cat .env)
      echo "Goto following Links  "
      echo "http://localhost:8080/                    ->  Traefic Dashboard"
      echo "https://jaeger.${BASE_DOMAIN}                 ->  (jaeger) Distributed Tracing "
      echo "https://whoami.${BASE_DOMAIN}                 ->  Sample App"      
      ;;
    down)
      echo "Destroy Application Stack & Services"
      docker-compose ${SERVICES} down
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