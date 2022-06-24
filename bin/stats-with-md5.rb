#!/usr/bin/env ruby

require 'digest/md5'
require 'digest'


if RUBY_VERSION.split('.')[0] == 1
  puts "Refusing to launch a script form Ruby 1. Sorry Ric, its 2020 damn it!"
  exit 2020
end

=begin

  ############################################################
  @author:    Riccardo Carlesso
  @email:     riccardo.carlesso@gmail.com
  @maturity:  development
  @language:  Ruby
  @synopsis:  Brief Description here
  @tags:      development, rcarlesso, test
  @description: See description
 ############################################################

=end

$PROG_VER = '0.2'
$DEBUG    = true

require 'optparse'       # http://ruby.about.com/od/advancedruby/a/optionparser.htm


def deb(s);   puts "#DEB #{s}" if $DEBUG; end
# colors 16
def gray(s)    "\033[1;30m#{s}\033[0m" ; end
def green(s)   "\033[1;32m#{s}\033[0m" ; end
def red(s)     "\033[1;31m#{s}\033[0m" ; end
def yellow(s)  "\033[1;33m#{s}\033[0m" ; end
def blue(s)  "\033[1;34m#{s}\033[0m" ; end
def purple(s)  "\033[1;35m#{s}\033[0m" ; end
def azure(s)   "\033[1;36m#{s}\033[0m" ; end
def white(s)   "\033[1;37m#{s}\033[0m" ; end

# colors 64k
def orange(s)   "\033[38;5;208m#{s}\033[0m" ; end

# Program constants, automagically picked up by RicLib
# More configuration could be written in:
#    $GIC/etc/ricsvn/<FILENAME>.yml
# That would go into the variable '$prog_conf_d'
$myconf = {
    :app_name            => "AppName should be sth like #{$0}",
    :description         => "
        This program gets stats from Ruby File.Stats library
		plus computes MD5 or CRC32 of the file.
		And bakes it in a way that can be easily parsed. 
    ".strip.gsub(/^\s+/, "").gsub(/\s+$/, ""),
}
# This template from scripta.rb. from 2.1.0 removed aby ric gem dependency.
# 2022-04-26 2.1.1  Added more colors
# 2022-04-26 2.1.0  Historical momemnt: removed gem 'ric' dependency
$TEMPLATE_VER = '2.1.1'

def usage(comment=nil)
  puts white($optparse.banner)
  puts($optparse.summarize)
  puts("Description: " + gray($myconf[:description]))
  puts red(comment) if comment
  #puts "Description: #{ $myconf[:description] }"
  exit 13
end

# include it in main if you want a custome one
def init()    # see lib_autoinit in lib/util.rb
  $opts = {}
  # setting defaults
  $opts[:verbose] = false
  $opts[:dryrun] = false
  $opts[:debug] = false

  $optparse = OptionParser.new do |opts|
    opts.banner = "#{$0} v.#{$PROG_VER}\n Usage: #{File.basename $0} [options] file1 file2 ..."
    opts.on( '-d', '--debug', 'enables debug (DFLT=false)' )  {  $opts[:debug] = true ; $DEBUG = true }
    opts.on( '-h', '--help', 'Display this screen' )          {  usage }
    #opts.on( '-j', '--jabba', 'Activates my Jabber powerful CLI' ) {  $opts[:jabba] = true  }
    opts.on( '-n', '--dryrun', "Don't really execute code" ) { $opts[:dryrun] = true }
    opts.on( '-l', '--logfile FILE', 'Write log to FILE' )    {|file| $opts[:logfile] = file }
    opts.on( '-v', '--verbose', 'Output more information' )   { $opts[:verbose] = true}
  end
  $optparse.parse!
end

def compute_stats_and_md5(file)
	ret={}
	ret[:name] = file
	file_content = File.read(file)
	#ret[:md5_fake] = Digest::MD5.hexdigest 'abc'      #=> "90015098..."
	#ret[:md5_digest] = Digest::MD5.digest(file_content) #=> string with binary hash
	ret[:md5] = Digest::MD5.hexdigest(file_content) #=> string with hexadecimal digits
	#<File::Stat                     
	# dev=0x100000f,                  
	# ino=1247768,                    
	# mode=0100644 (file rw-r--r--),  
	# nlink=1,
	# uid=164825 (ricc),
	# gid=89939 (primarygroup),
	# rdev=0x0 (0, 0),
	# size=564,
	# blksize=4096,
	# blocks=8,
	# atime=2022-03-05 22:36:48.373362127 +0100 (1646516208),
	# mtime=2022-03-05 22:36:48.176789949 +0100 (1646516208),
	# ctime=2022-03-05 22:36:48.176789949 +0100 (1646516208)>
	stats = File.stat(file)
	ret[:stats_object] = stats # TODO deprecate
	ret[:size] = stats.size
	ret[:mode] = stats.mode
	# datetimes
	ret[:stat_birthtime] = stats.birthtime # eg,  2022-03-05 21:47:51 +0100 
	ret[:stat_mtime] = stats.mtime # eg,  2022-03-05 21:47:51 +0100 Returns the modification time of stat.
	ret[:stat_ctime] = stats.ctime # eg,  2022-03-05 21:47:51 +0100 Returns the change time for stat (that is, the time directory information about the file was changed, not the file itself). Note that on Windows (NTFS), returns creation time (birth time).
	ret[:stat_atime] = stats.atime # eg,  2022-03-05 21:47:51 +0100 Last Access
	ret[:stat_gid] = stats.gid     # Group Id
	ret 
end

def print_stats_and_md5(file, opts={})
	opts_color = opts.fetch :color, true
	stats = compute_stats_and_md5 file 
	colored_string = "[COL] #{red stats[:md5]} #{stats[:size]} #{stats[:stat_birthtime]} #{white stats[:name]}"
	boring_string =  "[B/W] #{    stats[:md5]} #{stats[:size]} #{stats[:stat_birthtime]} #{      stats[:name]}"
	puts(opts_color ? colored_string : boring_string) 
end

def real_program
  t0 = Time.now
  deb "+ Options are:  #{gray $opts}"
  deb "+ Depured args: #{azure ARGV}"
  # Your code goes here...
  puts "Description: '''#{white $myconf[:description] }'''"
  for arg in ARGV
	print_stats_and_md5(arg, :color => true)
  end
  tf = Time.now
  puts "# Time taken: #{tf-t0}"
end

def main(filename)
  deb "I'm called by #{white filename}"
  deb "To remove this shit, just set $DEBUG=false :)"
  init        # Enable this to have command line parsing capabilities!
  warn "[warn] template v#{$TEMPLATE_VER }: proviamo il warn che magari depreca il DEB"
  real_program
end

main(__FILE__)
