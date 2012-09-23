#!/usr/bin/env ruby

class String
  RICVERSION = '1.1'

  def basename
    split('/').last
  end
  
  def left(length,padding)
    mylen = self.length
    padding_char = padding[0] # troppo difficile fare che paddi "abc" su 8 fa "abcabcab" checcavolo :)
    mylen < length ?
      self + padding * (length - mylen) :
      self 
  end
  
  def color(mycolor = :orange )
    send(mycolor,self)
  end
  
  def uncolor()
    scolora(self)
  end
  
		# trovata qui: la mia funziona cmq
	# http://www.ruby-forum.com/topic/96222
	def to_class
		Object.const_get(self)
	end

  def nlines
    split("\n").size
  end
  
    # rimuove spazi a inizio e fine
  def trim
    self.gsub(/^\s+/,'').gsub(/\s+$/,'')
  end
  
  def escape_printf
     gsub("%",'%%')
  end
  
  def escape_double_quotes
    gsub('"','\"')
  end
  def escape_single_quotes
    gsub("'","\'")
  end
  
  # dumps string to file (in APPEND) :)
  def tee(opts={})
    filename = opts.fetch :file, __FILE__ + ".tmpric"
    verbose  = opts.fetch :verbose,  true
    preamble = lambda {|where| return "# Teeing string (pid=#{$$}, size=#{self.size}B, opts=#{opts}) into file: #{blue filename}\n" }
    deb "Teeing string (#{self.size}B, opts=#{opts}) into file: #{blue filename}"
    File.open(filename, 'a') {|f|
      f.write("# {{{  String.tee #{} from #{__FILE__}\n") if verbose
      f.write(preamble.call(:BEGIN)) if verbose
      f.write(self)
      f.write("\n" + preamble.call(:END))if verbose
      f.write("\n# }}} Tee stop pid=##{$$}\n")if verbose
    } # i think it closes it here...
    puts "Written #{self.size}B in append to: '#{yellow filename}'" if verbose
    return self
  end

=begin
  return string with regex highlighted
  
  TODO highlight just the matching regex
=end
  def grep_color(regex, opts={} )
    deb "string grep_color(regex: '#{regex}')"
    color   = opts[:color]   || true # false
    verbose = opts[:verbose] || true # TODO false
    return red(self) if self.match(regex)
    return verbose ?
      self :
      ''
  end
  
  # Doesnt work. Look at ~/bin/uptimes for a VERY nice implementation
  # def color_grep(regex, mycolor, opts={} )
  #   #deb "string grep_color(regex: '#{regex}' w/ color='#{mycolor}')"
  #   color   = opts[:color]   || true # false
  #   return self.gsub(regex, $1.color(mycolor)) if self.match(regex)
  #   return self
  # end
  
  alias :right :left
  
  def flag(nation)
    flag(self, flag = '')
  end
  
    # enclose string in single quotes..
  def quote(sep = nil)
    sep ||= "'"
    sep + self + sep
  end
  def double_quote(); quote('"') ; end
  
  def depurate_for_file 
    gsub(/[\/: \.]/ , '_')
  end

  def prepend(str)
    str.to_s+self
  end
  def append(str)
    self+str.to_s
  end
  
  # a: b
  # c: d 
  # --> 
  def to_hash(description='String::to_hash() made by genious RCarlesso (give a better description if u dont like this!)')
    arr = Hash.new
    arr['_meta']  = Hash.new
    arr['_meta']['description'] = description
    arr['_meta']['time'] = Time.now
    self.split("\n").each{|line| 
      k,v = line.split(': ') 
      arr[k.strip] = v.strip 
      } rescue arr['_meta']['errors'] = $! 
    arr
  end
  
  # serio
  def start_with? prefix
    prefix = prefix.to_s
    self[0, prefix.length] == prefix
  end
	alias :starts_with? :start_with?
	alias :begins_with? :start_with?
	alias :begin_with? :start_with?
  
    # 'abcde' => '*****'
  def asterisks(ch='*')
    ch * (self.size)
  end
  
  def shorten (count = 50)
     if self.length >= count
       shortened = self[0, count]
       splitted = shortened.split(/\s/)
       words = splitted.length
       splitted[0, words-1].join(" ") + ' ...'
     else
       self
     end
   end
