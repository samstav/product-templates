require_relative 'spec_helper'

describe '|{.Cookbook.Name}|::|{.Options.Name}|' do
  let(:chef_run) do
    ChefSpec::Runner.new.converge('|{.Cookbook.Name}|::|{.Options.Name}|')
  end

  it 'includes the nginx recipe' do
    expect(chef_run).to include_recipe('nginx')
  end

  it 'includes the |{.Cookbook.Name}|::_ruby_common recipe' do
    expect(chef_run).to include_recipe('|{.Cookbook.Name}|::_ruby_common')
  end

  ##TODO: Add application tests
  ##TODO: Add unicorn tests
end
