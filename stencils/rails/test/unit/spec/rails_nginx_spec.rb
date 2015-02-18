require_relative 'spec_helper'

describe '|{ cookbook['name'] }|::|{ options['name'] }|' do
  let(:chef_run) do
    ChefSpec::Runner.new.converge('|{ cookbook['name'] }|::|{ options['name'] }|')
  end

  it 'includes the nginx recipe' do
    expect(chef_run).to include_recipe('nginx')
  end

  it 'includes the |{ cookbook['name'] }|::_ruby_common recipe' do
    expect(chef_run).to include_recipe('|{ cookbook['name'] }|::_ruby_common')
  end

  ##TODO: Add application tests
  ##TODO: Add unicorn tests
end
