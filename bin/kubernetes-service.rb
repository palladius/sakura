#!/usr/bin/env ruby 

if RUBY_VERSION.split('.')[0] == 1
  puts "Refusing to launch a script form Ruby 1. Sorry Ric, its 2020 damn it!"
  exit 2020
end

minimal_version = "2.7"
unless Gem::Version.new(RUBY_VERSION) >= Gem::Version.new(minimal_version)
	puts "Refusing to launch as script needs filter_array which requires v2.7.\nUmglaublughly your version is #{RUBY_VERSION}"
	exit 27
end

$PROG_VER = '2.2'
$DEBUG    = false

# 2.1 Moved to sakura for having the world seeing this amazing crown jewel. Unfortunately a small dependency is NOT in sakura yet. Bear with me.
# 2.0 had to obsolete this hottibler GCP_COLONED_ENDPOINT1 as I was giving it BOTH IPs and static endpoints for GCP
#     so i moved to both names and halt the program if I find the old one. Hopegully it'll nbe clearer thanks to patching also the help.
# 1.1 amazing

require 'ric'
require 'optparse'       # http://ruby.about.com/od/advancedruby/a/optionparser.htm
require 'dotenv'
require ENV['GICLIB'] + "ruby2/figata2021"
include ModuloFigata2021

# Program constants, automagically picked up by RicLib
# More configuration could be written in:
#    $GIC/etc/ricsvn/<FILENAME>.yml
# That would go into the variable '$prog_conf_d'
$myconf = {
    :app_name            => "kubernetes-service ruby-reloaded", # should be sth like #{$0}",
    :description         => "
        Vuole essere un super generico kubectl-service che tira SU e giu la roba
        Leggendo da .env tutti i parametri che interessano :)
        Tipo:
        - GKE_CREDENTIALS_COMMAND
        - GCLOUD_CONFIG_NAME (che registra ilk cos di sopra)
        - addirittura:     gke-setup-loadbalancer-and-dns.sh 
        - GCP_STATIC_IP_NAME1 CLOUD_DNS_NAME1 che va da 1 a 10 forse...
        - anzi piu coeso fare GCP_COLONED_ENDPOINT1 dove so io che hai 'STATIN_NAME:HOST.palladius.it'

        ENV files:
        - GCP_COLONED_ENDPOINT1 :DEPRECATED as I was confused from thw two followint and started using BOTH which is wrong until i got an error or using one for another...
        - IP_DNS_MAPPING: Something like '1.2.3.4:myhost.example.com' (usuallty for LoadBalancer deployment)
        - GCP_ENDPOINT_DNS_MAPPING: somerthing like 'my-static-ip-endpoint:myhost.example.com' (usually for Nodeport Deployments)
    ".strip.gsub(/^\s+/, "").gsub(/\s+$/, ""),
    :default_env => ".env",
    :default_kubedir => ".", # "kubernetes/",
    :mandatory_keys => %w{ PROJECT_ID GCLOUD_CONFIG_NAME NAMESPACE GKE_CREDENTIALS_COMMAND },
    # inutile e nmon usato..
    #:additional_keys => %w{ GCP_COLONED_ENDPOINT__SINGLEDIGIT GCP_STATIC_IP_NAME1 CLOUD_DNS_NAME1 GCP_STATIC_IP_NAME2 CLOUD_DNS_NAME2  GCP_COLONED_ENDPOINT1 GCP_COLONED_ENDPOINT2 },

}
$mandatory_keys = $myconf[:mandatory_keys]

def usage(comment=nil)
  puts $optparse.banner
  puts $optparse.summarize
  pred comment if comment
  puts "More on ENV variables: #{white $myconf[:description]}"
  exit 13
end

# include it in main if you want a custome one
def init()    # see lib_autoinit in lib/util.rb
  #Dotenv::Railtie.load # loads dotenv prima di tutto
  $opts = {}
  $opts[:envfile] = $myconf[:default_env] # deflt
  $opts[:kubedir] = $myconf[:default_kubedir] # deflt
  $opts[:verbose] = false # dflt
  $optparse = OptionParser.new do |opts|
    opts.banner = "#{$0} v.#{$PROG_VER}\n Usage: #{File.basename $0} [--envfile <FILE>] [check | up/start | stop/down | restart | status | init | drain/killpod | destroy/cleanup] "
    opts.on( '-d', '--debug', 'enables debug (DFLT=false)' ) {  $opts[:debug] = true ; $DEBUG = true }
    opts.on( '-h', '--help', 'Display this screen') {  usage }
    opts.on( '-k', '--dir KUBE_DIR', "Kubernetes Dir (dflt: '#{$opts[:default_kubedir]}')") {|kubedir| $opts[:kubedir] = kubedir }
    #opts.on( '-n', '--dryrun', "Don't really execute code (TODOIMPL)" ) { $opts[:dryrun] = true }
    opts.on( '-e', '--envfile FILE', 'Write log to FILE') {|file| $opts[:envfile] = file }
    opts.on( '-v', '--verbose', 'Output more information') { $opts[:verbose] = true}
  end
  $optparse.parse!  
