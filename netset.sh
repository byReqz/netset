#!/bin/bash
# license: gpl-3
echo "which networkmanager do you want to use?"
echo "please enter the name or number of your choice"
if [[ -n $(systemctl --version | grep -e "systemd") ]];then
    echo "1. systemd-resolved [installed]"
else
    echo "1. systemd-resolved [not installed]"
fi
if [[ -n $(ls /etc | grep -e "NetworkManager") ]];then
    echo "2. NetworkManager [installed]"
else
    echo "2. NetworkManager [not installed]"
fi
if [[ -n $(ls /etc | grep -e "netplan") ]];then
    echo "3. netplan [installed]"
else
    echo "3. netplan [not installed]"
fi
if [[ -n $(ls /etc | grep -e "netctl") ]];then
    echo "4. netctl [installed]"
else
    echo "4. netctl [not installed]"
fi
if [[ -n $(ls /etc | grep -e "network") ]];then
    echo "5. interfaces (ifup/ifdown) [installed]"
else
    echo "5. interfaces (ifup/ifdown) [not installed]"
fi
read c1
if [[ "$c1" == "1" ]] || [[ "$c1" == "1." ]] || [[ "$c1" == "systemd-resolved" ]];then
    echo "Do you want to configure by Interfacename or MAC? (ifn/MAC)"
    read choice1
    if [[ "$choice1" =~ "ifn" ]];then
        echo "======================"
        echo "type the name of the interface to use"
        echo "======================"
        ip a
        echo "======================"
        read sndif
        sndif="Name="$sndif""
    elif [[ "$choice1" =~ "mac" ]];then
        echo "======================"
        echo "Please type out the MAC-Adress"
        echo "======================"
        ip a
        echo "======================"
        read sndif
        sndif="MACAdress="$sndif""
    else
        echo "empty input, exiting"
        exit
    fi
    echo "======================"
    echo "input the ip to set (cidr notion needed, defaults to /24)"
    echo "======================"
    read sndip
    if [[ -z "$(echo $sndip | grep -e "/")" ]];then
        sndip=""$sndip"/24"
    fi
    echo "======================"
    echo "input the gateway adress to set"
    echo "======================"
    read sndgw
    echo "======================"
    echo "input the dns server adress to set"
    echo "leave empty for default"
    echo "======================"
    read snddns
    if [[ -z "$snddns" ]];then
        # those are the default hetzner dns servers
        snddns="213.133.98.98"
    fi
    echo "[Match]" > ".systemd.network"
    echo "$sndif" >> ".systemd.network"
    echo "" >> ".systemd.network"
    echo "[Network]" >> ".systemd.network"
    echo "Address=$sndip" >> ".systemd.network"
    echo "Gateway=$sndgw" >> ".systemd.network"
    echo "DNS=$snddns" >> ".systemd.network"
    echo "======================"
    echo "config has been generated in the current directory"
    echo "should the config be installed now? (y/N)"
    echo "======================"
    read $sndyn2
    if [[ "$sndyn2" == "y" ]] || [[ "$sndyn2" == "Y" ]] || [[ "$sndyn2" == "yes" ]];then
        mv .systemd.network "/etc/systemd/network/10-ethernet.network"
        systemctl daemon-reload
        systemctl restart systemd-networkd
        exit
    else
        mv .systemd.network systemd.network
        echo "======================"
        echo "the config should be copied to:"
        echo -e "\e[31m/etc/systemd/network/\e[0m"
        echo "and prefixed with"
        echo -e "\e[31m10-\e[0m"
        echo "and activated with"
        echo -e "\e[31mdaemon-reload\e[0m"
        echo -e "\e[31msystemctl restart systemd-networkd\e[0m"
        echo "======================"
        exit
    fi
elif [[ "$c1" == "2" ]] || [[ "$c1" == "2." ]] || [[ "$c1" == "networkmanager" ]];then
    echo "======================"
    echo "select a new connectionname"
    echo "======================"
    read nmc
    echo "======================"
    echo "type the name of the interface to use"
    echo ""
    ip a
    echo "======================"
    read nmcif
    echo "======================"
    echo "input the ip to set (cidr notion also accepted, defaults to /24 if empty)"
    echo "======================"
    read nmcip
    if [[ -z "$(echo $nmcip | grep -e "/")" ]];then
        nmcip=""$nmcip"/24"
    fi
    echo "======================"
    echo "input the gateway adress to set"
    echo "======================"
    read nmcgw
    echo "======================"
    echo "input the dns server adress(es) to set"
    echo "leave empty for default"
    echo "======================"
    read nmcdns
    if [[ -z "$nmcdns" ]];then
        # those are the default hetzner dns servers
        nmcdns="213.133.98.98"
    fi
    echo -e "[connection]" > ."$nmc".nmconnection
    echo -e "id="$nmc"" >> ."$nmc".nmconnection
    echo -e "uuid=$(curl -s "http://uuid4.com/?count=1&format=raw")" >> ."$nmc".nmconnection
    echo -e "type=ethernet" >> ."$nmc".nmconnection
    echo -e "autoconnect-priority=1" >> ."$nmc".nmconnection
    echo -e "interface-name="$nmcif"" >> ."$nmc".nmconnection
