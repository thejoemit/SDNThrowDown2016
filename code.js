var cy;
$(function(){
			var	$window = $(window),
			$body = $('body'),
			$menu = $('#menu'),
			$main = $('#main'),
			$map = $.getJSON('map.json');
			var $search = $('#search'),
				$search_input = $search.find('input');
			$body
				.on('click', '[href="#search"]', function(event) {
					event.preventDefault();
						if (!$search.hasClass('visible')) {
								$search[0].reset();
								$search.addClass('visible');
								$search_input.focus();
						}
				});
			$search_input
				.on('keydown', function(event) {
					if (event.keyCode == 27)
						$search_input.blur();

				})
				.on('blur', function() {
					window.setTimeout(function() {
						$search.removeClass('visible');
					}, 100);
				});
	
  cy = cytoscape({
    container: document.getElementById('cy'),
    style: $.getJSON('css.json'),
    elements: $map
  });
				
  var params = {
	name: 'cola', animate: true,
    fit: true, maxSimulationTime: 8000/*1500*/, 
    padding: 10, refresh: 1, ungrabifyWhileSimulating: false,
    edgeLengthVal: 50,
    edgeLength: 20,
    boundingBox: undefined, // constrain layout bounds; { x1, y1, x2, y2 } or { x1, y1, w, h }
	// positioning options
	randomize: false, // use random node positions at beginning of layout
	avoidOverlap: true, // if true, prevents overlap of node bounding boxes
	handleDisconnected: true, // if true, avoids disconnected components from overlapping
	nodeSpacing: 10, // extra spacing around nodes
	flow: undefined, // use DAG/tree flow layout if specified, e.g. { axis: 'y', minSeparation: 30 }
	alignment: undefined, // relative alignment constraints on nodes, e.g. function( node ){ return { x: 0, y: 1 } }
	// different methods of specifying edge length
	// each can be a constant numerical value or a function like `function( edge ){ return 2; }`
	edgeSymDiffLength: undefined, // symmetric diff edge length in simulation
	edgeJaccardLength: undefined, // jaccard edge length in simulation
	// iterations of cola algorithm; uses default values on undefined
	unconstrIter: 100, // unconstrained initial layout iterations
	userConstIter: 100, // initial layout iterations with user-specified constraints
	allConstIter: 100, // initial layout iterations with all constraints including non-overlap
	// infinite layout options
	infinite: false // overrides all other options for a forces-all-the-time mode
	//, infinite: false
  };
  var layout = makeLayout();
  var running = false;

  cy.on('layoutstart', function(){
  	$map = $.getJSON('map.json');
    running = true;
  }).on('layoutstop', function(){
    running = false;
  });
  
  layout.run();
  
  var $config = $('#config');
  var $info = $('#selectinfo');
  var $traffic = $('#network');
  var $btnParam = $('<div class="param"></div>');
  $config.append( $btnParam );
  

  var sliders = [
    {
      label: 'Edge length',
      param: 'edgeLengthVal',
      min: 1,
      max: 200
    },

    {
      label: 'Node spacing',
      param: 'nodeSpacing',
      min: 1,
      max: 50
    }
  ];

  var buttons = [
    {
      label: '<i class="fa fa-random"></i>',
      layoutOpts: {
		fit: true, maxSimulationTime: 8000/*1500*/, 
		padding: 10, refresh: 1, ungrabifyWhileSimulating: false,
		randomize: true,
		edgeLength: function(e){ return params.edgeLengthVal / e.data('weight'); },
		flow: { axis: 'x', minSeparation: 1 },
		flow: { axis: 'y', minSeparation: 1 },
		infinite: false
      }
    },

    {
      label: '<i class="fa fa-thumbs-o-up"></i>',
      layoutOpts: {
		fit: true, maxSimulationTime: 8000/*1500*/, 
		padding: 10, refresh: 1, ungrabifyWhileSimulating: false,
		edgeLength: 20,
		boundingBox: undefined, // constrain layout bounds; { x1, y1, x2, y2 } or { x1, y1, w, h }
	  // positioning options
		randomize: false, // use random node positions at beginning of layout
		avoidOverlap: true, // if true, prevents overlap of node bounding boxes
		handleDisconnected: true, // if true, avoids disconnected components from overlapping
		nodeSpacing: 10, // extra spacing around nodes
		flow: undefined, // use DAG/tree flow layout if specified, e.g. { axis: 'y', minSeparation: 30 }
		alignment: undefined, // relative alignment constraints on nodes, e.g. function( node ){ return { x: 0, y: 1 } }
		// different methods of specifying edge length
		// each can be a constant numerical value or a function like `function( edge ){ return 2; }`
		edgeSymDiffLength: 10, // symmetric diff edge length in simulation
		edgeJaccardLength: 10, // jaccard edge length in simulation
		// iterations of cola algorithm; uses default values on undefined
		unconstrIter: 100, // unconstrained initial layout iterations
		userConstIter: 100, // initial layout iterations with user-specified constraints
		allConstIter: 100, // initial layout iterations with all constraints including non-overlap
		// infinite layout options
		infinite: false
      }
    },
	{
      label: '<i class="fa fa-unlock"></i>',
      layoutOpts: {
		infinite: true
      }
    }
  ];

  sliders.forEach( makeSlider );
  buttons.forEach( makeButton );

  function makeLayout( opts ){
    params.randomize = false;
    params.edgeLength = function(e){ return params.edgeLengthVal / e.data('weight'); };
    for( var i in opts ){
      params[i] = opts[i];
    }
    return cy.makeLayout( params );
  }

  function makeSlider( opts ){
    var $input = $('<input></input>');
    var $param = $('<div class="param"></div>');
    $param.append('<span class="label label-default">'+ opts.label +'</span>');
    $param.append( $input );
    $config.append( $param );
    var p = $input.slider({
      min: opts.min,
      max: opts.max,
      value: params[ opts.param ]
    }).on('slide', _.throttle( function(){
      params[ opts.param ] = p.getValue();

      layout.stop();
      layout = makeLayout();
      layout.run();
    }, 16 ) ).data('slider');
  }
  function makeButton( opts ){
    var $button = $('<button class="btn btn-default">'+ opts.label +'</button>');
    $btnParam.append( $button );
    $button.on('click', function(){
      layout.stop();
      if( opts.fn ){ opts.fn(); }
      layout = makeLayout( opts.layoutOpts );
      layout.run();
    });
  }
  $('#config-toggle').on('click', function(){
    $('body').toggleClass('config-closed');
    cy.resize();
  });
  var timeout;
  cy.on('select', 'node', function(event){
	   var t = cy.$('node:selected').attr("hostName");
	   var $param = $('<div class="param"></div>');
	    $info.empty();
	    $param.append('<br><br>');
	    $param.append('<p class="label label-default">Hostname:</p> ');
	    $param.append('<p class="label label-info">'+ t +'</p> ');
	    t = cy.$('node:selected').attr("asNumber");
	    $param.append('<p class="label label-default">AS:</p> ');
	    $param.append('<p class="label label-info">'+ t +'</p> ');
	    $param.append('<br>');
	    t = cy.$('node:selected').attr("id");
	    $param.append('<p class="label label-default">Router ID:</p> ');
	    $param.append('<p class="label label-info">'+ t +'</p>');
	    $param.append('<br>');
	    $param.append('<p class="label label-default">PCEP Status:</p> ');
	    t = cy.$('node:selected').attr("pcep_status");
	    if(t == "Up"){
		    $param.append('<p class="label label-info">'+ t +'</p>');
		    t = cy.$('node:selected').attr("pcep_address");
		    $param.append(' <p class="label label-default">PCEP IP:</p> ');
		    $param.append('<p class="label label-info">'+ t +'</p>');
	    } else {
		    $param.append('<p class="label label-down">'+ t +'</p>');
	    }
	    $param.append('<br>');
	    t = cy.$('node:selected').attr("management");
	    $param.append('<p class="label label-default">Management:</p> ');
	    if(t == "Unknown"){
		    $param.append('<p class="label label-down">'+ t +'</p>');
	    } else {
		    $param.append('<p class="label label-info">'+ t +'</p>');
	    }
	    $param.append('<br>');
	    t = cy.$('node:selected').attr("ospf_rid");
	    $param.append('<p class="label label-default">OSPF RID:</p> ');
	    $param.append('<p class="label label-info">'+ t +'</p>');
	    $param.append('<br>');
	    t = cy.$('node:selected').attr("ospf_terid");
	    $param.append('<p class="label label-default">OSPF TE-RID:</p> ');
	    $param.append('<p class="label label-info">'+ t +'</p>');
	    $param.append('<br>');
	    $info.append($param);
	    $info.reload();
  });
  cy.on('select', 'edge', function(event){
	   var t = cy.$('edge:selected').attr("topoObjectType");
	   if (t=="link") {
		   t = cy.$('edge:selected').attr("linkIndex");
		   var $param = $('<div class="param"></div>');
		    $info.empty();
		    $param.append('<br><br>');
		    $param.append('<p class="label label-default">Link:</p> ');
		    $param.append('<p class="label label-info">'+ t +'</p> ');
		    t = cy.$('edge:selected').attr("status");
		    $param.append('<p class="label label-default">Status:</p> ');
		    $param.append('<p class="label label-info">'+ t +'</p> ');
		    $param.append('<br>');	    
		    t = cy.$('edge:selected').attr("name_p");
		    $param.append('<p class="label label-default">Link Name:</p> ');
		    $param.append('<p class="label label-info">'+ t +'</p> ');
		    t = cy.$('edge:selected').attr("enda_host");
		    $param.append('<br>');
		    $param.append('<p class="label label-default">'+ t +'</p> ');
		    t = cy.$('edge:selected').attr("endz_host");
		    $param.append('<p class="label label-default">to</p> ');
		    $param.append('<p class="label label-default">'+ t +'</p>');
		    t = cy.$('edge:selected').attr("enda_ipv4");
		    $param.append('<p class="label label-info">'+ t +'</p> ');
		    t = cy.$('edge:selected').attr("endz_ipv4");
		    $param.append('<p class="label label-info">'+ t +'</p>');
		    $param.append('<br>');
		    t = cy.$('edge:selected').attr("enda_bw");
		    $param.append('<p class="label label-default">Bandwidth</p> ');
		    $param.append('<p class="label label-info">'+ t +'</p> ');
		    t = cy.$('edge:selected').attr("endz_bw");
		    $param.append('<p class="label label-info">'+ t +'</p>');
		    $param.append('<br>');
		    t = cy.$('edge:selected').attr("enda_tem");
		    $param.append('<p class="label label-default">TE Metric</p> ');
		    $param.append('<p class="label label-info">'+ t +'</p> ');
		    t = cy.$('edge:selected').attr("endz_tem");
		    $param.append('<p class="label label-info">'+ t +'</p> ');
		    t = cy.$('edge:selected').attr("enda_tec");
		    $param.append('<p class="label label-default">TE Colour</p> ');
		    $param.append('<p class="label label-info">'+ t +'</p> ');
		    t = cy.$('edge:selected').attr("endz_tec");
		    $param.append('<p class="label label-info">'+ t +'</p>');
		    $param.append('<br>');
		    t = cy.$('edge:selected').attr("enda_rsvpbw");
		    $param.append('<p class="label label-default">RSVP BW</p> ');
		    $param.append('<p class="label label-info">'+ t +'</p> ');
		    t = cy.$('edge:selected').attr("endz_rsvpbw");
		    $param.append('<p class="label label-info">'+ t +'</p>');
		    $param.append('<br>');
		    t = cy.$('edge:selected').attr("enda_ospfarea");
		    $param.append('<p class="label label-default">OSPF Area</p> ');
		    $param.append('<p class="label label-info">'+ t +'</p> ');
		    t = cy.$('edge:selected').attr("endz_ospfarea");
		    $param.append('<p class="label label-info">'+ t +'</p> ');
		    t = cy.$('edge:selected').attr("enda_ospftem");
		    $param.append('<p class="label label-default">OSPF TE Metric</p> ');
		    $param.append('<p class="label label-info">'+ t +'</p> ');
		    t = cy.$('edge:selected').attr("endz_ospftem");
		    $param.append('<p class="label label-info">'+ t +'</p>');
		    $param.append('<br>');
		    t = cy.$('edge:selected').attr("enda_timestamp");
		    $param.append('<p class="label label-default">Time</p> ');
		    $param.append('<p class="label label-info">'+ t +'</p> ');
		    t = cy.$('edge:selected').attr("endz_timestamp");
		    $param.append('<p class="label label-info">'+ t +'</p>');
		    t = cy.$('edge:selected').attr("enda_inputbps");
		    $param.append('<br>');
		    $param.append('<p class="label label-default">BPS In</p> ');
		    $param.append('<p class="label label-info">'+ t +'</p> ');
		    t = cy.$('edge:selected').attr("endz_inputbps");
		    $param.append('<p class="label label-info">'+ t +'</p>');
		    $param.append('<br>');
		    t = cy.$('edge:selected').attr("enda_outputbps");
		    $param.append('<p class="label label-default">BPS Out</p> ');
		    $param.append('<p class="label label-info">'+ t +'</p> ');
		    t = cy.$('edge:selected').attr("endz_outputbps");
		    $param.append('<p class="label label-info">'+ t +'</p>');
		    $param.append('<br>');
		    t = cy.$('edge:selected').attr("enda_inputpps");
		    $param.append('<p class="label label-default">PPS In</p> ');
		    $param.append('<p class="label label-info">'+ t +'</p> ');
		    t = cy.$('edge:selected').attr("endz_inputpps");
		    $param.append('<p class="label label-info">'+ t +'</p> ');
		    t = cy.$('edge:selected').attr("enda_outputpps");
		    $param.append('<p class="label label-default">PPS Out</p> ');
		    $param.append('<p class="label label-info">'+ t +'</p> ');
		    t = cy.$('edge:selected').attr("endz_outputpps");
		    $param.append('<p class="label label-info">'+ t +'</p>');
		    $param.append('<br>');
		    t = cy.$('edge:selected').attr("enda_inputpacket");
		    $param.append('<p class="label label-default">Packets In</p> ');
		    $param.append('<p class="label label-info">'+ t +'</p> ');
		    t = cy.$('edge:selected').attr("endz_inputpacket");
		    $param.append('<p class="label label-info">'+ t +'</p>');
		    $param.append('<br>');
		    t = cy.$('edge:selected').attr("enda_outputpacket");
		    $param.append('<p class="label label-default">Packets Out</p> ');
		    $param.append('<p class="label label-info">'+ t +'</p> ');
		    t = cy.$('edge:selected').attr("endz_outputpacket");
		    $param.append('<p class="label label-info">'+ t +'</p>');
		    $param.append('<br>');
		    $info.append($param);
		    $info.reload();
	   } else if (t=="lsp") {
		   t = cy.$('edge:selected').attr("lsp");
		   var $param = $('<div class="param"></div>');
		   if(t=="ete") {
			    t = cy.$('edge:selected').attr("group");
			    $info.empty();
			    $param.append('<br><br>');
			    $param.append('<p class="label label-default">Group:</p> ');
			    $param.append('<p class="label label-info">'+ t +'</p> ');
			    $param.append('<br>');
				t = cy.$('edge:selected').attr("tunnelId");
			    $param.append('<p class="label label-default">Tunnel Id:</p> ');
			    $param.append('<p class="label label-info">'+ t +'</p> ');
			    t = cy.$('edge:selected').attr("operationalStatus");
			    $param.append('<p class="label label-default">Status:</p> ');
			    $param.append('<p class="label label-info">'+ t +'</p> ');
			    t = cy.$('edge:selected').attr("controller");
			    $param.append('<br>');	    
			    $param.append('<p class="label label-default">Controller</p> ');
			    $param.append('<p class="label label-info">'+ t +'</p> ');
			    t = cy.$('edge:selected').attr("initiator");
			    $param.append('<p class="label label-info">'+ t +'</p>');
			    $param.append('<br>');	    
			    t = cy.$('edge:selected').attr("name_p");
			    $param.append('<p class="label label-default">Link Name:</p> ');
			    $param.append('<p class="label label-info">'+ t +'</p> ');
			    $param.append('<br>');
			    $info.append($param);
			    $info.reload();
		   } else {
			    t = cy.$('edge:selected').attr("group");
			    $info.empty();
			    $param.append('<br><br>');
			    $param.append('<p class="label label-default">Group:</p> ');
			    $param.append('<p class="label label-info">'+ t +'</p> ');
			    $param.append('<br>');
			    t = cy.$('edge:selected').attr("tunnelId");
			    $param.append('<p class="label label-default">Tunnel Id:</p> ');
			    $param.append('<p class="label label-info">'+ t +'</p> ');
			    t = cy.$('edge:selected').attr("live_status");
			    $param.append('<p class="label label-default">Status:</p> ');
			    $param.append('<p class="label label-info">'+ t +'</p> ');
			    $param.append('<br>');
			    t = cy.$('edge:selected').attr("name_p");
			    $param.append('<p class="label label-default">Link Name:</p> ');
			    $param.append('<p class="label label-info">'+ t +'</p> ');
			    $param.append('<br>');
			    $info.append($param);
			    $info.reload();
		   }
	   }
  });
})(jQuery);
$(function() {
  FastClick.attach( document.body );
});
