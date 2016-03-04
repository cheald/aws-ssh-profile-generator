require_relative "./lib/aws_ssh_profile_generator"

task :default do
  AwsSshProfileGenerator::Generator.new(ARGV[0] || "config.yml").run!
end