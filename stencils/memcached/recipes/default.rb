#
# Cookbook Name:: |{ cookbookd['name'] }|
# Recipe :: |{ options['name'] }|
#
# Copyright |{ cookbook['year'] }|, Rackspace
#

include_recipe 'memcached'

{% if options['openfor'] != "" %}
%w(udp tcp).each do |proto|
{% if options['openfor'] == "environment" %}
  search_add_iptables_rules("chef_environment:#{node.chef_environment}",
                            'INPUT',
                            "-m #{proto} -p #{proto} --dport #{node['memcached']['port']} -j ACCEPT",
                            9999,
                            'Open port for memcached')
{% elif options['openfor'] == "all" %}
  search_add_iptables_rules("nodes:*",
                            'INPUT',
                            "-m #{proto} -p #{proto} --dport #{node['memcached']['port']} -j ACCEPT",
                            9999,
                            'Open port for memcached')
{% else %}
  search_add_iptables_rules("chef_environment:#{node.chef_environment} AND tags:|{ options['openfor'] }|",
                            'INPUT',
                            "-m #{proto} -p #{proto} --dport #{node['memcached']['port']} -j ACCEPT",
                            9999,
                            'Open port for memcached')
{% end %}
end
{% end %}
