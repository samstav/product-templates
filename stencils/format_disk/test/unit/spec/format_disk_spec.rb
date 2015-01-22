require_relative 'spec_helper'

describe '|{.Cookbook.Name}|::|{.Options.Name}|' do
  let(:chef_run) do
    ChefSpec::Runner.new.converge('|{.Cookbook.Name}|::|{.Options.Name}|')
  end

  it 'includes the format_disk recipe' do
    expect(chef_run).to include_recipe('format_disk')
  end
end
