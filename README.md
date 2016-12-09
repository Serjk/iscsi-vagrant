# iscsi-vagrant

Requirements:  
* Virtual box
* Virtual box extentions
* vagrant

Usage
* Create storage base box
  * Start vagrant in storage-base dir by invoking `vagrant up`
  * Package provisioned VM via `vagrant package --out storage-base.box`
* Start iscsi targets by invoking `vagrant up` in storage dir
  * You may need to remove previously imported storage-base box from vagrant: `vagrant box remove storage-base`
* Start iscsi initiator by invoking the same in initiator dir
* Use `vagrant ssh` from any of these dirs to get ssh to specific machine
* Have fun
