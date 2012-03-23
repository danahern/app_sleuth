color_file = File.new(File.join(Rails.root, 'tmp', 'colors.html'), "w+")

template_header = <<TEMPLATE
<!doctype html>
<!--[if lt IE 7]> <html class="no-js lt-ie9 lt-ie8 lt-ie7" lang="en"> <![endif]-->
<!--[if IE 7]>    <html class="no-js lt-ie9 lt-ie8" lang="en"> <![endif]-->
<!--[if IE 8]>    <html class="no-js lt-ie9" lang="en"> <![endif]-->
<!--[if gt IE 8]><!--> <html class="no-js" lang="en"> <!--<![endif]-->
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
  <title>Color Sleuth</title>
  <meta name="description" content="">
  <meta name="viewport" content="width=device-width">
  <link rel="stylesheet" href="css/style.css">
  <script src="js/libs/modernizr-2.5.3.min.js"></script>
</head>
<body>
  <!--[if lt IE 7]><p class=chromeframe>Your browser is <em>ancient!</em> <a href="http://browsehappy.com/">Upgrade to a different browser</a> or <a href="http://www.google.com/chromeframe/?redirect=true">install Google Chrome Frame</a> to experience this site.</p><![endif]-->
  <header>

  </header>
  <div id="main" role="main">

  <a class='btn' id="light-switch">Toggle Text Color</a>
    <ul id="swatches">
TEMPLATE

template_footer = <<TEMPLATE
    </ul>
  </div>
  <footer>

  </footer>

  <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>
  <script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.18/jquery-ui.min.js"></script>
  <script src="js/plugins.js"></script>
  <script src="js/script.js"></script>


  <script>
    var _gaq=[['_setAccount','UA-30291020-1'],['_trackPageview']];
    (function(d,t){var g=d.createElement(t),s=d.getElementsByTagName(t)[0];
    g.src="http://www.google-analytics.com/ga.js";
    s.parentNode.insertBefore(g,s)}(document,'script'));
  </script>
</body>
</html>

TEMPLATE

color_file.puts template_header

def color_lookup(color_code)
  c = `egrep -ir '(#{color_code})( |;)' #{File.join(Rails.root, 'app', 'assets', 'stylesheets')}`.split("\n")
end

colors = `egrep --no-filename -ior '(#[a-fA-F0-9]{6}|#[a-fA-F0-9]{3})( |;)' #{File.join(Rails.root, 'app', 'assets', 'stylesheets')}`.split.map{|c| c.gsub(';', '').gsub(' ', '').downcase }.uniq.sort

colors.each{|color| color_file.puts "<li data-hex='#{color}' data-color-lookup='#{color_lookup(color)}' class='swatch' style='background-color:#{color};'><a class='close delete'>x</a><span class='help'>Double Click To Bring to Front</span></li>"}

color_file.puts template_footer

color_file.close