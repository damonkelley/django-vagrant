# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
PROJECT_NAME = File.basename(Dir.getwd)

VAGRANT_DIR = File.dirname(File.readlink(__FILE__))
VAGRANT_BASENAME = File.basename(VAGRANT_DIR)

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.network :forwarded_port, guest: 8000, host: 8000, auto_correct: true
  config.vm.network "private_network", ip: "192.168.33.10"
  config.vm.hostname = "django-vagrant.dev"
  config.ssh.forward_agent = true
  config.vm.synced_folder ".", "/home/vagrant/#{PROJECT_NAME}", :nfs => true

  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--memory", "1024"]
    v.customize ["modifyvm", :id, "--cpus", "4"]
    v.customize ["modifyvm", :id, "--cpuexecutioncap", "100"]
    v.customize ["modifyvm", :id, "--hwvirtex", "on"]
  end

  config.vm.provision :shell, :path => "#{VAGRANT_DIR}/etc/install/install.sh", :args => [PROJECT_NAME, VAGRANT_BASENAME]
end
