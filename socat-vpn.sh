#!/bin/bash
#### Socat key-maker
me=$(curl -s -4 icanhazip.com)
side=$1
[ ! -f /usr/bin/socat ]&& apt install socat -y
pth="/root/socat_con"
#############################
key_maker(){
[[ -d $pth ]] || mkdir $pth
############################
openssl genrsa -out $1.key
openssl req -new -key $1.key -x509 -days 365 -out $1.crt -nodes -subj "/C=US/ST=CA/L=CA/O=$me/OU=IBBH/CN=$me"
cat $1.key $1.crt > $1.pem
chmod 600 $1.key $1.pem
}
############################
key_transfer(){
read -p "Enter Server address: " server_add
scp client.crt root@$server_add:$pth/
}

[ $side=="s" ] && key_maker server
[ $side=="c" ] && key_maker client
[ $side=="c" ] && key_transfer
