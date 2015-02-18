#
# Cookbook Name:: |{.Cookbook.Name}|
# Recipe :: |{.Options.Name}|
#
# Copyright |{ .Cookbook.Year }|, Rackspace
#

%w(
  rbenv::default
  rbenv::ruby_build
).each do |r|
  include_recipe r
end

rbenv_ruby |{.QString .Options.Ruby}| do
  global true
end

rbenv_gem 'rake' do
  options('--force')
end

directory File.join(|{.QString .Options.Root}|, '.ssh') do
  owner |{.QString .Options.Owner}|
  group |{.QString .Options.Group}|
  mode 0500
  recursive true
  action :create
end
