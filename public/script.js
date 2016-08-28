var map, geocoder, markers = [];

function fillResultsWith(offers) {
  $('#results').html('');
  var buffer = '';
  for (var offer in offers) {
    offer = offers[offer]

    buffer += '<a class="offer" href="http://www.anfe.fr/component/offresemploi/' + offer.reference + '?view=offre" target="_blank">';
    buffer += '<span class="type">' + offer.type + '</span> - ';
    buffer += '<span class="name">' + offer.name + '</span>';
    buffer += '<div class="city">(' + offer.city + ')</div>';
    buffer += '</a>';
  }
  $('#results').html(buffer);
}

function iconFor(offer) {
  if (offer.type === "CDD") {
    return "http://maps.google.com/mapfiles/ms/icons/yellow-dot.png";
  } else if (offer.type === "CDI") {
    return "http://maps.google.com/mapfiles/ms/icons/blue-dot.png";
  } else {
    return "http://maps.google.com/mapfiles/ms/icons/green-dot.png";
  }
}

function insertMarkers() {
  for (var coords in offer_groups) {
    if (offer_groups.hasOwnProperty(coords)) {
      (function(coords) {
        var offers = offer_groups[coords];
        var offer = offers[0];;
        var marker = new google.maps.Marker({
          position: { lat: offer.coords[0], lng: offer.coords[1] },
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
