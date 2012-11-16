// viz.js
 
var width = 600, height = 600;

function renderExampleOn(svg) {
	svg.append("circle")
			.style("stroke", "gray")
			.style("fill", "white")
			.attr("r", 40)
			.attr("cx", 50)
			.attr("cy", 50)
			.on("mouseover", function(){d3.select(this).style("fill", "aliceblue");})
			.on("mouseout", function(){d3.select(this).style("fill", "white");}); 	
}

function renderCompanyDataOn(svg) {
	var bar_height = 12, bar_spacing = 3;
	var indent = 200;
	d3.json("/org/count_by_person?min=2", function (result) {
		console.log("Got " + result.length + " items.");
		svg.selectAll("rect")
			.data(result)
			.enter()
			.append("rect")
				.attr("x", indent)
				.attr("y", function (d, index) { return index * (bar_height + bar_spacing); })
				.attr("width", function (d, index) { return d.members * 10; })
				.attr("height", bar_height)
				.attr("fill", "#ccccff")
				;
		svg.selectAll("text.label")
			.data(result)
			.enter()
  		.append("text")
				.text(function (d, i) { return d.orgname; })
				.attr("class", "label")
				.attr("x", 0)
				.attr("y", function (d, i) { return i * (bar_height + bar_spacing); })
				.attr("dy", 1+(bar_height + bar_spacing) / 2)
				;
		svg.selectAll("text.value")
			.data(result)
			.enter()
			.append("text")
				.text(function (d, i) { return d.members; })
				.attr("class", "value")
				.attr("x", indent)
				.attr("y", function (d, i) { return i * (bar_height + bar_spacing); })
				.attr("dx", 2)
				.attr("dy", 1+(bar_height + bar_spacing) / 2)
				;
	});
}

var svg = d3.select("#viz")
	.append("svg")
		.attr("width", width)
		.attr("height", height)
	
// renderExampleOn(svg);  
renderCompanyDataOn(svg);

// The End
