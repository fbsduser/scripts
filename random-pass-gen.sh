#!/usr/local/bin/bash
len=$1
< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-$len};echo;
< /dev/urandom tr -dc 'A-Za-z0-9!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~' | head -c${1:-$len};echo;
