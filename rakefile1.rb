require 'rake/clean'

dirs = {
        'log' => 'build/log',
        'logSelnim' => 'build/log/selenium'
       }

def deploy(src='dist/', user='cmuser', host='test', dest)
  puts 'task deploy'
  puts defined? dirs
  puts dirs
end

# tasks
task :default => [:build]

task :build => [:deploy] do
end

task :deploy do
  deploy('dist/', 'cmuser', 'test', 'www/fbl')
end
