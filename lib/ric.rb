#!/usr/bin/env ruby -W0

=begin

  Welcome to Riccardo Carlesso first (private) library..

=end

# was: 'SVNRIC'
$SAKURADIR = File.expand_path(ENV['SAKURADIR'] || '~/git/sakura/') 

$git_conf = {
  #:svn_id => "$Id$",
  :ver    => '0.10.02',
  :use_ric_gem => false
}
#$git_conf[:svn_last_rev] = $git_conf[:svn_id].split(' ')[2]
$RICLIB_VERSION = $git_conf[:ver] # now dry { }"0.9.009"

#NON VA in alcune macchine! Nescio cur! require 'rubygems'     # necessary for other gems
require 'digest/md5'
require 'digest/sha1'
require 'net/smtp'
require "socket"
require 'yaml'

if $git_conf[:use_ric_gem] # slow but cool
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

    # conf files into auto/ dir (mi son rotto di aggiungerli qui uno a uno!)
  def _get_auto_files(subdir)
    absolute_dir = "#{$SAKURADIR}/lib/#{subdir}"
    Dir.new(absolute_dir).select{|f| f.match( /\.rb$/ )}.map{|x| subdir + File.basename(x,'.rb') }
  end

def reload_doesnt_work_properly!(first_time=false,enable_debug=false)
  puts "[#{$$}] reload_doesnt_work_properly!(#{$0},#{first_time},#{enable_debug},#{$RELOADED_ONCE}) being called" if $RELOAD_DEBUG
  $RELOADED_ONCE += 1
  npass = $RICLIB['nreloaded']
	if npass > 3
		deb "More than first pass: quitting checcacchio!"
		#return 
	end
  debug_on("reload_doesnt_work_properly called with debug enabled!") if enable_debug
  str = "Reloaded Riclibs v#{$RICLIB_VERSION} -- per la #{$RICLIB['nreloaded']} a volta"
  first_time = false if $RICLIB['nreloaded'] > 1 
  modules_to_be_included = $RIC_LIB_MODULES + _get_auto_files("auto/") + _get_auto_files("classes/") 
  modules_to_be_included.each{ |cls| 
    was_necessary = require "#{$SAKURADIR}/lib/#{cls}.rb"
    deb "Pass[#{npass}] Loading: #{cls} (necessary: #{was_necessary})" rescue puts("nil #{$!}")
  }
end


=begin
  Sto qui inizializza TUTTO cazzo, ho detto TUTTO, non voglio codice qui fuori!
  # puo' esser chiamato piu' volte...
  
  $RELOAD_DEBUG serve a debuggare il tutto.
=end
def _init(explaination='no explaination given')
  #debug_off
 $RELOAD_DEBUG = false # 
 deb "pre init '#{explaination}'" if $RELOAD_DEBUG
 $SCRIP_BEGUN = Time.now
 $SVN_ID = "$Id$".split[3] # .quote non ancora def azz!
 $USER = 'riccardo'
 $INIT_DEBUG = false   # dice se debuggare la mia intera infrastruttura o no...
 $RELOADED_ONCE = 0    # aiuta a capuire quante volte includo sta cazo di lib! Sempre 2!!!
 $RIC_LIB_MODULES = %w{ debug_ric 
  arrays hashes strings 
  network architecture nil 
  assertions configurator  
  ricconf heanet files twitter ricldap riccache console util ricsvn
 } # unless defined?($RIC_LIB_MODULES)
 # Removed:
 # - rails/riclife_ar 
 # - ric_colors

 $HOME = File.expand_path('~')
 $DEBUG ||= false 
 $PROG = File.basename($0)

  ################################################################################
  # fake data for some tests :)
 $a = [1 ,2 ,3, '4', 'cinque', :simbolo ] rescue nil
 $h = { :key => 'value', :answer => 42 , 'float' => 4.2 , :sym => 'bol', :foo => 'bar1 (symbol)', "foo" => 'bar2 (symbol)' } # rescue nil
 $s = "This is a test string with some color TBD and some @tags @personal ok?!?"
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
    Questa libreria contiene tutto il mio sapere enciclopedico, ovvero nozionistico. :P
    ho finalmente risolto il baco della doppia inclusion (cribsio, files includeva questo!)
  BURIDONE
  reload_doesnt_work_properly!(true) 
  $CONF = RicConf.new
  $SVN_ID="$Id$".split[3].quote rescue "No SVN Id causa migrazione!"
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
  dirs             = opts.fetch :dirs,          ['.', '~', '/etc/']
  file_patterns    = opts.fetch :file_patterns, [".#{confname}.yml", "#{confname}/conf.yml"]
  sample_hash      = opts.fetch :sample_hash,   { 'load_auto_conf' => "please add an :sample_hash to me" , :anyway => "I'm in #{__FILE__}"}
  verbose          = opts.fetch :verbose,       true
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
  puts "Conf not found. Try this:\n---------------------------\n$ cat > ~/#{file_patterns.first}\n#{yellow "#Creatd by ric.rb:load_auto_conf()\n" +sample_hash.to_yaml}\n---------------------------\n"
  raise "LoadAutoConf: configuration not found for '#{confname}'!"
  return sample_hash
end

## CALL THE INIT! YAY!
_init("inizializzo alle #{Time.now}") 

#end /module Carlesso
