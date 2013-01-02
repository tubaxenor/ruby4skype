$:.push File.expand_path("../lib", __FILE__)
spec = Gem::Specification.new do |s|
  s.name = 'Ruby4Skype'
  s.version = '0.4.1'
  s.has_rdoc = true
  s.platform    = Gem::Platform::RUBY
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

