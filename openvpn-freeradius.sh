#!/bin/bash
    ### Coded by t4z3v4r3d Wed Jun 12 12:03:52 2019 ###
    ### You should have two nics for best perfomance and securuity, although it is possible with one.
    ### apt    upgrdae test    
now=`date +%s`
status=`stat -c %Z /var/lib/apt/extended_states`
strech_def="1560333329"
tlrt=86400
[ $status -eq $strech_def  ] && apt update && apt upgrade  -y && reboot
[ "`expr $now - $status`" -gt $tlrt ]&& apt update && apt upgrade  -y 
echo -e "\033[1;37m UPDATE DONE ! --- Now I am starting other jobs ! \033[0m"
sleep 10

SERVERIP=""                     ### It's ok if you have a valid dns name or public IP;) 
RADIUS_IP=""                    ### FreeRadius server's IP
USER=""                         ### user could called by func &|| program args 
INCOM_NIC=""                    ### Should firewalled for incoming ovpn and ssh 
OUTCOM_NIC=""                   ### It should be firewalled too for web and out going dns and apps 
NAT_RANGE="10.0.3.0/24"
DB_ROOT_PASS=""                 ### Database ROOT PASSWORD
 ### #1
openvpn_pkg_installer (){
echo "Insalling packages ! "
sleep 10 
apt install openvpn-auth-radius  openvpn-radius  openvpn libgcrypt11-dev libgcrypt20-dev make gc++ g++ gcc 

 ### radius prepare 
mkdir /etc/radiusplugin && cd /etc/radiusplugin/
wget http://www.nongnu.org/radiusplugin/radiusplugin_v2.1a_beta1.tar.gz || echo "Unable to download plugin Sorry" || exit
tar xvf radiusplugin_v2.1a_beta1.tar.gz && cd radiusplugin_v2.1a_beta1 && \
make && echo "make pkg is done " || echo "failed to make radius package ! please check it again" || exit
mkdir  /etc/openvpn/radius
cp -r radiusplugin.so /etc/openvpn/radius
echo "
NAS-Identifier=000.000.000.000_TCP_443
Service-Type=5
Framed-Protocol=1
NAS-Port-Type=5
NAS-IP-Address=000.000.000.000
OpenVPNConfig=/etc/openvpn/server.conf
subnet=255.255.255.0
overwriteccfiles=true
nonfatalaccounting=false
server
{
        acctport=1813
        authport=1812
        name=$RADIUS_IP
        retry=1
        wait=1
        sharedsecret=testing123
}
"

}

