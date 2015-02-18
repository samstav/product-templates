require_relative 'spec_helper'

describe '|{ cookbook['name'] }|::|{ options['name'] }|' do
  let(:chef_run) do
    ChefSpec::Runner.new.converge('|{ cookbook['name'] }|::|{ options['name'] }|')
  end

  it 'includes the chef-sugar recipe' do
    expect(chef_run).to include_recipe('chef-sugar')
  end

  it 'includes the rabbitmq recipe' do
    expect(chef_run).to include_recipe('rabbitmq')
  end
end
