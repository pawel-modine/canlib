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

# Kvaser linuxcan drivers DKMS Makefile

DRIVERS   += common
DRIVERS   += leaf
DRIVERS   += mhydra
DRIVERS   += usbcanII
DRIVERS   += virtualcan
# KV_NO_PCI should be set on targets that do not have PCI, such as RaspberryPi.
ifndef KV_NO_PCI
DRIVERS   += pcican
DRIVERS   += pcican2
DRIVERS   += pciefd
endif

#---------------------------------
# Debug levels are defined in config.mak
KV_DEBUG_ON ?= 0
export KV_DEBUG_ON

#---------------------------------
SUBDIRS   = $(DRIVERS)

reverse=$(if $(1),$(call reverse,$(wordlist 2,$(words $(1)),$(1)))) $(firstword $(1))

KV_KERNEL_VERSION ?= `uname -r`
KDIR ?= /lib/modules/$(KV_KERNEL_VERSION)/build
define print_versions
	echo '$1 building linuxcan v'`sed -n 's/^version=//g; s/_/./g; s/\([[:digit:]]\+\.[[:digit:]]\+\.[[:digit:]]\+\).\(beta\)\?/\1 \2/p' moduleinfo.txt`
	echo '  User    : '$(USER)
	echo '  System  : '`uname -a`
	echo '  CC      : '$(CC)
	echo '  CC ver. : '`$(CC) -dumpfullversion -dumpversion`
	echo '  KDIR    : '$(KDIR)
	echo '  Kernel  : '$(KV_KERNEL_VERSION)
	echo ''
endef

#---------------------------------------------------------------------------
# RULES
.PHONY: print_versions_start common leaf mhydra pcican pcican2 usbcanII virtualcan pciefd install uninstall clean check load

all: print_versions_start $(SUBDIRS)
	@echo
	@$(call print_versions, Done)
	@$(call check_for_kvaser_usb_devices)

print_versions_start:
	@$(call print_versions, Start)
	@$(call check_for_kvaser_usb_devices)

common:
	@cd ./common; $(MAKE) kv_module

pcican: common
	@cd ./pcican; $(MAKE) kv_module

pcican2: common
	@cd ./pcican2; $(MAKE) kv_module

usbcanII: common
	@cd ./usbcanII; $(MAKE) kv_module

leaf: common
	@cd ./leaf; $(MAKE) kv_module

mhydra: common
	@cd ./mhydra; $(MAKE) kv_module

virtualcan: common
	@cd ./virtualcan; $(MAKE) kv_module

pciefd: common
	@cd ./pciefd; $(MAKE) kv_module

install:
	@for dir in $(DRIVERS) ; do cd $$dir; echo Installing $$dir;./installscript.sh dkms-install || exit 1; cd ..; done

uninstall:
	@for dir in $(call reverse,$(DRIVERS)) ; do cd $$dir; echo Uninstalling $$dir;./uninstallscript.sh || exit 1; cd ..; done

load:
	@for dir in $(DRIVERS) ; do cd $$dir; echo Installing $$dir;./installscript.sh dkms-load || exit 1; cd ..; done

clean:
	@for dir in $(SUBDIRS) ; do cd $$dir; $(MAKE) clean; cd ..; done

define check_for_kvaser_usb_devices
	if lsusb -d 0bfd: > /dev/null ; then \
		echo '*****************************************************'; \
		echo 'WARNING: Found connected Kvaser USB device(s)!'; \
		echo '         Unplug them before installing the drivers.'; \
		echo '*****************************************************'; \
		echo ''; \
	fi
endef
