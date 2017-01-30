#!/bin/bash

#####################################################################################
#                                  ADS-B RECEIVER                                   #
#####################################################################################
#                                                                                   #
# This script is not meant to be executed directly.                                 #
# Instead execute install.sh to begin the installation process.                     #
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

RECEIVER_ROOT_DIRECTORY="${PWD}"
BUILDDIRECTORY="${RECEIVER_ROOT_DIRECTORY}/build"
PORTAL_BUILD_DIRECTORY="${BUILDDIRECTORY}/portal"
PORTAL_PYTHON_DIRECTORY="${PORTAL_BUILD_DIRECTORY}/python"
PYTHONPATH=`which python`

## SETUP FLIGHT LOGGING

echo -e ""
echo -e "\e[95m  Setting up flight logging...\e[97m"
echo -e ""

# Create and set permissions on the flight logging and maintenance maintenance scripts.
echo -e "\e[94m  Creating the flight logging maintenance script...\e[97m"
tee ${PORTAL_PYTHON_DIRECTORY}/flights-maint.sh > /dev/null <<EOF
#!/bin/bash
while true
  do
    sleep 30
        ${PYTHONPATH} ${PORTAL_PYTHON_DIRECTORY}/flights.py
  done
EOF

echo -e "\e[94m  Creating the maintenance maintenance script...\e[97m"
tee ${PORTAL_PYTHON_DIRECTORY}/maintenance-maint.sh > /dev/null <<EOF
#!/bin/bash
while true
  do
    sleep 30
        ${PYTHONPATH} ${PORTAL_PYTHON_DIRECTORY}/maintenance.py
  done
EOF

echo -e "\e[94m  Making the flight logging maintenance script executable...\e[97m"
chmod +x ${PORTAL_PYTHON_DIRECTORY}/flights-maint.sh
echo -e "\e[94m  Making the maintenance maintenance script executable...\e[97m"
chmod +x ${PORTAL_PYTHON_DIRECTORY}/maintenance-maint.sh

#Remove old flights-maint.sh start up line from /etc/rc.local.
sudo sed -i '/build\/portal\/logging\/flights-maint.sh/d' /etc/rc.local

# Add flight logging maintenance script to rc.local.
if [[ `grep -cFx "${PORTAL_PYTHON_DIRECTORY}/flights-maint.sh &" /etc/rc.local` -eq 0 ]] ; then
    echo -e "\e[94m  Adding the flight logging maintenance script startup line to /etc/rc.local...\e[97m"
    LINENUMBER=($(sed -n '/exit 0/=' /etc/rc.local))
    ((LINENUMBER>0)) && sudo sed -i "${LINENUMBER[$((${#LINENUMBER[@]}-1))]}i ${PORTAL_PYTHON_DIRECTORY}/flights-maint.sh &\n" /etc/rc.local
fi

# Remove old maintenance-maint.sh start up line from /etc/rc.local.
sudo sed -i '/build\/portal\/logging\/maintenance-maint.sh/d' /etc/rc.local

# Add maintenance maintenance script to rc.local.
if [[ `grep -cFx "${PORTAL_PYTHON_DIRECTORY}/maintenance-maint.sh &" /etc/rc.local` -eq 0 ]] ; then
    echo -e "\e[94m  Adding the maintenance maintenance script startup line to /etc/rc.local...\e[97m"
    LINENUMBER=($(sed -n '/exit 0/=' /etc/rc.local))
    ((LINENUMBER>0)) && sudo sed -i "${LINENUMBER[$((${#LINENUMBER[@]}-1))]}i ${PORTAL_PYTHON_DIRECTORY}/maintenance-maint.sh &\n" /etc/rc.local
fi

# Kill any previously running maintenance scripts.
echo -e "\e[94m  Checking for any running flights-maint.sh processes...\e[97m"
PIDS=`ps -efww | grep -w "flights-maint.sh" | awk -vpid=$$ '$2 != pid { print $2 }'`
if [[ -n "${PIDS}" ]] ; then
    echo -e "\e[94m  Killing any running flights-maint.sh processes...\e[97m"
    sudo kill ${PIDS}
    sudo kill -9 ${PIDS}
fi
PIDS=`ps -efww | grep -w "maintenance-maint.sh" | awk -vpid=$$ '$2 != pid { print $2 }'`
if [[ -n "${PIDS}" ]] ; then
    echo -e "\e[94m  Killing any running maintenance-maint.sh processes...\e[97m"
    sudo kill ${PIDS}
    sudo kill -9 ${PIDS}
fi

# Start flight logging.
echo -e "\e[94m  Executing the flight logging maintenance script...\e[97m"
nohup ${PORTAL_PYTHON_DIRECTORY}/flights-maint.sh > /dev/null 2>&1 &

# Start maintenance.
echo -e "\e[94m  Executing the maintenance maintenance script...\e[97m"
nohup ${PORTAL_PYTHON_DIRECTORY}/maintenance-maint.sh > /dev/null 2>&1 &

exit 0
