require 'erb'
require 'sinatra'
require 'color'
require 'css_parser'
require 'sprockets'
require 'sass-rails'
# require 'sass'
require 'active_support/inflector'
require 'json'

require "app_sleuth/version"
require "app_sleuth/colors"
require "app_sleuth/fonts"
require "app_sleuth/server"

module AppSleuth
  GEM_PATH = File.dirname(__FILE__)
end
