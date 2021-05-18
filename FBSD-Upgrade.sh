#!/usr/local/bin/bash
[ "`env | grep proxy`" ]&& unset http_proxy && unset https_proxy
#pkg upgrade -y
###################
n=0
path="/usr/src/"
command=svnlite
add="https://svn.freebsd.org/base/stable/12"

cd $path

kern(){
clear
echo -e "\033[1;31m \033[1;3f Kernel Upgrade proc ... \033[2;3f\033[0m"
krn_name="`uname -v|cut -d "/" -f 8| cut -d " " -f 4`"
#cd /usr/src/ &&  make buildkernel KERNCONF=$krn_name && make installkernel KERNCONF=$krn_name && exit
exit
}

up(){

  echo "-------------Try: $n---------"

    $command cleanup $path
    $command resolved $path ; $command cleanup $path 
    $command co $add $path && res=$?
        [ "$res" -eq "0" ] && (echo Done ; kern ; exit )
        [ "$res" != "0" ] && $command resolved $path ; $command cleanup $path 
    let n++
        [ "$res" -eq "0" ]&& exit ||   up
}

up
