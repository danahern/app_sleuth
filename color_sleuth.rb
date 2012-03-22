color_file = File.new(File.join(Rails.root, 'tmp', 'colors.html'), "w+")
template_top = <<TEMPLATE
Multiple Lines
Are Possible
Here
TEMPLATE

color_file.puts template_top

def color_lookup(color_code)
  c = `egrep -ir '(#{color_code})( |;)' #{File.join(Rails.root, 'app', 'assets', 'stylesheets')}`.split
end

colors = `egrep --no-filename -ior '(#[a-fA-F0-9]{6}|#[a-fA-F0-9]{3})( |;)' #{File.join(Rails.root, 'app', 'assets', 'stylesheets')}`.split.map{|c| c.gsub(';', '').gsub(' ', '').downcase }.uniq.sort

colors.each{|color| color_file.puts "<div style='float: left; margin: 0 20px 20px 0; width:100px;height:100px;background-color:#{color};'><span style='color:white'>#{color}</span><br/><span style='color:black'>#{color}</span></div><div style='display:none;'>#{color_lookup(color)}</div>"}
color_file.close