#!/usr/bin/env ruby

require 'digest/md5'
require 'digest'
require 'socket'
require 'optparse'       # http://ruby.about.com/od/advancedruby/a/optionparser.htm
require 'date' # for DateTime
require 'tempfile'

if RUBY_VERSION.split('.')[0] == 1
  puts "Refusing to launch a script form Ruby 1. Sorry Ric, its 2020 damn it!"
  exit 2020
end

$PROG_VER = '0.4'
$DEBUG    = false
$reset_autowrite_file_reincarnation = 0
DEFAULT_MAX_FILES = 'Infinite'

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

def usage(comment=nil)
  puts white($optparse.banner)
  puts($optparse.summarize)
  puts("Description: " + gray($myconf[:description]))
  puts red(comment) if comment
  exit 13
end

def reset_autowrite_file()
	$autowrite_file = "# #{File.basename $0} Autowrite v1.0 #{Time.now} reincarnation=#{$reset_autowrite_file_reincarnation}\n"
	$reset_autowrite_file_reincarnation += 1 # ($reset_autowrite_file_reincarnation + 1) # rescue 1
end 

# include it in main if you want a custome one
def init()    # see lib_autoinit in lib/util.rb
  $opts = {}
  # setting defaults
  $opts[:verbose] = false
  $opts[:dryrun] = false
  $opts[:debug] = false
  $opts[:autowrite] = false
  $opts[:color] = true
  $opts[:max_files] = nil # infinite

  reset_autowrite_file()

  $optparse = OptionParser.new do |opts|
    opts.banner = "#{$0} v.#{$PROG_VER}\n Usage: #{File.basename $0} [options] file1 file2 ..."
    opts.on( '-a', '--autowrite', 'automatically writes results to Root Folder (DFLT=false)' )  {  $opts[:autowrite] = true  }
    opts.on( '-c', '--no-color', 'disables color (DFLT=false, that is color enabled)' )  {  $opts[:color] = false  }
    opts.on( '-d', '--debug', 'enables debug (DFLT=false)' )  {  $opts[:debug] = true ; $DEBUG = true }
    opts.on( '-h', '--help', 'Display this screen' )          {  usage }
    opts.on( '-m', '--max-files NUMBER', "sets max files per Dir to X (DFLT=#{DEFAULT_MAX_FILES})" ) {|nfiles| $opts[:max_files] = nfiles.to_i }
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

$print_stats_and_md5_version = "1.1a_220624_F" # files
$print_stats_and_md5_counter = 0
$print_stats_and_md5_for_gcs_version = "1.1alpha_220628_G" #GCS bucket

def stats_and_md5_number_of_files_processed()
	return $print_stats_and_md5_counter 
end

def smells_like_gcs?(file)
	file =~ /gs:\/\//
end