end

def kubectl_command(payload, opts={})
  ret = "kubectl --namespace #{ENV["NAMESPACE"]} #{payload}"
  deb "kubectl_command(payload='#{payload}', opts=#{opts}) ==> #{ret}"
  ret 
end

# funge ma inutile - lo fa gia la gemma mitica `dotenv` e il resto del mono non ruby sta a guardare!
def ensure_env_exist_or_die(arr_of_keys)
  deb "CHecking ENV for: #{arr_of_keys}"
  arr_of_keys.each do |k|
    #deb "CHecking ENV[#{k}]"
    if ENV[k] 
      deb "- OK ENV#{k} ->\t#{ENV[k]}"
    else
      fatal 42, "Missing ENV[#{k}]"
    end
  end
end

# # ora lo prendo da LIB2021! ModuloFigata2021 esegui 
# def esegui_OBSOLETO(cmd, opts={})

def my_email()
  ENV.fetch "GCLOUD_USER_EMAIL", "palladiusbonton@gmail.com"
end

def set_dns_based_on_env(ip_dns_mapping)
  pred "[set_dns_based_on_env] set_dns_based_on_env => #{ip_dns_mapping.split(':')}" 
  static_ip, dns =  ip_dns_mapping.split(':')
  #pgreen :TODO_IMPLEMENT_CREATE_DNS_ENTRY
  command = "cloud-dns-manage create #{dns} --ip #{static_ip}" 
  esegui(command)
end

def release_dns_based_on_env(ip_dns_mapping)
  pred "[release_dns_based_on_env] release_dns_based_on_env => #{ip_dns_mapping.split(':')}" 
  static_ip_name, dns =  ip_dns_mapping.split(':')
  pgreen :TODO_IMPLEMENT_DESTROY_DNS_ENTRY_MA_COPIA_DA_SOPRA_SE_SOPRA_FUNGE
end

# static_ip_name, dns
def destroy_endpoint_based_on_env(gcp_coloned_endpoint)
  pred "[destroy_endpoint_based_on_env] gcp_coloned_endpoint => #{gcp_coloned_endpoint.split(':')}" 
  raise "Wrong size for  gcp_coloned_endpoint (must contain a single colon): .." unless 2 == gcp_coloned_endpoint.split(':').size 
  static_ip_name, dns =  gcp_coloned_endpoint.split(':')
  #puts esegui("echo OPPOSITE OF gke-setup-loadbalancer-and-dns.sh #{static_ip_name} #{dns}")
  #1 distruggi static IP.
  puts esegui("gcloud compute --quiet addresses delete '#{static_ip_name}' --global", :exit_on_fail => false ) # vediamo se VA senza chiedere...
  #2 distruggi DNS cjhe ho appena implementato
  puts esegui("cloud-dns-manage rm #{dns}", :exit_on_fail => false)
end
# static_ip_name, dns
def setup_endpoint_init_based_on_env(gcp_coloned_endpoint)
  puts "Facoltativo: Now enabling a Carlessian thing: transactionally creating a STATIC IP + setting up DNS for #{green gcp_coloned_endpoint}"
  deb  gcp_coloned_endpoint.split(':')
  raise "Wrong size for  gcp_coloned_endpoint (must contain a single colon): .." unless 2 == gcp_coloned_endpoint.split(':').size 
  static_ip_name, dns =  gcp_coloned_endpoint.split(':')
  puts esegui("echodo gke-setup-loadbalancer-and-dns.sh #{static_ip_name} #{dns}") # OBSOLETE
  #1. gcloud compute addresses create "$IPNAME" --global 
  #puts esegui("gcloud compute --quiet addresses create '#{static_ip_name}' --global --ip-version IPV4", :exit_on_fail => false ) # vediamo se VA senza chiedere...
  #2. cloud-dns-manage add #{dns} --ip #{static_ip_name}
  #puts esegui("cloud-dns-manage add #{dns}", :exit_on_fail => false)
end

