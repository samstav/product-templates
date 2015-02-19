require 'json'
require 'git'
require 'pathname'

class UpdatedCookbooks < Thor
  desc "updated_cookbooks", "find cookbooks that were updated on last commit"

  def list_cookbooks
  end

  def files_to_stencil_sets
    # Map a list of files to stencils.
  end

  def stencils_to_cookbooks
    # Map a list of stencils to cookbook json files
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

    Pathname.new(updated_file).each_filename.to_a[1]
  end

  def stencil(stencil_set, updated_file)
    # Given a stencil_set and updated file, make sure file exists in
    # stencil. Return the name of the stencil.

    stencil_manifest = JSON.parse(File.read("stencils/#{stencil_set}/manifest.json"))
    stencil_manifest['stencils'].each do |stencil|
      stencil['files'].each do |source, dest|
        if Pathname.new(dest).to_a == Pathname.new(updated_file).to_a[2..-1]
          stencil[0]
        else
          :not_found
        end
      end
    end
  end

  
  def cookbook(cookbook, stencil_set, stencil)
    # Given a stencil_set, stencil, and a cookbook, see if stencil
    # exists in cookbook. Return the cookbook.

    cookbook_json = JSON.parse(File.read("cookbooks/#{cookbook}.json"))
    cookbook_json['stencils'].each do |stencil|
      if stencil['stencil_set'] == stencil_set && stencil['stencil'] == stencil
        cookbook_json['name']
      end
    end
  end
end
