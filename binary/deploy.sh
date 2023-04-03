#!/bin/bash

WEB_APPS_TOMCAT_DIR=webapps
tomcat_path=/home/andrii/tomcat
tomcat_ec2_path=/home/ec2-user/tomcat
filename=webSocket.war
key_path=/home/andrii/keys/
key_name=mykey
ipcurl=localhost

ip=""
username=""
password=""
endpoint=""
port=""

for opt in "$@"; do
    case "$opt" in
        -u | --undeploy )
          file_deployed="$tomcat_path"/"$WEB_APPS_TOMCAT_DIR"/"$filename"
          if [ ! -f "$file_deployed" ]; then
            echo "File not found:", $file_deployed
            exit 1
          fi
          rm -R "${file_deployed%.*}"
          rm "$file_deployed"
          printf "File %s was removed: %s/%s\n%s" \
          $filename $tomcat_path $WEB_APPS_TOMCAT_DIR "$(ls "$webapp_directory")"
          ls "$tomcat_path"/"$WEB_APPS_TOMCAT_DIR"/
          ;;
        -d | --deploy )
          if [ ! -f "$filename" ]; then
            printf "File not found: %s", $file_deployed
            exit 1
          fi
          webapp_directory="$tomcat_path"/"$WEB_APPS_TOMCAT_DIR"/
          cp "$filename" "$webapp_directory"
          printf "%s was placed in %s:\n%s\n" $filename $webapp_directory "$(ls "$webapp_directory")"
          ;;
        -da | --deploy-amazon )
            if [ ! -f "$filename" ]; then
              printf "File not found: %s", $filename
              exit 1
            fi
            webapp_directory="$tomcat_ec2_path"/"$WEB_APPS_TOMCAT_DIR"/
            if [ -z "$ip" ]; then
              printf "Error: IP must be set for deploy-amazon option"
            fi
            scp -i "$key_path"/"$key_name" "$filename" ec2-user@"$ip":"$webapp_directory"
            printf "%s was placed in %s\n", $filename, $webapp_directory
            ;;
        -p | --path )
          tomcat_path="$2"
          ;;
        -kp | --key-path )
          key_path="$2"
          ;;
        -k | --key )
          key_name="$2"
          ;;
        -ip | --myip )
          ip="$2"
          ipcurl="$2"
          ;;
        -f | --filename )
          filename="$2"
          ;;
        -dc | --deploy-curl )
          # check that username, password, endpoint, and port are all set
          if [ -z "$username" ] || [ -z "$password" ] || [ -z "$endpoint" ] || [ -z "$port" ]; then
            printf "Error: username, password, endpoint, and port must be set for deploy-curl option"
            exit 1
          fi

          full_file_name=$(realpath "$filename")

          eval curl -u \'"$username":"$password"\' \
          -T \""$full_file_name"\" \
          \""http://""$ipcurl"":""$port"/manager/text/deploy?path="$endpoint""&update=true"\"
          ;;
        -uc | --undeploy-curl )
          # check that username, password, endpoint, and port are all set
          if [ -z "$username" ] || [ -z "$password" ] || [ -z "$endpoint" ] || [ -z "$port" ]; then
            printf "Error: username, password, endpoint, and port must be set for undeploy-curl option"
            exit 1
          fi

          eval curl -u \'"$username":"$password"\' \
           \""http://""$ipcurl"":""$port"/manager/text/undeploy?path="$endpoint""&update=true"\"
          ;;
        --username=* )
          username="${1#*=}"
          ;;
        --password=* )
          password="${1#*=}"
          ;;
        --endpoint=* )
          endpoint="${1#*=}"
          ;;
        --port=* )
          port="${1#*=}"
          ;;
        *) echo "Invalid option: $opt"
    esac
    shift
done