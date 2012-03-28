#!/usr/bin/env ruby
require 'logger'
require 'sinatra'

$LOAD_PATH.unshift ::File.expand_path(::File.dirname(__FILE__) + '/lib')
require 'app_sleuth'
require 'app_sleuth/server'

use Rack::ShowExceptions
run AppSleuth::Server.new