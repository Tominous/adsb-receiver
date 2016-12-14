#!/bin/bash

#####################################################################################
#                                   ADS-B RECEIVER                                  #
#####################################################################################
#                                                                                   #
#  A set of scripts created to automate the process of installing the software      #
#  needed to setup a Mode S decoder as well as feeders which are capable of         #
#  sharing your ADS-B results with many of the most popular ADS-B aggregate sites.  #
#                                                                                   #
#  Project Hosted On GitHub: https://github.com/jprochazka/adsb-receiver            #
#                                                                                   #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#                                                                                   #
# Copyright (c) 2015-2016 Joseph A. Prochazka                                       #
#                                                                                   #
# Permission is hereby granted, free of charge, to any person obtaining a copy      #
# of this software and associated documentation files (the "Software"), to deal     #
# in the Software without restriction, including without limitation the rights      #
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell         #
# copies of the Software, and to permit persons to whom the Software is             #
# furnished to do so, subject to the following conditions:                          #
#                                                                                   #
# The above copyright notice and this permission notice shall be included in all    #
# copies or substantial portions of the Software.                                   #
#                                                                                   #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR        #
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,          #
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE       #
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER            #
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,     #
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE     #
# SOFTWARE.                                                                         #
#                                                                                   #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

## VARIABLES

PROJECTBRANCH="master"
PROJECTROOTDIRECTORY="$PWD"
BASHDIRECTORY="$PROJECTROOTDIRECTORY/bash"
BUILDDIRECTORY="$PROJECTROOTDIRECTORY/build"
VERBOSE=""

## INCLUDE EXTERNAL SCRIPTS

source $BASHDIRECTORY/functions.sh

## MORE VARIABLES

export ADSB_PROJECTTITLE="The ADS-B Receiver Project Installer"
TERMINATEDMESSAGE="  \e[91m  ANY FURTHER SETUP AND/OR INSTALLATION REQUESTS HAVE BEEN TERMINIATED\e[39m"

## PARSE OPTIONS FROM CLI

usage()
{
    echo -e ""
    echo -e "$0: Installs and updates $ADSB_PROJECTTITLE"
    echo -e ""
    echo -e "Usage: $0 [OPTS]"
    echo -e "    -h | --help    \t Shows this dialog"
    echo -e "    -v | --verbose \t Provides extra confirmation at each stage of the install"
    echo -e ""
}

while [[ $1 = -* ]]; do
   case "$1" in
       -h|--help)
           usage
           exit 1
           ;;
       -v|--verbose)
           VERBOSE="1"
           shift 1
           ;;
       *)
           echo -e "Error: Unknown option: $1" >&2
           usage
           exit 1
           ;;
    esac
done

## CHECK IF THIS IS THE FIRST RUN USING THE IMAGE RELEASE

if [ -f $PROJECTROOTDIRECTORY/image ]; then
    # Enable extra confirmation dialogs..
    VERBOSE="1"
    # Execute image setup script..
    chmod +x $BASHDIRECTORY/image.sh
    $BASHDIRECTORY/image.sh
    if [ $? -ne 0 ]; then
        echo ""
        echo -e $TERMINATEDMESSAGE
        echo ""
        exit 1
    fi
    exit 0
fi

## FUNCTIONS

# UPDATE REPOSITORY PACKAGE LISTS
function AptUpdate() {
    clear
    echo -e "\n\e[91m  $ADSB_PROJECTTITLE"
    echo ""
    echo -e "\e[92m  Downloading the latest package lists for all enabled repositories and PPAs..."
    echo -e "\e[93m----------------------------------------------------------------------------------------------------\e[97m"
    echo ""
    sudo apt-get update
    echo ""
    echo -e "\e[93m----------------------------------------------------------------------------------------------------"
    echo -e "\e[92m  Finished downloading and updating package lists.\e[39m"
    echo ""
    if [ ${VERBOSE} ] ; then 
        read -p "Press enter to continue..." CONTINUE
    fi
}

