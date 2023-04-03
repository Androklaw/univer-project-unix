#!/bin/bash

key_path=/home/andrii/keys/mykey
ip=""


for opt in "$@"; do
    case "$opt" in
        -l | --launch )
          if [ -z "$ip" ]; then
            printf "Error: IP must be set for deploy-amazon option"
          fi
          ssh -i "$key_path" ec2-user@"$ip"
          ;;

        -ip | --myip )
          ip="$2"
          ;;
        *) echo "Invalid option: $opt"
    esac
    shift
done