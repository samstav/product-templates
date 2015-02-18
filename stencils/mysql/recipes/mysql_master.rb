#
# Cookbook Name:: |{ cookbook['name'] }|
# Recipe :: |{ options['name'] }|
#
# Copyright |{ cookbook['year'] }|, Rackspace
#

include_recipe 'mysql-multi::mysql-master'
include_recipe 'database::mysql'

{% if options['database'] != "" %}
conn = {
  host: 'localhost',
  username: 'root',
  password: node['mysql']['server_root_password']
}

{% if options['databag'] != "" %}
mysql_creds = Chef::EncryptedDataBagItem.load(
  '|{ options['databag'] }|',
  node.chef_environment
)

mysql_database |{ qstring(options['database']) }| do
  connection conn
  action :create
end

mysql_database_user mysql_creds['username'] do
  connection conn
  password mysql_creds['password']
  database_name |{ qstring(options['database']) }|
  action :create
end
{% else %}
mysql_database |{ qstring(options['database']) }| do
  connection conn
  action :create
end

mysql_database_user |{ options['user'] }| do
  connection conn
  password |{ options['password'] }|
  database_name |{ qstring(options['database']) }|
  action :create
end
{% endif %}
{% endif %}

{% if .options['openfor'] != "" %}
{% if options['openfor'] == "environment" }|
search_add_iptables_rules("chef_environment:#{node.chef_environment}",
                          'INPUT',
                          "-m #{proto} -p #{proto} --dport #{node['mysql']['port']} -j ACCEPT",
                          9999,
                          'Open port for Mysql')
{% elif options['openfor'] == "all" %}
search_add_iptables_rules("nodes:*",
                          'INPUT',
                          "-m #{proto} -p #{proto} --dport #{node['mysql']['port']} -j ACCEPT",
                          9999,
                          'Open port for Mysql')
{% else %}
search_add_iptables_rules("chef_environment:#{node.chef_environment} AND tags:|{ options['openfor'] }|",
                          'INPUT',
                          "-m #{proto} -p #{proto} --dport #{node['mysql']['port']} -j ACCEPT",
                          9999,
                          'Open port for Mysql')
{% endif %}
{% endif %}
