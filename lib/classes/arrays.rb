#!/usr/bin/env ruby

$arr_int = [10.5, 5.4, 40.3, 58.0, 9.9, 58.0 ]

 # doppioni code: http://snippets.dzone.com/posts/show/3838
module Enumerable
  def dups # pulito con solo elementi ALMENO doppi.
    inject({}) {|h,v| h[v]=h[v].to_i+1; h}.reject{|k,v| v==1}.keys
  end
  def dups_c # tutto l'arrai con doppioni e relativa cardinalita..
    inject({}) {|h,v| h[v]=h[v].to_i+1; h}.reject{|k,v| v==1 }      
  end
  def dups_indices   
    (0...self.size).to_a - self.uniq.map{ |x| index(x) }
  end
  
end

########################
# Array powerup class
class Array
  
  alias :to_s_secondo_ruby :to_s
  def to_s
    "[ #{join(', ').to_s} ]"
  end
  
    # ARGV: "-h -dn -aaa A B C" --> "A B C"
  def remove_options
    select{|x| ! x.match( /^-/ ) }
  end

    # mosso su OBJECT :-) 
  # def sort_on(something)
  #   sort{ |x,y| x.send(something) <=> y.send(something) }
  # end
    
  # EL penso debba essere ESATTO come match. NON una regex :(
  def from(el)
    return [] unless self.include?(el) 
    ix1 = self.index(el)
    ix2 = self.length
    self[ix1..ix2]
  end

  def to(el)
    return [] unless self.include?(el)
    ix2 = self.index(el)
    self[0..ix2]
  end
  
  def from_to(el1,el2)
    from(el1).to(el2)
  end
  
    # [1,2,3].join2('- ',"\n")    => "- 1\n- 2\n- 3\n"
  def join2(initial,final)
    initial + self.join(final+initial) + final
  end
  def join3(initial="'",middle="', '",final="'")
    initial.to_s + self.join(middle.to_s) + final.to_s
  end

  def map_to_hash
    map { |e| yield e }.inject({}) { |carry, e| carry.merge! e }
  end
  
  # sarebbe la figata con method_not_existent che plurali -> mappa i singolari tipo
  def names
    map{|x| x.name }
  end
  def quote(sep=nil)
    map{|x| x.quote(sep) }
  end
  def double_quote()
    map{|x| x.quote('"') }
  end
  def chomp_all
    map{|x| x.chomp }
  end
  def match(regex)
    each{|x| 
      ret  = x.match(regex) 
      return ret if ret
    }
    return nil
  end
  alias :matches :match
  
  # GREP
  alias :contains :include?
  alias :has      :include?
  
  def head
    self[0] # raise if empty
  end 
  
  def tail # TBOPT
    cp = Array.new(self)
    cp.shift
    return cp 
  end
  
  # Math
  def sum
    ret = 0
    self.each{ |el| 
      ret += el.to_f
    }
    ret
  end
  
  def average
    sum / size
  end
  alias :avg :average
  
  def scalar_product(arr2)
    #debug_on
    # assert size coincide
    throw "must be same size (self: #{size}) / arg: #{arr2.size})!!!" if( size != arr2.size )
    ret = 0.0
    for i in (0..size)
      deb "DEB #{self[i]} * #{arr2[i]}" 
      ret += ( self[i].to_f * arr2[i].to_f)
    end
    ret
  end
  alias :mul :scalar_product
  
  def weighted_average(weights)
    scalar_product(weights) / weights.sum
  end
  alias :wavg :weighted_average
  
  def prepend(str)
    map{|x| str+x}
  end
  def append(str)
    map{|x| x+str}
  end
  def chop_all
    map{|x| x.chop }
  end
  def trim_all
    map{|x| x.trim }
  end
  def quote_all
    map{|x| x.quote }
  end
  
  # options:
  #   :first_line_as_title (make it bold)
  # smart printf of an AoA like
  # [[ title1, title2, title3],
  #  [  arg1   arg2     arg3 ]
  # ....
  # printf with perfect %10d length
  def smart_printf(opts={})
    #debug_on :debugging_smart_printf
    printf_template = ''
    # assret its a AoA
    width=self[0].size
    deb width
    for k in (0 .. width-1) # { |k|
      max = self.map{|line| line[k].to_s.length }.max
      deb( [k, max].join(':'))
      printf_template += "%-#{max}s "
    end
    printf_template += "\n"
    deb("printf_template: #{printf_template}")
    #max_column_lengths = # self.map
    self.each{ |line| 
      #deb( line.join(", "), "\n") 
      puts( printf_template % line ) # [0], line[1]
    }
  end
  
  #def prepend_all(str);   map{|x| x.prepend(str) };  end
  
  alias :trim :trim_all
  # come UNIQ - C, returns uncity with cardinality into an elegant HASH :)
  # sort is inutile
  def uniq_c(min_cardinality = 1) # sort=false)
     hash=Hash.new
