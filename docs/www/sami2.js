// A few things about this.
//
// First, this leans pretty heavily on jQuery, but I'm running it in
// noConflict() mode because I'm not sure what JavaScript libraries we're going
// to be using down the line. Given that this is the first real web-based Vista
// project that we're doing, this just seemed prudent.
//
// Second, you'll note that this does no form validation whatsoever at the
// moment. Mumps is both a programming language and the database engine, and
// thus it should specify *all* the business logic (just as you might with a
// proper SQL database). Later on, we'll work out a way to encode that logic
// and pass it to the JavaScript so that validation can happen in the browser,
// but for now, the server needs to do it old-school.
//
// Third, you'll note that the -switch regions are toggled on and off with a
// .disabled class, which dims the text to a light grey. This could have been
// done with the CSS inherit property so that .disabled could just be set on
// the parent property, but we don't know whether any of the text in these
// regions will be highlighted in a different color or whatnot in the future,
// so we're using an explicit class so that any of their "normal" properties
// will be preserved.
//
// (My thanks to Domenic DiNatale, who knows JavaScript a lot better than I.)
//
// ---ven/mcglk

var $jQ = jQuery.noConflict();

$jQ( document ).ready( function() {

  // Get the first form element; for the SAMI forms, this will always be the
  // first form.

  var switchon = function(container){
        var obj = $jQ(container);
        obj.removeClass("disabled");
        obj.find(".disabled").each( function(){
          if (this.id.match(/-n?switch/)) { return; }
          $jQ(this).removeClass("disabled");
        });
        obj.find("input, select, textarea").each( function(){
          if (this.name.match(/-vis$/)) { return; }
          $jQ(this).prop("disabled", false);
        });
      },
      switchoff = function(container){
        var obj = $jQ(container);
        obj.addClass("disabled");
        obj.find().addClass("disabled");
        obj.find("input, select, textarea").prop("disabled", true);
      },
      switcher = function(){
        var control = $jQ(this).attr("switch");
        var container = $jQ("[id^='" + this.name + "-switch']");
        if (container.length > 0 && control == "y") {
          switchon( container );
        } else {
          switchoff( container );
        }
        container = $jQ("[id^='" + this.name + "-nswitch']");
        if (container.length > 0 && control != "y") {
          switchon( container );
        } else {
          switchoff( container );
        }
      },
      bgform = $jQ( "form#backgroundForm" )[0],
      msinyear = 31557600000.0; // Milliseconds in one year.

    // The I-ELCAP data format.
    $jQ( "input.ddmmmyyyy" ).datepicker( {
      showOn: "button",
      buttonImage: "calendar.png",
      buttonImageOnly: true,
      buttonText: "Select date",
      dateFormat: "dd/M/yy"
    } );
    // ISO date format, when we get around to that.
    $jQ( "input.yyyymmdd" ).datepicker( {
      showOn: "button",
      buttonImage: "calendar.png",
      buttonImageOnly: true,
      buttonText: "Select date",
      dateFormat: "yy-mm-dd"
    } );

  if (bgform) {
    var flatInput = function( name ){
          return $jQ( "form#backgroundForm [name='" + name + "']" );
        },
        radioSelected = function( name ){
          return $jQ(
            "form#backgroundForm input[name='" + name + "']:checked"
          )[0];
        },
        calculateBMI = function( htInMeters, wtInKilograms ) {
          if( htInMeters > 0 && wtInKilograms > 0 ) {
            var areaInSquareMeters = htInMeters * htInMeters,
                bmi = wtInKilograms / areaInSquareMeters;
            return bmi;
          } else {
            return undefined;
          }
        },
        bmiCalc = function(){
          var htm = (radioSelected("sbphu").value == "i" ? 0.0254 : 0.01),
              wtm = (radioSelected("sbpwu").value == "p" ? 0.4535 : 1),
              ht = flatInput("sbph").val() * htm,
              wt = flatInput("sbpw").val() * wtm,
              bmi = calculateBMI(ht,wt);
          if( bmi ) {
            flatInput("sbbmi").val( bmi.toFixed(1) );
          } else {
            flatInput("sbbmi").val( "" );
          }
          flatInput("sbbmivis").val( flatInput("sbbmi").val() );
        },
        sbffrCalc = function(){
          var sbffr;
          if( flatInput("sbfvc").val() > 0.1 ) {
            sbffr = (
              flatInput("sbfev1").val() / flatInput("sbfvc").val() * 100.0
            );
            flatInput("sbffr").val( sbffr.toFixed(2) );
            flatInput("sbffrvis").val( sbffr.toFixed(1) + '%' );
          } else {
            flatInput("sbffrvis").val( "" );
          }
        },
        sbsdlcyyThing = function(field){
          var x = parseInt(flatInput(field).val());
          if (x) {
            return x.toFixed(0);
          } else {
            return 0;
          }
        },
        sbsdlcyyCalc = function(){
          var today = new Date(),
              quitYear, quitMonth, quitDay, quitDate, since;
          quitYear = sbsdlcyyThing("sbsdlcy");
          quitMonth = sbsdlcyyThing("sbsdlcm");
          quitDay = sbsdlcyyThing("sbsdlcd");
          if (quitYear && quitMonth && quitDay) {
            quitMonth--;
          } else if (quitYear && quitMonth && !quitDay) {
            quitMonth--;
            quitDay = 1;
          } else if (quitYear && !quitMonth && quitDay) {
            quitMonth = today.getMonth();
          } else if (!quitYear && quitMonth && quitDay) {
            quitYear = today.getFullYear();
          } else if (quitYear && !quitMonth && !quitDay) {
            quitMonth = today.getMonth();
            quitDay = today.getDate();
          } else if (!quitYear && !quitMonth && quitDay) {
            quitYear = today.getFullYear();
            quitMonth = today.getMonth();
          } else if (!quitYear && quitMonth && !quitDay) {
            quitYear = today.getFullYear();
            quitDay = 1;
          } else if (!quitYear && !quitMonth && !quitDay) {
            flatInput("sbsdlcy-vis").val("");
            return;
          }
          quitDate = new Date(quitYear, quitMonth, quitDay);
          since = today - quitDate;
          if (since < 0) {
            flatInput("sbsdlcy-vis").val("");
            return;
          }            
          since /= msinyear;
          flatInput("sbsdlcy-vis").val( since.toFixed(1) );
        },
        sbntpyCalc = function(){
          var dpw = flatInput("sbcdpw").val(),
              ppd = flatInput("sbcppd").val(),
              yrs = flatInput("sbfdur").val();
          if (dpw && ppd && yrs) {
            flatInput("sbntpy").val(dpw * ppd * 52 * yrs);
          } else {
            flatInput("sbntpy").val("");
          }
        };
    flatInput("sbph").on( "change", bmiCalc );
    flatInput("sbpw").on( "change", bmiCalc );
    flatInput("sbphu").on( "change", bmiCalc );
    flatInput("sbpwu").on( "change", bmiCalc );
    bmiCalc();
    flatInput("sbfev1").on( "change", sbffrCalc );
    flatInput("sbfvc").on( "change", sbffrCalc );
    sbffrCalc();
    flatInput("sbsdlcd").on( "change", sbsdlcyyCalc );
    flatInput("sbsdlcm").on( "change", sbsdlcyyCalc );
    flatInput("sbsdlcy").on( "change", sbsdlcyyCalc );
    sbsdlcyyCalc();
    flatInput("sbcdpw").on( "change", sbntpyCalc );
    flatInput("sbcppd").on( "change", sbntpyCalc );
    flatInput("sbfdur").on( "change", sbntpyCalc );
    sbntpyCalc();
    // Set up switch triggers.
    $jQ("form [switch]").on("change", switcher);
    // Deactivate all the switch regions. (Note: We could just leave them all
    // inactive in the original HTML, but if for some reason JavaScript isn't
    // available, we need this to degrade gracefully.)
    $jQ("form [switch]").each(function(){
      var sname = "[id^='" + this.name + "-switch']";
      switchoff(sname);
      sname = "[id^='" + this.name + "-nswitch']";
      switchoff(sname);
    });
    // Now turn on all the ones whose triggers are switched on.
    $jQ("form [switch]").each(function(){
      var sname = "[id^='" + this.name + "-switch']";
      if ($jQ(this).prop("checked") && $jQ(this).val() == "y") {
        switchon(sname);
      }
      sname = "[id^='" + this.name + "-nswitch']";
      if ($jQ(this).prop("checked") && $jQ(this).val() != "y") {
        switchon(sname);
      }
    });
  }

} );

