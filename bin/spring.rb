#!/usr/bin/env ruby

# This file loads spring without using Bundler, in order to be fast.
# It gets overwritten when you run the `spring binstub` command.

unless defined?(Spring)
  require 'rubygems'
  require 'bundler'

  if (match = Bundler.default_lockfile.read.match(/^GEM$.*?^    (?:  )*spring \((.*?)\)$.*?^$/m))
    Gem.paths = { 'GEM_PATH' => [Bundler.bundle_path.to_s, *Gem.path].uniq.join(Gem.path_separator) }
    gem 'spring', match[1]
    require 'spring/binstub'
  end
end
