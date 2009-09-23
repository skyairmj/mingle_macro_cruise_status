namespace :macro do |ns|

  task :deploy do
    macro_folder = File.expand_path(File.join(File.dirname(__FILE__), '..'))
    mingle_plugins_folder = File.join(ENV['MINGLE_LOCATION'], 'vendor', 'plugins')
    FileUtils.cp_r(macro_folder, mingle_plugins_folder)
    public_folder = File.expand_path(File.join(File.dirname(__FILE__), '..', 'public'))
    mingle_folder = File.join(ENV['MINGLE_LOCATION'])
    FileUtils.cp_r(public_folder, mingle_folder)
    puts "#{macro_folder} successfully copied over to #{mingle_plugins_folder}. Restart the Mingle server to start using the macro."
  end

end