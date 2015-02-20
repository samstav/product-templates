require 'json'
require 'git'
require 'pathname'

class Cookbook
  attr_accessor: stencil_sets
end

class StencilSet
  attr_accessor: stencils
end

class Stencil
  attr_accessor: files
end


class UpdatedCookbooks < Thor
  desc "updated_cookbooks", "find cookbooks that were updated on last commit"

  def updated_cookbooks
    
  end

  def file_map
    fmap = Hash.new{|k, v| k[v] = []}
    
    updated_files.each do |updated_file|
      case updated_file_type(updated_file)
      when :base
        fmap[:base].push(updated_file)
      when :stencils
        fmap[:stencils].push(updated_file)
      when :cookbook
        fmap[:cookbook].push(updated_file)
      when :other
        fmap[:other].push(updated_file)
      end
    end
    fmap
  end

  def stencils_to_cookbooks
    smap = Hash.new{|k, v| k[v] = []}
    file_map[:stencils].each do |inv_stencil|
      sset = belongs_to_stencil_set(stencil_file)
      s = stencil(sset, inv_stencil)
      smap[sset.to_sym].push(s)
    end
  end
  
  def updated_files
    # Compares HEAD of the current branch with master. Returns a list
    # of changed files as an array.

    Git.open('.').diff('HEAD','master').stats[:files].keys
  end

  def updated_file_type(updated_file)
    # Was change made to a stencil file, cookbook, base, or other?
    
    path_array = Pathname.new(updated_file).each_filename.to_a

    return case path_array[0]
           when "base" ; :base
           when "stencils" ; :stencil
           when "cookbooks" ; :cookbook
           else :other
           end
  end
    
  def belongs_to_stencil_set(stencil_file)
    # Once we've determined the file is a stencil file, find the
    # stencil set it belongs to.

    Pathname.new(stencil_file).each_filename.to_a[1]
  end

  def stencil(stencil_set, updated_file)
    # Given a stencil_set and updated file, make sure file exists in
    # stencil. Return the name of the stencil.
    stencils = Array.new
    
    stencil_manifest = JSON.parse(File.read("stencils/#{stencil_set}/manifest.json"))
    stencil_manifest['stencils'].each do |stencil, stencil_values|
      stencil_values['files'].values.each do |dest|
        if Pathname.new(dest).each_filename.to_a == Pathname.new(updated_file).each_filename.to_a[2..-1]
          stencils.push stencil
        end
      end
    end

    if stencils.empty?
      return :no_stencils_found
    else
      stencils
    end
  end
  
  def cookbook(cookbook, stencil_set, stencil)
    # Given a stencil_set, stencil, and a cookbook, see which stencils
    # exist in cookbooks. Return the cookbooks.
    cookbooks = Array.new

    cookbook_json = JSON.parse(File.read("cookbooks/#{cookbook}.json"))
    cookbook_json['stencils'].each do |stencil_key|
      if stencil_key['stencil_set'] == stencil_set && stencil_key['stencil'] == stencil
        cookbooks.push(cookbook_json['name'])
        puts "cookbooks is #{cookbooks}"
      end
    end
  end
end
