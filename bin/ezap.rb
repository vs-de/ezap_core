##!/usr/bin/env ruby

module EzapExec
  
  module CM
    
    def start *args
      puts "starting"
    end

    def help *args
      puts help_msg
    end

    def help_msg
<<HELP

  << -- e z a p -- >>

usage:
  ezap (s)tart [<service|web_app>] name]
  ezap stop/(h)alt [service]
  ezap (r)un <file/args to 'ruby'>
  ezap (e)val <ruby-expression>
  ezap (c)onsole
  //TODO: ezap (g)enerate <service> <name>
  //TODO: ezap (g)enerate <web_app> <controller|view> <name>
  //TODO: ezap (i)nstall [args]
  ezap (h)elp

HELP
    end


  end

  extend CM
end
EE = EzapExec
args = ARGV.clone
case args.shift
  when 's', 'start'
    EE.start args
  when 'h',' halt', 'stop'
    EE.stop args
  when 'help'
    EE.help args
  else
    EE.help args
end