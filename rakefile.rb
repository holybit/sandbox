# Standard use is to be run from Jenkins
# If you need to run locally set following Jenkins environment variables:
# export WORKSPACE='/home/USER/git/foo'

require 'rake/clean'

# constants
DIST = ENV['WORKSPACE'] + '/dist'
BUILD = ENV['WORKSPACE'] + '/build'
LOGS = ENV['WORKSPACE'] + '/build/logs'
STAGE_HOST = 'stage.tst.returnpath.net'
STAGE_CI_HOST = 'stage-ci.returnpath.net'

CLEAN.add(DIST)
CLEAN.add(BUILD)

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

# tasks
task :default => [:build]

task :build => [:clean, :init, :dist] do
end

task :init do
  FileUtils.mkdir_p(LOGS)
  FileUtils.mkdir(DIST)
end

task :dist do
  fileList = FileList.new(ENV['WORKSPACE'] + '/**').exclude(*dist_exclude)
  fileList.each do |file|
    #puts file
    FileUtils.cp_r file, DIST, :preserve => true
  end
end
