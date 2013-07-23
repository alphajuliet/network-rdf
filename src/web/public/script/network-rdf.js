// network-rdf.js
// Requires jQuery and Underscore

// Convert SPARQL results hash to a more concise hash, using the headings as
// the keys
function compressSPARQL (json) {
  _.map(json.results.bindings, function (e) { return _.object(_.keys(e), _.values(e)) } )
}

function main() {
	$("input#cmd_person_all").click(function () {
			window.location = "person/" + $("input[name=person1]").val();
	});

	$("input#cmd_org_people").click(function () {
			window.location = "org/" + $("input[name=org1]").val() + "/people";
	});

  $("input#cmd_viz_person").click(function () {
      window.location = "viz/person/" + $("input[name=person2]").val();
  });
}

$(document).ready(function() {
	main()
});


// The end
