#!/usr/bin/env ruby

require 'digest/md5'
require 'digest'
require 'socket'
require 'optparse'       # http://ruby.about.com/od/advancedruby/a/optionparser.htm

if RUBY_VERSION.split('.')[0] == 1
  puts "Refusing to launch a script form Ruby 1. Sorry Ric, its 2020 damn it!"
  exit 2020
end

$PROG_VER = '0.3'
$DEBUG    = false

=begin

  ############################################################
  @author:    Riccardo Carlesso
  @email:     riccardo.carlesso@gmail.com
  @maturity:  development
  @language:  Ruby
  @tags:      development, rcarlesso, test
  @works_on:  Linux (little tested since v0.3), Mac (100% developed here)
 ############################################################

=end



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
  exit 13
end

# include it in main if you want a custome one
def init()    # see lib_autoinit in lib/util.rb
  $opts = {}
  # setting defaults
  $opts[:verbose] = false
  $opts[:dryrun] = false
  $opts[:debug] = false
  $opts[:color] = true

  $optparse = OptionParser.new do |opts|
    opts.banner = "#{$0} v.#{$PROG_VER}\n Usage: #{File.basename $0} [options] file1 file2 ..."
    opts.on( '-c', '--no-color', 'disables color (DFLT=false)' )  {  $opts[:color] = false  }
    opts.on( '-d', '--debug', 'enables debug (DFLT=false)' )  {  $opts[:debug] = true ; $DEBUG = true }
    opts.on( '-h', '--help', 'Display this screen' )          {  usage }
    opts.on( '-n', '--dryrun', "Don't really execute code" ) { $opts[:dryrun] = true }
    opts.on( '-l', '--logfile FILE', 'Write log to FILE' )    {|file| $opts[:logfile] = file }
    opts.on( '-v', '--verbose', 'Output more information' )   { $opts[:verbose] = true}
  end
  $optparse.parse!
end

def getSafeCreationTime(file)
	File.ctime(file)
end

def compute_stats_and_md5(file)
	ret={}
	ret[:name] = file

	begin
		stats = File.stat(file)
		ret[:stats_object] = stats # TODO deprecate
		deb("Stats methods: #{stats.methods.sort.join(', ')}")
		#deb(stats.ftype)
		#puts(stats.methods)
		deb(stats.ctime)
		#puts(stats.birthtime rescue (stats.ctime))

		# On Mac:
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

		# On LInux:
		#<File::Stat                                
		#  dev=0xfe01,                                
		#  ino=6293055,                               
		#  mode=0100644 (file rw-r--r--),             
		#  nlink=1,                                   
		#  uid=164825 (ricc),                         
		#  gid=89939 (primarygroup),                  
		#  rdev=0x0 (0, 0),                           
		#  size=7,                                    
		#  blksize=4096,                              
		#  blocks=8,                                  
		#  atime=2022-06-27 08:49:38.586706861 +0200 (1656312578),
		#  mtime=2022-03-23 14:28:45 +0100 (1648042125),
		#  ctime=2022-05-30 10:12:10.381629305 +0200 (1653898330)>
		ret[:size] = stats.size
		ret[:mode] = stats.mode
		# datetimes
		ret[:stat_safebirthtime] = getSafeCreationTime(file) # in Mac uses birthtime,but on Linux wont work
#			defined?(stats.birthtime) ? # rescue stats.mtime # eg,  2022-03-05 21:47:51 +0100 on Mac (not implemented on my Linuix)#
#			stats.birthtime : # works on Mac 
#			stats.ctime
		ret[:stat_mtime] = stats.mtime # eg,  2022-03-05 21:47:51 +0100 Returns the modification time of stat.
		ret[:stat_ctime] = stats.ctime # eg,  2022-03-05 21:47:51 +0100 Returns the change time for stat (that is, the time directory information about the file was changed, not the file itself). Note that on Windows (NTFS), returns creation time (birth time).
		ret[:stat_atime] = stats.atime # eg,  2022-03-05 21:47:51 +0100 Last Access
		ret[:stat_gid] = stats.gid     # Group Id
		ret[:stat_uid] = stats.uid     # UUID
		ret[:stat_ftype] = stats.ftype     # 
		
		ret[:md5] = '______________NONE______________'
		if stats.ftype != "directory"
			file_content = File.read(file)
			ret[:md5] = Digest::MD5.hexdigest(file_content) # rescue 'none                             ' #=> string with hexadecimal digits
		end
	rescue Errno::EISDIR => e 
		#puts "It's a dir, nothing I can do here except skipping the stuff"
		ret[:md5] = "_________I'm a dir sorry________" 	
	rescue Exception => e 
		ret[:error] = e
	end
	ret 
