require_relative 'spec_helper'

describe '|{ cookbook['name'] }|::|{ options['name'] }|' do
  let(:chef_run) do
    ChefSpec::Runner.new.converge('|{ cookbook['name'] }|::|{ options['name'] }|')
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
