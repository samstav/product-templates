#
# Cookbook Name:: |{ cookbook['name'] }|
# Recipe :: |{ options['name'] }|
#
# Copyright |{ cookbook['year'] }|, Rackspace
#

include_recipe 'chef-sugar'
include_recipe 'pg-multi::pg_master'
include_recipe 'postgresql::ruby'

{% if options['database'] != "" %}
{% if options['databag'] != "" %}
pg_creds = Chef::EncryptedDataBagItem.load(
  '|{ options['databag'] }|',
  node.chef_environment
)

pg_user = pg_creds['username']
pg_password = pg_creds['password']
{% else %}
pg_user = |{ qstring(options['user']) }|
pg_password = |{ qstring(options['password']) }|
{% endif %}

conn = {
  host: 'localhost',
  username: 'postgres',
  password: node['postgresql']['password']['postgres']
}

postgresql_database |{ qstring(options['database']) }| do
  connection conn
  action :create
end

postgresql_database_user pg_user do
  connection conn
  action :create
  password pg_password
  database_name |{ qstring(options['database']) }|
  privileges [:all]
end

{% if options['openfor'] != "" %}
{ if options['openfor'] == "environment" }|
openfor = search(:node, "chef_environment:#{node.chef_environment}")
{% elif options['openfor'] == "all" %}
openfor = search(:node, 'nodes:*')
{% else %}
openfor = search(:node, "chef_environment:#{node.chef_environment} AND tags:|{.Options.Openfor}|")
{% endif %}

unless openfor.empty?
  openfor.each do |n|
    node.default['postgresql']['pg_hba'] << {
      comment: "# authorize #{n.name}",
      type: 'host',
      db: |{ qstring(options['database']) }|,
      user: pg_user,
      addr: "#{best_ip_for(n)}/32",
      method: 'md5'
    }
  end
end
{% end %}
{% end %}

{% if options['openfor'] != "" %}
{% if options['openfor'] == "environment" %}
search_add_iptables_rules("chef_environment:#{node.chef_environment}",
                          'INPUT',
                          "-m #{proto} -p #{proto} --dport #{node['postgresql']['config']['port']} -j ACCEPT",
                          9999,
                          'Open port for postgres')
{% elif options['openfor'] == "all" %}
search_add_iptables_rules("nodes:*",
                          'INPUT',
                          "-m #{proto} -p #{proto} --dport #{node['postgresql']['config']['port']} -j ACCEPT",
                          9999,
                          'Open port for postgres')
{% else %}
search_add_iptables_rules("chef_environment:#{node.chef_environment} AND tags:|{ options['openfor'] }|",
                          'INPUT',
                          "-m #{proto} -p #{proto} --dport #{node['postgresql']['config']['port']} -j ACCEPT",
                          9999,
                          'Open port for postgres')
{% end %}
{% end %}
