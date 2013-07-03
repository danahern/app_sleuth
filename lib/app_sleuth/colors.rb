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


      def regex_hex
        /(#[a-fA-F0-9]{6}|#[a-fA-F0-9]{3})[ |;]/
      end

      def regex_hsla
        /(hsla|hsl)\((.*?)\)[ |;]/
      end

      def regex_rgba
        /(rgba|rgb)\((.*?)\)[ |;]/
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
        # gather_from_scss(location, colors)

        Dir.chdir(cwd)
        colors.to_json
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
          parse_from_css(colors, parser, css_file)
        end
      end

      def parse_from_css(colors, parser, file_name)
        parser.each_selector do |selector, declarations, specificity|
          if css_colors = declarations.scan(Regexp.new(regex_hex))
            gather_from_hex(colors, css_colors, declarations, specificity, selector, file_name)
          end
          if css_colors = declarations.scan(Regexp.new("(#{color_names.join('|')})", true))
            gather_from_name(colors, css_colors, declarations, specificity, selector, file_name)
          end
          if css_colors = declarations.scan(Regexp.new(regex_hsla))
            gather_from_hsla(colors, css_colors, declarations, specificity, selector, file_name)
          end
          if css_colors = declarations.scan(Regexp.new(regex_rgba))
            gather_from_rgba(colors, css_colors, declarations, specificity, selector, file_name)
          end
        end
      end

      def gather_from_scss(location, colors)
        Dir.chdir(File.expand_path(location))
        scss_files = Dir.glob("**/*.scss")
        scss_files.each do |scss_file|
          scss_file = Sass::SCSS.compile_file(scss)
          File.new(File.join('/', "tmp", File.basename(scss)))
        end
      end

      def attributes_from(declarations, color)
        attributes = declarations.split(";").find_all{|a| a.include?(color)}
        attributes = attributes.map{|a| v = a.split(":").map(&:strip); {key: v.first, value: v.last}}
        attributes
      end

      def gather_from_hex(colors, css_colors, declarations, specificity, selector, css_file)
        css_colors.each do |c|
          color_value = c.first
          attributes = attributes_from(declarations, color_value)
          color = Color::RGB.from_html(color_value)
          add_to_color(colors, color, "hex", specificity, selector, css_file, attributes, false, color.css_rgba, color.css_hsla)
        end
      end

      def gather_from_name(colors, css_colors, declarations, specificity, selector, css_file)
        css_colors.each do |c|
          color_value = c.first
          attributes = attributes_from(declarations, color_value)
          color = Color::RGB.const_get(color_value.classify)
          add_to_color(colors, color, "name", specificity, selector, css_file, attributes, false, color.css_rgba, color.css_hsla)
        end
      end

      def gather_from_hsla(colors, css_colors, declarations, specificity, selector, css_file)
        css_colors.each do |type, color_value|
          from = color_value.include?("%") ? :percent : :fraction
          attributes = attributes_from(declarations, color_value)
          h, s, l, alpha = color_value.split(",").map(&:strip)
          if from == :percent
            color = Color::HSL.new(h.to_i,s.to_i,l.to_i)
          else
            color = Color::HSL.from_fraction(h,s,l)
          end
          transparency = !((alpha.to_f||1) == 1)
          rgba = rgb_alpha(color.to_rgb, alpha)
          hsla = hsl_alpha(color.to_hsl, alpha)
          add_to_color(colors, color, type, specificity, selector, css_file, attributes, transparency, rgba, hsla)
        end
      end

      def gather_from_rgba(colors, css_colors, declarations, specificity, selector, css_file)
        css_colors.each do |type, color_value|
          from = color_value.include?("%") ? :percent : :numbers
          attributes = attributes_from(declarations, color_value)
          r, g, b, alpha = color_value.split(",").map(&:strip)
          if from == :percent
            color = Color::RGB.from_percentage(r.to_i,g.to_i,b.to_i)
          else
            color = Color::RGB.new(r.to_i,g.to_i,b.to_i)
          end
          transparency = !(alpha.nil? || alpha.to_f == 1)
          rgba = rgb_alpha(color.to_rgb, alpha)
          hsla = hsl_alpha(color.to_hsl, alpha)
          add_to_color(colors, color, type, specificity, selector, css_file, attributes, transparency, rgba, hsla)
        end
      end

      def rgb_alpha(color, alpha)
        "rgba(%3.2f%%, %3.2f%%, %3.2f%%, %3.2f)" % [ color.red_p, color.green_p, color.blue_p, (alpha.to_f||1) ]
      end

      def hsl_alpha(color, alpha)
        "hsla(%3.2f, %3.2f%%, %3.2f%%, %3.2f)" % [ color.hue, color.saturation, color.luminosity, (alpha.to_f||1) ]
      end

      def instance(found_as, specificity, selector, css_file, attributes, transparency, rgba, hsla)
        {found_as: found_as, specificity: specificity, selector: selector, extension: File.extname(css_file).gsub(".",''), file_name: File.basename(css_file), file: css_file, attribute: attributes, selector_path: selector.split(" "), base_class: !(selector.include?('.') || selector.include?('#')), transparency: transparency, rgba: rgba, hsla: hsla}
      end

      def add_to_color(colors, color, found_as, specificity, selector, css_file, attributes, transparency, rgba, hsla)
        if colors.has_key?(color.html)
          colors[color.html][:instances] << instance(found_as, specificity, selector, css_file, attributes, transparency, rgba, hsla)
          colors[color.html][:count] += 1
        else
          colors[color.html] = {html: color.html, rgb: color.css_rgb, hsl: color.css_hsl, count: 1, instances: [instance(found_as, specificity, selector, css_file, attributes, transparency, rgba, hsla)]}
        end
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
        # gem_dir = File.dirname(File.expand_path(__FILE__))
        # rendered_file = ERB.new(File.read(File.join(gem_dir, "server/views/colors.html.erb")))
        # rendered_file.result(binding)
      end

      def write_report(dir)
        colors_file = File.new("/tmp/colors.html", "w+")
        color_report = AppSleuth::Colors.generate_report(dir)
        colors_file.puts color_report
        colors_file.close
      end
    end
  end
end
# color_file = File.new(File.join(Rails.root, 'tmp', 'colors.html'), "w+")
# in_project(File.join(Rails.root, 'app', 'assets', 'stylesheets'))