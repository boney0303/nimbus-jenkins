require 'erb'

task default: %w(lint unit converge verify)
task refresh: %w(clean default)
task ci: %w(lint unit test)

namespace 'ci' do
  task :generate_databags do
    Dir.glob('./test/integration/data_bags/*/*.json.erb') do |rb_file|
      template = ERB.new File.new(rb_file).read, nil, '%'
      File.open(rb_file.chomp('.erb'), 'w') do |f|
        f.write template.result(binding)
      end
    end
  end
end

task :lint do
  sh 'cookstyle'
end

task :unit do
  sh 'chef exec rspec'
end

task :converge do
  sh 'kitchen converge'
end

task :verify do
  sh 'kitchen verify'
end

task :test do
  sh 'kitchen test'
end

task :destroy do
  sh 'kitchen destroy'
end

task :clean do
  sh 'kitchen destroy'
  # any other cleanup
end
