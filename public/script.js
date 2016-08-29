var map, geocoder, markers = [];

function fillResultsWith(offers) {
  $('#results').html('');
  var buffer = '';
  for (var offer in offers) {
    offer = offers[offer]

    buffer += '<a class="offer" href="' + offer.url + '" target="_blank">';
    buffer += '<span class="name">' + offer.name + '</span><br />';
    buffer += '<span class="type">' + offer.type + '</span> - ';
    buffer += '<span class="city">' + offer.city + '</span> - ';
    buffer += '<span class="date">' + offer.created_at + '</span>';
    buffer += '</a>';
  }
  $('#results').html(buffer);
}

function iconFor(newest_offer) {
  if (newest_offer.age < 5) {
    return "http://maps.google.com/mapfiles/ms/icons/red-dot.png";
  } else if (newest_offer.age < 15) {
    return "http://maps.google.com/mapfiles/ms/icons/green-dot.png";
  } else {
    return "http://maps.google.com/mapfiles/ms/icons/blue-dot.png";
  }
}

function insertMarkers() {
  for (var coords in offer_groups) {
    if (offer_groups.hasOwnProperty(coords)) {
      (function(coords) {
        var offers = offer_groups[coords];
        var offer = offers[offers.length - 1];;
        var marker = new google.maps.Marker({
          position: { lat: offer.lat, lng: offer.lng },
          icon: iconFor(offer),
          map: map,
          title: 'Résulats (' + offers.length + ')',
        });

        google.maps.event.addListener(marker, 'click', function() {
          fillResultsWith(offers);
        });

        markers.push(marker);
      })(coords)
    }
  }
}

$(function(){
  geocoder = new google.maps.Geocoder();
  var options = { zoom: 6, center: { lat: 46.8937365, lng: 2.5274564 } }
  map = new google.maps.Map(document.getElementById("map-canvas"), options);
  insertMarkers();
});
