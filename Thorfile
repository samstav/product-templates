require 'json'
require 'git'
require 'pathname'
require 'pp'

class TestRunner < Thor
  desc 'error_checks', 'Check for preconditions that would fail a test right away.'
  option :allow_templatepack_files, type: :boolean
  option :allow_files_without_stencils, type: :boolean
  option :allow_stencils_without_cookbooks, type: :boolean

  def error_checks
    # Raise an error if you try to change a file that is not a base
    # file, cookbook json, or stencil, because it most likely means
    # you are changing something that affects the entire templatepack,
    # such as the master manifest.json file.
    if file_types.keys.include?(:other) && !options[:allow_templatepack_files]
      fail <<-eos
A file you are trying to change is not a base file, cookbook json file, or a stencil.
Attempting to update #{updated_files}
eos
    end

    # Raise an error if you are changing a file, but it does not
    # belong to a stencil.
    if stencil_map.values.include?(:no_stencils_found) && !options[:allow_files_without_stencils]
      fail <<-eos
You're trying to change a file in a stencil set, but it does not belong to a stencil.
Attempting to update #{updated_files}
eos
    end

    # Raise an error if you are changing a file in a stencil, but have
    # not created a cookbook json file that builds that stencil.
    if !file_types[:stencil].empty? && updated_cookbooks.empty? &&
       !options[:allow_stencils_without_cookbooks]
      fail <<-eos
You are editing a stencil but there is no corresponding cookbook json file in cookbooks/ directory.
Attempting to update #{updated_files}"
eos
    end
  end

  desc 'updated_cookbooks', 'You are changing files. What cookbooks are using them?'
  def updated_cookbooks
    # Loop through all cookbooks. Find out which ones have stencil_sets
    # and stencils that have changed.

    cookbooks = []

    all_cookbooks.each do |cbook|
      stencil_map.each do |sset, stencils|
        unless stencils == :no_stencils_found
          stencils.each do |stencil|
            if cookbook_contains_stencil?(cbook, sset.to_s, stencil)
              cookbooks.push(cbook)
            end
          end
        end
      end
    end
    pp cookbooks
    cookbooks
  end

  desc 'print_updated_files', 'What files have changed between master and your HEAD?'
  def print_updated_files
    pp updated_files
  end

  desc 'print_file_types', 'What types of files are you changing?'
  def print_file_types
    pp file_types
  end

  desc 'print_stencil_map', 'What stencil-set and stencils are updated by the files you changed?'
  def print_stencil_map
    pp stencil_map
  end

  no_commands do
    def updated_files
      # Compares HEAD of the current branch with master. Returns a list
      # of updated files as an array.

      Git.open('.').diff('HEAD', 'master').stats[:files].keys
    end

    def stencil_map
      # Reads in the list of changed files, and builds a K.V hash of
      # which stencil-sets and stencils have been updated.
      smap = {}
      file_types[:stencil].each do |inv_stencil|
        sset = belongs_to_stencil_set(inv_stencil)
        s = belongs_to_stencil(sset, inv_stencil)
        smap[sset.to_sym] = s
      end
      smap
    end

    def file_types
      # Generate a list of changed files and their associated types:
      # base, stencil, cookbook, manifest, or other.
      fmap = Hash.new { |k, v| k[v] = [] }

      updated_files.each do |updated_file|
        case updated_file_type(updated_file)
        when :base
          fmap[:base].push(updated_file)
        when :stencil
          fmap[:stencil].push(updated_file)
        when :cookbook
          fmap[:cookbook].push(updated_file)
        when :manifest
          fmap[:manifest].push(updated_file)
        when :other
          fmap[:other].push(updated_file)
        end
      end
      fmap
    end

    def updated_file_type(updated_file)
      # Is the changed file a base file, a cookbook json file, or a
      # stencil?  If it was a file in the stencil directory, handle
      # manifest.json files differently. Returns a list of all files
      # grouped by type.

      path_array = Pathname.new(updated_file).each_filename.to_a

      case path_array[0]
             when 'base' then :base
             when 'stencils'
               if File.basename(updated_file) == 'manifest.json'
                 :manifest
               else
                 :stencil
               end
             when 'cookbooks' then :cookbook
             else :other
             end
    end

    def belongs_to_stencil_set(stencil_file)
      # Once we've determined the file is a stencil file, find the
      # stencil set it belongs to.

      Pathname.new(stencil_file).each_filename.to_a[1]
    end

    def belongs_to_stencil(stencil_set, updated_file)
      # Given a stencil_set and updated file, make sure file exists in
      # stencil. Return the name of the stencil.
      stencils = []

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

    def all_cookbooks
      # Return all cookbook json files as an array.
      cookbooks = []

      Dir['cookbooks/*.json'].each do |cookbook_json|
        cookbooks.push(File.basename(cookbook_json, '.json'))
      end

      cookbooks
    end

    def cookbook_contains_stencil?(cookbook, stencil_set, stencil)
      # Given a stencil_set, stencil, and a cookbook, see which stencils
      # exist in cookbooks. Return the cookbooks.
      cookbook_json = JSON.parse(File.read("cookbooks/#{cookbook}.json"))
      cookbook_json['stencils'].each do |stencil_key|
        if stencil_key['stencil_set'] == stencil_set && stencil_key['stencil'] == stencil
          return true
        end
      end
      false
    end
  end
end
