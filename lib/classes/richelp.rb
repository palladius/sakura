
#module 'richelp'

$HELP_DIR =  "#{$SAKURADIR}/doc/richelp/"

def helpfile_parse(helpfile_name)
  err = ''
  helpfile = helpfile_name 
  helpfile += ".yml" unless helpfile_name.match( /.yml$/ )
  helpfile = "#{$HELP_DIR}/#{helpfile}" unless  helpfile.match(/\//) # has a slash
  conf = YAML.load_file(helpfile) rescue exception_yml($!)
  err = $!
  deb("_conf: " + conf['_conf'].inspect)
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

def sanitize_help_file(file_str)
  file_str = file_str.gsub(/\.yml$/,'')  
  File.expand_path "#{$HELP_DIR}/#{file_str}.yml"
end

def show_test(file_str)
  file = sanitize_help_file(file_str)
  hash_or_errorstring = YAML.load_file( file ) rescue "#{$!}"
  if hash_or_errorstring.class == Hash
    puts "OK File yml: #{green file}"
    exit 0
  else
    puts "Some problems with '#{file}': #{red hash_or_errorstring}"
    exit 78
  end
end