function CheckPrerequisites() {
    clear
    echo -e "\n\e[91m  $ADSB_PROJECTTITLE"
    echo ""
    echo -e "\e[92m  Checking to make sure the whiptail and git packages are installed..."
    echo -e "\e[93m----------------------------------------------------------------------------------------------------\e[97m"
    echo ""
    CheckPackage whiptail
    CheckPackage git
    echo ""
    echo -e "\e[93m----------------------------------------------------------------------------------------------------"
    echo -e "\e[92m  The whiptail and git packages are installed.\e[39m"
    echo ""
    if [ ${VERBOSE} ] ; then
        read -p "Press enter to continue..." CONTINUE
    fi
}


function UpdateRepository() {
## UPDATE THIS REPOSITORY
    clear
    echo -e "\n\e[91m  $ADSB_PROJECTTITLE"
    echo ""
    echo -e "\e[92m  Pulling the latest version of the ADS-B Receiver Project repository..."
    echo -e "\e[93m----------------------------------------------------------------------------------------------------\e[97m"
    echo ""
    echo -e "\e[94m  Switching to branch $PROJECTBRANCH...\e[97m"
    echo ""
    git checkout $PROJECTBRANCH
    echo ""
    echo -e "\e[94m  Pulling the latest git repository...\e[97m"
    echo ""
    git pull
    echo ""
    echo -e "\e[93m----------------------------------------------------------------------------------------------------"
    echo -e "\e[92m  Finished pulling the latest version of the ADS-B Receiver Project repository....\e[39m"
    echo ""
    if [ ${VERBOSE} ] ; then
        read -p "Press enter to continue..." CONTINUE
    fi
}

# UPDATE THE OPERATING SYSTEM
function UpdateOperatingSystem() {
    clear
    echo -e "\n\e[91m  $ADSB_PROJECTTITLE"
    echo ""
    echo -e "\e[92m  Downloading and installing the latest updates for your operating system..."
    echo -e "\e[93m----------------------------------------------------------------------------------------------------\e[97m"
    echo ""
    sudo apt-get -y dist-upgrade
    echo ""
    echo -e "\e[93m----------------------------------------------------------------------------------------------------"
    echo -e "\e[92m  Your operating system should now be up to date.\e[39m"
    echo ""
    if [ ${VERBOSE} ] ; then
        read -p "Press enter to continue..." CONTINUE
    fi
}

AptUpdate
CheckPrerequisites
UpdateRepository

## DISPLAY WELCOME SCREEN

## ASK IF OPERATING SYSTEM SHOULD BE UPDATED

if (whiptail --backtitle "$ADSB_PROJECTTITLE" --title "Operating System Updates" --yesno "It is recommended that you update your system before building and/or installing any ADS-B receiver related packages. This script can do this for you at this time if you like.\n\nWould you like to update your operating system now?" 11 78) then
    UpdateOperatingSystem
fi

## EXECUTE BASH/MAIN.SH

chmod +x $BASHDIRECTORY/main.sh
$BASHDIRECTORY/main.sh
if [ $? -ne 0 ]; then
    echo -e $TERMINATEDMESSAGE
    echo ""
    exit 1
fi

## INSTALLATION COMPLETE

# Display the installation complete message box.
whiptail --backtitle "$ADSB_PROJECTTITLE" --title "Software Installation Complete" --msgbox "INSTALLATION COMPLETE\n\nDO NOT DELETE THIS DIRECTORY!\n\nFiles needed for certain items to run properly are contained within this directory. Deleting this directory may result in your receiver not working properly.\n\nHopefully, these scripts and files were found useful while setting up your ADS-B Receiver. Feedback regarding this software is always welcome. If you have any issues or wish to submit feedback, feel free to do so on GitHub.\n\nhttps://github.com/jprochazka/adsb-receiver" 20 65

# Unset any exported variables.
unset ADSB_PROJECTTITLE

# Remove the FEEDERCHOICES file created by whiptail.
rm -f FEEDERCHOICES

echo -e "\033[32m"
echo "Installation complete."
echo -e "\033[37m"

exit 0
