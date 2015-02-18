require_relative 'spec_helper'

describe '|{ cookbook['name'] }|::|{ options['name'] }|' do
  let(:chef_run) do
    ChefSpec::Runner.new.converge('|{ cookbook['name'] }|::|{ options['name'] }|')
  end

  it 'includes the nginx recipe' do
    expect(chef_run).to include_recipe('nginx')
  end

  ##TODO: Add application tests
  ##TODO: Add uwsgi tests
end