openvpn_conf(){

[ -d /etc/openvpn ]|| echo "It seems openvpn does not exist "|| exit
cd /etc/openvpn

mv server.conf server.conf.org
mkdir -p /etc/openvpn/easy-rsa/keys
cp -rf /usr/share/easy-rsa/* /etc/openvpn/easy-rsa
cd /etc/openvpn/easy-rsa
ln -s openssl-1.0.0.cnf openssl.cnf
source ./vars
./clean-all
./build-ca
./build-key-server server
./build-dh
./build-key $USER ### It might be changable

echo "
port 443
proto tcp
dev tun
server $NAT_RANGE 255.255.255.0
ca /etc/openvpn/easy-rsa/keys/ca.crt
cert /etc/openvpn/easy-rsa/keys/server.crt
key /etc/openvpn/easy-rsa/keys/server.key
dh /etc/openvpn/easy-rsa/keys/dh2048.pem
#cipher SHA512 
cipher AES-256-CBC
plugin /etc/openvpn/radius/radiusplugin.so /etc/openvpn/radius/radius.cnf 
ifconfig-pool-persist ipp.txt persist-key
persist-tun
keepalive 10 60
reneg-sec 0
comp-lzo
tun-mtu 1468
tun-mtu-extra 32
mssfix 1400
push "persist-key"
push "persist-tun"
push "redirect-gateway def1"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
status /etc/openvpn/443.log
verb 4
duplicate-cn
script-security 2
down-pre
up /etc/openvpn/tc/tc.sh
down /etc/openvpn/tc/tc.sh
client-connect /etc/openvpn/tc/tc.sh
client-disconnect /etc/openvpn/tc/tc.sh
" > server.conf


 ### Tc ### The ip and db should be replace by real databse and all codes in tc.sh should replaced in golang -
 mkdir -p /etc/openvpn/tc/{db,ip,}
 cp /root/tc.sh /etc/openvpn/tc/tc.sh
 
}

USER_KEY_MAKER(){

echo "
client
dev tun
proto tcp
sndbuf 0
rcvbuf 0
remote $SERVERIP 443 
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
auth SHA512
cipher AES-256-CBC
setenv opt block-outside-dns
key-direction 1
auth-nocache
auth-user-pass auth_$USER.txt
auth-retry interact
verb 4
"<ca>"
`cat  /etc/openvpn/easy-rsa/keys/ca.crt`
"</ca>"
`cat  /etc/openvpn/easy-rsa/keys/$USER.crt`
"</cert>"
"<key>"
`cat  /etc/openvpn/easy-rsa/keys/$USER.key`
"</key>"
" >/root/$USER.ovpn         ### We could have a database to store keys 
}

SERVER_NETWORK_CONFIG(){
    ### iptables and net share
echo 1 > /proc/sys/net/ipv4/ip_forward

iptables -F flush 
iptables -A INPUT -i $INCOM_NIC -m state --state NEW -p udp --dport 443 -j ACCEPT
iptables -A INPUT -i tun+ -j ACCEPT
iptables -A FORWARD -i tun+ -j ACCEPT
iptables -A FORWARD -i tun+ -o $OUTCOM_NIC -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i $OUTCOM_NIC -o tun+ -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -t nat -A POSTROUTING -s $NAT_RANGE/24 -o $OUTCOM_NIC -j MASQUERADE
iptables -A OUTPUT -o tun+ -j ACCEPT

iptables-save >/etc/network/iptables.up.rules
iptables-apply
 
}

FREE_RADIUS_INSTALLER(){
apt install -y freeradius freeradius-mysql freeradius-utils php-common php-gd php-curl php-mysql mysql-server mysql-client || echo "Failed to install Esseintial packages" || exit
sleep 2
mysql -u root < "uninstall plugin validate_password;
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$DB_ROOT_PASS';
CREATE DATABASE radius;"

[ -d /etc/freeradius/3.0/mods-config/sql/main/mysql/ ] && cd /etc/freeradius/3.0/mods-config/sql/main/mysql/ || echo "/etc/freeradius/3.0/mods-config/sql/main/mysql/ IS a necessary directory and i could not found it please check it "|| exit
mysql -uroot -p$DB_ROOT_PASS radius < schema.sql
mysql -uroot -p$DB_ROOT_PASS radius < setup.sql
cd /etc/freeradius/3.0/mods-enabled
ln -s ../mods-available/sql sql
my_var="`head -7   /etc/freeradius/3.0/mods-available/sql`"
mv sql /root/sql_back
echo "
$my_var
sql {
        driver = \"rlm_sql_mysql\"
        dialect = \"mysql\"
        server = \"localhost\"
        port = 3306
        login = \"radius\"
        password = \"radpass\"
        radius_db = \"radius\"
        acct_table1 = \"radacct\"
        acct_table2 = \"radacct\"
        postauth_table = \"radpostauth\"
        authcheck_table = \"radcheck\"
        groupcheck_table = \"radgroupcheck\"
        authreply_table = \"radreply\"
        groupreply_table = \"radgroupreply\"
        usergroup_table = \"radusergroup\"
        delete_stale_sessions = yes
        pool {
                start = ${thread[pool].start_servers}
                min = ${thread[pool].min_spare_servers}
                max = ${thread[pool].max_servers}
                spare = ${thread[pool].max_spare_servers}
                uses = 0
                retry_delay = 30
                lifetime = 0
                idle_timeout = 60
        }
        read_clients = yes
        client_table = \"nas\"
        group_attribute = \"SQL-Group\"
        $INCLUDE ${modconfdir}/${.:name}/main/${dialect}/queries.conf
}" >sql
    ### These valuse should change ! 
mysql -u root -P$DB_ROOT_PASS < "INSERT INTO nas VALUES (NULL , '0.0.0.0/0', 'myNAS', 'other', NULL , 'mysecret', NULL , NULL , 'RADIUS Client');
INSERT INTO radcheck (username, attribute, op, value) VALUES ('testuser', 'Cleartext-Password', ':=', 'testpassword');
INSERT INTO radusergroup (username, groupname, priority) VALUES ('testuser', 'testgroup', '1');
INSERT INTO radgroupreply (groupname, attribute, op, value) VALUES ('testgroup', 'Service-Type', ':=', 'Framed-User'), ('testgroup', 'Framed-Protocol', ':=', 'PPP'), ('testgroup', 'Framed-Compression', ':=', 'Van-Jacobsen-TCP-IP');"

}

main(){
[ "$1" == vpn ]&&\
openvpn_pkg_installer
openvpn_conf
USER_KEY_MAKER
SERVER_NETWORK_CONFIG
[ "$1" == rad ]&& FREE_RADIUS_INSTALLER
}
