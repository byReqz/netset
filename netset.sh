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
read c1
if [[ "$c1" == "1" ]] || [[ "$c1" == "1." ]] || [[ "$c1" == "systemd-resolved" ]];then
    if [[ -z $(sudo systemctl status systemd-networkd | grep -e "dead") ]];then
        if [[ $(ls -l /etc/systemd/network | wc -l) != 0 ]];then
            echo "warning, there already are configs present"
            echo "do you want to continue? (Y/n)"
            read continue
            if [[ "$continue" == y ]] || [[ "$continue" == yes ]] || [[ -z "$continue" ]];then
                touch "/etc/systemd/network/10-ethernet.network"
                echo "[Match]" >> "/etc/systemd/network/10-ethernet.network"
                echo "Do you want to configure by Interfacename or MAC? (ifn/MAC)"
                read choice1
                if [[ "$choice1" =~ "ifn" ]];then
                    echo "======================"
                    echo "Please type out the Interfacename"
                    echo "======================"
                    ip link show
                    read interface
                    echo "Name=$interface" >> "/etc/systemd/network/10-ethernet.network"
                    echo "" >> "/etc/systemd/network/10-ethernet.network"
                elif [[ "$choice1" =~ "mac" ]];then
                    echo "======================"
                    echo "Please type out the MAC-Adress"
                    echo "======================"
                    read mac
                    echo "MACAdress=$mac" >> "/etc/systemd/network/10-ethernet.network"
                    echo "" >> "/etc/systemd/network/10-ethernet.network"
                else
                    echo "no proper input provided"
                    exit
                fi
                echo "[Network]" >> "/etc/systemd/network/10-ethernet.network"
                echo "======================"
                echo "Please type out the IP-Adress you want to set (with CIDR)"
                echo "======================"
                read ipstatic
                echo "Address=$ipstatic" >> "/etc/systemd/network/10-ethernet.network"
                echo "======================"
                echo "Please type out the Gateway adress"
                echo "======================"
                read gateway
                echo "Gateway=$gateway" >> "/etc/systemd/network/10-ethernet.network"
                echo "======================"
                echo "Please type out the main DNS address (blank for none)"
                echo "======================"
                read dns
                if [[ -z "$dns" ]];then
                    echo "======================"
                    echo "Interface has been configured"
                    echo "restart systemd-networkd to apply the profile"
                    echo "======================"
                    exit
                fi
                echo "DNS=$dns" >> "/etc/systemd/network/10-ethernet.network"
                echo "======================"
                echo "Interface has been configured"
                echo "restart systemd-networkd to apply the profile"
                echo "======================"
                exit
            else
                exit
            fi
        else
                touch "/etc/systemd/network/10-ethernet.network"
                echo "[Match]" >> "/etc/systemd/network/10-ethernet.network"
                echo "Do you want to configure by Interfacename or MAC? (ifn/MAC)"
                read choice1
                if [[ "$choice1" =~ "ifn" ]];then
                    echo "======================"
                    echo "Please type out the Interfacename"
                    echo "======================"
                    ip link show
                    read interface
                    echo "Name=$interface" >> "/etc/systemd/network/10-ethernet.network"
                    echo "" >> "/etc/systemd/network/10-ethernet.network"
                elif [[ "$choice1" =~ "mac" ]];then
                    echo "======================"
                    echo "Please type out the MAC-Adress"
                    echo "======================"
                    read mac
                    echo "MACAdress=$mac" >> "/etc/systemd/network/10-ethernet.network"
                    echo "" >> "/etc/systemd/network/10-ethernet.network"
                else
                    echo "no proper input provided"
                    exit
                fi
                echo "[Network]" >> "/etc/systemd/network/10-ethernet.network"
                echo "======================"
                echo "Please type out the IP-Adress you want to set (with CIDR)"
                echo "======================"
                read ipstatic
                echo "Address=$ipstatic" >> "/etc/systemd/network/10-ethernet.network"
                echo "======================"
                echo "Please type out the Gateway adress"
                echo "======================"
                read gateway
                echo "Gateway=$gateway" >> "/etc/systemd/network/10-ethernet.network"
                echo "======================"
                echo "Please type out the main DNS address (blank for none)"
                echo "======================"
                read dns
                if [[ -z "$dns" ]];then
                    echo "======================"
                    echo "Interface has been configured"
                    echo "restart systemd-networkd to apply the profile"
                    echo "======================"
                    exit
                fi
                echo "DNS=$dns" >> "/etc/systemd/network/10-ethernet.network"
                echo "======================"
                echo "Interface has been configured"
                echo "restart systemd-networkd to apply the profile"
                echo "======================"
                exit
        fi
    else
        echo "systemd-networkd is not running"
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
    else
        mv ."$nmc".nmconnection "$nmc".nmconnection
        exit
    fi
    exit
elif [[ "$c1" == "3" ]] || [[ "$c1" == "3." ]] || [[ "$c1" == "netplan" ]];then
    echo "please enter the interface name"
    echo "======================"
    ip l
    echo "======================"
    read npif
    echo "network:" > $PWD/.netplan.yaml
    echo -e "    version: 2" >> $PWD/.netplan.yaml
    echo -e "    renderer: networkd" >> $PWD/.netplan.yaml
    echo -e "    ethernets:" >> $PWD/.netplan.yaml
    echo -e "        $npif:" >> $PWD/.netplan.yaml
    echo -e "            addresses:" >> $PWD/.netplan.yaml
    if [[ -n $(ip a | grep -e "$npif") ]];then
        echo "please enter the ip adress to set (with cidr notation)"
        read npip
        echo -e "                 - "$npip"" >> $PWD/.netplan.yaml
        echo "please enter the gateway adress to set"
        read npgw
        echo -e "            gateway4: "$npgw"" >> $PWD/.netplan.yaml
        echo -e "            nameservers:" >> $PWD/.netplan.yaml
        echo -e "                search: [mydomain, otherdomain]" >> $PWD/.netplan.yaml
        echo "please enter the dns servers adress, leave empty for default"
        read npdns
        if [[ -z "$npdns" ]];then
            echo -e "                addresses: [213.133.98.98]" >> $PWD/.netplan.yaml
        else
            echo -e "                addresses: ["$npdns"]" >> $PWD/.netplan.yaml
        fi
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
            exit
        fi
    else
        echo "interface not found, exiting"
        exit
    fi

else
    echo "selected manager not supported"
    exit
fi