require_relative 'spec_helper'

describe '|{ cookbook['name'] }|::|{ options['name'] }|' do
  let(:chef_run) do
    ChefSpec::Runner.new.converge('|{ cookbook['name'] }|::|{ options['name'] }|')
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