#     arr = sort ? self.sort : self 
     self.map{|x| hash[x] = (hash[x] + 1) rescue 1  }
     #self.uniq
     return hash.select{|k,v| v >= min_cardinality}
  end
  
  def color(regex, opts = {} )
    opts[:color] ||= :red
    map{|line| 
      line.gsub(regex) {|match|
        match.color(opts[:color])
        #match.class
      } 
    } rescue map{|line| line.gsub(/(b)/,green('b')) }
  end
  
    # [1,2,3,4,5] => [1,2,3,4]
  def remove_last
    return self[0.. self.size-2 ]
  end
  
  def egrep_v(regex)
    select{|line| ! line.match(regex) }
  end
  def egrep(regex)
     select{|line| line.match(regex) }
  end
   
  # string must NOT contain //, i.e. 'goliardia' or "zuppa|pambagnato"
  def evidenzia(string_or_array_or_regex, opts = {} )
    opts[:color] ||= :yellow
    color(autoregex(string_or_array_or_regex), opts)
  end
  # potrei metterlo in Enumerable...
  
    # find duplicates
    # if count, does what uniq -c does (returns occurrences as well)

  # def dups
  #   inject({}) {|h,v| h[v]=h[v].to_i+1; h}.reject{|k,v| v==1 }.keys
  # end
  def duplicates(count = false)
    count ? dups_c : dups
  end
  alias :doppioni :duplicates
  
    # copiato da srtsolution.com/public/blog/250508
  def method_missing(method_name, *args)
    method_name = method_name.to_s
    deb "Array.method_missing: called '#{method_name}' (class=#{method_name.class}) with args: #{ (args * ',') }"
    if m = method_name.match( /^(.*)_all$/)
      descr = "Calling on this array this function: " + white(" .map{|x| x.#{m[1]}(#{args.map{|x| x.to_s.quote}.join(', ')}) }")
      deb descr
      deb "DEB Figoso: I call #{m[1]} on the Array son, as an object, like obj.foo(args)"
      return self.map{|x| x.send(m[1], *args ) }
    end
    if method_name =~ /^map_(.*)$/
      deb "method_name matches map_SOMETHING!"
      return self.map{|x| x.send($1, *args ) }
    end
    if method_name =~ /^(.*)s$/
      pazure "Cool! Seems like you called a plural attribute over an array. It would be *SO* cool to call map.#{$1} but I dont trust myself enough, so its better that you use: #{green "map_#{$1}"}"
      return super #return self.map{|x| x.send($1, *args ) }
    end
    #super(self.object_id)
    #super(method_name, args)
    return true
  end
  
  # finds index of regex, per sicurezza stringihifico tutto
  def index_regex(regex)
    first_element = self.map{|x| x.to_s}.grep(regex).first
    #=> "cinque"
    #irb(main):015:0> $a.index( "cinque" )
    #el = self.grep(regex) # trova un elemento o piu elementi
    return index( first_element )
  end
  
end #/Array
