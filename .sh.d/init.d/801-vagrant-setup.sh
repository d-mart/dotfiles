
QUICK_VAGRANTFILE=<<EOF
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "trusty64"

  # Disable automatic box update checking. If you disable this, then
  # config.vm.box_check_update = false

  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  #my_large_storage_place = "/path/to/storage"
  #config.vm.provider :virtualbox do |vb|
  #  vb.customize [ "modifyvm", :id, "--memory", 256 ]
  #  vb.customize "pre-import", [ "setproperty", "machinefolder", my_large_storage_place ]
  #  vb.customize "post-boot",  [ "setproperty", "machinefolder", "default" ]
  #end #config.vm.synced_folder "../", "/stuff"

  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.memory = "512"
    vb.cpus = 2
  end

  config.vm.provision "shell", inline: <<-SHELL
    sudo apt-get update
    sudo apt-get install -y openvpn tmux
  SHELL
end

EOF
