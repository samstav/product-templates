#
# Cookbook Name:: |{.Cookbook.Name}|
# Recipe :: |{.Options.Name}|
#
# Copyright |{ .Cookbook.Year }|, Rackspace
#

include_recipe 'chef-sugar'

tag '|{.Options.Clustertag}|'

node.default['rabbitmq']['use_distro_version'] = true
node.default['rabbitmq']['port'] = '5672' if node['rabbitmq']['port'].nil?

|{ if eq .Options.Cluster "true" }|
rabbit_nodes = search(:node, "chef_environment:#{node.chef_environment} AND tags:|{.Options.Clustertag}| AND NOT name:#{node.name}")

cluster_nodes = []
rabbit_nodes.each do |rabbit_node|
  node_ip = best_ip_for(rabbit_node)
  cluster_nodes.push "rabbit@#{node_ip}"
  add_iptables_rules('INPUT', "-s #{node_ip} -j ACCEPT", 70, 'rabbitmq cluster access')
end

node.default['rabbitmq']['cluster'] = true
node.default['rabbitmq']['cluster_disk_nodes'] = cluster_nodes
|{ end }|

include_recipe 'rabbitmq'

|{ if ne .Options.Openfor "" }|
search_add_iptables_rules("chef_environment:#{node.chef_environment} AND tags:|{.Options.Openfor}|", 'INPUT', "-p tcp --dport #{node['rabbitmq']['port']} -j ACCEPT", 70, 'access to rabbitmq')
|{ end }|
