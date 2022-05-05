=begin

  This module tries to automate stuff like exporting important variables.
  once you include this you should be good to go with your PROHECT ID setup.

  export PROJECT_ID
  export PROJECT_NUMBER
=end

require 'colorize'



module GcpMagic

  DEFAULT_REGION = 'europe-west1'
  DEFAULT_ZONE_DESINENCE = 'a'
  DEFAULT_ZONE_DESINENCE = [DEFAULT_REGION, DEFAULT_ZONE_DESINENCE].join('-')

  def init
  end


  def get_prid_from_gcloud()
    `gcloud config get core/project 2>/dev/null`.chomp
  end

  def get_prnu_from_gcloud(project_id=nil)
    project_id = get_prid_from_gcloud unless project_id
    `gcloud projects describe '#{project_id}' --format="value(projectNumber)" 2>/dev/null`.chomp
  end

  # TODO does this exist? If not lets set it up
  def sfrucglinit()
    puts 'Trying to infer your favorite PROJECT_ID from ENV and in sub order from GCLOUD config..'
    # project id
    $project_id = ENV.fetch 'PROJECT_ID', get_prid_from_gcloud()
    $project_number = ENV.fetch 'PROJECT_NUMBER', get_prnu_from_gcloud($project_id)

    puts "I inferred your project_id: '#{$project_id.to_s.colorize :yellow}'"
    puts "I inferred your project_nu: '#{$project_number.to_s.colorize :green}'"

  end

  # # removeme https://www.culttt.com/2015/07/01/creating-and-using-modules-in-ruby#:~:text=Creating%20Modules%20in%20Ruby&text=To%20define%20a%20module%2C%20use,camel%20case%20(e.g%20MyModule).
  # class Http
  #   def self.get(url)
  #     # Make a GET request
  #   end
  # end


end


# TODO remove me
#GcpMagic::Http.get('http://example.com/users')

include GcpMagic
sfrucglinit()
