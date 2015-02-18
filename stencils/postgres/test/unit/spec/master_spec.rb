require_relative 'spec_helper'

describe '|{.Cookbook.Name}|::|{.Options.Name}|' do
  let(:chef_run) do
    ChefSpec::Runner.new.converge('|{.Cookbook.Name}|::|{.Options.Name}|')
  end

  %w(
    chef-sugar
    pg-multi::pg_master
    postgresql::ruby
  ).each do |r|
    it "includes the #{r} recipe" do
      expect(chef_run).to include_recipe(r)
    end
  end
end
