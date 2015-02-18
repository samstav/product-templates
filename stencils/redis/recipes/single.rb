#
# Cookbook Name:: |{ .Cookbook.Name }|
# Recipe :: |{ .Options.Name }|
#
# Copyright |{ .Cookbook.Year }|, Rackspace
#

include_recipe 'redis-multi'
include_recipe 'redis-multi::enable'
include_recipe 'redis-multi::single'

|{ if ne .Options.Openfor "" }|
|{ template "Iptables" . }|
|{ end }|
