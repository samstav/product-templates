require_relative 'spec_helper'

describe '|{.Cookbook.Name}|::|{.Options.Name}|' do
  let(:chef_run) do
    ChefSpec::Runner.new.converge('|{.Cookbook.Name}|::|{.Options.Name}|')
  end

  it 'includes the rackops_rolebook default recipe' do
    expect(chef_run).to include_recipe('rackops_rolebook::default')
  end

  it 'includes the users sysadmins recipe' do
    expect(chef_run).to include_recipe('users::sysadmins')
  end

  it 'includes the sudo default recipe' do
    expect(chef_run).to include_recipe('sudo::default')
  end
end
