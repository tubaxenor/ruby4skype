# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
#require 'rake/rdoctask'
require 'hanna/rdoctask'


require 'rake/testtask'
require 'spec/rake/spectask'

spec = Gem::Specification.new do |s|
  s.name = 'Ruby4Skype'
  s.version = '0.4.1'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README', 'LICENSE']
  s.summary = 'SkypeAPI wrapper'
  s.description = s.summary
  s.author = 'bopper'
  s.email = 'bopper123@gmail.com'
  s.homepage = 'http://rubyforge.org/projects/skyperapper/'
  s.rubyforge_project = "Ruby4Skype"
  # s.executables = ['your_executable_here']
  s.files = %w(LICENSE README Rakefile) + Dir.glob("{lib,spec}/**/*")
  s.require_path = "lib"
  # s.bindir = "bin"
end

Rake::GemPackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = true
  p.need_zip = true
end

Rake::RDocTask.new do |rdoc|
  #files =['README', 'LICENSE', 'lib/**/*.rb']
  #files =['README', 'LICENSE', 'lib/skypeapi/os/windows.rb', 'lib/skypeapi/chat.rb', 'lib/skypeapi/chatmessage.rb','lib/skypeapi/chatmember.rb','lib/skypeapi/user.rb','lib/skypeapi/version.rb', 'lib/skypeapi/call.rb','lib/skypeapi/application.rb']
  files = ['README','LICENSE']
  files << ['lib/skype.rb']
  files << ['lib/skype/*.rb']
  rdoc.rdoc_files.add(files)
  rdoc.main = "README" # page to start on
  rdoc.title = "SkypeAPI Docs"
  rdoc.rdoc_dir = 'doc' # rdoc output folder
  rdoc.options << '--line-numbers'
  rdoc.options << '-c UTF-8'
  rdoc.options << '--inline-source'
  rdoc.options << '--template=hanna'
end

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/*.rb']
end

Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*.rb']
end

#desc "Publish to RubyForge"
#task :rubyforge => [:rdoc] do
#  Rake::RubyForgePublisher.new(RUBYFORGE_PROJECT, 'bopper').upload
#end
