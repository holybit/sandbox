require 'rake/clean'
require 'Find'

WORKINGDIR = './**'

CLEAN.add('./dist/')
dist_exclude = [ './',
                './build',
                'build.xml',
                './dist',
                './offline'
              ]

task :dist => :clean do
    puts ENV['WORKSPACE']
    FileUtils.mkdir('dist')
    fileList = FileList.new(WORKINGDIR).exclude(*dist_exclude)
    #dirList = FileList.new(WORKINGDIR + '/**/').exclude('./', './dist/', './offline/')
    #dirList = FileList.new(WORKINGDIR + '/**/').exclude(*dist_exclude)
    #pathList = Find.find(WORKINGDIR)
    #fileList = FileList.new(WORKINGDIR + '/**')
    fileList.each do |file|
        #if File.directory?(path)
            #puts "path - #{path}"
            #next
            #dist_exclude.each do |pattern|
                #puts "pattern - #{pattern}"
                #if path.match(/#{pattern}/i)
                    puts file 
                #end
            #end
        #end
    end
    #fileList.each do |file|
            #FileUtils.cp_r dir, './dist', :verbose => true, :preserve => true
        #if ! File.exists?(file)
            #puts file
        #end
    #end
end
