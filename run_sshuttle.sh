#!/bin/bash
### sshuttle vpn/proxy -pooooooormanz proxy. for linux/or you can change it
### Some GOV(Z) may exploits users and shall they sets payloads address on local machiens, so block them >|< \0x00.
### YOu may want to change routes and drop all routes to filtering machines that may be a part of interlan lan or 
### wan, so your option is sshuttle -x "any ip/range " that you want to avoid to ;).
### And you may run tor over sshuttle , So do it and have fun :D.
rhost=$1
server_port=22
evil_ip_range="Put evil(s) ip range here, Some private  range like 10.0.0.0/8 or maybe 172.... or 192... comment for me"
[ ! -f ~/range ] && (echo -e "\033[1;31m Ip file not found !. Script is failed !;( \033[0;0m" ;exit)
echo -e  "\033[1;37m $(figlet routing ...)\033[0m"
### :-p
bsd_style(){
route add -net $evil_ip_range 127.0.0.1 >>/dev/null 2>&1  127.0.0.1 
/etc/rc.d/pf onestart   ||  touch /etc/pf.conf &&  /etc/rc.d/pf onestart >/dev/null 2>&1  127.0.0.1 
cat ~/range | while read range ;do route del -net $range >>/dev/null 2>&1  127.0.0.1  ;done
sleep 1
cat ~/range | while read range ;do route add -net $range >>/dev/null 2>&1  127.0.0.1  ;done 
}

linux_style(){
route add -net $evil_ip_range gw 127.0.0.1 lo >> /dev/null 2>&1 
cat ~/range | while read range ;do sudo route del -net $range gw 127.0.0.1 lo >> /dev/null 2>&1 ;done
sleep 1
cat ~/range | while read range ;do sudo route add -net $range gw 127.0.0.1 lo >> /dev/null 2>&1 ;done 
echo -e "\033[1;32m $(figlet Proxy  ...)\033[0m"
}

echo -e "\033[1;32m $(figlet routing ...)\033[0m"
#### Remove all D>P>I servers &|| Infection machines ... || range of IP !
[ "$(uname -o | grep -i bsd)" ]&& bsd_style || [ "$(uname -o | grep -i linux )" ]&& linux_style
echo -e "\033[1;36m $(figlet Proxy  ...)\033[0m"

sht(){
    sshuttle --dns -vHN --method auto -r root@$rhost:$server_port 0.0.0.0/0 --ns-hosts $rhost --disable-ipv6
}

main(){
sht
[ ret_st=$? != 0 ] && sht
sleep 2 
main
}
main
