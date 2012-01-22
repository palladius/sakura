
  # $Id$
  # This class wraps my wonderful SVN!
  
class RicSvn # < RicClass
  @@default_user = 'rcarlesso'
  attr_accessor :svn_info, :path, :label , :revision , :author, :user # sets funztioncs such as 'path()' and 'path=()'
  @@description = 'This class aims to wrap a SVN repository'
  @@svn_max_obsolescense_days = 6
  
  def initialize(path='.', mylabel=nil, fast_initialize=false)
    @path     ||= '_unset'
    @svn_info ||= '_unset'
    @label    ||= '_unset' 
    deb 'verifying the SVN exists...'
    @path = File.expand_path(path) 
    raise "Repo doesnt seem to exist: #{red path}" unless legal_repo? # (path)
    @label  = mylabel || "Unnamed Repository for path: #{@path}"
    @user ||= @@default_user  # prendilo da "/etc/per-host-conf"
    _compute_more_stuff unless fast_initialize
  end
  
    # serve per una SUPER automatica a fine initialize.. mi pare.
  def after_initialize
    puts "TEST AfterInitialize for RicSvn object: #{gray to_s}"
  end
  
  def self.help(query=nil)
    puts title( "Welcome to #{white('RicSvn.help()')}" )
    puts( "Static Methods:   #{blue self.methods(false) }") 
    puts( "Instance Methods: #{azure self.instance_methods(false) }") 
    p( "Repos on this computer: #{yellow RicSvn.ric_repos}" )
    p("Lets show our favorite SVN: ")
    test = self.singhelton(RicSvn.new($SVNHOME,'the wonderful SVN di Riccardo')     )
    nil
  end
  
    # verifica che se padre ha .svn non cerchi tra figli
    # aggiungi altre dir, come /etc/ ... o /etc/*/.svn
  def self.ric_repos(basedirs = ["#{$HOME}/svn/", '/etc/' ] )
    basedirs.map{ |basedir| 
      `ls "#{basedir}/" `.split.select{|paz| File.exists?("#{basedir}/#{paz}/.svn/") }.map{|relative| File.expand_path(basedir) + '/' + relative }
    }
  end
  
  def self.find_all
    self.ric_repos.map{|svn_repo_path| RicSvn.new(svn_repo_path)}
  end
  
  def legal_repo? #(path)
    File.exists?("#{path}/.svn/")
  end
     
  def info
    ret = white "= SVN Info =\n"
    printable_variables = instance_variables - %w{ @svn_info }
    deb printable_variables # similar to: %w{ @label @path @time_to_compute @revision @obsolescete @author @change_date @url}
    printable_variables.each{|attr|
      ret += " + #{attr}: '#{yellow eval(attr)}'\n"
    }
#    ret += "instance_variables: #{gray instance_variables}\n"
    ret += "Other repos (RicSvn.ric_repos): #{blue self.class.ric_repos}\n"
  end
  
  def search(query)
    "tbd"
  end
  
  def to_s
    return info()
  end
  
  def update
    `svn update #{$path}`
    _compute_more_stuff() # revision could have changed..
  end
  
  def self.singhelton(desc)
    # TBD singleton fatta bene
    #DEVELOPMENT_HOSTS
    RicSvn.new($SVNHOME,'the wonderful SVN di Riccardo')     
  end
  
  # @tags: cool
  def self.test
    #debug_on('RicSvn.test debug on..')
    mysvn = singhelton('Checking my SVN..')
    pred 'TODO checka gli YML..'
    `ls ~/etc/*yml ~/etc/ricsvn/*.yml ~/doc/help/*yml `.split("\n").each{|f|
      ok = YAML.load(File.read(f)) rescue false
      ok = true if ok
      deb "Checking: #{white f}: #{okno ok}"
      unless ok
        puts "Error in YML: #{red f}: #{YAML.load(File.read(f)) rescue $! }"
      end
    }
  end
  
private
  
    def _compute_more_stuff()
      deb "SVN: Computing interesting info.."
      t_initial = Time.now
      @obsolescete = svn_dir_obsolete?(path)
      @svn_info = `cd "#{path}" && svn info`.strip
      @revision = @svn_info.to_hash['Last Changed Rev'] rescue "Err: #{$!}"
      @author = @svn_info.to_hash['Last Changed Author'] rescue "Err: #{$!}"
      @change_date = @svn_info.to_hash['Last Changed Date'] rescue "Err: #{$!}"
      @url = @svn_info.to_hash['URL'] rescue "Err: #{$!}"
      @time_to_compute = Time.now - t_initial # debug
      return "Computed a lot of nice stuff in #{@time_to_compute} secs"
    end
end


#########################################################################################################
# RUBATO da ~/bin/h

def helpfile_parse(helpfile_name)
  err = ''
  helpfile = helpfile_name 
  helpfile += ".yml" unless helpfile_name.match( /.yml$/ )
  helpfile = "#{HELP_DIR}/#{helpfile}" unless  helpfile.match(/\//) # has a slash
  conf = YAML.load_file(helpfile ) rescue exception_yml($!)
  err = $!
  deb(conf['_conf'].inspect) 
  $color_title      = conf['_conf']['colors']['title']    rescue "azure" 
  $color_line_key   = conf['_conf']['colors']['line_key'] rescue "blue" 
  $color_line_val   = conf['_conf']['colors']['line_val'] rescue 'lgray'
  deb [  $color_title ,  $color_line_key ,   $color_line_val   ]
  return conf unless conf.nil? 
  return { 'Some error' => { 'parsing YML file' => "'#{$!}'" , "11" => 2 } }
end

def show_help(query_str)
  n=0
  $help_opt.each{ |menu_title,submenu|
    next if special_help_title?(menu_title)
    n += 1
    if (! query_str.nil? ) # searching for sth
      # foreach (father, sons)I have to visualize ALL sons and the matching father if and only if:
      # 1. father string matches , OR
      # 2. at least ONE son matches
      # if father matches, I give ALL sons. If father doesnt, I publish the father with ONLY the matching sons :)
      ret_search = ret_all = ''
      submenu.each{ |k,v|
        ret_search += help(k,v,query_str).to_s
        ret_all    += help(k,v,'')
      }
      father_matches = menu_title.match(query_str)
      sons_match = ret_search.length > 0 
      if (father_matches || sons_match)
        title("#{n}. #{menu_title.capitalize}")  
        puts father_matches ? ret_all : ret_search
      end
    else # no searching: visualizing everything
      #puts "Querystring: #{query_str} (#{query_str.length})"
      title("#{n}. #{menu_title.capitalize}") 
      submenu.each{ |k,v|
         puts help(k,v,query_str)
      }
    end
  }
end