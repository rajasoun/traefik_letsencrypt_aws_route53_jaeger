#!/usr/bin/env bash

user=$1
password=$2

echo $(htpasswd -nbB $user $password) | sed -e s/\$/\$\$/g
#printf "$user:$(openssl passwd -crypt $password)\n" > .htpasswd