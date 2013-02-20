
module Sakuric
  #print "[DEBUG] Including sakura.Sakuric"
  $SAKURA_DFLTDIR = '~/git/sakura/'
  $VERSION        = 'TBD_from($DIR/VERSION)'
  SCRIPT_BEGUN    = Time.now
  
  def self.VERSION
    $VERSION = File.read(File.expand_path(BASEDIR() + '/VERSION')) # reads version file
  end
  
  def self.BASEDIR
    File.expand_path(File.dirname(__FILE__) + '/..')
  end
  
  def self.use_ric_gem
    false
  end
  
      # conf files into auto/ dir (mi son rotto di aggiungerli qui uno a uno!)
  def self.get_auto_files(subdir)
    absolute_dir = "#{$SAKURADIR}/lib/#{subdir}"
    Dir.new(absolute_dir).select{|f| f.match( /\.rb$/ )}.map{|x| subdir + File.basename(x,'.rb') }
  end
  
end #/Module Sakuric
