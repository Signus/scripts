#!/bin/bash

# Signus
# This script compares the md5 hashes of a public and private key pair
# Uses the expect shell to enter the passphrase for the private key if it is supplied

# TODO: Add zsh support 

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[1;33m'
nc='\033[0m'

show_usage() {
    prog=$0
    echo -e "\n Usage: ${prog##*/}  [public_key] [private_key] [passphrase]"
    echo -e "\t- [public_key]\t(Required)"
    echo -e "\t- [private_key]\t(Required) "
    echo -e "\t- [passphrase]\t(Optional)"
}

# TODO: Add check for OSX, Cygwin, Linux
realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

# Show usage on '--help' or '-h'
if [[ $@ == "--help" || $@ == "-h" ]]; then
    show_usage
    exit 0
fi

# Check that at least two arguments are provided.
# Passphrase is not a necessary option
if [[ $# -le 1 || $# -gt 3 ]]; then
    echo -e "${red} Invalid number of arguments specified. ${nc}"
    show_usage
    exit 1
fi

pubKey=$(openssl x509 -noout -modulus -in $1 | openssl md5)

# TODO: Implement check for if pair doesn't match at all and errs before pwd
# If a passphrase is supplied, implement expect
if [[ -z $3 ]]; then 
    privKey=$(openssl rsa -noout -modulus -in $2 | openssl md5) 
else
    # Sends password and gets modulus output
    # NOTE: Expect does not support piping
    privKeyMod=$(
        /usr/bin/expect << EOS
            log_user 0
            spawn openssl rsa -noout -modulus -in $2
            expect -re {Enter pass phrase for.*}
            send "$3\r"
            unset expect_out(buffer)
            expect -re {Modulus=.*}
            puts \$expect_out(0,string)
EOS
    )
    
    # Remove all whitespace and pipe to get md5 hash
    privKeyMod=$(echo $privKeyMod | tr -d '\040\011\012\015')
    privKey=$(echo $privKeyMod  | openssl md5)
fi

# Check if the md5 hashes are the same
if [[ $pubKey == $privKey ]]; then
    echo -e "${green} The public/private pair matches! ${nc}"
else
    if [[ -z $3 ]]; then
        echo -e "${red} The public/private pair does not match! ${nc}"
    else
        echo -e "${red} The public/private pair does not match! ${nc}"
        echo -e "${yellow} Invalid passphrase supplied. ${nc}"
    fi
fi

echo -e "Public key: $(realpath "$1")"
echo -e "Private key: $(realpath "$2")"
