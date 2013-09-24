---
global_master_service:
  sockets:
    pub:
      #name_space: ctrl
      default:
        addr: 'tcp://127.0.0.1:43690'
    rep:
      default:
        addr: &gm_address 'tcp://127.0.0.1:43691'
  opts:
    sub_port_range: 
      default:
        start: 52001
        end: 53000
    cache_storage:
      default:
        type: redis #memcache, whatever?
        addr: '127.0.0.1:6379'

global_master_address:
  default: *gm_address
  dev: *gm_address
