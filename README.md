# iscsi-vagrant

Requirements:  
* Virtual box
* Virtual box extentions
* vagrant

Usage
* Create storage base box
  * Start vagrant in storage-base dir by invoking `vagrant up`
  * Package provisioned VM via `vagrant package --out storage-base.box`
  * Remove previous version of the box: `vagrant box remove storage-base`
* Start iscsi targets by invoking commands in the storage dir
  * `vagrant up --no-provision` starts VMs
  * `vagrant up --provision-with cluster-setup` configures corosync and dlm services
  * `vagrant up --provision-with clvm-setup` configures CLVM daemon
  * `vagrant up --provision-with iscsi-setup` configures iSCSI targets
* Start iscsi initiator by invoking `vagrant up` in initiator dir
* Use `vagrant ssh` from any of these dirs to get ssh to specific machine
* Have fun
