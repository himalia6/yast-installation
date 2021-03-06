#!/bin/sh
#================
# FILE          : network.sh
#----------------
# PROJECT       : YaST (Yet another Setup Tool v2)
# COPYRIGHT     : (c) 2004 SUSE Linux AG, Germany. All rights reserved
#               :
# AUTHORS       : Marcus Schaefer <ms@suse.de> 
#               :
#               :
# BELONGS TO    : System installation and Administration
#               :
# DESCRIPTION   : Common used functions used for the YaST2 startup process
#               : refering to network environment issues
#               :
# STATUS        : $Id$
#----------------
#
#----[ is_iface_up ]-----#
is_iface_up() {
#--------------------------------------------------
# check if given interface is up
# ---
	test -z "$1" && return 1
	case "$(LC_ALL=POSIX ip link show "$1" 2>/dev/null)" in
		*$1*UP*) ;;
		*) return 1 ;;
	esac
}

#----[ found_iface ]-----#
found_iface() {
#--------------------------------------------------
# search for a queued network interface
#
	for i in $(ip -o link show | cut -f2 -d:); do
		iface=$(echo "$i" | tr -d " ")
		if is_iface_up "$iface" ; then
			return 0
		fi
	done
	return 1
}


list_ifaces()
{
    # list network interfaces
    # - all active ones with all IPv4 / IPv6 addresses
    # - excluding loopback device
    ifaces=$(/sbin/ip -oneline address show | grep "inet" | cut --delimiter=' ' --fields=2 | uniq | grep --invert-match "^lo")

    for i in ${ifaces}; do
      ip address show "$i" | sed --quiet \
        --expression="1{s/^[^ ]* \([^:]*\).*/\1:/;h}" \
        --expression="/ether/{ s/^.*ether[^ ]* \([^ ]*\).*/\1/; H; g; s/\n/ /; p}" \
        --expression="s/^[ ]*inet \([^ ]*\).*/  \1/p" \
        --expression="s/^[ ]*inet6 \([^ ]*\).*/  \1/p"
    done;
}


#----[ vnc_message ]-----#
vnc_message() {
#--------------------------------------------------
# console message displayed with a VNC installation
# ---
	cat <<-EOF
	
	***
	***  Please return to your X-Server screen to finish installation
	***
	
	EOF
}

#----[ ssh_message ]-----#
ssh_message () {
#--------------------------------------------------
# console message displayed with a SSH installation
# ---
	cat <<-EOF
	
	***  sshd has been started  ***
	
	you can login now and proceed with the installation
	run the command 'yast.ssh'
	
	These network addresses are available:
	
	EOF
	list_ifaces
	echo
}
