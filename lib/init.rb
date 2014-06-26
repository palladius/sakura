#!/usr/bin/env ruby -W0

=begin

  Welcome to Riccardo Carlesso first (private) library..
  This seems to be broken with Ruby v2.0.. trying to fix it now.

=end

require File.expand_path(File.dirname(__FILE__) + '/sakuric')
require File.expand_path(File.dirname(__FILE__) + '/classes/debug_ric')


$SAKURADIR      = Sakuric.BASEDIR
$RICLIB_VERSION = Sakuric.VERSION

#DOESNT work on some machines! Nescio cur! require 'rubygems'     # necessary for other gems
require 'digest/md5'
require 'digest/sha1'
require 'net/smtp'
require "socket"
require 'yaml'

if Sakuric.use_ric_gem # slow but cool
  require 'rubygems'
  require 'ric' 
else
  require "#{$SAKURADIR}/lib/ric_colors.rb"
end

	################################################################################
	# Riccardo Ruby LIBRARY
	# 
	# TO INCLUDE THIS FILE, just paste this:
	#
	#      require "$SAKURADIR/lib/ric.rb"
	#
	################################################################################
  
#module Carlesso
 ################################################################################
 # Configuratione... see _init
 # @tags: obsolete, ric, r, lib, gem, init, loader
 # @description: try instead
 ################################################################################


 def load_sakura_modules!(enable_debug=false)
   debug_on("load_sakura_modules() called with debug enabled!") if enable_debug
   str = "Reloaded Riclibs v#{$RICLIB_VERSION} -- per la #{$RICLIB['nreloaded']} a volta"
   modules_to_be_included = $RIC_LIB_MODULES + Sakuric.get_auto_files("classes/") 
   modules_to_be_included.each{ |cls| 
     deb "Loading class: '#{cls}'..", :color => 'yellow'
     was_necessary = require "#{$SAKURADIR}/lib/#{cls}.rb"
     deb("Loading: #{cls} (necessary: #{was_necessary})") rescue puts("Error: #{$!}")
   }
 end



=begin
  Sto qui inizializza TUTTO cazzo, ho detto TUTTO, non voglio codice qui fuori!
  # puo' esser chiamato piu' volte...
  
  $RELOAD_DEBUG serve a debuggare il tutto.
=end
def _init(explaination='no explaination given', initial_debug_state = false)
  $RELOAD_DEBUG = false # 
  deb "pre init '#{explaination}'" if $RELOAD_DEBUG
  $INIT_DEBUG    = false   # dice se debuggare la mia intera infrastruttura o no...
  $RELOADED_ONCE = 0    # aiuta a capuire quante volte includo sta cazo di lib! Sempre 2!!!
  $RIC_LIB_MODULES = %w{ classes/debug_ric } # to be explicitly included in this order.
  $HOME  = File.expand_path('~')
  $DEBUG ||= initial_debug_state 
  $PROG  = File.basename($0)
  case $PROG
    when 'irb'
      print "[DEB] Welcome to Sakura within IRB! Happy playing. Try 'Sakuric.VERSION'"
    when 'ruby'
      print "[DEB] Welcome to Sakura within RUBY! Happy playing. Try 'Sakuric.VERSION'"
    default
      # do nothing
  end
    
  ################################################################################	
  # Path to riccardo's Library... Library stuff
  $LOAD_PATH << './lib' 
  $LOAD_PATH << "#{$SAKURADIR}/lib/"

  # BEWARE: ORDER *IS* RELEVANT!
  $RICLIB = Hash.new unless defined?($RICLIB)
  $RICLIB['VERSION'] = $RICLIB_VERSION
  $RICLIB['libs'] ||= []
  $RICLIB['nreloaded'] ||= 0
  $RICLIB['nreloaded'] += 1  
  $RICLIB['help'] =<<-BURIDONE
This library contains all my enciclopedic knowledge (that is, notionistic). :
Finally solved the bug of double inclusion (crisbio, files included this!)
BURIDONE

  load_sakura_modules!(true)
  $CONF = RicConf.new()
  pyellow( riclib_info ) if debug?  
  puts "post init delle #{Time.now}" if $RELOAD_DEBUG
  print "Sakuric.n_called(): #{ Sakuric.n_called() }"
end

=begin
  This wants to be a magic configuration loader who looks for configuration automatically in many places, like:
  
  - ./.CONFNAME.yml
  - ~/.CONFNAME.yml
  - .CONFNAME/conf.yml
  
  Loads a YAML file looked upon in common places and returns a hash with appropriate values, or an exception 
  and maybe a nice explaination..
=end
def load_auto_conf_migrated_to_ric_gem(confname, opts={})
  dirs          = opts.fetch :dirs,          ['.', '~', '/etc/']
  file_patterns = opts.fetch :file_patterns, [".#{confname}.yml", "#{confname}/conf.yml"]
  sample_hash   = opts.fetch :sample_hash,   {
     'load_auto_conf' => "please add an :sample_hash to me" , 
     :anyway => "I'm in #{__FILE__}" 
  }
  verbose       = opts.fetch :verbose,       true
  puts "load_auto_conf('#{confname}') start.." if verbose
  dirs.each{|d|
    dir = File.expand_path(d)
    deb "DIR: #{dir}"
    file_patterns.each{|fp|
      # if YML exists return the load..
      file = "#{dir}/#{fp}"
      deb " - FILE: #{file}"
      if File.exists?(file)
        puts "Found! #{green file}"
        yaml =  YAML.load( File.read(file) )
        deb "load_auto_conf('#{confname}') found: #{green yaml}"  
        return yaml
      end
    }
  }
  puts "Conf not found. Try this:
---------------------------
$ cat > ~/#{file_patterns.first}\n#{yellow "#Creatd by ric.rb:load_auto_conf()" + sample_hash.to_yaml }
---------------------------
"
  raise "LoadAutoConf: configuration not found for '#{confname}'!"
  return sample_hash
end

## CALL THE INIT! YAY!
_init("inizializing at #{Time.now}") 

#end /module Carlesso
