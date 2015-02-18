#
# Cookbook Name:: |{ .Cookbook.Name }|
# Recipe :: |{ .Options.Name }|
#
# Copyright |{ .Cookbook.Year }|, Rackspace
#

deploy_dir = '/usr/local/rspace_devops'

directory deploy_dir do
  action :create
  mode 0755
end

%w(
  deploy_flag.json
  deploy_app.sh
).each do |f|
  cookbook_file File.join(deploy_dir, f) do
    action :create
    source f
    mode 0755
  end
end