end

$print_stats_and_md5_version = "1.1a_220624"
$print_stats_and_md5_counter = 0

def stats_and_md5_number_of_files_processed()
	return $print_stats_and_md5_counter 
end

def print_stats_and_md5(file, opts={})
	opts_color = opts.fetch :color, true
	opts_verbose = opts.fetch :verbose, false 
	opts_ping_frequency = opts.fetch :ping_frequency, 50
	$print_stats_and_md5_counter += 1 # global counter! I should increment at the END of fucntion.. but you never know if i exit wrongly so i do at beginning. so within this function the real #files is N-1 (i.e., if N is 6, we're processing file %5)

	# in main i had to put 2 branched to invoke a single thing but if logic changes that sentence might be printed twice. Instead here, the BEGIN line could be nice to do here instead.
	#$stderr.puts("print_stats_and_md5() Fikst invocation! Consider moving the 2 things in main here :)") if ($print_stats_and_md5_counter == 1)
	puts("[print_stats_and_md5] version=#{$print_stats_and_md5_version}  host=#{Socket.gethostname}(#{`uname`.chomp}) created_on=#{Time.now}") if ($print_stats_and_md5_counter == 1)

	$stderr.puts "-- print_stats_and_md5(v#{$print_stats_and_md5_version}): #{$print_stats_and_md5_counter - 1} files processed --" if (($print_stats_and_md5_counter) % opts_ping_frequency == 1 )

	#puts "print_stats_and_md5: #{file}" if opts_verbose
	stats = compute_stats_and_md5 file 
	maybecolored_md5 = opts_color ? red(stats[:md5]) : stats[:md5]
	maybecolored_filename = opts_color ? azure(stats[:name]) : stats[:name]
	maybecolored_size = opts_color ? white(stats[:size]) : stats[:size]
	mode  = sprintf("%06o", stats[:mode] ) rescue :ERROR # .to_s.right(4)        #=> "100644"
	file_type = stats[:stat_ftype][0] rescue '?'

	#colored_string = "[COL] #{red stats[:md5]} #{stats[:size]} #{stats[:stat_safebirthtime]} #{white stats[:name]}"
	#boring_string =  "[B/W] #{    stats[:md5]} #{stats[:size]} #{stats[:stat_safebirthtime]} #{      stats[:name]}"
	#puts(opts_color ? colored_string : boring_string)
	puts "#{maybecolored_md5} #{mode} #{file_type} #{maybecolored_size} #{stats[:stat_safebirthtime]} #{maybecolored_filename}"
end

def real_program
  t0 = Time.now
  deb "+ Options are:  #{gray $opts}"
  deb "+ Depured args: #{azure ARGV}"
  # Your code goes here...
  #puts "Description: '''#{white $myconf[:description] }'''"
  #puts("[print_stats_and_md5] version=#{$print_stats_and_md5_version}  host=#{Socket.gethostname}(#{`uname`.chomp}) created_on=#{Time.now}") if ARGV.size > 0

  if ARGV.size == 1
    directory_to_explore_recursively = ARGV[0]
	deb "1. I expect a single arg with DIR to explore: #{blue directory_to_explore_recursively }"
	Dir.glob("#{(directory_to_explore_recursively)}/**/*") do |globbed_filename|
		# Do work on files & directories ending in .rb
		#puts "[deb] #{globbed_filename}" 
		print_stats_and_md5(globbed_filename, :color => $opts[:color], :verbose => $opts[:verbose])
	  end
  elsif ARGV.size > 1
	deb "2. I expect a lot of single files:"
    for arg in ARGV
   		print_stats_and_md5(arg, :color => $opts[:color], :verbose => $opts[:verbose])
    end
  else
	puts "No args given. Exiting"
	exit 41
  end
  tf = Time.now
  puts "# Time taken for processing #{stats_and_md5_number_of_files_processed} files: #{tf-t0}"
end

def main(filename)
  deb "I'm called by #{white filename}"
  deb "To remove this shit, just set $DEBUG=false :)"
  init        # Enable this to have command line parsing capabilities!
  #warn "[warn] template v#{$TEMPLATE_VER }: proviamo il warn che magari depreca il DEB"
  real_program
end

main(__FILE__)
