module AppSleuth
  class Colors
    class << self
      # ./app/assets/stylesheets/orders.css.scss:  color: #603913;
      # ./app/assets/stylesheets/orders.css.scss:    border-bottom: solid 1px #e1d4c3;
      # ./app/assets/stylesheets/orders.css.scss:  color: #603913;
      # ./app/assets/stylesheets/orders.css.scss:    border-right: solid 1px #f1e8d8;
      # ./app/assets/stylesheets/orders.css.scss:    border-bottom: solid 1px #f1e8d8;

      def color_names
        Color::RGB.constants.reject{|rgb| rgb == :PDF_FORMAT_STR}
      end


      def regex_rgb
        "(#[a-fA-F0-9]{6}|#[a-fA-F0-9]{3})( |;)"
      end

      def regex_hsla
        "(hsl|hsla)(.*?)( |;)"
      end

      def hex_shortcode(color)
        return color unless color.length == 4
        hex = color.gsub('#', '').split('')
        hex = "##{hex[0]}#{hex[0]}#{hex[1]}#{hex[1]}#{hex[2]}#{hex[2]}"
      end

      def gather(location)
        cwd = Dir.getwd
        colors = {}
        gather_from_css(location, colors)
        scss_files = Dir.glob("**/*.scss")
        
        Dir.chdir(cwd)
        colors
      end

      def gather_from_css(location, colors)
        Dir.chdir(File.expand_path(location))
        css_files = Dir.glob("**/*.css")
        css_files.each do |css_file|
          begin
            parser = CssParser::Parser.new
            parser.load_file!(css_file, "", :all)
          rescue => e
            puts "Error Processing: #{css_file}\n\t#{e.to_s}" 
          end
          parser.each_selector do |selector, declarations, specificity|
            # if css_colors = declarations.scan(Regexp.new(regex_rgb))
            #   gather_from_hex(colors, css_colors, declarations, specificity, selector, css_file)
            # end
            # if css_colors = declarations.scan(Regexp.new("(#{color_names.join('|')})", true))
            #   gather_from_name(colors, css_colors, declarations, specificity, selector, css_file)
            # end
            if css_colors = declarations.scan(Regexp.new(regex_hsla))
              gather_from_hsla(colors, css_colors, declarations, specificity, selector, css_file)
            end
          end
        end
      end

      def gather_from_hex(colors, css_colors, declarations, specificity, selector, css_file)
        css_colors.each do |c|
          c = c.first
          attribute = declarations.split(";").find_all{|a| a.include?(c)}
          attributes = attribute.map{|a| v = a.split(":").map(&:chomp); {key: v.first, value: v.last}}
          color = Color::RGB.from_html(c)
          if colors.has_key?(color.css_rgba)
            colors[color.css_rgba][:instances] << instance("hex", specificity, selector, css_file, attributes)
            colors[color.css_rgba][:count] += 1
          else
            colors[color.css_rgba] = {transparency: false, html: color.html, rgb: color.css_rgb, hsl: color.css_hsl, rgba: color.css_rgba, hsla: color.css_hsla, count: 1, instances: [instance("hex", specificity, selector, css_file, attributes)]}
          end
        end
      end

      def gather_from_name(colors, css_colors, declarations, specificity, selector, css_file)
        css_colors.each do |c|
          c = c.first
          attribute = declarations.split(";").find_all{|a| a.include?(c)}
          attributes = attribute.map{|a| v = a.split(":").map(&:chomp); {key: v.first.chomp, value: v.last.chomp}}
          color = Color::RGB.const_get(c.classify)
          if colors.has_key?(color.css_rgba)
            colors[color.css_rgba][:instances] << instance("name", specificity, selector, css_file, attributes)
            colors[color.css_rgba][:count] += 1
          else
            colors[color.css_rgba] = {transparency: false, html: color.html, rgb: color.css_rgb, hsl: color.css_hsl, rgba: color.css_rgba, hsla: color.css_hsla, count: 1, instances: [instance("name", specificity, selector, css_file, attributes)]}
          end
        end
      end

      def instance(found_as, specificity, selector, css_file, attributes)
        {found_as: found_as, specificity: specificity, selector: selector, extension: File.extname(css_file).gsub(".",''), file_name: File.basename(css_file), file: css_file, attribute: attributes, selector_path: selector.split(" ")}
      end

      # def gather(location)
      #   color_hash = {}
      #   colors_exp = `egrep --include='*.*css' -ir '#{regex_color}' #{location}`.split("\n")
      #   regex = Regexp.new("(.*?):(.*?):.*#{regex_color}")
      #   colors_exp.each do |color_string|
      #     color_string.match(regex)
      #     file, tag, color = $1, $2, $3
      #     color = hex_shortcode(color)
      #     tag = tag.split("{").last
      #     if color_hash.has_key?(color)
      #       color_hash[color][:tag_locations] << "#{file}: #{tag}"
      #       color_hash[color][:tags] << tag
      #       color_hash[color][:tags].uniq!
      #       color_hash[color][:files] << file
      #       color_hash[color][:files].uniq!
      #     else
      #       color_hash[color] = {tag_locations: ["#{file}: #{tag}"], tags: [tag], files: [file]}
      #     end
      #   end
      #   color_hash
      #   #.map{|c| c.gsub(';', '').gsub(' ', '').downcase }.uniq.sort

      #   # colors.map{|c| hex_shortcode(c) }.uniq.sort
      # end
      
      # def color_location(color_code, location)
      #   c = `egrep --include='*.*css' -ir '(#{color_code})( |;)' #{location}`.split("\n")
      # end

      # def color_swatch(color, location)
      #   # colors.each{|color| 
      #     "<li data-hex='#{color}' data-color-lookup='#{color_location(color, location)}' class='swatch' style='background-color:#{color};'><a class='close delete'>x</a><span class='help'>Double Click To Bring to Front</span></li>"
      #   # }
      # end

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