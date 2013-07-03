// Authors: Dan Ahern & Lynn Wallenstein

$(document).ready(function() {

//  RENDERING THE JSON START
// -------------------------------------------------------------

  // JSON Sources
  // var colorsData = "/dynamic/colors.json";

  // Template Sources
  // var colorItemTemplate = $("#colorItemTemplate").html();

  // Compile Templates
  // var tmplColorItemTemplate = Handlebars.compile(colorItemTemplate);


  // $('#loading_indicator').show();

  // // Loading Data for Templating
  // $.getJSON(colorsData, function(colorsData) {

  //   console.log("Getting Data from: "+colorsData);
  //   console.log("Length: "+colorsData.length);
  //   if(colorsData.length === 0) {
  //     $('#loading_indicator').hide();
  //     console.log("No Data Found");
  //   } else {
  //     console.log("Data Found");
  //     console.dir(colorsData);
  //     $('#loading_indicator').hide();
  //     console.log("Hiding Indicator");
  //     console.log("------== Rendering Data Start ==-------");
  //     console.log("Rendering Colors Start");
  //     $("ul#swatches").html(tmplColorItemTemplate(colorsData));
  //     console.log("Rendering Colors End");
  //     console.log("------== Rendering Data Complete ==-------");
  //   }
  //   $( ".swatch" ).draggable();
  // });

  //  RENDERING THE JSON END
// -------------------------------------------------------------

  var currentIndex = 100;

  $("body").delegate("a#light-switch", "click", function(){
    $(".swatch").toggleClass("light-switch");
  });

  $("body").delegate(".swatch", "click", function(){
    $( ".swatch" ).draggable();
    //console.log(currentIndex);
    $(this).css("z-index",currentIndex);
      currentIndex = currentIndex +1;
  });

  $("body").delegate(".close", "click", function(){
      //console.log("you clicked close.");
      var answer = confirm("You Sure You Want to Delete This Swatch?");
      if (answer) {
        $(this).parents("li.swatch").remove()
      }
  });

});
