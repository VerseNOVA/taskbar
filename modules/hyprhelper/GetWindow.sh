#!/bin/bash
address=$1
property=$2
window=$(hyprctl clients -j | jq -c -r --arg ADDRESS $address '.[] | select(.address == $ADDRESS)')
if ([[ -z $window ]]); then
  echo "Window $address not found"
  exit 1
fi
if ([[ -z $property ]]); then
  echo $window
  exit 0
else
  prop=$(echo $window | jq -r -c --arg PROPERTY $property '.[$PROPERTY]')
  echo $prop
  exit 0
fi
