#!/usr/bin/env ruby -W0

=begin

  Welcome to Riccardo Carlesso first (private) library..

=end

require File.expand_path(File.dirname(__FILE__) + '/sakuric')

#$SAKURA_DFLTDIR = '~/git/sakura/'
$SAKURADIR      = Sakuric.BASEDIR # File.expand_path(ENV['SAKURADIR'] || $SAKURA_DFLTDIR)
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

def reload_doesnt_work_properly!(first_time=false,enable_debug=false)
  puts "[#{$$}] reload_doesnt_work_properly!(#{$0},#{first_time},#{enable_debug},#{$RELOADED_ONCE}) being called" if $RELOAD_DEBUG
  $RELOADED_ONCE += 1
  npass = $RICLIB['nreloaded']
  if npass > 1
    $stderr.puts "[ERR] More than first pass (pass=#{npass}): Should be quitting checcacchio!"
    #return 
  end
  debug_on("reload_doesnt_work_properly called with debug enabled!") if enable_debug
  str = "Reloaded Riclibs v#{$RICLIB_VERSION} -- per la #{$RICLIB['nreloaded']} a volta"
  first_time = false if $RICLIB['nreloaded'] > 1 
  modules_to_be_included = $RIC_LIB_MODULES + Sakuric.get_auto_files("classes/") 
  modules_to_be_included.each{ |cls| 
    was_necessary = require "#{$SAKURADIR}/lib/#{cls}.rb"
    deb "Pass[#{npass}] Loading: #{cls} (necessary: #{was_necessary})" rescue puts("nil #{$!}")
  }
  npass += 1
end


=begin
  Sto qui inizializza TUTTO cazzo, ho detto TUTTO, non voglio codice qui fuori!
  # puo' esser chiamato piu' volte...
  
  $RELOAD_DEBUG serve a debuggare il tutto.
=end
def _init(explaination='no explaination given', initial_debug_state = false)
  $RELOAD_DEBUG = false # 
  deb "pre init '#{explaination}'" if $RELOAD_DEBUG
  #$USER          = 'riccardo'
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
Finally solved the bug of double inclusion (cribsio, files included this!)
BURIDONE
  reload_doesnt_work_properly!(true) 
  $CONF = RicConf.new
  pyellow( riclib_info ) if debug?  
  puts "post init delle #{Time.now}" if $RELOAD_DEBUG
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
