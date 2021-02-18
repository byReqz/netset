#!/bin/bash
# license: gpl-3
echo "which networkmanager do you want to use?"
echo "please enter the name or number of your choice"
if [[ -n $(systemctl --version | grep -e "systemd") ]];then
    echo "1. systemd-resolved [installed]"
else
    echo "1. systemd-resolved [not installed]"
fi
if [[ -n $(NetworkManager -h | grep -e "Usage:") ]];then
    echo "2. NetworkManager [installed]"
else
    echo "2. NetworkManager [not installed]"
fi
read $c1
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
    echo "select a new connectionname"
    read $nmc
    nmcli networking on
    nmcli connection add type ethernet con-name "$nmc"
    nmcli connection modify "$nmc" connection.autoconnect yes
    nmcli connection modify "$nmc" connection.autoconnect-priority -999
    nmcli connection modify "$nmc" connection.autoconnect-retries -1
    nmcli connection modify "$nmc" connection.read-only no
    nmcli connection modify "$nmc" connection.autoconnect-slaves -1
    nmcli connection modify "$nmc" connection.wait-device-timeout -1
    echo "----------------------------"
    echo "input the ip to set (cidr notion also accepted)"
    echo "----------------------------"
    read $nmcip
    nmcli con mod "$nmc" ipv4.method manual ipv4.addr "$nmcip"
    # sets hetzner dns
    nmcli con modify "$nmc" +ipv4.dns 213.133.98.98
    echo "connection has been set (restart network manager if necessary)"
    exit
else
    echo "selected manager not supported"
    exit
fi