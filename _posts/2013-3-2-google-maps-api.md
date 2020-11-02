---
layout: post
title: Google Maps Api
image: /assets/img/2013-3-2-google-maps-api/maps.jpg
readtime: 3 minutes
---

I've been playing about with the Google maps API.


Here is an example - I have set the latitude and longitude to show all the bars in the northern quarter in manchester: position 53.484171,-2.236357

<script src="http://maps.google.com/maps?file=api&amp;v=3&amp;sensor=false&amp;key=AIzaSyAFovXryTb-pSfgtfuavqoeqHGbupC2dfU" type="text/javascript"></script>

<div id="map" style="height: 450px; width: 550px;">
<div class="separator" style="clear: both; text-align: center;">

<script type="text/javascript">
    //<![CDATA[
    
    if (GBrowserIsCompatible()) { 

      function createMarker(point,html) {
        var marker = new GMarker(point);
        GEvent.addListener(marker, "click", function() {
          marker.openInfoWindowHtml(html);
        });
        return marker;
      }

      var map = new GMap2(document.getElementById("map"));
      map.addControl(new GLargeMapControl());
      map.addControl(new GMapTypeControl());
      map.setCenter(new GLatLng(53.484171,-2.236357),16);
   
      var point = new GLatLng(53.48510, -2.2379);
      var marker = createMarker(point,'<div style="width:240px">
Hare And Hounds<\/div>')
      map.addOverlay(marker);
    }
    
    // display a warning if the browser was not compatible
    else {
      alert("Sorry, the Google Maps API is not compatible with this browser");
    }
    //]]>
</script>