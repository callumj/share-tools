root = File.dirname(__FILE__)
load File.join(root, "bootstrap.rb")

rake_tasks = File.join(root, "lib", "tasks", "**.rake")
Dir[rake_tasks].each { |file| load file }