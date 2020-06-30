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
echo "Kernel Upgrade proc ..."
krn_name="`uname -v|cut -d "/" -f 8`"
cd /usr/src/ &&  make buildkernel KERNCONF=$krn_name && make installkernel KERNCONF=$krn_name && exit
}

up(){

  echo "-------------Try: $n---------"

    $command cleanup $path
    $command resolved $path ; $command cleanup $path 
    $command co $add $path && res=$?
	[ "$res" -eq "0" ] && echo Done && kern && exit 
	[ "$res" !="0" ] && $command resolved $path ; $command cleanup $path 
    let n++
  up
}

up
