# Intro

Bootsy projects produces the following tools in EFITOOLS folder:

- cert-to-efi-hash-list

    tool for converting openssl certificates to EFI signature hash revocation lists
- cert-to-efi-sig-list

    tool for converting openssl certificates to EFI signature lists
- efi-readvar

    tool for showing secure variables
- efi-updatevar

    tool for updating secure variables
- hash-efi-sig-list
    
    create a hash signature list entry from a binary
- sig-list-to-certs
    
    tool for converting EFI signature lists back to openssl certificates
- sign-efi-sig-list

    signing tool for secure variables as EFI Signature Lists

# Prerequisites

The prerequisites are:
- the standard development environment
- gnu-efi version 3.0+
- help2man 
- sbsigntools

## Build sbsign
CentOS
```
sudo yum install binutils-devel openssl-devel libuuid-devel gnu-efi-devel help2man -y
```

Ubuntu
```
sudo apt-get install binutils-dev libssl-dev uuid-dev gnu-efi help2man

```

```
git clone git://kernel.ubuntu.com/jk/sbsigntool.git
cd sbsigntool
./autogen.sh
./configure
```

Build

```.sh
git clone git@github.com:go-phorce/bootsy.git
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ../bootsy/efitools
make
```


Creating, using and installing custom keys
============================================

To create PEM files with the certificate and the key for PK for example, do

```
scripts/mkcerts.sh
```

Which will create a self signed X509 certificate for PK in PK.crt (using unprotected key PK.key).

There can be created three sets of certificates: one for PK, one for KEK and one for db.

All the efi binaries in /usr/share/efitools/efi should be signed with the custom db key using

```
sbsign --key db.key --cert db.crt --output UpdateVars-signed.efi UpdateVars.efi
```

To install the new keys on the platform, first create authorised update bundles:

```
cert-to-sig-list PK.crt PK.esl
sign-efi-sig-list -k PK.key -c PK.crt PK PK.esl PK.auth
```

And repeat for KEK and db.  In setup mode, it only matters that the PK update PK.auth is signed by the new platform key.  None of the other variables will have their signatures checked.

Now on the platform update the variables, remembering to do PK last because an update to PK usually puts the platform into secure mode:

```
UpdateVars db db.auth
UpdateVars KEK KEK.auth
UpdateVars PK PK.auth
```

And the host should now be running in secure mode with your own keys.
