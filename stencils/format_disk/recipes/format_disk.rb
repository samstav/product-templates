#
# Cookbook Name:: |{.Cookbook.Name}|
# Recipe :: |{.Options.Name}|
#
# Copyright |{ .Cookbook.Year }|, Rackspace
#

filesystem '|{.Options.Label}|' do
  fstype '|{.Options.Fstype}|'
  device '|{.Options.Device}|'
  mount '|{.Options.Mount}|'
  action '|{.Options.Action}|'
end
