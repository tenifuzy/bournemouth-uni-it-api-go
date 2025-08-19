Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"
  config.vm.hostname = "bournemouth-api"
  
  # Network configuration
  config.vm.network "private_network", ip: "192.168.56.10"
  config.vm.network "forwarded_port", guest: 8080, host: 8080
  config.vm.network "forwarded_port", guest: 8081, host: 8081
  config.vm.network "forwarded_port", guest: 8082, host: 8082
  config.vm.network "forwarded_port", guest: 5432, host: 5432
  
  # VM configuration
  config.vm.provider "virtualbox" do |vb|
    vb.name = "bournemouth-uni-api"
    vb.memory = "2048"
    vb.cpus = 2
  end
  
  # Sync project folder
  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"
  
  # Provisioning script
  config.vm.provision "shell", path: "scripts/setup.sh", privileged: false
end