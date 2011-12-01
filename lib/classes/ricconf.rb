  # $Id$

=begin
  Nella mia mente malvagia e maliziosa, questa classe dovrebbe contenere tutta la mia configurazione...
  Meglio una classe che un insieme di metodi a cazzo di cane, che dici? La uso piu' per scope (protezione/namespace)
  che per ereditarieta' e menate varie... vorrei poter dire: RicConf.inspect e avere tutto il buridone di configurazione
  e null'altro...
=end

$RIC_SVNUSER ||= 'riccardo'
# TODO9 questa variabile a tendere dovrebbe essere distrutta e sostituita da $prog_conf nel programma devel..
$devel_conf = YAML.load(File.read("#{$SAKURADIR}/etc/sakura/devel.yml")) # dato che ci accedo da devel.rb

def ric_services
  sane_service_regex = /^[a-z_\.-]+$/
  arr_services = [
     hostconf('services') , # .split(',').trim_all,  # host_services = 
     networkconf('services'), # .split(',').trim_all ,
  ] rescue [ "Eccezione: #{$!}" ]
  deb arr_services
  return arr_services.compact.flatten.join(',').split(',').trim_all.select{|srv| 
		# TODO rimuovi le right vuote
		# next if srv == ''
    ok = srv.match(sane_service_regex) 
    deb("ricconf.rb:#{__LINE__} Beware, illegal service here: ''#{red srv}'' (services: #{gray arr_services.join(', ')})") unless ok
    ok
  }
end


class RicConf
  attr_accessor :ver, :home, :user, :svn, :nreloads, :path
  $obsolete_tags = %w{ sobenme sobenme_services sobenme_tags hea lavoro SobenmeGlobalConfDistObsolete }
  
  def initialize()
    #puts "DEB RicConf::initialize(): Initializing a new #{self.class}"
    self.ver      = $RICLIB_VERSION
    self.home     = $HOME
    self.user     = $USER || get_username # = 'riccardo'
    self.path     = ENV['PATH'].split(':').uniq.sort # = 'riccardo'
    self.svn      = ENV['SVNRIC'] 
    self.nreloads ||= 0
    self.nreloads += 1   # lo riassegna quindi vale sempre uno a ogni costruzione..
  end
  
  def to_s
    "RicConf: #{yellow self.inspect}"
  end
  
  # after migration svn!
  def SVNRIC
    File.expand_path(ENV['SVNRIC'] || "~/git/gic" ) 
  end
  
    # x is a string
  def cool_eval(x)
    y = (eval(x.to_s)) rescue "CoolEvalEsception: '#{$!}'"
    deb "CoolEval('#{yellow x}' (#{x.class})) --> ''#{azure(y)}'' (class=#{y.class})"
    return y
  end
  
  def get_tags()
    deb "$network_conf is a #{$network_conf.class}"
    deb "$host_conf is a #{$hostconf.class}"
    [ '$host_conf', '$network_conf', '2+3', 'RicConf' ].each{|var| 
      # x = 'var.inspect()'
      #       y = eval(x)
      #       deb "Supercool: Evaluing('#{x}') for #{blue var} (#{var.class}) --> #{azure(y)} (class=#{y.class})"
      cool_eval(var)
    }
   # my_network_tags = $network_conf['tags'] rescue []
    tags = { 
    #  :conf_network => my_network_tags.split(',') ,
      :ENV_TAGS     => ENV['HOST_TAGS'].split(','),
      :ENV_SRVS     => ENV['HOST_SERVICES'].split(','),
    }
    tags[:conf_host]    = $host_conf['tags'].split(',') rescue [] # fatal("Conf missing for this host: #{$!}")
    tags[:conf_network] = $network_conf['tags'] .split(',') rescue [] # fatal("Conf missing for this host: #{$!}")
    tags.each{|k,v|
      deb "#{k}: #{v}"  
    }
    cleanup_tags = tags.values.flatten.compact.map{|x| x.strip }.uniq.sort
    deb tags.inspect
    # obsolete tags:
    my_obsolete_tags =  cleanup_tags & $obsolete_tags 
    deb "#Obsolete tags: #{red(my_obsolete_tags.map{|tag| "'#{tag}' from #{tags.map{|k,v| k if v.match(tag) }.compact }"}) }"
    return cleanup_tags - $obsolete_tags
  end
  
end # /RicConf

def get_username
  $USER ||= `whoami`.strip
end
alias :username :get_username

def get_tags()
  RicConf.new.get_tags
end

# Terminal stuff
def supports_64k_colors?
  good_terminals = %w{ iTerm.app } # these support 64k, i.e. orange
  bad_terminals = %w{ Apple_Terminal }  # these support only 16 colors, i.e. red
  my_terminal = ENV['TERM_PROGRAM'].to_s
  return true if good_terminals.include?(my_terminal)
  return false if bad_terminals.include?(my_terminal)
  raise "Unknown terminal #{red my_terminal.quote}, please define me in: #{yellow __FILE__}"
  return nil
end
