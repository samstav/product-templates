#
# Cookbook Name:: |{ cookbook['name'] }|
# Recipe :: |{ options['name'] }|
#
# Copyright |{ cookbook['year'] }|, Rackspace
#

include_recipe 'redis-multi'
include_recipe 'redis-multi::enable'
include_recipe 'redis-multi::single'

{% if options['openfor'] != "" %}
{% if options['openfor'] == "environment" %}
search_add_iptables_rules("chef_environment:#{node.chef_environment}",
                          'INPUT',
                          "-m tcp -p tcp --dport #{node['redis-multi']['bind-port']} -j ACCEPT",
                          9999,
                          'Open port for redis')
{% elif options['openfor'] == "all" %}
search_add_iptables_rules("nodes:*",
                          'INPUT',
                          "-m tcp -p tcp --dport #{node['redis-multi']['bind-port']} -j ACCEPT",
                          9999,
                          'Open port for redis')
{% else %}
search_add_iptables_rules("chef_environment:#{node.chef_environment} AND tags:|{ options['openfor'] }|",
                          'INPUT',
                          "-m tcp -p tcp --dport #{node['redis-multi']['bind-port']} -j ACCEPT",
                          9999,
                          'Open port for redis')
{% endif %}
{% endif %}
