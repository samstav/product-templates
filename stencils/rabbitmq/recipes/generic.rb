#
# Cookbook Name:: |{ cookbook['name'] }|
# Recipe :: |{ options['name'] }|
#
# Copyright |{ cookbook['year'] }|, Rackspace
#

include_recipe 'chef-sugar'

tag '|{ options['clustertag'] }|'

node.default['rabbitmq']['use_distro_version'] = true
node.default['rabbitmq']['port'] = '5672' if node['rabbitmq']['port'].nil?

{% if options['cluster'] == "true" %}
rabbit_nodes = search(:node, "chef_environment:#{node.chef_environment} AND tags:|{ options['clustertag'] }| AND NOT name:#{node.name}")

cluster_nodes = []
rabbit_nodes.each do |rabbit_node|
  node_ip = best_ip_for(rabbit_node)
  cluster_nodes.push "rabbit@#{node_ip}"
  add_iptables_rules('INPUT', "-s #{node_ip} -j ACCEPT", 70, 'rabbitmq cluster access')
end

node.default['rabbitmq']['cluster'] = true
node.default['rabbitmq']['cluster_disk_nodes'] = cluster_nodes
{i% end %}

include_recipe 'rabbitmq'

{% if options['openfor'] != "" %}
search_add_iptables_rules("chef_environment:#{node.chef_environment} AND tags:|{ options['openfor'] }|",
                          'INPUT',
                          "-p tcp --dport #{node['rabbitmq']['port']} -j ACCEPT",
                          70,
                          ['access to rabbitmq')
{% end %}
