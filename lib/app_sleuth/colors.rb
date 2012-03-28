module AppSleuth
  class Colors
    class << self
      def gather(location)
        colors = `egrep --no-filename -ior '(#[a-fA-F0-9]{6}|#[a-fA-F0-9]{3})( |;)' #{location}`.split.map{|c| c.gsub(';', '').gsub(' ', '').downcase }.uniq.sort
      end
      
      def color_location(color_code, location)
        c = `egrep -ir '(#{color_code})( |;)' #{location}`.split("\n")
      end

      def color_swatch(color, location)
        # colors.each{|color| 
          "<li data-hex='#{color}' data-color-lookup='#{color_location(color, location)}' class='swatch' style='background-color:#{color};'><a class='close delete'>x</a><span class='help'>Double Click To Bring to Front</span></li>"
        # }
      end

      def generate_report(location)
        colors = gather(location)
        colors = colors.map{|c| color_swatch(c, location) }.join("\n\n")
        rendered_file = ERB.new(File.read("lib/app_sleuth/server/views/colors.html.erb"))
        rendered_file.result(binding)
      end
    end
  end
end
# color_file = File.new(File.join(Rails.root, 'tmp', 'colors.html'), "w+")
# in_project(File.join(Rails.root, 'app', 'assets', 'stylesheets'))