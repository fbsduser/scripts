#sshuttle-for-bsd-over-tor
#!/usr/bin/env bash
rhost=$1
PORT=$2
signal=$3


[ ! "`sudo pfctl -s info`" ]&& (sudo /etc/rc.d/pf onestart   || sudo touch /etc/pf.conf && sudo /etc/rc.d/pf onestart >/dev/null 2>&1  127.0.0.1  )

echo -e  "\033[1;37m $(figlet routing ...)\033[0m"
sudo route add -net 10.0.0.0/8 127.0.0.1  >/dev/null 2>&1  127.0.0.1  
#echo -e "\033[1;31m Removing \033[1;37m routes \033[0m"
#cat ~/range | while read range_ ;do sudo   route del -net $range_   127.0.0.1  >/dev/null 2>&1 ;done 
#echo -e "\033[1;34m Adding \033[1;37m routes \033[0m"
[  "` head -n 10 range <<< $(netstat -nar ) `" ] && echo -e "\033[1;32m routes all done \033[0m " || (cat /home/t4z3v4r3d/range | while read range_ ;do sudo route add -net $range_  127.0.0.1 >/dev/null 2>&1    ;done ) 
#set -ex
#hostname=$(echo $1|grep -oP '(?<=@).*')
echo -e "\033[1;36m $(figlet Proxy  ...)\033[0m"

# Start keychain and load SSH keys
/usr/local/bin/keychain --quiet --agents ssh ~/.ssh/id_rsa
source ~/.keychain/$HOSTNAME-sh

sht(){
 echo -e "\033[3;37m "
 sshuttle -x 192.168.20.0/23 -x 10.0.0.0/8 --dns -HN --method auto -r root@$rhost:$PORT 0.0.0.0/0 --ns-hosts $rhost
#   sshuttle --dns -vHN --method auto -r root@192.99.212.42  0.0.0.0/0 --ns-hosts 192.99.212.42
 echo -e "\033[0;0m "
}

clr(){
cat ~/range | while read range_ ;do sudo   route del -net $range_   127.0.0.1  >/dev/null 2>&1 ;done 
killer.sh sshuttle

}
main(){
sht 
[ ret_st=$? != 0 ] && sht
 sleep 5  
main

}
main

