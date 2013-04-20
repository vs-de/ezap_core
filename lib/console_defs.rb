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
#IRB.conf[:AUTO_INDENT] = true
#IRB.conf[:USE_READLINE] = true
#unless (IRB.conf[:LOAD_MODULES] ||= []).include?('irb/completion')
#  IRB.conf[:LOAD_MODULES] << 'irb/completion'
#end
extend Ezap::DirectZeroExtension
