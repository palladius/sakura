#!/usr/bin/env ruby

  # PLease forgive me this is going to be obsoleted soon
  
module RicColorsObsolete
  
  $debug_pad_colors = nil # try: [ '(',')']
  $colors_active = false

  $color_db = [
    %w{ normal  black2 black   dkblack  red     green brown   blue midngihtblue purple  cyan  lgray   gray     lred    lgreen  yellow lblue violet azure   white  orange   orange2  orangey  magenta lyellow  pink     dkpink   gold     dkgreen carminio vermiglio bordeaux kawasaki azure2   indigo } , # english word
    %w{ normale nero2  nero    nerone   rosso   verde marrone blu  bluenotte    porpora ciano grigino grigione rossino verdino giallo lblu  viola  azzurro bianco arancio  arancio2 arancino magenta giallino rosa     rosino   oro      verdone carminio vermiglio bordo    kawasaki azzurro2 indaco } , # italian word
    %w{ 0;37    0;30  38;5;233 38;5;236 0;31    1;32  38;5;94 0;34 38;5;17      1;35    0;36  0;37    1;30     1;31    1;32    1;33   1;34  1;35   1;36    1;37   38;5;208 38;5;166 38;5;222 0;35    38;5;229 38;5;204 38;5;203 38;5;214 38;5;28 38;5;196 38;5;125  38;5;89  38;5;119 38;5;45  38;5;57 } ,
    %w{ 000     000    111     222      f00     0f0           00f  191970       ff0     0ff   aaa     888      f00     afa     ff0                                                                    eebb00 } # HEX RGB
    ]

  def colors_on
    set_color :on #(true)
  end
  def colors_off
    set_color(false)
  end
  
    # TODO support a block (solo dentro l blocco fai il nocolor)
  def set_color(bool)
    b = bool ? true : false
    deb "Setting color mode to: #{yellow bool} --> #{white b.to_s}"
    b = false if bool.to_s.match( /(off|false)/ )
    deb "Setting color mode to: #{yellow bool} --> #{white b.to_s}"
    if block_given?
      puts "TODO!!! scolara qui"
      yield
      puts "TODO ricolora qui"
    end
    $colors_active = bool
  end
  alias :set_colors :set_color

  def bash_color(n, str  )
    "\033[#{n}m#{str}\033[0m"
  end

  def pcolor(color_name='red',str='COLOR: please define a string')
    if $colors_active
      puts colora(color_name,str)
    else
      puts str
    end
  end

  def visible_color(s)
    !( s.match(/nero|black/) )
  end


  def colora(color_name='green',str='string to be coloured', opts={})
    color_name = color_name.to_s
    str = $debug_pad_colors ? $debug_pad_colors.join(str) : str                    # Adding '(2πi)'
    return str unless $colors_active
    return str if opts[:nocolor]
    if ix = $color_db[0].index(color_name) 
      bash_color($color_db[2][ix],str)
    elsif ix = $color_db[1].index(color_name)
      bash_color($color_db[2][ix],str)
    else
      debug "Sorry, unknown color '#{color_name}'. Available ones are: #{$color_db[0].join(',') }"
    end
  end

  alias :p :puts

  def color_test(with_italian = false)
    i=0
    palette = $color_db[0].map { |c|
      inglese  = c
      italiano = $color_db[1][i]
      i = i+1
      colora( c, with_italian ? [c,italiano].join(','): c )
    }
    puts( (1..257).map{|c| bash_color( "38;5;#{c}", c) }.join(', ') )
    puts( palette.sort{|a,b| a.to_s.gsub(/[^a-z]/,'') <=> b.to_s.gsub(/[^a-z]/,'') }.join(' ')) # sort on a-z chars only (no color)
    _flag_nations.sort.each{|nation|
      puts "- Flag sample for #{nation}:\t" + flag("ThisIsAFlaggedPhraseBasedOnNation:#{nation}",nation)
    }
  end
  alias :colortest :color_test

  # carattere per carattere...
  def rainbow(str)
    i=0
    ret = '' 
    str=str.to_s
    while(i < str.length)
      ch = str[i]
      palette = $color_db[0][i % $color_db[0].length ]
      ret << (colora(palette,str[i,1]))
      i += 1
    end
    ret
  end
  alias  :arcobaleno :rainbow


