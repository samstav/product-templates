#
# Cookbook Name:: |{.Cookbook.Name}|
# Recipe :: |{ .Options.Name }|
#
# Copyright |{ .Cookbook.Year }|, Rackspace
#

node.default['authorization']['sudo']['passwordless'] = |{ .Options.Sudo }|
node.default['platformstack']['omnibus_updater']['enabled'] = false

include_recipe 'rackops_rolebook::default'
include_recipe 'users::sysadmins'
include_recipe 'sudo::default'
