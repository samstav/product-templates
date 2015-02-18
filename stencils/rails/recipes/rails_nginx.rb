#
# Cookbook Name:: |{.Cookbook.Name}|
# Recipe :: |{.Options.Name}|
#
# Copyright |{.Cookbook.Year}|, Rackspace
#

include_recipe 'nginx'
include_recipe 'chef-sugar'
include_recipe '|{.Cookbook.Name}|::_ruby_common'

|{ if ne .Options.Dbcredentials "" }|
db_credentials = Chef::EncryptedDataBagItem.load(|{.QString .Options.Dbcredentials}|, node.chef_environment)
db_master = search(:node, "chef_environment:#{node.chef_environment} AND tags:|{.Options.Dbtype}|_master").first
|{ end }|

app_name = |{.QString .Options.Name}|
app_path = File.join(|{.QString .Options.Root}|, |{.QString .Options.Name}|)

bundle_cmd = File.Join(node['rbenv']['root_path'], 'shims/bundle')
application app_name do
  path app_path
  owner |{.QString .Options.Owner}|
  group |{.QString .Options.Group}|
  repository |{.QString .Options.Repo}|
  revision |{.QString .Options.Revision}|
  migrate |{.Options.Migrate}|
  environment_name node.chef_environment

  rails do
    bundler true
    bundle_command bundle_cmd
    precompile_assets true
    |{ if ne .Options.Dbcredentials "" }|
    database do
      adapter |{.QString .Options.Dbadapter}|
      host best_ip_for(db_master)
      database db_credentials['database']
      username db_credentials['username']
      password db_credentials['password']
    end
    |{ end }|
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
  user |{.QString .Options.Owner}|
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
  user |{.QString .Options.Owner}|
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
    |{if eq .Options.Hostname ""}|
    hostname: app_name,
    |{ else }|
    hostname: |{.QString .Options.Hostname}|
    |{ end }|
    socket: unicorn_socket,
    root: File.join(app_path, current)
  })
end

nginx_site app_name do
  enable true
  notiies :reload, 'service[nginx]'
end
