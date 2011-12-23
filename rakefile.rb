# Standard use is to be run from Jenkins where the WORKSPACE and other
# environment variables are picked up from.
#
# Note, if you want to run non Jenkins test builds:
# export RP_BUILD_TEST=true
# The following will then apply:
#   1. deploy task will rsync dist to /tmp/stage or /tmp/rsync_test
#   2. 

require 'open4'
require 'rake/clean'

if ! ENV['RP_BUILD_TEST'].nil?
  puts "RP_BUILD_TEST=" + ENV['RP_BUILD_TEST']
  ENV['WORKSPACE'] = File.dirname(__FILE__)
elsif ENV['WORKSPACE'].nil?
  puts 'can not find shell environment variable WORKSPACE - exit'
  exit 1
end
puts "WORKSPACE=" + File.dirname(__FILE__)

# constants
DATETIME = Time.now.strftime("%Y%m%d%H%M%S")
dirs = {
        'log' => 'build/log',
        'logSelnim' => 'build/log/selenium'
       }
dist = [ 
        'documentroot',
        'includes',
        'README'
       ]

CLEAN.add('dist/')
CLEAN.add('build/')

def deploy(src='dist/', user='cmuser', host='test', relDest, dirs)
  stagedir = '/usr/local/stage'
  stageBuildTest = '/tmp/stage'

  if host != 'ci' && host != 'test'
    puts 'deploy HOST must be either ci or test - exit'
    puts host
    exit 1
  elsif relDest.nil?
    puts 'deploy RELDEST not supplied - exit'
    exit 1
  end

  if ! ENV['RP_BUILD_TEST'].nil?
    if host == 'ci'
      dest = stageBuildTest + '/ci_test'
      puts dirs.fetch('log')
      log = dirs['log'] + '/rsync_ci.log'
    else
      dest = stageBuildTest + '/test'
      log = dirs['log'] + '/rsync_test.log'
    end
  elsif host == 'ci'
    dest = '/usr/local/stage/test/' + dest
    log = dirs['log'] + '/rsync_ci.log'
    rhost = 'stage.tst.returnpath.net'
  elsif host == 'test'
    dest = '/usr/local/stage/ci_test/' + dest
    log = dirs['log'] + '/rsync_test.log'
    rhost = 'stage-ci.tst.returnpath.net'
  end

  puts log

  rargs = [ 
           '-av',
           '--stats',
           '--compress',
           '--checksum',
           '--size-only',
           '--perms',
           '--delete',
           '--backup',
           '--backup-dir=backup/push_' + DATETIME
          ]

  if ! ENV['RP_BUILD_TEST'].nil?
    if File.directory? stageBuildTest
      FileUtils.rm_rf(stageBuildTest)
    end
      FileUtils.mkdir(stageBuildTest)
    rsync = '/usr/bin/rsync ' + rargs.join(' ') + ' ' + src + ' ' + dest + '/ > ' + log + ' 2>&1'
  else
    rsync = '/usr/bin/rsync ' + rargs.join(' ') + ' ' + src + ' ' + user + '@' + rhost + ':' + dest + '/ > ' + log + ' 2>&1'
  end
  puts rsync
    
  status =
    Open4::popen4("sh") do |pid, stdin, stdout, stderr|
      stdin.puts rsync
      #stdin.puts "echo 42.err 1>&2"
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

task :build => [:clean, :init, :dist, :deploy] do
end

task :init do
  FileUtils.mkdir_p(dirs['log'])
  FileUtils.mkdir('dist/')
end

task :dist do
  fileList = Dir[*dist]
  fileList.each do |file|
    #puts file
    FileUtils.cp_r file, 'dist/', :preserve => true
  end
end

task :deploy do
  deploy('dist/', 'cmuser', 'test', 'www/fbl', dirs)
end
