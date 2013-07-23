// viz_person_card.js

var width = 500, 
		height = 500;

function renderPersonOn(svg, person) {
	
	d3.json("/person/" + person + "/knows", function (sparql) {
    var data = sparql.results.bindings;
		var nodes = _.map(data, function (e) { return { "name": e.name.value } });
    nodes.unshift({"name": person});

		// Map names to an index into the nodes
    var links = [];
    for (i=1; i<nodes.length; i++) {
      links.push({"name": "foaf:knows", "source": 0, "target": i});
    }
		console.log("Processed " + nodes.length + " nodes, " + links.length + " links.");
				
		var force = d3.layout.force()
			.nodes(nodes)
			.links(links)
			.size([width, height])
      .charge(-150)
      .gravity(0.05)
      .linkDistance(150)
      .linkStrength(1)
			.start();

    // Render the edges
    var edge = svg.selectAll(".edge")
      .data(links)
      .enter()
      .append("g")
        .attr("class", "edge")
      .append("line");


    // Render the nodes
		var node = svg.selectAll(".node")
      .data(nodes)
			.enter()
      .append("g")
        .attr("class", "node");

    node.append("circle")
      .attr("r", 12)
      .style("fill", function (d, i) { return i==0 ? "#f99" : "#99f" })
      .call(force.drag);
			
    node.append("text")
      .text(function (d) { return d.name })
      .attr("dx", 15)
      .attr("dy", 15);
			
		force.on("tick", function() {
			edge.attr("x1", function(d) { return d.source.x; })
					.attr("y1", function(d) { return d.source.y; })
					.attr("x2", function(d) { return d.target.x; })
					.attr("y2", function(d) { return d.target.y; });
			node.attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; });
		});
			
	});
}

var svg = d3.select("#viz")
	.append("svg")
		.attr("width", width)
		.attr("height", height)
		
// renderPersonOn(svg, name);		
		
// The End
