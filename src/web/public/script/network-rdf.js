// network-rdf.js

// var server = "http://192.168.0.2:4567/";
var server = "";

function main() {
	$("input#cmd_person_value").click(function () {
			window.location = server + "person/" + $("input[name=person1]").val();
	});
	
	$("input#cmd_person_knows").click(function () {
			window.location = server + "person/" + $("input[name=person2]").val() + "/knows";
	});
	
	$("input#cmd_people_at").click(function () {
			window.location = server + "people/at/" + $("input[name=org1]").val();
	});

	
}

$(document).ready(function() {
	main()
});


// The end
