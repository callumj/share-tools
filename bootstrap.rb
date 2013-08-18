require 'bundler'
Bundler.require :default, :development

require 'active_support/core_ext/object'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/array'
require 'active_support/time'

# setup load path
APP_ROOT = File.dirname(__FILE__)
$:.unshift File.join(APP_ROOT, "lib")

RailsConfig.load_and_set_settings(File.join(APP_ROOT, "config", "settings.yml"))

# bring in libs
require 'share-tools'