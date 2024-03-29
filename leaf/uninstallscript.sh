#!/bin/sh

#
#             Copyright 2023 by Kvaser AB, Molndal, Sweden
#                         http://www.kvaser.com
#
#  This software is dual licensed under the following two licenses:
#  BSD-new and GPLv2. You may use either one. See the included
#  COPYING file for details.
#
#  License: BSD-new
#  ==============================================================================
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are met:
#      * Redistributions of source code must retain the above copyright
#        notice, this list of conditions and the following disclaimer.
#      * Redistributions in binary form must reproduce the above copyright
#        notice, this list of conditions and the following disclaimer in the
#        documentation and/or other materials provided with the distribution.
#      * Neither the name of the <organization> nor the
#        names of its contributors may be used to endorse or promote products
#        derived from this software without specific prior written permission.
#
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
#  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
#  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
#  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
#  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
#  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
#  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
#  IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
#  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
#  POSSIBILITY OF SUCH DAMAGE.
#
#
#  License: GPLv2
#  ==============================================================================
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA
#
#
#  IMPORTANT NOTICE:
#  ==============================================================================
#  This source code is made available for free, as an open license, by Kvaser AB,
#  for use with its applications. Kvaser AB does not accept any liability
#  whatsoever for any third party patent or other immaterial property rights
#  violations that may result from any usage of this source code, regardless of
#  the combination of source code and various applications that it can be used
#  in, or with.
#
#  -----------------------------------------------------------------------------
#

MODNAME=leaf
DEPMOD=`which depmod`
SOCKETCAN_DRIVER=kvaser_usb
MODPROBE_DIR=/etc/modprobe.d
BLACKLIST_FILE=$MODPROBE_DIR/blacklist-$SOCKETCAN_DRIVER.conf
DIR="${0%/*}"
DEVEL=
PURGE=

print_usage() {
  echo "Usage: uninstallscript.sh [-p] [-d] [-h]"
  echo
  echo "  -p    Uninstall all versions of $MODNAME"
  echo "  -d    Developer install, ignores $DEPMOD -a"
  echo "  -h    Prints this usage message"
}

while getopts 'dph' flag ; do
  case "${flag}" in
    d) DEVEL=true ;;
    p) PURGE=true ;;
    h) print_usage
       exit 0 ;;
  esac
done

modprobe -r $MODNAME 2>/dev/null

# Check if module is still loaded
MODLOADED=$(lsmod | grep $MODNAME)
if [ $? -eq 0 ] ; then
  echo "*************************************************************************"
  echo "WARNING: $MODNAME could not be removed! Either unplug USB device and     "
  echo "          remove $MODNAME manually after uninstallation or do a reboot.  "
  echo "*************************************************************************"
fi

if [ "$PURGE" = true ] ; then
    find /lib/modules/*/kernel/drivers/usb/misc/ -name $MODNAME.ko -exec rm -f {} +

# Need to loop in case installer was run several times on different kernel versions
elif test -f "$DIR/kernel_ver"; then
  while read line; do
    rm -f /lib/modules/$line/kernel/drivers/usb/misc/$MODNAME.ko
  done < "$DIR/kernel_ver"
  rm -f "$DIR/kernel_ver"
# If user for some reason deleted kernel_ver we try deleting in current kernel
else
  rm -f /lib/modules/`uname -r`/kernel/drivers/usb/misc/$MODNAME.ko
fi


if [ -f $BLACKLIST_FILE ] ; then
  echo "Remove blacklisting of SocketCAN driver $SOCKETCAN_DRIVER"
  rm -f $BLACKLIST_FILE
fi

if [ "$DEVEL" = true ] ; then
  echo "Ignoring $DEPMOD -a for now.."
else
  $DEPMOD -a
  if [ "$?" -ne 0 ] ; then
    echo Failed to execute $DEPMOD -a
  fi
fi
