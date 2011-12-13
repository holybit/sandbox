# Standard use is to be run from Jenkins
# If you need to run locally set following Jenkins environment variables:
# export WORKSPACE='/home/USER/git/foo'

require 'rake/clean'

DIST = ENV['WORKSPACE'] + 'dist/'
LOGS = ENV['WORKSPACE'] + 'build/logs'
STAGE_HOST = 'stage.tst.returnpath.net'
STAGE_CI_HOST = 'stage-ci.returnpath.net'

CLEAN.add(ENV['WORKSPACE'] + '/dist/')
CLEAN.add(ENV['WORKSPACE'] + '/build/')

dist_exclude = [ 
                 '**/build.xml',
                 '**/build',
                 '**/dist',
                 '**/hudsonBuild.properties',
                 '**/logs',
                 '**/offline',
                 '**/rakefile.rb',
                 '**/test'
               ]

#def rsync(arg1, arg2)
#end

for env in ENV do
  puts env
end

# tasks
task :default => [:build]

task :build => [:clean, :init, :dist] do
end

task :init do
  FileUtils.mkdir_p( ENV['WORKSPACE'] + '/build/logs')
  FileUtils.mkdir(ENV['WORKSPACE'] + '/dist')
end

task :dist do
  fileList = FileList.new(ENV['WORKSPACE'] + '/**').exclude(*dist_exclude)
  fileList.each do |file|
    #puts file
    FileUtils.cp_r file, ENV['WORKSPACE'] + '/dist', :preserve => true
  end
end
