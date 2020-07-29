# Firewall Configuration

The Balena installation procedure in the previous step creates a firewall configuration that allows the OCI container network to be accessed. This only creates firewall settings for Balena. To adjust firewall settings for PLCnext Engineer, ssh, web access, etc., the table `plcnext-filter` must also be loaded. The easiest way to load the `plcnext-filter` table is to "Start" the firewall via Web-Based Management (WBM). In the Security->Firewall WBM page, you will see the firewall rules that are defined in the file `/etc/nftables/plcnext-filter`. These can be activated by selecting "Start" from the "General Configuration" section on this WBM page.

If Balena does not need network access and only wants to access an application via one port, it is sufficient to simply accept connections on that port.

## Configure ip forwarding

This is normally already set. To check this:

```bash
cat /proc/sys/net/ipv4/ip_forward
# When 0 then
echo 1 > /proc/sys/net/ipv4/ip_forward
```

## balenaEngine firewall settings

**Not necessary since FW2020.6**

The rules are loaded automatically by Balena during boot and start. Alternatively, the rules can be controlled via `/etc/init.d/balenafw`.

For the automatically loaded ruleset see [archive/nftables/balena.nft](../../archive/etc/nftables/balena.nft)

In the `balena.nft` configuration file used to during the installation step, it may be necessary to change the network address in the line `define balena_v4 = 172.18.1.1/24`

Check the inet addr of your network adapter `balena0` using the command `ip address`, and change the network address to suit. For example, if the `balena0` adapter address is `192.168.0.1` with subnetmask `255.255.255.0`, change the line in `balena.nft` to `define balena_v4 = 192.168.0.0/24` .

## Additional ruleset for PLCnext

If more ports are needed for applications or containers, they can be added to the basic rules in `plcnext-filter`. It is also possible to set the port access via Web based management.

> **Notice:** If firewall rules are set using WBM, the file `/etc/nftables/plcnext-filter` is overwritten. All rules in `plcnext-filter` created in Linux will be deleted. The balena rules are not affected.

```bash
# Reload firewall rules:
nft flush ruleset
nft -f <MyFile>

# Reload specific table:
nft flush table <mytable>
nft -f <MyFile>
```

**`/etc/nftables/plcnext-filter`**

```bash
# Example of how to add your own rules
chain basic_filter {
                udp dport 123 accept  comment "NTP (Network Time Protocol)"
                tcp dport 41100 accept  comment "Remoting (e.g. PLCnext Engineer)"
                tcp dport 22 accept  comment "SSH"
                tcp dport <myport> comment "My Docker application Port"
```

Copyright (c) Phoenix Contact Gmbh & Co KG. All rights reserved.

Licensed under the [MIT](LICENSE) License.
