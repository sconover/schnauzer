# ARCHFLAGS='-arch i386 -arch x86_64'
# rvm install 1.8.7 --debug --reconfigure -C --enable-shared=yes
require "fileutils"

system(%{wget -q -O - "http://sourceforge.net/projects/rubycocoa/files/RubyCocoa/1.0.1/RubyCocoa-1.0.1.tar.gz/download" | tar xzv})

FileUtils.cd("RubyCocoa-1.0.1") do
  system("ruby install.rb config && ruby install.rb setup && sudo ruby install.rb install")
end