# not sure if this actually works
#    echo -e "permissions=user:*:;" >> ."$nmc".nmconnection
    echo -e "timestamp=$(date +%s)" >> ."$nmc".nmconnection
    echo -e "" >> ."$nmc".nmconnection
    echo -e "[ethernet]" >> ."$nmc".nmconnection
    echo -e "auto-negotiate=true" >> ."$nmc".nmconnection
    echo -e "mac-address-blacklist=" >> ."$nmc".nmconnection
    echo -e "" >> ."$nmc".nmconnection
    echo -e "[ipv4]" >> ."$nmc".nmconnection
    echo -e "address1="$nmcip","$nmcgw"" >> ."$nmc".nmconnection
    echo -e "dns="$nmcdns";" >> ."$nmc".nmconnection
    echo -e "dns-search=" >> ."$nmc".nmconnection
    echo -e "method=manual" >> ."$nmc".nmconnection
    echo -e "" >> ."$nmc".nmconnection
    echo -e "[ipv6]" >> ."$nmc".nmconnection
    echo -e "addr-gen-mode=stable-privacy" >> ."$nmc".nmconnection
    echo -e "dns-search=" >> ."$nmc".nmconnection
    echo -e "method=auto" >> ."$nmc".nmconnection
    echo -e "" >> ."$nmc".nmconnection
    echo -e "[proxy]" >> ."$nmc".nmconnection
    echo "======================"
    echo "the connection file has been created in $PWD"
    echo "should it be installed right now? (requires root) [y/N]"
    echo "======================"
    read nmcyn1
    if [[ "$nmcyn1" == "y" ]] || [[ "$nmcyn1" == "Y" ]] || [[ "$nmcyn1" == "yes" ]];then
        mv ."$nmc".nmconnection /etc/NetworkManager/system-connections/"$nmc".nmconnection
        chown root:root /etc/NetworkManager/system-connections/"$nmc".nmconnection
        chmod 600 /etc/NetworkManager/system-connections/"$nmc".nmconnection
        systemctl restart NetworkManager
        nmcli connection up "$nmc"
    else
        mv ."$nmc".nmconnection "$nmc".nmconnection
        echo "======================"
        echo "the config should be copied to:"
        echo -e "\e[31m/etc/NetworkManager/system-connections/\e[0m"
        echo "and can be activated with:"
        echo -e "\e[31mnmcli connection up "$nmc"\e[0m"
        echo -e "remember to set permissions to \e[31mroot/600\e[0m"
        echo "======================"
        exit
    fi
    exit
elif [[ "$c1" == "3" ]] || [[ "$c1" == "3." ]] || [[ "$c1" == "netplan" ]];then
    echo "please enter the interface name"
    echo "======================"
    ip l
    echo "======================"
    read npif
    if [[ -n $(ip a | grep -e "$npif") ]];then
        echo "======================"
        echo "select the renderer to use, defaults to networkd"
        if [[ -n $(ls /etc | grep -e "NetworkManager") ]];then
            echo "- Networkmanager [nm]"
        fi
        if [[ -n $(systemctl --version | grep -e "systemd") ]];then
            echo "- systemd-networkd [nd]"
        fi
        echo "======================"
        read nprd
        if [[ "$nprd" == "nm" ]] || [[ "$nprd" == "networkmanager" ]] || [[ "$nprd" == "NetworkManager" ]];then
            nprd="NetworkManager"
        elif [[ "$nprd" == "nd" ]] || [[ "$nprd" == "networkd" ]] || [[ "$nprd" == "systemd-networkd" ]];then
            nprd="networkd"
        else
            nprd="networkd"
        fi
        echo "please enter the ip adress to set (with cidr notation)"
        read npip
        echo "please enter the gateway adress to set"
        read npgw
        echo "please enter the dns servers adress, leave empty for default"
        read npdns
        if [[ -z "$npdns" ]];then
            npdns="213.133.98.98"
        fi
        echo "network:" > $PWD/.netplan.yaml
        echo -e "    version: 2" >> $PWD/.netplan.yaml
        echo -e "    renderer: "$nprd"" >> $PWD/.netplan.yaml
        echo -e "    ethernets:" >> $PWD/.netplan.yaml
        echo -e "        "$npif":" >> $PWD/.netplan.yaml
        echo -e "            addresses:" >> $PWD/.netplan.yaml
        echo -e "                 - "$npip"" >> $PWD/.netplan.yaml
        echo -e "            gateway4: "$npgw"" >> $PWD/.netplan.yaml
        echo -e "            nameservers:" >> $PWD/.netplan.yaml
        echo -e "                search: [mydomain, otherdomain]" >> $PWD/.netplan.yaml
        echo -e "                addresses: ["$npdns"]" >> $PWD/.netplan.yaml
        echo "======================"
        echo "config has been generated in the current directory"
        echo "should the config be installed now? (y/N)"
        echo "======================"
        read $npyn2
        if [[ "$npyn2" == "y" ]] || [[ "$npyn2" == "Y" ]] || [[ "$npyn2" == "yes" ]];then
            mv .netplan.yaml /etc/netplan/netplan.yaml
            exit
        else
            mv .netplan.yaml netplan.yaml
            echo "======================"
            echo "the config should be copied to:"
            echo -e "\e[31m/etc/netplan/\e[0m"
            echo "and can be activated with:"
            echo -e "\e[31mnetplan apply\e[0m"
            echo "======================"
            exit
        fi
    else
        echo "interface not found, exiting"
        exit
    fi
