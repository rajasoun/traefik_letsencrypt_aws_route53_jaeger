#!/usr/bin/env bash

set -eo pipefail

SERVICES=" -f router.yml -f tracer.yml -f whoami.yml"

function help(){
    echo "Usage: $0  {up|down|status|logs|ssl}" >&2
    echo
    echo "   up               Provision, Configure, Validate Application Stack"
    echo "   down             Destroy Application Stack"
    echo "   status           Displays Status of Application Stack"
    echo "   logs             Application Stack Logs"
    echo "   ssl              Generate SSL Certs (Experimental)"
    echo
    return 1
}

opt="$1"
choice=$( tr '[:upper:]' '[:lower:]' <<<"$opt" )
case $choice in
    up)
      echo "Bring Up Application Stack"
      docker-compose ${SERVICES} up -d 
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
    ssl)
      echo "Generate Certificates from Letsencrypt.."
      export WORKSPACE=$(git rev-parse --show-toplevel)
      source ".env"
      source "src/load.bash"
      generate_ssl_certificate_from_letsencrypt
      ;;
    *)  help ;;
esac