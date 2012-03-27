module AppSleuth
  class Server < Sinatra::Base
    dir = File.dirname(File.expand_path(__FILE__))
    set :views,  "#{dir}/server/views"
    
  end
end