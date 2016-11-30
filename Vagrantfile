# -*- mode: ruby -*-
# vi: set ft=ruby :

disk_size = 5 * 1024

file_root = File.dirname(File.expand_path(__FILE__))

$nvme_disks = {
    File.join(file_root, "nvme0.vdi") => "0",
    File.join(file_root, "nvme1.vdi") => "1"
}

$disk_size = disk_size.to_s

class VagrantPlugins::ProviderVirtualBox::Action::SetName
    alias_method :original_call, :call
    def call(env)
        ui = env[:ui]
        controller_name = "NVMe"
        driver = env[:machine].provider.driver
        uuid = driver.instance_eval { @uuid }
        vm_info = driver.execute("showvminfo", uuid)
        has_controller = vm_info.match("Storage Controller Name.*#{controller_name}")

        if !has_controller
            ui.info "Creating storage controller '#{controller_name}'..."
            driver.execute(
                "storagectl", uuid,
                "--name", "#{controller_name}",
                "--add", "pcie",
                "--controller", "NVMe",
                "--portcount", "2",
                "--hostiocache", "off"
            )
        end

        $nvme_disks.each do |disk_file, port|
            if !File.exist?(disk_file)
                ui.info "Creating storage file '#{disk_file}'..."
                driver.execute(
                  "createmedium", "disk",
                  "--filename", disk_file,
                  "--format", "VDI",
                  "--size", $disk_size
                )
            end

            ui.info "Attaching '#{disk_file}' to '#{controller_name}'..."
            driver.execute(
                "storageattach", uuid,
                "--storagectl", "#{controller_name}",
                "--port", port,
                "--device", "0",
                "--type", "hdd",
                '--nonrotational', 'on',
                "--medium", disk_file
            )
        end
        original_call(env)
    end
end

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "ubuntu/xenial64"
  config.vm.box_check_update = true

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: "10.0.1.100"
  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    vb.gui = false
    vb.name = "iscsi-target"
    vb.memory = "1024"
  end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "shell", inline: <<-SHELL
    locale-gen
    sudo apt-get update && apt-get install -y targetcli

    sudo lvm vgcreate nvmegroup /dev/nvme0n1 /dev/nvme0n2
    sudo lvm lvcreate nvmegroup -L 3G
    sudo lvm lvcreate nvmegroup -L 3G
    sudo lvm lvcreate nvmegroup -L 3G

    sudo targetcli /backstores/iblock create name=lvol0 dev=/dev/nvmegroup/lvol0
    sudo targetcli /backstores/iblock create name=lvol1 dev=/dev/nvmegroup/lvol1
    sudo targetcli /backstores/iblock create name=lvol2 dev=/dev/nvmegroup/lvol2

    sudo targetcli /iscsi create | tee iscsi_create_output
    WWN=$(cat iscsi_create_output | head -n 1 | sed -e 's/Created target //' | sed -e 's/.$//')
    rm iscsi_create_output

    sudo targetcli /iscsi/${WWN}/tpg1 set attribute authentication=0 demo_mode_write_protect=0 generate_node_acls=1 cache_dynamic_acls=1

    sudo targetcli /iscsi/${WWN}/tpg1/portals create ip_address=10.0.1.100

    sudo targetcli /iscsi/${WWN}/tpg1/luns create storage_object=/backstores/iblock/lvol0
    sudo targetcli /iscsi/${WWN}/tpg1/luns create storage_object=/backstores/iblock/lvol1
    sudo targetcli /iscsi/${WWN}/tpg1/luns create storage_object=/backstores/iblock/lvol2

    yes | sudo targetcli saveconfig
  SHELL
end
