# vagrant_template_vb
Template for deploying Vagrant VM's via a yaml config file.  This is built primarily for deploying CentOS images.

1.  [Configuration](#configuration)

## Configuration

*  hostsfile

   This is an array of entries to be added to /etc/hosts.  Any existing entries will be unaffected.  Config 
here will only take effect if the key nodes[customhostsfile] is _true_.

```
hostsfile:
  - "172.16.32.10    server01.test.shandymora.com    server01"
  - "172.16.32.11    server02.test.shandymora.com    server02"   

```

*  synced_folders

   This is an array of hashes.  Each hash should contain two keys, _source_ and _target_.  _Source_ can
be either a relative or absolute path.  _Traget_ should be absolute from the perspective of the guest.


```
synced_folders:
  - source: "~/Vagrant/common_files/environments"
    target: "/vagrant/environments"
```

*  nodes
   
   An array of hashes, each one describing a specific guest VM.

  *  hostname (String)

     The hostname of the guest, the VirtualBox machine will also be assigned this name.

  *  networks (Array)

     A list of hashes describing a network interface.

     *  ip          (String) The ip address to assign to this host.
     *  type        (String) Can be either _public_ or _private_.
     *  interface   (Optional String) If _type_ is _public_ then what physcial interface of the host to bridge.

  *  box (String)

     What VirtualBox image to use.

  *  domain (String)

     The domain name of the build environment.

  *  environment (String)

     Used when provisioning via Puppet apply.

  *  ram (Integer)

     How much memory in MB to assign to teh guest.

  *  puppet (Boolean)

     To provision using the Puppet apply provisioner.
 
  *  hostmanager (Boolean)

     Manage /etc/hosts files using the hostmanager VirtualBox plugin.

  *  customhostsfile (Boolean)

     Whether to added custom host entries defined in key _hostsfile_.

  *  customresolv (Boolean)

     If set then the resolv.conf file in build/files/resolv.conf is copied to the guest.

  *  customrepos (Boolean)

     If set then all yum repo files defined in build/files/yum.repos.d/ are synced to the guest at /etc/yum.repos.d/

  *  packages (Array)

     A list of packages to install

  *  flushiptables (Boolean)

     Clear any iptables rules.

  *  port_forward (Array)

     A list of hashes, each one defining two keys, _fwdguest_ and _fwdhost_.

     *  fwdguest (Integer)  The port on the guest to forward traffic to.
     *  fwdhost (Integer)   The port on the host to listen on.

  *  synced_folders (Array)

     This is an array of hashes.  Each hash should contain two keys, _source_ and _target_.  _Source_ can
be either a relative or absolute path.  _Target_ should be absolute from the perspective of the guest.


```
synced_folders:
  - source: "~/Vagrant/common_files/environments"
    target: "/vagrant/environments"
```

  *  synced_files (Array)

     This is an array of hashes.  Each hash should contain two keys, _source_ and _target_.  _Source_ can
be either a relative or absolute path.  _Target_ should be absolute from the perspective of the guest.

```
synced_files:
  - source: "build/files/example_role/synced_file.txt"
    target: "/tmp/synced_file"
```

  *  postinstall (Boolean)

     Whether to run a post installation script after provisioning.  The script is named from the _hostname_ key and is located 
at build/scripts/postinstall/ 

  *  facter (Hash)

     Any additional facts that need to be pased to the Puppet apply provisioner.

