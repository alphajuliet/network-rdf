// viz_people_knows.js

var width = 700, height = 500;

var force = d3.layout.force()
    .charge(-300)
    .linkDistance(120)
    .size([width, height]);

    
function renderNetworkOn(svg) {
	
	d3.json("/people/knows", function (data) {
		var names = _.union( _.pluck(data, "source"), _.pluck(data, "target"));
		var nodes = _.map(names, function (n, i) { return {"name": n}; });
		// Map names to an index into the nodes
		var links = _.map(data, function (link) {
				return {
					"source": _.indexOf(names, link.source),
					"target": _.indexOf(names, link.target)
				}
		});
		console.log("Processed " + nodes.length + " nodes, " + links.length + " links.");
		console.log(links[0]);
				
		var force = d3.layout.force()
			.nodes(nodes)
			.links(links)
			.size([width, height])
			.start();

		var link = svg.selectAll(".link")
				.data(links)
			.enter().append("line")
				.attr("class", "link");
	
		var node = svg.selectAll(".node")
				.data(nodes)
			.enter().append("circle")
				.attr("class", "node")
				.attr("r", 5)
				.call(force.drag);	
			
		node.append("text")
			.attr("dx", "12px")
			.attr("dy", 0)
			.text(function (d) { return d.name });
			
		node.append("title")
			.text(function (d) { return d.name });
			
		force.on("tick", function() {
			link.attr("x1", function(d) { return d.source.x; })
					.attr("y1", function(d) { return d.source.y; })
					.attr("x2", function(d) { return d.target.x; })
					.attr("y2", function(d) { return d.target.y; });
			node.attr("cx", function(d) { return d.x; })
					.attr("cy", function(d) { return d.y; });
		});
			
	});
}

var svg = d3.select("#viz")
	.append("svg")
		.attr("width", width)
		.attr("height", height)
		
renderNetworkOn(svg);		
		
// The End
