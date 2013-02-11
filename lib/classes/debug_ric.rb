

# copied from Mixins in Programming ruby book, pag 119

module RicDebug
  puts "DEBUG: including module RicDebug, as a mixin within #{self.class}"

  def whoami?
    "#{self.class.name} (\##{self.object_id}): #{self}"
  end

  def trace()
    puts "== Riccardo Debug Trace program (excuse verboity) =="
    puts "File: #{__FILE__}"
    #TODO put verbose context like call stack, ...  
  end

  def to_verbose_s()
    whoami?
  end
end



################################################################################################################
# DEBUG AND ERRORS
################################################################################################################

$_debug_tags = []

=begin
  
  This is a denbug with steroids

  Introduced tags: NORMAL deb() works.
  If you launch debug_on('reason', :tags => [ :this, :foo, :bar])
  from this moment on normal debug is prevented unless you debug using the explicit tags..

  Il vecchio debug era:
  debug (s, :really_write => true,:write_always => false ) 

=end

def debug(s, opts = {} )
  out = opts.fetch(:out, $stdout)
  tag = opts.fetch(:tag, '_DFLT_')
  really_write = opts.fetch(:really_write, true) # you can prevent ANY debug setting this to false
  write_always = opts.fetch(:write_always, false)

  raise "ERROR: ':tags' must be an array in debug(), maybe you meant to use :tag?" if ( opts[:tags] && opts[:tags].class != Array )
  final_str = "#RDeb#{write_always ? '!' : ''}[#{opts[:tag] || '-'}] #{s}"
  final_str = "\033[1;30m" +final_str + "\033[0m" if opts.fetch(:coloured_debug, true) # color by gray by default
  if (debug_tags_enabled? ) # tags
    puts( final_str ) if debug_tag_include?( opts )
  else # normal behaviour: if NOT tag
    puts( final_str ) if ((really_write && $DEBUG) || write_always) && ! opts[:tag]
  end
end #/debug()
alias :deb :debug

def debug_tags_enabled?
  $_debug_tags != []
end

def debug_tag_include?(opts)
  assert_array($_debug_tags, 'debug_tags')
  assert_class( opts[:tag], Symbol, "tag must be a symbol, ", :dontdie => true ) if opts[:tag]
  assert_array( opts[:tags] , 'opts[:tags]' ) if opts[:tags]
  return $_debug_tags.include?(opts[:tag].to_sym) if opts[:tag]
  return ($_debug_tags & opts[:tags]).size > 0    if opts[:tags]
  #return $_debug_tags.include?(tag_or_tags.to_sym) if (tag.class == String || tag.class == Symbol)
  return false
end


def debug_on(comment="enabling debug (SVNID=#{$SVN_ID rescue 'ERR'})", opts={} )
  $DEBUG = true
  deb "debug_on(): #{comment}"
  _manage_debug_tags(opts)
  if opts[:tags]
    deb "debug_on(): new tags enabled (#{opts[:tags]}). Now ONLY debug called explicitly with one of those tags will work! To go back to normal behaviour just run: 'debug_reset_tags()'"
  end
end 
def debug_off(comment="Disabling DEBUG for once in a while :)", opts={})
  deb "debug_off(): #{comment}" 
  $DEBUG = false 
end

def debug_tags
  $_debug_tags
end
def debug_reset_tags
  $_debug_tags = []
end
def deb2(str)
  debug "(ERR) #{str}", :out => $stderr, :tag => 'stderr' # , :really_write => true,:write_always => false,
end
def stradebug(str)
  deb str, :tags => %w(verbose stradebug vvv)
end
alias :stradeb :stradebug

##################### 
# All the foloowing has been transferred to 'ric' gem
# to be removed in the future..

# if DEBUG is true, then execute the code
def deb?() 
	yield if $DEBUG
end
alias :if_deb  :deb?
alias :if_deb? :deb?

def debug?()
  $DEBUG == true
end

def debo(obj)
  deb "debo: #{obj.ispeziona}"
end

def err(str)
	$stderr.puts "ERR[RicLib] #{$0}: '#{str}'"
end

def fatal(ret,str)
	err "#{get_red 'RubyFatal'}(#{ret}) #{str}"
	exit ret
end

def warning(s)
	err "#{yellow 'WARN'} #{s}"
end 

#def d()
#  flag( "Cielcio (TBS arlecchinami di colori)", 'it')
#end
#def tbd(comment="TODO")
#  puts "#{white :TBD} (#{__FILE__}:#{__LINE__}): #{comment}"
#  raise "TBD_EXCEPTION! ''#{comment}''"
#end

# copiato da: 
# http://stackoverflow.com/questions/622324/getting-argument-names-in-ruby-reflection
$shadow_stack = []

set_trace_func( lambda {
  |event, file, line, id, binding, classname|
  if event == "call"
    $shadow_stack.push( eval("local_variables", binding) )
  elsif event == "return"
    $shadow_stack.pop
  end
} )

def obsolete(msg)
  puts "#{pink '_OBSOLETE_'} (#{file_line}): #{red msg}"
  #deb "TBD dammi la traccia chiamante, cazzo! Local functions: #{eval( 'local_variables') }"
  pgray("Obsolescense:\n -- " + caller().join("\n -- "))
end

# copiato da qui: http://www.caliban.org/ruby/rubyguide.shtml#style
def silently(&block)
  deb( "[DEBUG] Calling silently! warn_level is '#{$VERBOSE}'" )
  warn_level = $VERBOSE
  $VERBOSE = nil
  result = block.call
  $VERBOSE = warn_level
  result
end

  # TBD sposta in altro file
class RicException < Exception
  attr_reader :description, :options
  
  def initialize(str,opts={})
    description = str
    opts = options
    super(str)
  end
  
  def to_s
    "Ric_Exception (figata direi!): '''#{red description}'''"
  end
end  #/RicException

private
  def _manage_debug_tags(opts)
    #puts "_manage_debug_tags: #{opts}"
    $_debug_tags ||= []
    $_debug_tags += opts[:tags] if opts[:tags]
    #$_debug_tags << opts[:tag]  if opts[:tag]
    $_debug_tags = $_debug_tags.uniq
    #puts "$_debug_tags: #{$_debug_tags} (#{$_debug_tags.map{|x| x.class}})"
    deb "_manage_debug_tags(): new tags are: #{$_debug_tags}", :tag => :debug
  end