def relevant_static_ips()
  deb "Note: RESERVED: bad; IN_USE: good"
  esegui("gcloud compute addresses list --global| grep #{ENV['NAMESPACE']}", :exit_on_fail => false ).
    #colora_righe_by_regex(:white, /#{ENV['NAMESPACE']}/).
    colora_righe_by_regex(:red, /RESERVED/).
    to_s
end
# finalize, terminate, destroy: il contrario di INIT
def terminate_and_destroy()
  #pred "Qui distruggo tutto cio che hai creato che cosi a occhio sono solo: IP pubblici e DNS :) Tuttalpiu posso provare a dsitruggere il NAMESPACE anche ma senza troppe speranza:)"
  puts esegui("kubectl delete namespace #{ ENV['NAMESPACE'] }", :exit_on_fail => false  )
  puts "Existing Public IP addresses which mmight be of your interest:"
  puts relevant_static_ips
  
  usage "GCP_COLONED_ENDPOINT1 has been deprecated in favor of: TBD. Please update your .env file Ricc" if ENV['GCP_COLONED_ENDPOINT1']
  destroy_endpoint_based_on_env(ENV['GCP_ENDPOINT_DNS_MAPPING1']) if ENV['GCP_ENDPOINT_DNS_MAPPING1']
  destroy_endpoint_based_on_env(ENV['GCP_ENDPOINT_DNS_MAPPING2']) if ENV['GCP_ENDPOINT_DNS_MAPPING2']
  destroy_endpoint_based_on_env(ENV['GCP_ENDPOINT_DNS_MAPPING3']) if ENV['GCP_ENDPOINT_DNS_MAPPING3']

  release_dns_based_on_env(ENV['IP_DNS_MAPPING1']) if ENV['IP_DNS_MAPPING1']
  release_dns_based_on_env(ENV['IP_DNS_MAPPING2']) if ENV['IP_DNS_MAPPING2']
  release_dns_based_on_env(ENV['IP_DNS_MAPPING3']) if ENV['IP_DNS_MAPPING3']

  pgreen("Destroyed up to thre thingies")
end

# init: creo IP_PUBBLICO V4 GLOBAL e DNS su Palladius
def setup_forzato()
  pgreen ":TBD qui il bello e che se fallisce qualcosa non fai danni :) quindi adoro questo"
  # only to test - it works! esegui("/bin/false", :exit_on_fail => false)
  esegui "gcloud config configurations create #{ENV["GCLOUD_CONFIG_NAME"]}", :exit_on_fail => false # might exist already!
  # qui va bene sia ok che non ok `echo $?`.class
  esegui "gcloud config set project #{ENV['PROJECT_ID']}"
  esegui "gcloud config set account #{my_email}"
  # echodo 
  ret = esegui("gcloud config configurations activate #{ENV['GCLOUD_CONFIG_NAME']}")
  # #echodo gcloud container clusters get-credentials goliar dia-prod --zone europe-west6-c --project goliar dia-prod
  # # Cluster goliardifco
  # echodo $GKE_CREDENTIALS_COMMAND 
  ret = esegui( ENV['GKE_CREDENTIALS_COMMAND'] )
  # # gcloud container clusters get-credentials ricc-prod --zone europe-west1-b --project ric-cccwiki
  ret = esegui("kubectl create namespace #{ ENV['NAMESPACE'] }", :exit_on_fail => false  )
  # # creo IP
  usage "GCP_COLONED_ENDPOINT1 has been deprecated in favor of: TBD. Please update your .env file Ricc" if ENV['GCP_COLONED_ENDPOINT1']
  setup_endpoint_init_based_on_env(ENV['GCP_ENDPOINT_DNS_MAPPING1']) if ENV['GCP_ENDPOINT_DNS_MAPPING1']
  setup_endpoint_init_based_on_env(ENV['GCP_ENDPOINT_DNS_MAPPING2']) if ENV['GCP_ENDPOINT_DNS_MAPPING2']
  setup_endpoint_init_based_on_env(ENV['GCP_ENDPOINT_DNS_MAPPING3']) if ENV['GCP_ENDPOINT_DNS_MAPPING3']
  #raise "Ricc mo ti rocca implementarlo!" if ENV['GCP_COLONED_ENDPOINT2']
  set_dns_based_on_env(ENV['IP_DNS_MAPPING1']) if ENV['IP_DNS_MAPPING1']
  set_dns_based_on_env(ENV['IP_DNS_MAPPING2']) if ENV['IP_DNS_MAPPING2']
  set_dns_based_on_env(ENV['IP_DNS_MAPPING3']) if ENV['IP_DNS_MAPPING3']
  # gke-setup-loadbalancer-and-dns.sh palladiusit-global-staging www-staging.palladius.it 
  pgreen "Ciuccio bene. TODO fail if it fails :)"

