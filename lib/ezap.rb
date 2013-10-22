#####
# Copyright 2013, Valentin Schulte, Leipzig
# This File is part of Ezap.
# It is shared to be part of wecuddle from Lailos Group GmbH, Leipzig.
# Before changing or using this code, you have to accept the Ezap License in the Ezap_LICENSE.txt file 
# included in the package or repository received by obtaining this file.
#####
module Ezap
  #require 'bundler'
  #Bundler.require
  CFG_DEFAULT_FILE_NAME = 'defaults.yml'
  CFG_FILE_NAME = 'ezap_main.yml'
  CFG_PATH = 'config'
 
  def self.load_lib *x
    require File.join(EZAP_LIB_PATH, *x)
  end

  def self.load_lib_dir p
    Dir.glob(File.join(EZAP_LIB_PATH, p, '*.rb')) do |f|
      load f
    end
  end

  #order matters here 
  load_lib_dir '../ruby_ext'
  require 'ezap/config_access'
  require 'ezap/app_config'
  load_lib 'config'
  @@config = Config.new

  def self.config
    @@config
  end

  require 'ezap/base'
  require 'ezap/zmq_ctx'
  require 'ezap/sock'
  require 'ezap/direct_zero_extension'
  require 'ezap/wrapped_zero_extension'
  require 'ezap/global_master_connection'
  require 'ezap/sub_listener'
  require 'ezap/publisher'
  require 'ezap/cache_storage'
  require 'ezap/main_cache_storage'
  require 'ezap/service'
  require 'ezap/service/master'
  require 'ezap/service/global_master'
end
