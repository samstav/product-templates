require_relative 'spec_helper'

describe '|{.Cookbook.Name}|::|{.Options.Name}|' do
  let(:chef_run) do
    ChefSpec::Runner.new.converge('|{.Cookbook.Name}|::|{.Options.Name}|')
  end

  it 'should create the deploy directory' do
    expect(chef_run).to create_directory('/usr/local/rspace_devops')
  end

  %w(
    deploy_flag.json
    deploy_app.sh
  ).each do |f|
    it "should create the file #{f}" do
      expect(chef_run).to create_cookbook_file("/usr/local/rspace_devops/#{f}")
    end
  end
end
