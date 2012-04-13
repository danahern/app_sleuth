module AppSleuth
  class Server < Sinatra::Base
    dir = File.dirname(File.expand_path(__FILE__))
    set :views,  "#{dir}/server/views"

    if respond_to? :public_folder
      set :public_folder, "#{dir}/server/assets"
    else
      set :public, "#{dir}/server/assets"
    end

    set :static, true

    get '/' do
      "<a href='/colors'>Colors</a>"
    end
    
    get '/colors' do
      @colors = File.read("tmp/colors.json")
      erb :colors
      # File.read("/tmp/colors.html")
    end
  end
end