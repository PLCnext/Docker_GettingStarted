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

Copyright (c) Phoenix Contact Gmbh & Co KG. All rights reserved.

Licensed under the [MIT](LICENSE) License.
