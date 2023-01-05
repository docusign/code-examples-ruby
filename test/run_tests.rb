Dir["#{File.dirname(File.absolute_path(__FILE__))}/**/*_test.rb"].sort.each { |file| require file }
