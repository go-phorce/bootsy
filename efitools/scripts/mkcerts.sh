#!/bin/bash
key_dir=$1

if [ $# -ne 1 ]; then
    echo "Usage $0: key_dir"
    exit 1;
fi

curdir=`pwd`

if [ ! -d "$key_dir" ]; then
    mkdir $key_dir
fi

if [ ! -d "$key_dir" ]; then
    echo "Failed to find directory for key files: $key_dir"
    exit 1;
fi

cd $key_dir

export CN="Bootsy UEFI"
export FNAME="bootsy-uefi"
echo "Creating certs with CN: $CN"

# create certs
openssl req -new -x509 -newkey rsa:2048 -subj "/CN=$CN PK/" -keyout "$FNAME-pk.key" -out "$FNAME-pk.crt" -days 3650 -nodes -sha256
openssl req -new -x509 -newkey rsa:2048 -subj "/CN=$CN KEK/" -keyout "$FNAME-kek.key" -out "$FNAME-kek.crt" -days 3650 -nodes -sha256
openssl req -new -x509 -newkey rsa:2048 -subj "/CN=$CN DB/" -keyout "$FNAME-db.key" -out "$FNAME-db.crt" -days 3650 -nodes -sha256

# convert CRT to DER
openssl x509 -in "$FNAME-pk.crt" -out "$FNAME-pk.der" -outform DER
openssl x509 -in "$FNAME-kek.crt" -out "$FNAME-kek.der" -outform DER
openssl x509 -in "$FNAME-db.crt" -out "$FNAME-db.der" -outform DER

# generate keys GUID or use static 
# GUID=`python -c 'import uuid; print(str(uuid.uuid1()))'`
GUID='6547f910-a934-11e7-aed1-a08cfde31e7b'
echo $GUID > GUID.txt

# create ESL
cert-to-efi-sig-list -g $GUID "$FNAME-pk.crt" "$FNAME-pk.esl"
cert-to-efi-sig-list -g $GUID "$FNAME-kek.crt" "$FNAME-kek.esl"
cert-to-efi-sig-list -g $GUID "$FNAME-db.crt" "$FNAME-db.esl"

rm -f no-pk.esl
touch no-pk.esl

sign-efi-sig-list -t "$(date --date='1 second' +'%Y-%m-%d %H:%M:%S')" \
                  -k "$FNAME-pk.key" -c "$FNAME-pk.crt" PK "$FNAME-pk.esl" "$FNAME-pk.auth"

sign-efi-sig-list -t "$(date --date='1 second' +'%Y-%m-%d %H:%M:%S')" \
                  -k "$FNAME-pk.key" -c "$FNAME-pk.crt" PK no-pk.esl no-pk.auth

sign-efi-sig-list -t "$(date --date='1 second' +'%Y-%m-%d %H:%M:%S')" \
                  -k "$FNAME-pk.key" -c "$FNAME-pk.crt" KEK "$FNAME-kek.esl" "$FNAME-kek.auth"

sign-efi-sig-list -t "$(date --date='1 second' +'%Y-%m-%d %H:%M:%S')" \
                  -k "$FNAME-kek.key" -c "$FNAME-kek.crt" db "$FNAME-db.esl" "$FNAME-db.auth"

chmod 0600 *.key

cd $curdir

echo ""
echo "For use with KeyTool, copy the *.auth and *.esl files to a FAT USB"
echo "flash drive or to your EFI System Partition (ESP)."
echo "For use with most UEFIs' built-in key managers, copy the *.cer files."
echo ""
