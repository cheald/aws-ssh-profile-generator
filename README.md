# AWS SSH Profiles

This is a utility which can generate an SSH config file as well as portably KiTTY profiles from AWS instance definitions. This provides an automated way for you to build connection profiles for all your AWS machines easily. No more looking up machines in the AWS console!

## Usage

rename `config.yml.example` to `config.yml` and configure it to your preferences. Run `ruby profiles.rb` and then copy the generated configurations to the appropriate locations.

* move `ssh_config` to `~/.ssh/config` and chmod it 0600. If you have an AWS machine named `my machine` then you will be able to connect to it via `ssh my-machine`.
* move the kitty files and/or directories into your KiTTY portable sessions directory (`C:\ProgramData\chocolatey\lib\kitty.portable\tools\Sessions` on my machine)

## Configuration

See the comments in config.yml.example for configuration guidance