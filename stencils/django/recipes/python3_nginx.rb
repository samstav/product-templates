#
# Cookbook Name:: |{ cookbook['name'] }|
# Recipe :: |{ options['name'] }|
#
# Copyright |{ cookbook['year'] }|, Rackspace
#

include_recipe 'chef-sugar'
include_recipe 'nginx'

app_name = |{ qstring(options['name']) }|
app_path = File.join(|{ qstring(options['root']) }|, |{ qstring(options['name'])}|)

deploy_keys = Chef::EncryptedDataBagItem.load('secrets', 'deploy_keys')
{% if options['dbcredentials'] != "" %}
db_credentials = Chef::EncryptedDataBagItem.load(|{ qstring(options['dbcredentials']) }|, node.chef_environment)
{% endif %}

{% if .Options.Dbsearch != "" %}
db_master = best_ip_for(search(:node, "chef_environment:#{node.chef_environment} AND tags:|{ options['dbsearch'] }|").first)
{% else %}
db_master = |{ qstring(options['dbmaster']) }|
{% endif %}

directory '|{ options['root'] }|/.ssh' do
  owner |{ qstring(options['owner']) }|
  group |{ qstring(options['group']) }|
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
  owner |{ qstring(options['owner']) }|
  group |{ qstring(options['group']) }|
  deploy_key deploy_keys[app_name]
  repository |{ qstring(options['repo']) }|
  revision |{ qstring[options['revision']) }|
  restart_command do
    service "uwsgi-#{site}" do
      action :restart
      only_if { File.exist? "/etc/init.d/uwsgi-#{site}" }
    end
  end
  migrate |{ options['migrate'] }|
  environment_name node.chef_environment

  django do
    requirements true
    interpreter 'python3'
    packages %(uwsgi django)
    {% if options['dbcredentials'] != "" %}
    database do
      database db_credentials['database']
      username db_credentials['username']
      password db_credentials['password']
    end
    {% end %}
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
    user: |{ qstring(options['owner']) }|,
    group: |{ qstring(options['group']) }|,
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
  {% if options['hostname'] != "" %}
    hostname: |{ options['hostname'] }|,
  {% else %}
    hostname: app_name,
  {% endif %}
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
