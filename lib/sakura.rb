
module Sakura
  #print "[DEBUG] Including sakura.Sakura"
  $SAKURA_DFLTDIR = '~/git/sakura/'
  $VERSION        = 'TBD_from($DIR/VERSION)'
  SCRIPT_BEGUN    = Time.now
  N_CALLED        = 0                        # should be incremented at every inclusion...
  
  def self.VERSION()
    $VERSION = File.read(File.expand_path(BASEDIR() + '/VERSION')) # reads version file
  end
  
  def self.BASEDIR()
    File.expand_path(File.dirname(__FILE__) + '/..')
  end
  
  def self.use_ric_gem()
    false
  end
  
  def self.n_called()
    return N_CALLED
  end
  
  # conf files into auto/ dir (mi son rotto di aggiungerli qui uno a uno!)
  def self.get_auto_files(subdir)
    absolute_dir = "#{$SAKURADIR}/lib/#{subdir}"
    Dir.new(absolute_dir).select{|f| f.match( /\.rb$/ )}.map{|x| subdir + File.basename(x,'.rb') }
  end
  
  N_CALLED = N_CALLED + 1
  
end #/Module Sakura
