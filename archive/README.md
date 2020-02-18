# Additional Information 

## Balena daemon config

In order for Balena to start on the PLCnext device, the configuration of Balena must be adjusted.

Balena daemon configuration in `/etc/balena-engine/daemon.json`:

```json
{
  "data-root": "/media/rfs/rw/var/lib/balena",
  "storage-driver": "overlay2",
  "iptables": false
}
```

## Nftables

Configure ip forwarding. It is normally already set.

```bash
cat /proc/sys/net/ipv4/ip_forward
# When 0 then
echo 1 > /proc/sys/net/ipv4/ip_forward
```

Load new firewalls rules:

```bash
nft -f MyFile
```

The configuration allows the OCI container network to be accessed. The example shows only the settings for Balena, for PLCnext, ssh, web etc... the table `plcnext-filter` must be loaded additionally. The easiest way is to activate the firewall via WBM.

If Balena does not need network access and only wants to access a application via one port, it is sufficient to release the port.

Additional ruleset for PLCnext. The rules are loaded automatically by Balena during boot and start. Alternatively, the rules can be controlled via  `/etc/init.d/balenafw`.

Ruleset see `nftables/balena.nft`

If more ports are needed for applications or containers, they can be added to the basic rules in `plcnext-filter`.
It is also possible to set the port releases via Web based management.

**Notice: If firewall rules are set using WBM, the file `plcnext-filter` is overwritten. All rules in `plcnext-filter` created in Linux will be deleted. The docker rules are not affected.**

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
# Create own rules
chain basic_filter {
                udp dport 123 accept  comment "NTP (Network Time Protocol)"
                tcp dport 41100 accept  comment "Remoting (e.g. PLCnext Engineer)"
                tcp dport 22 accept  comment "SSH"
                tcp dport <myport> comment "My Docker applikation Port"
```