=begin
#########################################
# Dynamic functions
#########################################
#assert(color_db[0].length == color_db[1].length,"English and italian colors must be the same cardinality!!!")
# TODO ripeti con , $color_db[1] 

  This created for every color three fucntions, for instance something like this:
  
  def get_yellow(str='...')

=end
( $color_db[0] + $color_db[1] ).each { |colorname|
   dyn_func = "
   
  #def get_$colorname(str= 'colors.rb: get_color() dynamically generated ENGLISH COLOR but you forgot to give a string')
  def get_#{colorname}(str='colors.rb: get_color() dynamically generated ENGLISH COLOR but you forgot to give a string')
    return colora('#{colorname}',str)
  end
  
  def #{colorname} (str='colors.rb: COLOR dynamically generated ENGLISH COLOR TO BE COPIED TO GET')
    return colora('#{colorname}',str) rescue 
       \"Errore #{colorname} con stringa '#"+"{str}' e classe #"+"{str.class} \"
  end
  
  def p#{colorname} (str='colors.rb: pCOLOR dynamically generated ENGLISH COLOR TO BE DESTROYED')
    puts colora('#{colorname}',str)
  end 
"
    eval dyn_func unless method_defined?( "get_#{colorname}".to_sym )
}

def okno(bool,str=nil)
  str ||= bool
  bool = (bool == 0 ) if (bool.class == Fixnum) # so 0 is green, others are red :)
  return bool ? green(str) : red(str)
end

def colors_flag(nation = 'it')
  %w{ red white green }
end

  # "\e[0;31m42\e[0m" --> "42"
  # \e[38;5;28mXXXX    -> "XXX"
