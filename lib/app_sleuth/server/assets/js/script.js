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