elif [[ "$c1" == "4" ]] || [[ "$c1" == "4." ]] || [[ "$c1" == "netctl" ]];then
    echo "======================"
    echo "type the name of the interface to use"
    echo "======================"
    ip a
    echo "======================"
    read nctlif
    echo "======================"
    echo "input the ip to set (cidr notion needed, defaults to /24)"
    echo "======================"
    read nctlip
    if [[ -z "$(echo $nctlip | grep -e "/")" ]];then
        nctlip=""$nctlip"/24"
    fi
    echo "======================"
    echo "input the gateway adress to set"
    echo "======================"
    read nctlgw
    echo "======================"
    echo "input the dns server adress(es) to set"
    echo "leave empty for default"
    echo "======================"
    read nctldns
    if [[ -z "$nctldns" ]];then
        # those are the default hetzner dns servers
        nctldns="213.133.98.98"
    fi
    echo -e "Interface="$nctlif"" >> .netctl
    echo -e "Connection=ethernet" >> .netctl
    echo -e "IP=static" >> .netctl
    echo -e "Address=('"$nctlip"')" >> .netctl
    echo -e "Gateway='"$nctlgw"'" >> .netctl
    echo -e "DNS=('"$nctldns"')" >> .netctl
    echo "======================"
    echo "config has been generated in the current directory"
    echo "should the config be installed now? (y/N)"
    echo "======================"
    read $npyn2
    if [[ "$npyn2" == "y" ]] || [[ "$npyn2" == "Y" ]] || [[ "$npyn2" == "yes" ]];then
        mv .netctl /etc/netctl/
        netctl enable netctl
        netctl start netctl
        exit
    else
        mv .netctl netctl-config
        echo "======================"
        echo "the config should be copied to:"
        echo -e "\e[31m/etc/netctl\e[0m"
        echo "and activated with"
        echo -e "\e[31mnetctl enable netctl-config\e[0m"
        echo -e "\e[31mnetctl start netctl-config\e[0m"
        echo "======================"
        exit
    fi
elif [[ "$c1" == "5" ]] || [[ "$c1" == "5." ]] || [[ "$c1" == "interfaces" ]];then
    echo "======================"
    echo "type the name of the interface to use"
    echo "======================"
    ip a
    echo "======================"
    read ifif
    echo "======================"
    echo "input the ip to set (without cidr notion)"
    echo "======================"
    read ifip
    echo "======================"
    echo "input the netmask to set (long form)"
    echo "defaults to 255.255.255.0 if empty"
    echo "======================"
    read ifnm
    if [[ -z "$(echo $ifnm | grep -e ".")" ]];then
        ifnm="255.255.255.0"
    fi
    echo "======================"
    echo "input the gateway adress to set"
    echo "======================"
    read ifgw
    echo -e "auto lo" > .interfaces
    echo -e "iface lo inet loopback" >> .interfaces
    echo -e "" >> .interfaces
    echo -e "auto "$ifif"" >> .interfaces
    echo -e "allow-hotplug "$ifif"" >> .interfaces
    echo -e "iface "$ifif" inet manual" >> .interfaces
    echo -e "    adress "$ifip"" >> .interfaces
    echo -e "    netmask "$ifnm"" >> .interfaces
    echo -e "    gateway "$ifgw"" >> .interfaces
    echo "======================"
    echo "config has been generated in the current directory"
    echo "should the config be installed now? (y/N)"
    echo "======================"
    read $ifyn2
    if [[ "$ifyn2" == "y" ]] || [[ "$ifyn2" == "Y" ]] || [[ "$ifyn2" == "yes" ]];then
        mv .interfaces /etc/network/
        ifup "$ifif"
        exit
    else
        mv .interfaces interfaces-config
        echo "======================"
        echo "the config should be copied to:"
        echo -e "\e[31m/etc/network/ and renamed to interfaces\e[0m"
        echo "and activated with"
        echo -e "\e[31mifup "$ifif"\e[0m"
        echo "======================"
        exit
    fi
else
    echo "selected manager not supported"
    exit
fi