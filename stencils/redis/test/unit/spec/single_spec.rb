require_relative 'spec_helper'

describe '|{.Cookbook.Name}|::|{.Options.Name}|' do
  let(:chef_run) do
    ChefSpec::Runner.new.converge('|{.Cookbook.Name}|::|{.Options.Name}|')
  end

  it 'includes the redis-multi recipe' do
    expect(chef_run).to include_recipe('redis-multi')
  end

  it 'includes the redis-multi::enable recipe' do
    expect(chef_run).to include_recipe('redis-multi::enable')
  end

  it 'includes the redis-multi::single recipe' do
    expect(chef_run).to include_recipe('redis-multi::single')
  end
end
