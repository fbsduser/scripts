#!/usr/bin/env bash


valid_host=$1
valid_suer=$2
access_port=$3
local_port=$4

ssh -R $access_port:localhost:$local_port $valid_suer@$valid_host
