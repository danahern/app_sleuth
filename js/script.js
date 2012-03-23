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
        $(this).parent.remove()
      }
    }); 

});