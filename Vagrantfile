# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'
require 'pp'

settings = YAML.load_file('vagrant.yaml')
nodes = settings["nodes"]

common_files_path = "~/Vagrant/common_files"

common_facter = settings["facter"]

Vagrant.configure("2") do |config|

  config.ssh.insert_key = false

  # Setup common custom synced folders
  if settings.has_key?("synced_folders") && settings["synced_folders"].respond_to?("each")
    settings["synced_folders"].each do |folder|
      config.vm.synced_folder "#{folder["source"]}", "#{folder["target"]}", create: true if folder.has_key?("source") && folder.has_key?("target")
    end
  end

  nodes.each do |node|
    
    environment = node["environment"] ? node["environment"] : "test";
    domain = node["domain"] ? node["domain"] : "test.shandymora.com";
 
    # Configure VirtualBox settings
    config.vm.define node["hostname"] do |node_config|
      node_config.vm.box = node["box"]
      node_config.vm.hostname = node["hostname"] + '.' + domain
      # Setup networking
      node["networks"].each do |network|
        node_config.vm.network :private_network, ip: network["ip"] if network["type"] == "private"
        node_config.vm.network "public_network", ip: network["ip"], bridge: network["interface"] if network["type"] == "public"
#        node_config.vm.network :private_network, ip: network["ip"],
#          virtualbox__intnet: network["name"]
      end

      if node["port_forward"]
	node["port_forward"].each do |forward|
          if forward.has_key?("guest_ip")
            node_config.vm.network :forwarded_port, guest: forward["fwdguest"], host: forward["fwdhost"], guest_ip: forward["guest_ip"]
          else
            node_config.vm.network :forwarded_port, guest: forward["fwdguest"], host: forward["fwdhost"]
          end
	end
      end

      memory = node["ram"] ? node["ram"] : 256;
      cpus = node["cpus"] ? node["cpus"] : 1;

      node_config.vm.provider :virtualbox do |vb|
        vb.customize [
          'modifyvm', :id,
          '--name', node["hostname"],
          '--memory', memory.to_s,
	  '--ioapic', 'on',
          '--cpus', cpus.to_s
        ]
      end
      

      # Insert custom /etc/hosts entries using script
      if node["customhostsfile"]
        node_config.vm.provision "execute sync of custom hosts entries to /etc/hosts", type: "shell" do |s|
          s.path = "build/scripts/customhostsfile.sh"
          s.args = "'#{settings["hostsfile"].join("' '")}'"
        end
      end

      # Update /etc/resolv.conf to use home DNS server
      if node["customresolv"]
        node_config.vm.provision "copy custom resolv.conf to /etc", type: "shell" do |s|
          s.inline = "cp /vagrant/build/files/resolv.conf /etc/"
          s.privileged = true
        end
      end

      # Sync custom repo files
      if node["customrepos"]
        node_config.vm.provision "copy custom repo files to /etc/yum.repo.d", type: "shell" do |s| 
          s.inline = "cp /vagrant/build/files/yum.repos.d/* /etc/yum.repos.d/"
          s.privileged = true
        end
      end

      # Install required packages
      if node["packages"]
        node_config.vm.provision "install required packages", type: "shell", inline: "yum -y install #{node["packages"].join(" ")}"
      end

      # Setup node custom synced folders
      if node.has_key?("synced_folders") && node["synced_folders"].respond_to?("each")
        node["synced_folders"].each do |folder|
          node_config.vm.synced_folder "#{folder["source"]}", "#{folder["target"]}", create: true if folder.has_key?("source") && folder.has_key?("target")
        end
      end

      # Setup node custom synced files
      if node.has_key?("synced_files") && node["synced_files"].respond_to?("each")
        node["synced_files"].each do |file|
          if file.has_key?("source") && file.has_key?("target")
            node_config.vm.provision "sync custom files", type: "shell" do |s| 
              s.inline = "/bin/cp -f /vagrant/#{file["source"]} #{file["target"]}"
              s.privileged = true
            end
          end
        end
      end

      # Flush iptables
      if node["flushiptables"]
        node_config.vm.provision "Flush iptables", type: "shell" do |s|
          s.inline = "iptables -F"
          s.privileged = true
        end
      end
    
      # Run post install script
      if node["postinstall"]
        node_config.vm.provision "execute postinstall script", type: "shell" do |s|
          s.path = "build/scripts/postinstall/#{node["hostname"]}.sh"
        end
      end

      if node["puppet"] 
        # Create facter config
        node_facter = { "environment" => node["environment"] }
        node_facter = node_facter.merge(node["facter"]) if node.has_key?("facter")
        facter = common_facter.merge(node_facter)

        # Install required packages for Puppet
        node_config.vm.provision "install required packages", type: "shell", inline: "yum -y install ruby rubygems puppet"
        node_config.vm.provision "install gem deep_merge", type: "shell" do |s| 
          s.inline = "gem install /vagrant/build/files/puppet/deep_merge-1.0.1.gem"
          s.privileged = true
        end

        node_config.vm.provision "Puppet apply", type: "puppet" do |puppet|
          puppet.environment       = environment 
          puppet.manifests_path    = "puppet/environments/"+environment+"/manifests"
          puppet.module_path       = "puppet/environments/"+environment+"/modules"
          puppet.manifest_file     = "site.pp"
          puppet.hiera_config_path = "puppet/hiera.yaml"
          puppet.options           = "--show_diff"
          puppet.facter            = facter
        end
      end

    end   # End of node_config

  end

end
