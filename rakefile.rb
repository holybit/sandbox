require 'rake/clean'

# for local testing only
#ENV['WORKSPACE'] = '/Users/heathercrotty/git/sandbox'

dist_exclude = [ 
                 '**/build.xml',
                 '**/build',
                 '**/dist',
                 '**/offline',
                 '**/rakefile.rb',
                 '**/test'
               ]

# tasks
task :default => [:build]

CLEAN.add(ENV['WORKSPACE'] + '/dist/')
CLEAN.add(ENV['WORKSPACE'] + '/build/')

desc "One line task description"
task :build => [:clean, :init, :dist] do
end

task :init do
  FileUtils.mkdir_p( ENV['WORKSPACE'] + '/build/logs')
end

task :dist do
  FileUtils.mkdir(ENV['WORKSPACE'] + '/dist')
  fileList = FileList.new(ENV['WORKSPACE'] + '/**').exclude(*dist_exclude)
  fileList.each do |file|
    #puts file
    FileUtils.cp_r file, ENV['WORKSPACE'] + '/dist', :preserve => true
  end
end
