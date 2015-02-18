#
# Cookbook Name:: |{ .Cookbook.Name }|
# Recipe :: |{ .Options.Name }|
#
# Copyright |{ .Cookbook.Year }|, Rackspace
#

include_recipe 'memcached'

|{ if ne .Options.Openfor "" }|
%w(udp tcp).each do |proto|
|{ if eq .Options.Openfor "environment" }|
  search_add_iptables_rules("chef_environment:#{node.chef_environment}",
                            'INPUT',
                            "-m #{proto} -p #{proto} --dport #{node['memcached']['port']} -j ACCEPT",
                            9999,
                            'Open port for memcached')
|{ else if eq .Options.Openfor "all" }|
  search_add_iptables_rules("nodes:*",
                            'INPUT',
                            "-m #{proto} -p #{proto} --dport #{node['memcached']['port']} -j ACCEPT",
                            9999,
                            'Open port for memcached')
|{ else }|
  search_add_iptables_rules("chef_environment:#{node.chef_environment} AND tags:|{.Options.Openfor}|",
                            'INPUT',
                            "-m #{proto} -p #{proto} --dport #{node['memcached']['port']} -j ACCEPT",
                            9999,
                            'Open port for memcached')
|{ end }|
end
|{ end }|