end

def color_only_interesting_text(output)
  output.split("\n").map{|line| line.match(/unchanged/) ? gray(line) : yellow(line)}
end


def esegui_kubectl_get_all()
   # se no vengono 6 spazi vuoti (!)
   kube_get_all_regex = ENV.fetch "KUBE_REGEX", "."
   #puts esegui(kubectl_command("get all 2>&1 | ripulisci")) # debug per vedere cosa mettere di la
   esegui(kubectl_command("get all 2>&1 | egrep 'NAME|#{kube_get_all_regex}'| ripulisci")).
      colora_righe_by_regex(:green,  /-prod/).
      colora_righe_by_regex(:yellow, /-staging/).
      colora_righe_by_regex(:gray,   /-test-/).
      colora_righe_by_regex(:gray, /-dev-/).
      colora_righe_by_regex(:red, /CrashLoopBackOff|Error|ErrImagePull/i).
      to_s # ridondante ma mi aiuta a non togliere il punto..      
end

def print_interesting_info
      puts esegui_kubectl_get_all #  , :print_output => true) 
      pyellow relevant_static_ips
      # ora mi interesso a hosts in ENV['GCP_COLONED_ENDPOINT1'])
      interesting_hosts = %w{ GCP_COLONED_ENDPOINT1 GCP_COLONED_ENDPOINT2 GCP_COLONED_ENDPOINT3 GCP_COLONED_ENDPOINT4 }.
        map{|key| ENV.fetch key, "nullo_ma_cosi_ho_solo_stringhe:" }.
        #map{|s| s.split(':')[1] }.
        filter_map{|s| s.split(':')[1] unless s.nil?}
      interesting_hosts_commands = interesting_hosts.map{|host| "host #{host} ;"}
      #interesting_hosts.each{|host|
      #  puts esegui("host #{host} ; host www.google.com",  :exit_on_fail => false )
      #}
      puts esegui(interesting_hosts_commands.join(" ") , :exit_on_fail => false ).
        colora_righe_by_regex(:green, /has address/).
        colora_righe_by_regex(:red, /not found/).
        to_s
      puts esegui(kubectl_command("apply -f #{  $opts[:kubedir] } --dry-run")).color_by_env if $opts[:verbose]
      puts "IP Address Palooza: TODO capture IPs from: 1 Services 2. compute addresses list 3. ENV[IP_DNS_MAPPING] // ENV[GCP_ENDPOINT_DNS_MAPPING ]"
end
def kubectlizza(action)
  dir =  $opts[:kubedir] 
  deb "kubectlizza. Action=#{action}, dir"
  case action # no FALLTHROUGH! https://en.wikipedia.org/wiki/Switch_statement#Fallthrough
    when :start
      #kubectlizza(:start)
      puts "Iterating over all YAML files in directory: '#{dir}'/:"
      # glob *.yaml -> kubectl apply -f *
      #Dir.glob("#{dir}/*.yaml").each do|file|
      #  output = esegui(kubectl_command("--dry-run=server apply -f #{file}"))
      #  pyellow output
      #end
      output = esegui(kubectl_command("apply -f #{dir}"))
      # coloro solo le linee NON unchanged
      puts color_only_interesting_text(output) # .split("\n").map{|line| line.match(/unchanged/) ? gray(line) : yellow(line)}
      #pgray "TBD forse devi fare un glob su tutti i file YAML e poi fare un haduken. potresi fare unb cat*| kubectl ma penso sia meglio farlo file x file per migliore error taking"
    when :stop
      output = esegui(kubectl_command("delete -f #{dir}") )
      puts color_only_interesting_text(output) # non so se sia lo stesos per il delete vedremo.
      #pgray "TBD forse devi fare un glob su tutti i file YAML e poi fare un haduken. potresi fare unb cat*| kubectl ma penso sia meglio farlo file x file per migliore error taking"
      # magari colori di verde riusciti e rosso errati :)
    when :check # "downup", "restart"
      ensure_or_die_init_launched_vs_not(true, "Cant show you status. Run init first")
      # qui c'e' qualche puts a vuoto...
      print_interesting_info
    when :drain 
      pyellow "Soccia questa e dura. Lidea e di fare kill dei pods che triggera la nuova versione.. ma devi prima trovare il pod e poi killarlo. Cominciamo con questa:"
        #get pods -o jsonpath --template='{range .items[*]}{.metadata.name}{"\t"}{"\t"}{.spec.containers[0].image}{"\n"}{end}'
      ret = esegui kubectl_command( %q{ \
        get pods -o jsonpath --template='{range .items[*]}{.metadata.name}{"\t"}{"\t"}{.spec.containers[0].image}{"\n"}{end}'
        })
      pwhite "Pod+version: #{ret}"
      pod = ret.split(/\s/).first
      puts "Killing now pod '#{pod}'.."
      esegui kubectl_command("delete pods/#{pod}")
    when :init
      ensure_or_die_init_launched_vs_not(false) # uno script solo
      setup_forzato()
      print_interesting_info
      touch_after(:init)
    when :destroy # :terminate
      ensure_or_die_init_launched_vs_not(true) # uno script solo
      terminate_and_destroy()
      puts "Ora verifica che IP e DNS siano stati distruitti.."
      touch_after(:destroy)
    when String, Symbol
      fatal(84, "Azione sconosciuta (string/symbol): #{action}")
  else
    fatal 89, "STRANILLIMO: You gave me '#{action}'' which is not even a STRING!-- I have no idea what to do with that."
  end
