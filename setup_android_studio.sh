#!/bin/bash

RED='\033[1;31m'
BLUE='\033[1;36m'
GREEN='\033[1;32m'
NC='\033[0m' # No Color

echo -e "${RED} Log.txt created for logging !${NC}"

# Install packages
apt update -y && sudo apt-get upgrade -y
apt install -y curl git unzip xz-utils zip libglu1-mesa

# Install the following prerequisite packages for Android Studio:
apt install -y libc6:amd64 libstdc++6:amd64 lib32z1 libbz2-1.0:amd64

DOWNLOADS=$HOME/Downloads
BASHRC=$HOME/.bashrc

STUDIO_URL="https://r4---sn-4g5ednd7.gvt1.com/edgedl/android/studio/ide-zips/2024.2.1.12/android-studio-2024.2.1.12-linux.tar.gz"
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.27.1-stable.tar.xz";

#install flutter function

install_flutter () {

    # Download Flutter if needed

    if [ ! -f $DOWNLOADS/flutter* ]; then
        (cd $DOWNLOADS; wget $FLUTTER_URL)
        #verify download finished
        if [ ! -f $DOWNLOADS/flutter* ]; then
            echo -e "${RED}tar not found. Download failed?${NC}"
            exit
        fi
    fi
    FLUTTER_TAR=` ls $DOWNLOADS | grep "flutter" `


    # Extract Flutter


    echo -e "${BLUE}\nExtracting Flutter SDK to $HOME/Android/flutter${NC}"


    if [ ! -d $HOME/Android/flutter* ]; then
        tar xf $DOWNLOADS/$FLUTTER_TAR  -C $HOME/Android/  >> log.txt 2>&1 && echo -e "${GREEN} Success !${NC}" ||  (echo -e "${RED} Failed !${NC}" ; exit)
        if [ ! -d $HOME/Android/flutter* ]; then
            echo -e "${RED}Flutter SDK not installed not found. Extract failed ?${NC}"
            exit
        fi
        
    fi
    echo -e "${GREEN} Success !${NC}"
    echo -e "${BLUE}Setting Android Studio environment variables ($BASHRC)${NC}"

    # Setting Flutter environment variables

    FLUTTER_ENV=$(cat $BASHRC | grep "flutter")

    if [ -z "$FLUTTER_ENV"  ]; then
        echo -e "\n# Flutter environment variables" >> $BASHRC
        echo "export PATH=\$PATH:$HOME/Android/flutter/bin" >>  $BASHRC
        if [ ! -z "$FLUTTER_ENV"  ]; then
            echo -e "${RED}Flutter environment variables not set. failed ?${NC}"
            exit
        fi
    fi
    echo -e "${GREEN} Success !${NC}"
    echo -e "\n${BLUE}Upgrade Flutter${NC}"
    flutter upgrade
    echo -e "\n${BLUE}Executing Flutter Doctor${NC}"
    flutter doctor

}


#install JAVA

echo -e "${BLUE}Adding JDK to PPA repository${NC}"

sudo add-apt-repository ppa:webupd8team/java -y >> log.txt 2>&1 && echo -e "${GREEN} Success !${NC}" ||  (echo -e "${RED} Failed !${NC}" ; exit)
echo -e "${BLUE}Installing JDK 8${NC}"
sudo apt-get install oracle-java8-installer -y

echo -e "${BLUE}Setting JDK 8 as default${NC}"
sudo apt-get install oracle-java8-set-default  -y  && echo -e "${GREEN} Success !${NC}" ||  (echo -e "${RED} Failed !${NC}" ; exit)


#install Virtualization tools and unzip

PACKAGE=( unzip qemu-kvm libvirt-bin ubuntu-vm-builder bridge-utils ia32-libs-multiarch)

echo -e "${BLUE}Installing ${#PACKAGE[@]} necessary tools\n${NC}"

for i in "${PACKAGE[@]}"
do
    echo -e "${BLUE} Installing $i ${NC}"
    sudo apt-get install $i -y >> log.txt 2>&1 && echo -e "${GREEN}  Success !${NC}" ||  (echo -e "${RED}  Failed !${NC}" ; exit)
done

# download android studio if needed

if [ ! -f $DOWNLOADS/android-studio* ] && [[  ! -d ${HOME}/android-studio* ]]; then
    (cd $DOWNLOADS; wget $STUDIO_URL)
    #verify download finished
    if [ ! -f $DOWNLOADS/android-studio* ]; then
        echo -e "${RED}zip not found. Download failed?${NC}"
        exit
    fi
fi
STUDIO_ZIP=` ls $DOWNLOADS | grep "android-studio" `


# Extract android studio to home

echo -e "${BLUE}\nExtracting android studio to $HOME${NC}"

if [ ! -d $HOME/android-studio ]; then
    tar -xf $DOWNLOADS/$STUDIO_ZIP -C $HOME  >> log.txt 2>&1 && echo -e "${GREEN} Success !${NC}" ||  (echo -e "${RED} Failed !${NC}" ; exit)
    if [ ! -d $HOME/android-studio* ]; then
        echo -e "${RED}File not found. Extract failed ?${NC}"
        exit
    fi
fi

echo -e "${GREEN} Success !${NC}"


# Run android studio for installation

STUDIO_DIR=` ls $HOME | grep "android-studio" `

echo -e "${BLUE}\nExecuting setup for android studio (Close Android studio when installation is completed) ${NC}"

(cd $HOME; ./$STUDIO_DIR/bin/studio.sh >> log.txt 2>&1 && echo -e "${GREEN} Success !${NC}" ||  (echo -e "${RED} Failed !${NC}" ; exit))

echo -e "${GREEN} Android studio installed !${NC}"

# Setting Android Studio environment variables

echo -e "${BLUE}Setting Android Studio environment variables ($BASHRC)${NC}"


ANDROID_HOME=$(cat $BASHRC | grep "ANDROID_HOME")

if [ -z "$ANDROID_HOME"  ]; then
    echo -e "\n# Android Studio environment variables" >> $BASHRC
    echo "export ANDROID_SDK_ROOT=$HOME/Android/Sdk" >>  $BASHRC
    echo "export ANDROID_HOME=$ANDROID_SDK_ROOT" >>  $BASHRC

    source $HOME/.bashrc

    echo "export PATH=\$PATH:$HOME/Android/Sdk/tools:$HOME/Android/Sdk/platform-tools" >>  $BASHRC
    if [ ! -z "$ANDROID_HOME"  ]; then
        echo -e "${RED}ANDROID_HOME not set. Android Environment failed ?${NC}"
        exit
    fi
fi
echo -e "${GREEN} Success !${NC}"


#install flutter SDK

while true; do
    echo -e "${BLUE}(Optional) Do you wish to install Flutter SDK? (y/N)${NC}"
    read yn
    case $yn in
        [Yy]* ) install_flutter; break;;
        [Nn]* ) echo -e "${GREEN}-- SETUP COMPLETED --\n${NC}"; exit;;
        * ) echo "${RED}Please answer yes or no.${NC}";;
    esac
done


echo -e "${GREEN}-- SETUP COMPLETED --\n${NC}"


echo -e "${RED}\nNOTE: If you have issue with Android Toolchain, try executing Flutter doctor outside this script !${NC}\n\n"