# You give me gs://bucket123/path/to/dir
def print_stats_and_md5_for_gcs(mybucket_with_subdir, opts={})
#	opts_color = opts.fetch :color, true#
#	opts_verbose = opts.fetch :verbose, false 
#	opts_ping_frequency = opts.fetch :ping_frequency, 50
	opts_max_files = opts.fetch :max_files, nil # BigDecimal('Infinity')
	opts_autowrite = opts.fetch :autowrite, false

	raise "Wrong GCS Path: #{mybucket_with_subdir}" unless smells_like_gcs?(mybucket_with_subdir)
	#puts "0. mybucket_with_subdir: #{mybucket_with_subdir}" # gs://mybucket123/path/to/dir
	path_split = mybucket_with_subdir.split('/')
	mybucket = path_split[0,3].join('/')      # gs://mybucket123/
	gcs_subpath = path_split[3,42].join('/')  # path/to/dir
	cleanedup_bucket = path_split[2]          # mybucket123
	#puts "1. mybucket: #{mybucket}"
	#puts "2. gcs_subpath: #{gcs_subpath}"
	#puts "3. cleanedup_bucket: #{cleanedup_bucket}"
	
	puts("[print_stats_and_md5_for_gcs] version=#{$print_stats_and_md5_for_gcs_version} host=#{Socket.gethostname}(#{`uname`.chomp}) created_on='#{Time.now}' bucket=#{mybucket} subpath=#{gcs_subpath}")
	begin 
		require "google/cloud/storage"
		project_id = `gcloud config get project 2>/dev/null`
		deb "project_id: #{project_id}"
		storage = Google::Cloud::Storage.new(project_id: project_id)
		bucket = storage.bucket(cleanedup_bucket)
		# grabs them ALL if nil, optherwise its an integer.
		files = opts_max_files.nil? ? 
			bucket.files :                          # nil -> all of them (I've tried sth more idiomatic like -1 or nil or Infinite. they all failed.)
			bucket.files.first(opts_max_files)      # not nil -> first(N)
		#puts(files)
		deb("All Sorted Methods: #{files.first.methods.sort}")
		files.each do |gcs_file|
			md5 = Base64.decode64(gcs_file.md5).unpack('H*')[0]  # md5 in base64 -> then de-binarizied: Base64.urlsafe_decode64(md5).unpack('H*')[0]
			size = gcs_file.size # crc rescue :boh
			time_created = gcs_file.created_at
			mode = 'XXXXXX' # for compatbility with files
			file_type = gcs_file.name.to_s =~ /\/$/ ? 'd' : 'f' # if ends with a slash its a DIR :P
			#puts("[OLD_GCS_v11] #{md5} #{size}\t#{time_created} [#{gcs_file.content_type}]\t#{gcs_file.name}")
			print_colored_polymoprhic('gcs_v1.2', md5, mode, file_type, size, gcs_file.content_type, time_created, gcs_file.name, opts)
			deb gcs_file.to_yaml
		end
		#puts("Hash Methods: #{files.first.methods.select{|x| x.match /hash/}}")
	rescue LoadError # require Exception 
		puts 'Error with library #{$!}, maybe type: gem install google-cloud-storage'
	rescue Exception # generic Exception 
		puts "print_stats_and_md5_for_gcs(): Generic Error: #{$!}"
		exit 1
	end

	autowrite_to_dir_or_gcs(:gcs, mybucket_with_subdir) if opts_autowrite
end 

# Generic polymorpghic coloring, can be GCS. Would have been nice to pass a Dict so easier to extend, but Ruby doesnt support doesblt Dict with magic args. Plus might be a GOOD
# thing its hard to change since it breaks Storazzo.
# TODO(ricc): make sure the dates are the same. Currently:
# GCS Date:  2021-12-20T12:26:13+00:00  DateTime
# File Date: 2022-05-30 11:55:42 +0200  Time
def print_colored_polymoprhic(entity_type, md5, mode, file_type, size, content_type, creation_time, filename, opts={})
	opts_color = opts.fetch :color, true
	opts_verbose = opts.fetch :verbose, false 
	opts_ping_frequency = opts.fetch :ping_frequency, 50
	opts_autowrite = opts.fetch :autowrite, false

	# Increment counter across all!
	$print_stats_and_md5_counter += 1 # global counter! I should increment at the END of fucntion.. but you never know if i exit wrongly so i do at beginning. so within this function the real #files is N-1 (i.e., if N is 6, we're processing file %5)
	# in main i had to put 2 branched to invoke a single thing but if logic changes that sentence might be printed twice. Instead here, the BEGIN line could be nice to do here instead.
	#$stderr.puts("print_stats_and_md5() Fikst invocation! Consider moving the 2 things in main here :)") if ($print_stats_and_md5_counter == 1)
	#puts("[print_stats_and_md5] version=#{$print_stats_and_md5_version} host=#{Socket.gethostname}(#{`uname`.chomp}) created_on=#{Time.now}") if ($print_stats_and_md5_counter == 1)
	$stderr.puts "-- print_stats_and_md5(v#{$print_stats_and_md5_version}): #{$print_stats_and_md5_counter - 1} files processed --" if (($print_stats_and_md5_counter) % opts_ping_frequency == 1 )

	maybecolored_md5 = opts_color ? red(md5) : md5
	maybecolored_filename = opts_color ? azure(filename) : filename
	enlarged_size = sprintf("%7o", size.to_s ) # or SIZE 
	maybecolored_size = opts_color ? yellow(enlarged_size) : enlarged_size
	maybecolored_file_type = file_type
	colored_content_type = opts_color ? white(content_type) : content_type
	if opts_color 
		maybecolored_file_type = case file_type
		when 'f' then green(file_type)
		when 'd' then blue(file_type)
		when 's' then azure(file_type)
		else red(file_type)
		end
	end	
	standardized_creation_time = creation_time.is_a?(DateTime) ? 
		creation_time : 
		DateTime.parse(creation_time.to_s) # if you prefer to use Time since its already supported by Storazzo (but its ugly since it has SPACES! so hard to parse) use tt = Time.parse(d.to_s)
		# as per https://stackoverflow.com/questions/279769/convert-to-from-datetime-and-time-in-ruby
	#puts "#{maybecolored_md5} #{mode} #{maybecolored_file_type} #{maybecolored_size}\t#{creation_time}(DEB #{creation_time.class})(DEB2 #{DateTime.parse(creation_time.to_s)}) [#{colored_content_type}] #{maybecolored_filename}"
	# this mightr be colored
	str = "[#{entity_type}] #{maybecolored_md5} #{mode} #{maybecolored_file_type} #{standardized_creation_time} #{maybecolored_size} [#{colored_content_type}] #{maybecolored_filename}\n"
	# this will NEVER be colored. WARNING, now you need to maintain TWO of these beasts :/
	non_colored_str = "[#{entity_type}] #{md5} #{mode} #{file_type} #{standardized_creation_time} #{enlarged_size} [#{content_type}] #{filename}\n"
	if(opts_autowrite)
		# need to guarantee this is NOT colored. The easiest way to do it is TWICVE as expensive but... whatevs.
		# TODO(ricc): fire me for this lazimness!
		$autowrite_file += (non_colored_str)
	end
	print(str)
	return str
