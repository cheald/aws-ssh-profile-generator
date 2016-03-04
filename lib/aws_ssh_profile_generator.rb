require 'bundler/setup'
require 'aws-sdk'
require 'set'
require 'yaml'
require 'erb'
require 'fileutils'
require 'uri'

module AwsSshProfileGenerator
  require_relative "./aws_ssh_profile_generator/generator"
  require_relative "./aws_ssh_profile_generator/renderers/ssh_config"
  require_relative "./aws_ssh_profile_generator/renderers/kitty"
end
