#
# Cookbook Name:: |{ .Cookbook.Name }|
# Recipe :: |{ .Options.Name }|
#
# Copyright |{ .Cookbook.Year }|, Rackspace
#
newrelic_key = Chef::EncryptedDataBagItem.load(|{ .QString .Options.Databag }|, 'newrelic')
node.default['newrelic']['license'] = newrelic_key['key']

include_recipe 'newrelic::default'
