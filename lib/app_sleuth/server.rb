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
    
    get '/colors' do
      AppSleuth::Colors.generate_report(params[:location])
    end
  end
end