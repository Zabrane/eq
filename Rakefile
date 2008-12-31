require 'rubygems'
require 'spec/rake/spectask'

Spec::Rake::SpecTask.new do |t|
  t.spec_opts << "-c"
  t.spec_files = FileList['spec/*_spec.rb']
end

desc "Compile Erlang files"
task :compile => ["compile:mochiweb", "compile:jobq"]

namespace :compile do
  desc "Compile MochiWeb files"
  task :mochiweb do
    f = File.join(File.dirname(__FILE__), 'src', 'mochiweb', '*.erl')
    `erlc #{f}`
  end

  desc "Compile JobQ files"
  task :jobq do
    f = File.join(File.dirname(__FILE__), 'src', '*.erl')
    `erlc #{f}`
  end

  desc "Cleans all .beam and erl_crash.dump files"
  task :clean do
    f1 = File.join(File.dirname(__FILE__), '*.beam')
    f2 = File.join(File.dirname(__FILE__), 'erl_crash.dump')

    `rm #{f1} #{f2}`
  end
end
