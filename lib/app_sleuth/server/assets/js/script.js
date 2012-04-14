
// usage: log('inside coolFunc', this, arguments);
// paulirish.com/2009/log-a-lightweight-wrapper-for-consolelog/
window.log = function(){
  log.history = log.history || [];   // store logs to an array for reference
  log.history.push(arguments);
  if(this.console) {
    arguments.callee = arguments.callee.caller;
    var newarr = [].slice.call(arguments);
    (typeof console.log === 'object' ? log.apply.call(console.log, console, newarr) : console.log.apply(console, newarr));
  }
};

// make it safe to use console.log always
(function(b){function c(){}for(var d="assert,clear,count,debug,dir,dirxml,error,exception,firebug,group,groupCollapsed,groupEnd,info,log,memoryProfile,memoryProfileEnd,profile,profileEnd,table,time,timeEnd,timeStamp,trace,warn".split(","),a;a=d.pop();){b[a]=b[a]||c}})((function(){try
{console.log();return window.console;}catch(err){return window.console={};}})());



// Authors: Dan Ahern & Lynn Wallenstein

$(document).ready(function() {

    var currentIndex = 100;

    $( ".swatch" ).draggable();

    $("a#light-switch").click(function () {
      $(".swatch").toggleClass("light-switch");
    }); 

    $(".swatch").click(function () {
      //console.log(currentIndex);
      $(this).css("z-index",currentIndex);
      currentIndex = currentIndex +1;
    }); 

    $(".close").click(function () {
      //console.log("you clicked close.");
      var answer = confirm("You Sure You Want to Delete This Swatch?");
      if (answer) {
        $(this).parents("li.swatch").remove()
      }
    }); 

// --------------------------------------------

  // JSON Sources
  var colorsData = "/dynamic/colors.json";

  // Template Sources
  var colorItemTemplate = $("#colorItemTemplate").html();

  // Compile Templates
  var tmplColorItemTemplate = Handlebars.compile(colorItemTemplate);


  $('#loading_indicator').show();

  // Loading Data for Templating
  $.getJSON(colorsData, function(areaData) {

    console.dir(colorsData);
    if(colorsData.length === 0) {
      $('#loading_indicator').hide();
      console.log("No Data Found");
    } else {
      console.log("Data Found");
      console.dir(colorsData);
      $('#loading_indicator').hide();
      console.log("Hiding Indicator");
      console.log("-== Rendering Data ==-");
      console.log("Rendering Preloader");
      $("ul#colors").html(tmplColorItemTemplate(colorsData));
      console.log("Rendering Colors");
    }
  });

});
