#
# Cookbook Name:: |{ .Cookbook.Name }|
# Recipe :: |{ .Options.Name }|
#
# Copyright |{ .Cookbook.Year}|, Rackspace
#

include_recipe 'chef-sugar'
include_recipe 'nginx'

app_name = |{.QString .Options.Name}|
app_path = File.join(|{.QString .Options.Root}|, |{.QString .Options.Name}|)

deploy_keys = Chef::EncryptedDataBagItem.load('secrets', 'deploy_keys')
|{ if ne .Options.Dbcredentials "" }|
db_credentials = Chef::EncryptedDataBagItem.load(|{.QString .Options.Dbcredentials}|, node.chef_environment)
|{ end }|

|{ if ne .Options.Dbsearch "" }|
db_master = best_ip_for(search(:node, "chef_environment:#{node.chef_environment} AND tags:|{.Options.dbsearch}|").first)
|{ else }|
db_master = |{.QString .Options.Dbmaster}|
|{ end }|

directory '|{.Options.Root}|/.ssh' do
  owner |{.QString .Options.Owner}|
  group |{.QString .Options.Group}|
  mode '0700'
  recursive true
  action :create
end

node.default['python']['version'] = '3'
node.default['python']['pip_location'] = '/usr/local/bin/pip3.4'
node.default['python']['binary'] = "#{node['python']['prefix_dir']}/bin/python3.4"
node.default['nginx']['default_site_enabled'] = false

%w(
  uwsgi
  python
).each do |r|
  include_recipe r
end

application app_name do
  path app_path
  owner |{.QString .Options.Owner}|
  group |{.QString .Options.Group}|
  deploy_key deploy_keys[app_name]
  repository |{.QString .Options.Repo}|
  revision |{.QString .Options.Revision}|
  restart_command do
    service "uwsgi-#{site}" do
      action :restart
      only_if { File.exist? "/etc/init.d/uwsgi-#{site}" }
    end
  end
  migrate |{.Options.Migrate}|
  environment_name node.chef_environment

  django do
    requirements true
    interpreter 'python3'
    packages %(uwsgi django)
    |{ if ne .Options.Dbcredentials "" }|
    database do
      database db_credentials['database']
      username db_credentials['username']
      password db_credentials['password']
    end
    |{ end }|
  end
end

uwsgi_conf = "#{app_name}-uwsgi.ini"
uwsgi_socket = "/tmp/#{app_name}-uwsgi.sock"
uwsgi_conf_path = File.join(node['nginx']['dir'], uwsgi_confi)
template uwsgi_confi_path do
  source "nginx/#{uwsgi_conf}.erb"
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    site_directory: File.join(app_path, 'current'),
    virtual_env: File.join(app_path, 'shared/env'),
    socket: uwsgi_socket,
    user: |{.QString .Options.Owner}|,
    group: |{.QString .Options.Group}|,
    logto: File.join(node['nginx']['log_dir'], "#{app_name}-uwsgi.log"),
    module: "#{app_name}.wsgi"
  )
  notifies :restart, "service[uwsgi-#{app_name}]"
end

uwsgi_service app_name do
  uwsgi_bin File.Join(app_path, 'shared/env/bin/uwsgi')
  pid_path "/var/run/uwsgi-#{site}.pid"
  home_path File.Join(app_path, 'current')
  config_file uwsgi_conf_path
end

template File.join(node['nginx']['dir'], "sites-available", app_name) do
  source "nginx/sites/#{app_name}.erb"
  owner 'root'
  group 'root'
  mode '0644'
  variables(
  |{ if ne .Options.Hostname "" }|
    hostname: |{ .Options.Hostname }|,
  |{ else }|
    hostname: app_name,
  |{ end }|
    error_log: File.join(node['nginx']['log_dir'], "#{app_name}-error.log"),
    access_log: File.join(node['nginx']['log_dir'], "#{app_name}-access.log"),
    app_name: app_name,
    uwsgi_socket: uwsgi_socket
  )
  notifies :reload, 'service[nginx]', :delayed
end

nginx_site app_name do
  enable true
  notifies :reload, 'service[nginx]', :delayed
end

add_iptables_rule('INPUT',
                  '-p tcp --dport 80 -j ACCEPT',
                  70,
                  'allow web browsers to connect')
