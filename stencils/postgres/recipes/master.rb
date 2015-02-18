#
# Cookbook Name:: |{ .Cookbook.Name }|
# Recipe :: |{ .Options.Name }|
#
# Copyright |{ .Cookbook.Year }|, Rackspace
#

include_recipe 'chef-sugar'
include_recipe 'pg-multi::pg_master'
include_recipe 'potgresql::ruby'

|{ if ne .Options.Database "" }|
|{ if ne .Options.Databag "" }|
pg_creds = Chef::EncryptedDataBagItem.load(
  '|{.Options.Databag}|',
  node.chef_environment
)

pg_user = pg_creds['username']
pg_password = pg_creds['password']
|{ else }|
pg_user = |{ .QString .Options.User }|
pg_password = |{ .QString .Options.Password }|
|{ end }|

conn = {
  host: 'localhost',
  username: 'postgres',
  password: node['postgresql']['password']['postgres']
}

postgresql_database |{ .QString .Options.Database }| do
  connection conn
  action :create
end

postgresql_database_user pg_user do
  connection conn
  action :create
  password pg_password
  database_name |{ .QString .Options.Database }|
  privileges [:all]
end

|{ if ne .Options.Openfor "" }|
|{ if eq .Options.Openfor "environment" }|
openfor = search(:node, "chef_environment:#{node.chef_environment}")
|{ else if eq .Options.Openfor "all" }|
openfor = search(:node, 'nodes:*')
|{ else }|
openfor = search(:node, "chef_environment:#{node.chef_environment} AND tags:|{.Options.Openfor}|")
|{ end }|

unless openfor.empty?
  openfor.each do |n|
    node.default['postgresql']['pg_hba'] << {
      comment: "# authorize #{n.name}",
      type: 'host',
      db: |{ .QString .Options.Database }|,
      user: pg_user,
      addr: "#{best_ip_for(n)}/32",
      method: 'md5'
    }
  end
end
|{ end }|
|{ end }|

|{ if ne .Options.Openfor "" }|
|{ if eq .Options.Openfor "environment" }|
search_add_iptables_rules("chef_environment:#{node.chef_environment}",
                          'INPUT',
                          "-m #{proto} -p #{proto} --dport #{node['postgresql']['config']['port']} -j ACCEPT",
                          9999,
                          'Open port for postgres')
|{ else if eq .Options.Openfor "all" }|
search_add_iptables_rules("nodes:*",
                          'INPUT',
                          "-m #{proto} -p #{proto} --dport #{node['postgresql']['config']['port']} -j ACCEPT",
                          9999,
                          'Open port for postgres')
|{ else }|
search_add_iptables_rules("chef_environment:#{node.chef_environment} AND tags:|{.Options.Openfor}|",
                          'INPUT',
                          "-m #{proto} -p #{proto} --dport #{node['postgresql']['config']['port']} -j ACCEPT",
                          9999,
                          'Open port for postgres')
|{ end }|
|{ end }|
