# Standard use is to be run from Jenkins where the WORKSPACE and other
# environment variables are picked up from.
#
# Note, if you want to run non Jenkins test builds:
# export RP_BUILD_TEST=true
# The following will then apply:
#   1. deploy task will rsync dist to /tmp/rsync_ci or /tmp/rsync_test
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
puts defined? alldirs

CLEAN.add('dist/')
CLEAN.add('build/')

def deploy(src='dist/', user='cmuser', host='test', dest)
  puts 'here joe'
  puts defined? alldirs
  stagedir = '/usr/local/stage'
  rsyncLocal = '/tmp/stage'

  if host != 'ci' && host != 'test'
    puts 'deploy HOST must be either ci or test - exit'
    puts host
    exit 1
  elsif dest.nil?
    puts 'deploy DEST not supplied - exit'
    exit 1
  end

  #if ! ENV['RP_BUILD_TEST'].nil?
    #if host == 'ci'
      #dest = rsyncLocal + '/ci_test'
      #puts dirs.fetch('log')
      ##log12 = dirs.fetch('log') + '/rsync_ci.log'
    #else
      #dest = rsyncLocal + '/test'
      ##log12 = dirs.fetch('log') + '/rsync_test.log'
    #end
  #elsif host == 'ci'
    #dest = '/usr/local/stage/test/' + dest
    ##log = "#{dirs['log']}" + '/rsync_ci.log'
    #rhost = 'stage.tst.returnpath.net'
  #elsif host == 'test'
    #dest = '/usr/local/stage/ci_test/' + dest
    ##log = "#{dirs['log']}" + '/rsync_test.log'
    #rhost = 'stage-ci.tst.returnpath.net'
  #end

  #rargs = [ 
           #'-av',
           #'--backup',
           #'--backup-dir=backup/push_' + DATETIME,
           #'--delete',
           #'--compress',
           #'--checksum',
           #'--perms',
           #'--size-only',
           #'--stats'
          #]

  #if ! ENV['RP_BUILD_TEST'].nil?
    #if File.directory? rsyncLocal
      #FileUtils.rm_rf(rsyncLocal)
    #end
      #FileUtils.mkdir(rsyncLocal)
    #rsync = '/usr/bin/rsync ' + rargs.join(' ') + ' ' + src + ' ' + dest + '/' + ' > ' + log + ' 2>&1'
  #else
    #rsync = '/usr/bin/rsync ' + rargs.join(' ') + ' ' + src + ' ' + user + '@' + rhost + ':' + dest + '/'
  #end
  #puts rsync
    
  #status =
    #Open4::popen4("sh") do |pid, stdin, stdout, stderr|
      #stdin.puts rsync
      ##stdin.puts "echo 42.err 1>&2"
      #stdin.close

      #puts "pid        : #{ pid }"
      #puts "stdout     : #{ stdout.read.strip }"
      #puts "stderr     : #{ stderr.read.strip }"
    #end
      #puts "status     : #{ status.inspect }"
      #puts "exitstatus : #{ status.exitstatus }"
end

# tasks
task :default => [:build]

task :build => [:clean, :init, :dist, :deploy] do
end

task :init do
  FileUtils.mkdir_p(alldirs['log'])
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
  deploy('dist/', 'cmuser', 'test', 'www/fbl')
end