def scolora(str)
  str.to_s.
    gsub(/\e\[1;33m/,''). # colori 16
    gsub(/\e\[0m/,''). # colori 64k
    gsub(/\e\[38;\d+;\d+m/,'') # end color
end
alias :uncolor :scolora

  # italia:  green white red
  # ireland: green white orange
  # france:  green white orange
  # UK:      blue white red white blue
  # google:
def _flag_nations
  %w{ar cc it de ie fr es en goo br po pt }.sort
end
def flag(str, flag = '')
  case flag.to_s
    when 'ar'
    	    return flag3(str, 'azure2', 'white', 'cyan') 
    when 'br','pt'
        return flag3(str, 'dkgreen', 'gold', 'dkgreen') 
    when 'cc'
             return flag3(str, 'red', 'white', 'red')  # switzerland
    when 'de'
             return flag3(str, 'dkblack', 'red',   'gold')
    when 'ie','gd','ga'
   return flag3(str, 'dkgreen', 'white', 'orange')# non so la differenza, sembrano entrambi gaelici! 
    when 'en'
             return flag3(str, 'red', 'blue', 'red') # red white blue white red white blue white ... and again
    when 'es'
             return flag3(str, 'yellow', 'red', 'yellow') 
    when 'fr'
             return flag3(str, 'blue', 'white', 'red') 
    when 'goo','google'
   return flag_n(str, %w{ blue red yellow blue green red } ) 
    when 'it'
           return flag3(str, 'dkgreen', 'white', 'red')
    when 'po'
           return flag2(str, 'white', 'red')
    when ''
             return flag3(str + " (missing flag1, try 'it')")
  end
   return flag3(str + " (missing flag2, try 'it')")
end

  # for simmetry padding
  # m = length / 3
  # 6: 2 2 2        m   m   m    REST 0
  # 5: 2 1 2       m+1  m  m+1        2
  # 4: 1 2 1        m  m+1  m         1
def flag3(str,left_color='brown',middle_color='pink',right_color='red')
  m = str.length / 3
  remainder = str.length % 3
  central_length = remainder == 1 ? m+1 : m 
  lateral_length = remainder == 2 ? m+1 : m 
  colora( left_color,   str[ 0 .. lateral_length-1] ) + 
  colora( middle_color, str[ lateral_length .. lateral_length+central_length-1] ) + 
  colora( right_color,  str[ lateral_length+central_length .. str.length ] )  
end
def flag2(str,left_color='brown',right_color='pink')
  flag_n(str, [left_color, right_color] )
end

def flag_n(str,colors)
  size = colors.size
  #debug_on :flag6
  ret = ""
  m = str.length / size # chunk size
  deb m
  (0 .. size-1).each{|i|
    #deb "Passo #{i}"
    chunk = str[m*(i),m*(i+1)]
    #deb chunk
    ret += colora(colors[i], chunk )
  }
  #deb str.split(/....../)
  #remainder = str.length % 6
  #return ret + " (bacatino)"
  # central_length = remainder == 1 ? m+1 : m 
  # lateral_length = remainder == 2 ? m+1 : m 
  # colora(  left_color,    str[ 0 .. lateral_length-1] ) + 
  #   colora( middle_color, str[ lateral_length .. lateral_length+central_length-1] ) + 
  #   colora( right_color, str[ lateral_length+central_length .. str.length ] )  
  return ret
end


###################################################################################################################
# COLORS LIBRARY
=begin
  nero)   shift; echo -en "\033[0;30m$*\033[0m\n" ;;
  rossone)  shift; echo -en "\033[0;31m$*\033[0m\n" ;;
  verdone)  shift; echo -en "\033[0;32m$*\033[0m\n" ;;
  marrone)  shift; echo -en "\033[0;33m$*\033[0m\n" ;;
  bluino)     shift; echo -en "\033[0;34m$*\033[0m\n" ;;
  porpora)  shift; echo -en "\033[0;35m$*\033[0m\n" ;;
  ciano)    shift; echo -en "\033[0;36m$*\033[0m\n" ;;
  grigino)    shift; echo -en "\033[0;37m$*\033[0m\n" ;;

  grigione) shift; echo -en "\033[1;30m$*\033[0m\n" ;;
  rosso)    shift; echo -en "\033[1;31m$*\033[0m\n" ;;
  verde)    shift; echo -en "\033[1;32m$*\033[0m\n" ;;
  giallo)   shift; echo -en "\033[1;33m$*\033[0m\n" ;;
  blu)      shift; echo -en "\033[1;34m$*\033[0m\n" ;;
  viola)    shift; echo -en "\033[1;35m$*\033[0m\n" ;;
  azzurro)    shift; echo -en "\033[1;36m$*\033[0m\n" ;;
  bianco)   shift; echo -en "\033[1;37m$*\033[0m\n" ;;

  arancio)  shift; echo -en "\033[5;31m$*\033[0m\n" ;;
  
  colour_codes = {
          'black':        '\033[0;30m',
          'red':          '\033[0;31m',
          'green':        '\033[0;32m',
          'yellow':       '\033[0;33m',
          'blue':         '\033[0;34m',
          'magenta':      '\033[0;35m',
          'cyan':         '\033[0;36m',
          'white':        '\033[0;37m',
          'darkgray':     '\033[1;30m',
          'br-red':       '\033[1;31m',
          'br-green':     '\033[1;32m',
          'br-yellow':    '\033[1;33m',
          'br-blue':      '\033[1;34m',
          'br-magenta':   '\033[1;35m',
          'br-cyan':      '\033[1;36m',
          'br-white':     '\033[1;37m',
          'ul-black':     '\033[4;30m',
          'ul-red':       '\033[4;31m',
          'ul-green':     '\033[4;32m',
          'ul-yellow':    '\033[4;33m',
          'ul-blue':      '\033[4;34m',
          'ul-magenta':   '\033[4;35m',
          'ul-cyan':      '\033[4;36m',
          'ul-white':     '\033[4;37m',
          'default':      '\033[0m'
  }
=end

  class RicColor < String
    attr :color
  
    def initialize(mycol)
      super
      @color = mycol
    end
  
    # should this work at all?!?
    def to_s
      'RicColor: ' + self.send(@color)
    end
    
    def print(s)
      #"RicColor.print(): #{ self.send('get_' + @color, s) }"
      print render(s)
    end
    
    def render(str, opts={})
      color_name = @color
      #return str unless $colors_active
      #return str if opts[:nocolor]
      if ix = $color_db[0].index(color_name) 
        bash_color($color_db[2][ix],str)
      elsif ix = $color_db[1].index(color_name)
        bash_color($color_db[2][ix],str)
      else
        debug "Sorry, unknown color '#{color_name}'. Available ones are: #{$color_db[0].join(',') }"
      end
    end
  
    def to_html
      "<font color=\"#{@color}\" >#{self}</font>"
    end
  end #/Class RicColor

  def terminal
    ENV['TERM_PROGRAM'] || 'suppongo_ssh'
  end

  def daltonic_terminal?()
    return !! terminal.to_s.match( /Apple_Terminal/ )
  end

end # /module

#require 'ric'


include RicColorsObsolete
$colors_active = ! RicColor.daltonic_terminal? # DEFAULT: active
