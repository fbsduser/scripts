#!/usr/bin/env bash
#### ping ipv4 by number of ip ! lol tzvz
ip_oct=$1   #### first ip    
range=$2    #### how mamny ip do you have 
dec_ip=$(echo $ip_oct | tr . '\n' | awk '{s = s*256 + $1} END{print s}') #### the origin 
# make temp from input ip
dec_tmp=$dec_ip                 

# make end ip
let end_ip="$dec_ip+$range"
# make temp from end ip
total=$end_ip              

# ### Ip from oct to int 
for i in {1..4}; do 
    s='.'$((dec_ip%256))$s && ((dec_ip>>=8))
done

for i in {1..4}; do #### dec to oct
    s1='.'$((end_ip%256))$s1 && ((end_ip>>=8))
done

for  ((item=$dec_tmp;item<$total;item++));do
   # echo $item $dec_tmp $total
    tmp_item=$item
    for i in {1..4}; do #### dec to oct
    s3='.'$((item%256))$s3 && ((item>>=8))
    done
    
    middle_ip=$(echo $s3| cut -d "." -f 2-5 )
    ping -s 1 -c 1 $middle_ip  2>/dev/null | grep icmp_seq  &
    let "tmp_item++"
    item=$tmp_item
done 
wait
dec_oct_ip=$(echo $s| cut -d "." -f 2-5 )   
end_ip_=$(echo $s1| cut -d "." -f 2-5 )
echo -e "\033[1;31m [INPUT IP : $ip_oct] \033[1;35m  [INT IP tmp : $dec_tmp] \033[1;31m [ First decode DEC IP :$dec_oct_ip ] \033[1;36m [END IP $end_ip_] \033[0m"
