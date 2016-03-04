# AWS SSH Profiles

This is a utility which can generate an SSH config file as well as portably KiTTY profiles from AWS instance definitions. This provides an automated way for you to build connection profiles for all your AWS machines easily. No more looking up machines in the AWS console!

## Usage

rename `config.example.yml` to `config.yml` and configure it to your preferences. Run `rake` and then copy the generated configurations to the appropriate locations.

* move `out/ssh_config/config` to `~/.ssh/config` and chmod it 0600. If you have an AWS machine named `my machine` then you will be able to connect to it via `ssh my-machine`.
* move the files and/or directories in `out/kitty` into your KiTTY portable sessions directory (`C:\ProgramData\chocolatey\lib\kitty.portable\tools\Sessions` on my machine)

## Configuration

See the comments in `config.example.yml` for configuration guidance