end

def print_stats_and_md5(file, opts={})
	return print_stats_and_md5_for_gcs(file, opts) if smells_like_gcs?(file)

	opts_color = opts.fetch :color, true
	opts_verbose = opts.fetch :verbose, false 
	opts_ping_frequency = opts.fetch :ping_frequency, 50

	
	# $print_stats_and_md5_counter += 1 # global counter! I should increment at the END of fucntion.. but you never know if i exit wrongly so i do at beginning. so within this function the real #files is N-1 (i.e., if N is 6, we're processing file %5)

	# # in main i had to put 2 branched to invoke a single thing but if logic changes that sentence might be printed twice. Instead here, the BEGIN line could be nice to do here instead.
	# #$stderr.puts("print_stats_and_md5() Fikst invocation! Consider moving the 2 things in main here :)") if ($print_stats_and_md5_counter == 1)
	# puts("[print_stats_and_md5] version=#{$print_stats_and_md5_version} host=#{Socket.gethostname}(#{`uname`.chomp}) created_on=#{Time.now}") if ($print_stats_and_md5_counter == 1)
	# $stderr.puts "-- print_stats_and_md5(v#{$print_stats_and_md5_version}): #{$print_stats_and_md5_counter - 1} files processed --" if (($print_stats_and_md5_counter) % opts_ping_frequency == 1 )

	#puts "print_stats_and_md5: #{file}" if opts_verbose
	stats = compute_stats_and_md5 file 
	#maybecolored_md5 = opts_color ? red(stats[:md5]) : stats[:md5]
	#maybecolored_filename = opts_color ? azure(stats[:name]) : stats[:name]
	#maybecolored_size = opts_color ? white(stats[:size]) : stats[:size]
	mode  = sprintf("%06o", stats[:mode] ) rescue :ERROR # .to_s.right(4)        #=> "100644"
	file_type = stats[:stat_ftype][0] rescue '?'
	file_type = 's' if File.symlink?(file)
	content_type = `file --mime-type -b '#{file}' 2>/dev/null`.chomp # .split(': ',2)[1]

	#colored_string = "[COL] #{red stats[:md5]} #{stats[:size]} #{stats[:stat_safebirthtime]} #{white stats[:name]}"
	#boring_string =  "[B/W] #{    stats[:md5]} #{stats[:size]} #{stats[:stat_safebirthtime]} #{      stats[:name]}"
	#puts(opts_color ? colored_string : boring_string)
	#puts "[OLDv1.1deprecated] #{maybecolored_md5} #{mode} #{file_type} #{maybecolored_size} #{stats[:stat_safebirthtime]} #{maybecolored_filename}"
	print_colored_polymoprhic('file_v1.2', stats[:md5], mode, file_type,  stats[:size], content_type, stats[:stat_safebirthtime], stats[:name], opts)
