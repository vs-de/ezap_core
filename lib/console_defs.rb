#output related stuff
#=begin
#require 'wirble'
#Wirble.init
#Wirble.colorize
#require 'hirb'
#Hirb.enable
#=end
#output related stuff ends

$: << '.'
#require "#{ENV['EZAP_ROOT'] || '.'}/lib/init_file"
require "#{ENV['EZAP_ROOT'] || '.'}/lib/loader"
extend Ezap::DirectZeroExtension
