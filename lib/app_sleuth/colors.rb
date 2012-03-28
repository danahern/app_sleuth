module AppSleuth
  class Colors
    class << self
      def hex_shortcode(color)
        return color unless color.length == 4
        hex = color.gsub('#', '').split('')
        hex = "##{hex[0]}#{hex[0]}#{hex[1]}#{hex[1]}#{hex[2]}#{hex[2]}"
      end

      def gather(location)
        colors = `egrep --include='*.*css' --no-filename -ior '(#[a-fA-F0-9]{6}|#[a-fA-F0-9]{3})( |;)' #{location}`.split.map{|c| c.gsub(';', '').gsub(' ', '').downcase }.uniq.sort
        colors.map{|c| hex_shortcode(c) }.uniq.sort
      end
      
      def color_location(color_code, location)
        c = `egrep --include='*.*css' -ir '(#{color_code})( |;)' #{location}`.split("\n")
      end

      def color_swatch(color, location)
        # colors.each{|color| 
          "<li data-hex='#{color}' data-color-lookup='#{color_location(color, location)}' class='swatch' style='background-color:#{color};'><a class='close delete'>x</a><span class='help'>Double Click To Bring to Front</span></li>"
        # }
      end

      def generate_report(location)
        colors = gather(location)
        colors = colors.map{|c| color_swatch(c, location) }.join("\n\n")
        gem_dir = File.dirname(File.expand_path(__FILE__))
        rendered_file = ERB.new(File.read(File.join(gem_dir, "server/views/colors.html.erb")))
        rendered_file.result(binding)
      end
    end
  end
end
# color_file = File.new(File.join(Rails.root, 'tmp', 'colors.html'), "w+")
# in_project(File.join(Rails.root, 'app', 'assets', 'stylesheets'))