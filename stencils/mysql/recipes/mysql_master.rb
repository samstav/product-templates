#
# Cookbook Name:: |{ .Cookbook.Name }|
# Recipe :: |{ .Options.Name }|
#
# Copyright |{ .Cookbook.Year }|, Rackspace
#

include_recipe 'mysql-multi::mysql-master'
include_recipe 'database::mysql'

|{ if ne .Options.Database ""}|
conn = {
  host: 'localhost',
  username: 'root',
  password: node['mysql']['server_root_password']
}

|{ if ne .Options.Databag "" }|
mysql_creds = Chef::EncryptedDataBagItem.load(
  '|{ .Options.Databag }|',
  node.chef_environment
)

mysql_database |{ .QString .Options.Database }| do
  connection conn
  action :create
end

mysql_database_user mysql_creds['username'] do
  connection conn
  password mysql_creds['password']
  database_name |{ .QString .Options.Database }|
  action :create
end
|{ else }|
mysql_database |{ .QString .Options.Database }| do
  connection conn
  action :create
end

mysql_database_user |{ .Options.User }| do
  connection conn
  password |{ .Options.Password }|
  database_name |{ .QString .Options.Database }|
  action :create
end
|{ end }|
|{ end }|

|{ if ne .Options.Openfor "" }|
|{ if eq .Options.Openfor "environment" }|
search_add_iptables_rules("chef_environment:#{node.chef_environment}",
                          'INPUT',
                          "-m #{proto} -p #{proto} --dport #{node['mysql']['port']} -j ACCEPT",
                          9999,
                          'Open port for Mysql')
|{ else if eq .Options.Openfor "all" }|
search_add_iptables_rules("nodes:*",
                          'INPUT',
                          "-m #{proto} -p #{proto} --dport #{node['mysql']['port']} -j ACCEPT",
                          9999,
                          'Open port for Mysql')
|{ else }|
search_add_iptables_rules("chef_environment:#{node.chef_environment} AND tags:|{.Options.Openfor}|",
                          'INPUT',
                          "-m #{proto} -p #{proto} --dport #{node['mysql']['port']} -j ACCEPT",
                          9999,
                          'Open port for Mysql')
|{ end }|
|{ end }|
