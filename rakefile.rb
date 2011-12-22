# Standard use is to be run from Jenkins
# If you need to run locally set following Jenkins environment variables:
# export WORKSPACE='/home/USER/git/foo'

#require 'open4'
require 'rake/clean'

# constants
DIST = ENV['WORKSPACE'] + '/dist'
BUILD = ENV['WORKSPACE'] + '/build'
LOGS = ENV['WORKSPACE'] + '/build/logs'
STAGE_HOST = 'stage.tst.returnpath.net'
STAGE_CI_HOST = 'stage-ci.returnpath.net'

CLEAN.add(DIST)
CLEAN.add(BUILD)

dist = [ 
        'documentroot',
        'includes',
        'README',
       ]

def deploy
  status =
    Open4::popen4("sh") do |pid, stdin, stdout, stderr|
      stdin.puts "echo 42.out"
      stdin.puts "echo 42.err 1>&2"
      stdin.close

      puts "pid        : #{ pid }"
      puts "stdout     : #{ stdout.read.strip }"
      puts "stderr     : #{ stderr.read.strip }"
    end
      puts "status     : #{ status.inspect }"
      puts "exitstatus : #{ status.exitstatus }"
end

# tasks
task :default => [:build]

task :build => [:clean, :init, :dist] do
end

task :init do
  FileUtils.mkdir_p(LOGS)
  FileUtils.mkdir(DIST)
end

task :dist do
  fileList = Dir[*dist]
  fileList.each do |file|
    puts file
    FileUtils.cp_r file, DIST, :preserve => true
  end
end

task :deploy do

end
