# Ezap! applications with ease

# general stuff

#external: Gem::Specification.find_by_name
#internal: Gem.loaded_specs[ ]
EZAP_ROOT = Gem.loaded_specs['ezap_core'].gem_dir
EZAP_LIB_PATH = File.join(EZAP_ROOT, 'lib', 'ezap')
require 'yaml'
require 'ffi-rzmq'
require 'msgpack'
require 'redis'
require File.join(EZAP_LIB_PATH)

