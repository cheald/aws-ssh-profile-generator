require 'bundler/setup'
require 'aws-sdk'
require 'awesome_print'
require 'set'
require 'yaml'
require 'erb'
require 'fileutils'
require 'uri'

module AWSProfileGenerator
  require_relative "./aws_ssh_profile_generator/generator"
  require_relative "./aws_ssh_profile_generator/renderers/ssh_config"
  require_relative "./aws_ssh_profile_generator/renderers/kitty"
end
