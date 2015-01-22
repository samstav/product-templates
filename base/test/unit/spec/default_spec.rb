require_relative 'spec_helper'

describe '|{ .Name }|::default' do
  let(:chef_run) do
    ChefSpec::Runner.new.converge('|{.Name}|::default')
  end
end
