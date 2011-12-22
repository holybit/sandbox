# Standard use is to be run from Jenkins
# If you want to run non Jenkins test builds set shell variable below
# export RP_BUILD_TEST=true

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
DIST = ENV['WORKSPACE'] + '/dist'
BUILD = ENV['WORKSPACE'] + '/build'
LOGS = ENV['WORKSPACE'] + '/build/logs'

CLEAN.add(DIST)
CLEAN.add(BUILD)

dist = [ 
        'documentroot',
        'includes',
        'README',
       ]

def deploy(src='dist/', user='cmuser', host='test', dest)
  stagedir = '/usr/local/stage'
  rsync_test = '/tmp/rsync_test'

  if host != 'ci' && host != 'test'
    puts 'deploy HOST must be either ci or test - exit'
    puts host
    exit 1
  elsif dest.nil?
    puts 'deploy DEST not supplied - exit'
    exit 1
  end

  if ! ENV['RP_BUILD_TEST'].nil?
    dest = '/tmp/rsync_test'
    rhost = 'localhost'
    user = ENV['USER']
  elsif host == 'ci'
    dest = '/usr/local/stage/test/' + dest
    rhost = 'stage.tst.returnpath.net'
  elsif host == 'test'
    dest = '/usr/local/stage/ci_test/' + dest
    rhost = 'stage-ci.tst.returnpath.net'
  end

  rargs = [ 
           '-av',
           '--backup',
           "--backup-dir=backup/push_" + DATETIME,
           '--delete',
           '--compress',
           '--checksum',
           '--perms',
           '--size-only',
           '--stats'
          ]

  if ! ENV['RP_BUILD_TEST'].nil?
    if File.directory? rsync_test
      FileUtils.rm_rf(rsync_test)
      FileUtils.mkdir(rsync_test)
    end
    rsync = '/usr/bin/rsync ' + rargs.join(' ') + ' ' + src + ' ' + dest + '/'
  else
    rsync = '/usr/bin/rsync ' + rargs.join(' ') + ' ' + src + ' ' + user + '@' + rhost + ':' + dest + '/'
  end
  puts rsync
  exit
    
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
  FileUtils.mkdir_p(LOGS)
  FileUtils.mkdir(DIST)
end

task :dist do
  fileList = Dir[*dist]
  fileList.each do |file|
    #puts file
    FileUtils.cp_r file, DIST, :preserve => true
  end
end

task :deploy do
  deploy('dist/', 'cmuser', 'test', 'www/fbl')
end