#   alias :excerpt :shorten
# no dai, in realta excerpt sarebbe con SEARCH di parola e ci orla intorno...

  # sanitizza un filename
  def sanitize_path
    gsub(/[\/: ]/,'_')
  end

  # see arrays!
  # def method_missing
  # end
  
  def to_html
    %(<span class="ricsvn_string" >#{self}</span>)
  end
  
  def initial;  self[0..0] ; end 
  
  
  # canonicalize: delete leading and trailing spaces, replaces newlines
  # with one space and then replace all continuouse spaces with one ' '
  # (including tabs and other fancy things)
  
  # non funziona bene perche non so come CACCHIO mappare il /g.
  # oare che in ruby ci sia solo /i x(xtended)  n(multiline)
  def canonicalize
    value = self
    value = value.gsub( /^\s+/,  '')  # s/^\s+//;
    value = value.gsub( /\s+$/,  '')  # value =~ s/\s+$//;
    value = value.gsub( /\r*\n/n, ' ')  # value =~ s/\r*\n/ /g;
    value = value.gsub( /\s+$/n , ' ')  # value =~ s/\s+$/ /g;
    deb "Original:  '''#{self}'''"
    deb "Canonical: '''#{value}'''"
    return value
  end
  
  # a manhouse :-(
  if String.method_defined?(:singolarizza)
    $stderr.puts '#DEB 1 Attenzione! Singolarizza already defined within string. Bypassing. PS Fallo per tutta la classe String usando un prestanome tipo $ric_sticazzi = 42 e checka su di lui'
  else
    #$stderr.puts "#DEB 2 Singolarizza: prima definizione (string='#{self.inspect}')..."
    def singolarizza
      return self.singularize if self.respond_to?(:singularize)
      deb("singularize '#{self}'")
      m = self.match( /(.*)es$/)  # i.e. matches
      return m[1] if (m)
      m = self.match( /(.*)s$/)
      return m[1] if m
      return m
    end
  end

=begin
  greppa dalla prima occorrenza di FROM in poi
=end
  
  def from_first_line_matching(regex_from)
    arr_lines = self.split("\n")
    ix1 = arr_lines.index_regex(regex_from) || 0
    if ! ix1
      throw "Cattivo Indice per arr_lines. Non greppa una fava con: #{regex_from}"
      ix1 = 0
    end
    ix2 = arr_lines.length
    deb "#{ix1}..#{ix2}"
    joint = arr_lines[ix1..ix2].join("\n") #rescue ''
    return joint 
  end
  
  def to_first_line_matching(regex_from)
    arr_lines = self.split("\n")
    ix2 = arr_lines.index_regex(regex_from)
    #ix2 = arr_lines.length
    return arr_lines[0..ix2].join("\n")
  end

end #/Class String


################################################################################
### Miscellaneous string functions
################################################################################

def clear_screen
  print "\e[2J\e[f"
end
alias :clear :clear_screen

def title(s)
  title_n(s)
end
def title_n(s,n=2)
  "== #{s} =="
end

  

LOREM_IPSUM = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin at purus id ante pulvinar dapibus. Donec risus justo, gravida ac vulputate a, lacinia eget leo. Duis quam tellus, tempus at feugiat a, eleifend et velit. Donec et enim id libero malesuada luctus nec at nibh. Sed elit est, interdum sit amet sollicitudin ac, vulputate eget metus. In hac habitasse platea dictumst. Cras vitae justo at turpis elementum sollicitudin. Etiam quis quam placerat erat tincidunt fermentum. Ut vel mauris magna. Vestibulum luctus leo eget lectus gravida ac dignissim enim vestibulum. Integer facilisis mi sed justo aliquet a lacinia lacus scelerisque.
Aliquam sed purus vel felis euismod pharetra eu a ipsum. Suspendisse potenti. Mauris aliquet, lorem id mattis ornare, dolor mauris tincidunt tellus, ac feugiat urna sem eget diam. Nulla venenatis urna et elit lobortis eleifend. Ut feugiat adipiscing nisi vitae accumsan. Aliquam ullamcorper odio a nibh scelerisque non tincidunt urna ullamcorper. Sed vitae eleifend quam. Nunc vulputate vulputate viverra. Duis eu enim eros. Nunc lacinia nibh neque, sit amet varius arcu.
Maecenas facilisis porttitor vestibulum. Phasellus nisl elit, porttitor id pulvinar nec, malesuada quis lectus. Suspendisse lacinia odio vitae eros molestie suscipit. Vivamus eu nulla ac augue adipiscing luctus. Curabitur rhoncus placerat dui a consectetur. Integer suscipit felis vitae eros mattis cursus. Integer sollicitudin ante in risus feugiat tincidunt sed sit amet libero. Nunc molestie lorem ut nulla aliquam viverra. Etiam bibendum mollis mattis. Phasellus ipsum tortor, egestas consequat sollicitudin non, hendrerit eu tortor. Nam at magna ipsum, non convallis ligula. Etiam ac eros a nunc elementum bibendum vitae vitae lacus. Vivamus placerat quam sit amet urna mattis in luctus nulla venenatis. Praesent tempus egestas interdum. Nulla facilisi. Nulla id ligula et nunc egestas dictum sed sodales tellus. Integer vestibulum commodo mauris, blandit porta lectus tincidunt quis. Vestibulum varius est eu turpis ultrices pellentesque.
Donec aliquam elit quis augue tristique id lacinia augue laoreet. Duis placerat tellus eget urna vehicula volutpat. Vestibulum tortor dui, ultricies quis luctus sed, ultricies sit amet dui. Sed nec magna ac mauris imperdiet venenatis in id velit. Vestibulum non nibh nisi, eu elementum metus. Integer porttitor scelerisque pharetra. Maecenas eu tincidunt augue. Donec viverra diam lacinia ligula rhoncus viverra. Cras dictum rhoncus nisi sit amet malesuada. Quisque consectetur sollicitudin magna, nec faucibus nulla lacinia ac. Donec accumsan gravida odio, nec vehicula enim hendrerit sed. Etiam in mauris et mi sollicitudin congue non sit amet augue. Praesent nisi tortor, posuere vehicula rutrum interdum, tincidunt non tortor. Aliquam adipiscing mollis odio, eget accumsan lectus blandit sed. Sed tristique, ipsum eu laoreet dignissim, nunc nisi rhoncus tellus, sed molestie turpis ante vitae orci. Nullam tincidunt suscipit ligula sit amet sodales. Curabitur auctor tempus rutrum.
Donec non venenatis lectus. Ut imperdiet felis quis augue viverra pellentesque. Duis sodales, magna at tincidunt volutpat, turpis tellus auctor lacus, et mollis ante odio in tellus. Aliquam euismod tempor aliquam. Vivamus at eros eget felis consequat faucibus dignissim consequat diam. Cras et dolor sagittis mi pharetra tincidunt vitae a tortor. Vestibulum at dictum augue. Sed commodo magna quis lectus bibendum accumsan. Aliquam consectetur feugiat augue, eget suscipit mi mattis ac. Donec at tristique lorem. Nulla non nisl sed felis volutpat ullamcorper." unless defined?(LOREM_IPSUM)

def lorem_ipsum(len=0)
  len == 0 ? 
    LOREM_IPSUM :
    LOREM_IPSUM[0..len]
end
alias :lorem :lorem_ipsum

  # supports: strings, arrays and regexes :)
  # @returns a Regexp
def autoregex(anything)
  deb "Autoregex() supercool! With a #{blue anything.class}"
  case anything.class.to_s
    when 'String' 
      if anything.match(/^\/.*\/$/) # '/asd/' is probably an error! The regex builder trails with '/' automatically
        fatal 23,"Attention, the regex is a string with trailing '/', are you really SURE this is what you want?!?"
      end
      return  Regexp.new(anything)
    when 'Regexp'
      return anything # already ok
    when 'Array'
      return Regexp.new(anything.join('|'))
    else
      #msg = "#{__FILE__}.#{__LINE__}: autoregex() Exception: Unknown class for autoregexing: #{red anything.class}"
      msg = "Unknown class for autoregexing: #{red anything.class}"
      $stderr.puts( msg )
      raise( msg )
  end
  return nil
end

