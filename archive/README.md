# Additional Information

## Container daemon config

In order for Balena to start on the PLCnext device, the configuration of Balena must be adjusted.

Container daemon configuration in `/etc/<container runtime>/daemon.json`:

```json
{
  "data-root": "/media/rfs/rw/var/lib/balena",
  "storage-driver": "overlay2",
  "iptables": true
}
```

Copyright (c) Phoenix Contact Gmbh & Co KG. All rights reserved.

Licensed under the [MIT](LICENSE) License.