end

def autowrite_to_dir_or_gcs(fs_type, path, opts={})
    autowrite_version = "1.1_28jun22"
	file_to_save = "stats-with-md5.log"
	path_to_save = path + "/" + file_to_save
	puts(red "TODO(ricc): write results [size=#{$autowrite_file.size}] in this Directory: #{path_to_save}") if fs_type == :dir
	puts(red "TODO(ricc): write results [size=#{$autowrite_file.size}] in this GCS Bucket or Dir: #{path_to_save}") if fs_type == :gcs

	##########################################################################
	# do the thing: creates file locally and moves to GCS or Dir.
	##########################################################################
	$autowrite_file += "# [autowrite_to_dir_or_gcs v#{autowrite_version}]: about to write it now. #{Time.now}"
	tmpfile = Tempfile.new(path_to_save)
	tmpfile.write($autowrite_file)
	cmd = :no_cmd_yet
	
	if fs_type == :gcs
		cmd = "gsutil mv '#{tmpfile.path}' #{path}/#{file_to_save}"
	end
	if fs_type == :dir
		cmd = "mv '#{tmpfile.path}' #{path}/#{file_to_save}"
	end

	puts("TMP File is this big: #{azure tmpfile.size}")
	puts("About to execute this: #{white cmd}")
	ret = `#{cmd}`
	if $?.exitstatus != 0
		puts "Error to execute: #{red cmd}. Exit: #{red $?.exitstatus}"
		exit 53
	end
	puts "Command returned: '#{$?.exitstatus}'" #  - #{$?.class}"
	# wow: fork { exec("ls") }

	# removes the tmpfile :)
	tmpfile.close 
	tmpfile.unlink

	#####################################
	# finished, lets now clean up the file...
	#####################################
	reset_autowrite_file()
	return :ok
end

def print_stats_and_md5_for_directory(directory_to_explore_recursively, opts={})
	puts "# [print_stats_and_md5_for_directory] DIR to explore (make sure you glob also): #{directory_to_explore_recursively }"
	puts "# DEB Options: #{opts}"

	opts_autowrite = opts.fetch :autowrite, false

	Dir.glob("#{(directory_to_explore_recursively)}/**/*") do |globbed_filename|
		# Do work on files & directories ending in .rb
		#puts "[deb] #{globbed_filename}" 
		print_stats_and_md5(globbed_filename, :color => $opts[:color], :verbose => $opts[:verbose], :autowrite => $opts[:autowrite])
	end

	autowrite_to_dir_or_gcs(:dir, directory_to_explore_recursively) if opts_autowrite
end 

def real_program
  t0 = Time.now
  deb "+ Options are:  #{gray $opts}"
  deb "+ Depured args: #{azure ARGV}"
  # Your code goes here...
  #puts "Description: '''#{white $myconf[:description] }'''"
  #puts("[print_stats_and_md5] version=#{$print_stats_and_md5_version}  host=#{Socket.gethostname}(#{`uname`.chomp}) created_on=#{Time.now}") if ARGV.size > 0

  common_opts = {
	:max_files => $opts[:max_files], 
	:color => $opts[:color], 
	:verbose => $opts[:verbose],
	:autowrite => $opts[:autowrite],
  }

  if ARGV.size == 1
	directory_to_explore_recursively = ARGV[0]
    if smells_like_gcs?(directory_to_explore_recursively)
		print_stats_and_md5_for_gcs(directory_to_explore_recursively, common_opts)
	else # normal file..
		print_stats_and_md5_for_directory(directory_to_explore_recursively, common_opts)
	end
  elsif ARGV.size > 1
	deb "2. I expect a lot of single files or directories:"
    for arg in ARGV
		if File.directory?(arg)
			print_stats_and_md5_for_directory(arg, common_opts )
		else
	   		print_stats_and_md5(arg, common_opts)
		end
    end
  else
	puts "No args given. Exiting"
	exit 41
  end
  tf = Time.now
  puts "# [#{File.basename $0}] Time taken for processing #{stats_and_md5_number_of_files_processed} files: #{tf-t0}"
end

def main(filename)
  deb "I'm called by #{white filename}"
  deb "To remove this shit, just set $DEBUG=false :)"
  init        # Enable this to have command line parsing capabilities!
  real_program
end

main(__FILE__)
