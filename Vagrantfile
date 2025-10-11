# Vagrantfile for setting up a development environment for the student API server
# This configuration uses Ubuntu 24.04 LTS and sets up port forwarding for the application.
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"  # Ubuntu 24.04 LTS
  config.vm.hostname = "student-api-server"
  
  # Network configuration
  config.vm.network "forwarded_port", guest: 8080, host: 8080
  config.vm.network "forwarded_port", guest: 8081, host: 8081
  config.vm.network "forwarded_port", guest: 8082, host: 8082
  
  # VM configuration
  config.vm.provider "virtualbox" do |vb|
    vb.name = "bournemouth-students-api"
    vb.memory = "2048"
    vb.cpus = 2
    vb.gui = false
    config.vm.boot_timeout = 600  # Increase timeout to 10 minutes
  end
  
  # Sync project folder
  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"
  
  # Provisioning script
  config.vm.provision "shell", path: "vagrant/provision.sh"
  
  # Deploy application
  config.vm.provision "shell", inline: <<-SHELL
    cd /vagrant
    make vagrant-deploy
  SHELL
end