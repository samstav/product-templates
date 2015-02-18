|{ define "Iptables" }|
|{ if eq .Options.Openfor "environment" }|
search_add_iptables_rules("chef_environment:#{node.chef_environment}",
                          'INPUT',
                          "-m tcp -p tcp --dport #{node['redis-multi']['bind-port']} -j ACCEPT",
                          9999,
                          'Open port for redis')
|{ else if eq .Options.Openfor "all" }|
search_add_iptables_rules("nodes:*",
                          'INPUT',
                          "-m tcp -p tcp --dport #{node['redis-multi']['bind-port']} -j ACCEPT",
                          9999,
                          'Open port for redis')
|{ else }|
search_add_iptables_rules("chef_environment:#{node.chef_environment} AND tags:|{.Options.Openfor}|",
                          'INPUT',
                          "-m tcp -p tcp --dport #{node['redis-multi']['bind-port']} -j ACCEPT",
                          9999,
                          'Open port for redis')
|{ end }|
|{ end }|
