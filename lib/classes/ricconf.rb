=begin
  Nella mia mente malvagia e maliziosa, questa classe dovrebbe contenere tutta la mia configurazione...
  Meglio una classe che un insieme di metodi a cazzo di cane, che dici? La uso piu' per scope (protezione/namespace)
  che per ereditarieta' e menate varie... vorrei poter dire: RicConf.inspect e avere tutto il buridone di configurazione
  e null'altro...
=end

require 'yaml'

$RIC_SVNUSER ||= 'riccardo'
# TODO9 questa variabile a tendere dovrebbe essere distrutta e sostituita da $prog_conf nel programma devel..
$devel_file = File.read("#{$SAKURADIR}/etc/sakura/devel.yaml")
$devel_conf = YAML.load($devel_file) # dato che ci accedo da devel.rb

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
  attr_accessor :ver, :home, :user, :svn, :nreloads, :path, :gic, :arch, :net
  $obsolete_tags = %w{ sobenme sobenme_services sobenme_tags hea lavoro SobenmeGlobalConfDistObsolete }
  $default_gic_repo = "~/git/gic" 
  
  def _get_username()
    if self.user == nil
      #$USER = `whoami`
      self.user = ENV['USER']
    else
      return self.user
    end
    #whoami = %x{ whoami }
    #$USER = whoami # .strip("\n")
    # .strip() strip de che?!? Che argpmento, spazio? \n?
    #return $USER
  end
  alias :username :_get_username
  
  def initialize()
    #puts "DEB RicConf::initialize(): Initializing a new #{self.class}"
    self.ver      = $RICLIB_VERSION.split("\n")[0]
    self.home     = $HOME
    self.user     = nil
    self.user     = self._get_username()
    self.path     = ENV['PATH'].split(':').uniq.sort # = 'riccardo'
    self.svn      = self.SVNRIC()
    self.gic      = ENV['GIC'] 
    self.arch     = ENV['RICGIC_ARCHITECTURE'] 
    self.net      = ENV['RICGIC_NETWORK'] 
    self.nreloads ||= 0
    self.nreloads += 1   # lo riassegna quindi vale sempre uno a ogni costruzione..
  end
  
  def to_s
    "RicConf: #{yellow self.inspect}"
  end
  
  def info()
    ret = "= RicConf.info() =\n"
    #print "#{self.inspect().class} =\n"
    #{}"{self.to_s()}"
    self.instance_variables().each do |k|
      ret += "- #{k}:\t#{instance_variable_get(k)}\n"
    end
    return ret
  end
  
  # after migration svn!
  def SVNRIC
    File.expand_path(ENV['SVNRIC'] || ENV['GIC'] || $default_gic_repo ) 
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


def get_tags()
  RicConf.new.get_tags()
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
