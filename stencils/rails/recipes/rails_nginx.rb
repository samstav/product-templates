#
# Cookbook Name:: |{ cookbook['name']} |
# Recipe :: |{ options['name'] }|
#
# Copyright |{ cookbook['year'] }|, Rackspace
#

include_recipe 'nginx'
include_recipe 'chef-sugar'
include_recipe '|{ cookbook['name'] }|::_ruby_common'

{% if options['dbcredentials'] != "" %}
db_credentials = Chef::EncryptedDataBagItem.load(|{ qstring(options['dbcredentials']) }|, node.chef_environment)
db_master = search(:node, "chef_environment:#{node.chef_environment} AND tags:|{ options['dbtype'] }|_master").first
{% endif %}

app_name = |{ qstring(options['name']) }|
app_path = File.join(|{ qstring(options['root']) }|, |{ qstring(options['name']) }|)

bundle_cmd = File.Join(node['rbenv']['root_path'], 'shims/bundle')
application app_name do
  path app_path
  owner |{ qstring(options['owner']) }|
  group |{ qstring(options['group']) }|
  repository |{ qstring(options['repo']) }|
  revision |{ qstring(options['revision']) }|
  migrate |{ options['migrate'] }|
  environment_name node.chef_environment

  rails do
    bundler true
    bundle_command bundle_cmd
    precompile_assets true
    {% if options['dbcredentials'] != "" %}
    database do
      adapter |{ qstring(options['dbadapter']) }|
      host best_ip_for(db_master)
      database db_credentials['database']
      username db_credentials['username']
      password db_credentials['password']
    end
    {% endif %}
  end

  create_dirs_before_symlink %w(tmp tmp/cache)
  restart_command do
    service "unicorn-#{app_name}" do
      action :restart
      only_if { File.exist?("/etc/init.d/unicorn-#{app_name}") }
    end
  end
end

unicorn_socket = "unix:/tmp/unicorn-#{app_name}.sock"
unicorn_ng_config File.join(app_path, 'current/config/unicorn.rb') do
  worker_processes 4
  user |{ qstring(options['owner']) }|
  working_directory File.join(app_path, 'current')
  listen unicorn_socket
  pid "/tmp/unicorn-#{app_name}.pid"
  after_fork <<-EOS
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
  EOS
end

unicorn_ng_service File.join(app_path, 'current') do
  service_name "unicorn-#{app_name}"
  config File.join(app_path, 'current/config/unicorn.rb')
  environment node.chef_environment
  user |{ qstring(options['owner']) }|
  bundle bundle_cmd
  pidfile "/tmp/unicorn-#{app_name}.pid"
end

template app_name do
  source "#{app_name}-nginx-conf.erb"
  owner 'root'
  group 'root'
  mode 0644
  variables({
    app_name: app_name,
    {% if options['hostname'] == "" %}
    hostname: app_name,
    {% else %}
    hostname: |{ qstring(options['hostname']) }|
    {% endif %}
    socket: unicorn_socket,
    root: File.join(app_path, current)
  })
end

nginx_site app_name do
  enable true
  notiies :reload, 'service[nginx]'
end
