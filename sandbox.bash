#!/usr/bin/env bash

set -eo pipefail

source "scripts/actions.bash"
source "scripts/os.bash"
source "scripts/web.bash"

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

COMPOSE_FILES=" -f router.yml -f tracer.yml -f whoami.yml -f hotrod.yml"
services=(router tracer whoami1 hotrod)

# COMPOSE_FILES=" -f router.yml "
# services=(router)


export services
export $(cat config/ssl)

opt="$1"
choice=$( tr '[:upper:]' '[:lower:]' <<<"$opt" )
case $choice in
    up)
      echo "Bring Up Application Stack"
      docker-compose ${COMPOSE_FILES} up -d
      echo "Adding Host Enteries...  "
      add_host_entries
      verify_certificates
      display_app_status
      ;;
    down)
      echo "Destroy Application Stack & Services"
      docker-compose ${COMPOSE_FILES} down
      echo "Removing Host Enteries & Log files...  "
      remove_host_entries
      rm -fr logs/*.log
      ;;
    status)
      display_app_status
      echo -e "\nContainers Status..."
      docker-compose ${COMPOSE_FILES} ps
      ;;
    logs)
      echo "Containers Log..."
      tail -f logs/traefik.log | grep "$2"
      ;;
    *)  help ;;
esac