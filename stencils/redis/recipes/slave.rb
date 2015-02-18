#
# Cookbook Name:: |{ .Cookbook.Name }|
# Recipe :: |{ .Options.Name }|
#
# Copyright |{ .Cookbook.Year }|, Rackspace
#

include_recipe 'redis-multi::slave'
include_recipe 'redis-multi'
include_recipe 'redis-multi::enable'

|{ if ne .Options.Openfor "" }|
|{ template "Iptables" . }|
|{ end }|

search_add_iptables_rules("tags:redis AND chef_environment:#{node.chef_environment}",
                          'INPUT',
                          "-m tcp -p tcp --dport #{node['redis-multi']['bind_port']} -j ACCEPT",
                          9999,
                          'Open port for redis')
