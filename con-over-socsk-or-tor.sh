#!/usr/local/bin/bash
#con-over-socks-or-tor
SOCK_Srv=$1
SOCK_Prt=$2
REMOTE_S=$3
REMOTE_P=$4

cln="\033[1;31m"
tor="\033[1;34m"
srv="\033[0;36m"
end="\033[0m"

# Start keychain and load SSH keys
/usr/local/bin/keychain --quiet --agents ssh ~/.ssh/id_rsa
source ~/.keychain/$HOSTNAME-sh

trap 'kill $(jobs -p); exit' SIGINT SIGTERM EXIT

echo -e "
------------               -----------------          -----------------
|$cln Client $end  |        --- > | $tor TOR SERVICE $end   | $srv  ---> | PUBLIC_SERVER $end |
------------              -----------------          -----------------

$cln 192.168.20.12           $tor $SOCK_Srv:$SOCK_Prt          $srv $REMOTE_S:$REMOTE_P
$end"

conn(){
    if ! nc -z $SOCK_Srv $SOCK_Prt; then
        echo "Unable to connect to Tor service at $SOCK_Srv:$SOCK_Prt"
        exit 1
    fi

    ssh -o "Ciphers=chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes256-ctr" \
        -o "MACs=hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com" \
        -L 8080:localhost:2220 -l root -2 $REMOTE_S -p $REMOTE_P \
        -o ProxyCommand="./connect -4 -S $SOCK_Srv:$SOCK_Prt %h %p"
}

main(){
    pgrep connect || conn 
    sleep 10 
    main
}

main

