require "test/unit"
require "yuback/application"
require "yuback/backup"
require "tempfile"
require 'fileutils'
require 'libarchive_rs'

class TestYuback < Test::Unit::TestCase

  # Create a fake application skeleton and a fake application profile
  def setup
    if $orig.nil? then
      $orig = File.expand_path(File.dirname(__FILE__))
    end
    # Create fake application skel
    @tmp = Dir.mktmpdir('appli_test')
    Dir.mkdir("#{@tmp}/folder_framework")
    Dir.mkdir("#{@tmp}/css_framework_folder")
    Dir.mkdir("#{@tmp}/uploads")
    Dir.mkdir("#{@tmp}/sessions_dir")
    f = File.new("#{@tmp}/uploads/here", "w")
    f.write("blahah")
    f.close
    # Add a symlink
    @symlink_target = Dir.mktmpdir('symlink_target')
    f = File.new("#{@symlink_target}/symlinks_works", "w")
    f.write("blah")
    f.close 
    File.symlink(@symlink_target, "#{@tmp}/symlink")
    # Create fake application profile
    @profile = Tempfile.new("profile_test")
    @profile.write("config:\n")
    @profile.write("  name: appli test\n")
    @profile.write("  sources: #{@tmp}\n")
    @profile.write("\n")
    @profile.write("cache_dirs:\n")
    @profile.write("- name: sessions_dir\n")
    @profile.write("\n")
    @profile.write("frameworks:\n")
    @profile.write("  - name: folder_framework\n")
    @profile.write("  - name: css_framework_folder\n")
    @profile.write("\n")
    @profile.write("files_databases:\n")
    @profile.write("  - name: uploads\n")
    @profile.write("\n")
    @profile.write("databases:\n")
    @profile.write("  - name: yumail\n")
    @profile.write("\n")
    @profile.rewind
  end

  # Build a web application
  def test_01_web_application
    puts "\n\nTesting: building a web application"
    puts "-----------------------------------"
    puts "Create a new application"
    appli = Yuback::Application.new(
      :name => "appli_name", :path => "/tmp"
    )
    puts ":: Add a new database to the application"
    appli.add_database(Yuback::Database.new("yumail"))
    puts ":: Add two new framework folder to the application"
    appli.add_framework(Yuback::Framework.new("folder_framework"))
    appli.add_framework(Yuback::Framework.new("css_framework_folder"))
    puts ":: Add a new dynamic file folder to the application"
    appli.add_files_database(Yuback::FilesDatabase.new("uploads"))
    puts ":: Add a cache dir to the application"
    appli.add_cache_dir(Yuback::CacheDir.new("sessions_dir"))
    puts ":: Application loaded: "
    puts appli
  end

  # Load a web application from a profile file
  def test_02_web_application_from_profile
    puts "\n\nTesting: building a web application with a profile"
    puts "--------------------------------------------------"
    puts ":: Load a fake profile"
    appli = Yuback::Application.new(:profile => @profile.path)
    puts ":: Application created: "
    puts appli
  end

  # Backup a web application (files and sources)
  def test_03_backup
    puts "\n\nTesting: Backup a web application (files and sources)"
    puts "---------------------------------------------------------"
    puts ":: Create a backup from an application"
    @tmp_back = Dir.mktmpdir('backups')
    Dir.chdir(@tmp_back)
    appli = Yuback::Application.new(:profile => @profile.path)
    backup = Yuback::Backup.new(appli)
    puts ":: Backup sources"
    backup.sources
    puts ":: Backup dynamic files folders"
    backup.files_databases
    puts ":: Producted files:"
    filenames = Array.new
    sources = String.new
    folder = String.new
    Dir.entries(@tmp_back).each do |file|
      filenames << file if file != "." and file != ".."
    end
    filenames.each do |filename|
      sources = filename if filename =~ /.*SRC.*/
      folder = filename if filename =~ /.*FOLDER.*/
      puts "- #{filename}"
    end
    flunk "Sources not backuped" if sources == ''
    flunk "Dynamic folder not backuped" if folder == ''
   
    puts ":: Test the symlinks"
    puts "- Source file: #{sources}"
    Archive.read_open_filename("#{@tmp_back}/#{sources}") do |archive|
      while entry = archive.next_header
        path = entry.pathname.sub(/^\//, '')
        flunk "Symlinks not treated as folder" if path == "symlink"
        flunk "Symlinks contents are not backuped" if path == "symlink/" and !File.exist?("#{path}/symlinks_works")
      end
    end
  end

  # Backup a web application (source only) using the binary
  def test_04_binary
    puts "\n\nBackup a web application (source only) using the binary"
    puts "---------------------------------------------------------"
    puts ":: Call the binary with a profile"
    `#{$orig}/../bin/yuback #{@profile.path}`
  end

  def teardown
    FileUtils.rm_rf(@tmp_back) if @tmp_back
    FileUtils.rm_rf(@tmp)
    FileUtils.rm_rf(@symlink_target)
    @profile.close
    @profile.unlink
  end
end