end

# Ok sto barando. ora con has_been_initialized_already checko se .init deve esistere o no.
def ensure_or_die_init_launched_vs_not(has_been_initialized_already, msg=nil)
  deb "ensure_or_die_init_launched_vs_not(has_been_initialized_already=#{has_been_initialized_already})"
  if has_been_initialized_already
    puts "We are in DESTROY. Only going to destroy stuff if i find trace of someone creating it before :)"
    msg =  "Refusing to run destroy since I find no trace of init before. If you are sure whacchudoin rm that file" if msg.nil?
    usage(msg) unless File.exists?(".init")
  else # init
    puts "We probably are in INIT. Only going fwd if a placeholder file does NOT exist. Makefile style."
    msg = "Refusing to run init (a very dangerous and powerful script" if msg.nil?
    usage(msg) if File.exists?(".init")
  end

end

def touch_after(action)
  case action
    when :init
      `touch .init`
    when :destroy
      `rm .init`
    else
      raise "Unknown action: #{action}"
    end
end

def real_program
  puts white("Hello world from #{$myconf[:app_name]} v#{$PROG_VER} (nominated script of the year 2021 by Riccardo himself!)")
  debug_on 'Just created script, presuming u need some debug. TODO REMOVE ME when everything works!' if $DEBUG
  deb "+ Options are:  #{gray $opts}"
  deb "+ Depured args: #{azure ARGV}"
  unless ARGV.size == 1
    usage "Usage: $0 ACTION (vedi sopra per azioni DRY)"
  end
  argv_action = ARGV[0]


  # check ENV and loads it

  usage "File not found: #{$opts[:envfile]}" unless File.exists?($opts[:envfile])
  Dotenv.load($opts[:envfile]) # carica in ENV per tutti
  #manhouse = Dotenv.parse $opts[:envfile]  # lo fa vedere e basta
  #deb "Env a manhouse: #{manhouse}"
  ensure_env_exist_or_die($mandatory_keys) #  %w{ PROJECT_ID GCLOUD_CONFIG_NAME NAMESPACE boh })
  Dotenv.require_keys $mandatory_keys # ("SERVICE_APP_ID", "SERVICE_KEY", "SERVICE_SECRET")
  
  # now lets do sth about it
  case argv_action # first argment - action
    when "up", "start"
      kubectlizza(:start)
    when "down", "stop"
      kubectlizza(:stop)
    when "drain", "killpod"
      kubectlizza(:drain)
    when "downup", "restart"
      kubectlizza(:stop)
      sleep(1)
      kubectlizza(:start)
    when "check", "status"
      kubectlizza(:check)
    when "init"
      kubectlizza(:init)
    when "destroy", "cleanup", "terminate"
      kubectlizza(:destroy) # duale di init      
    when "exec"
      kubectlizza(:exec, :payload => "todo pensaci amico mio - non so se abbia senso perche sto cazzillo ha solo un argomento non vuoi imbarcarti nel dire: 1 arg a meno che...")
    when String
      fatal(84, "Azione sconosciuta: #{argv_action}")
  else
    fatal 89, "STRANILLIMO: You gave me #{x} -- I have no idea what to do with that."
  end
  pgreen "Sono uscito senza errori!"
end

def main(filename)
  init        # Enable this to have command line parsing capabilities!
  real_program 
end

main(__FILE__)
