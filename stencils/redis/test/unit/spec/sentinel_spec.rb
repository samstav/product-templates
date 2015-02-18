require_relative 'spec_helper'

describe '|{.Cookbook.Name}|::|{.Options.Name}|' do
  let(:chef_run) do
    ChefSpec::Runner.new.converge('|{.Cookbook.Name}|::|{.Options.Name}|')
  end

  it 'includes the redis-multi::sentinel recipe' do
    expect(chef_run).to include_recipe('redis-multi::sentinel')
  end

  it 'includes the redis-multi::sentinel_default recipe' do
    expect(chef_run).to include_recipe('redis-multi::sentinel_default')
  end

  it 'includes the redis-multi::sentinel_enable recipe' do
    expect(chef_run).to include_recipe('redis-multi::sentinel_enable')
  end
end
