require_relative "./lib/aws_profile_generator"

task :default do
  AWSProfileGenerator::Generator.new(ARGV[0] || "config.yml").run!
end