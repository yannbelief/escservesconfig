jQuery.fn.outerHTML = function() {    // returns html including the element itself, not just the innerhtml that JQuery's html() returns
    return $('<div>').append( this.eq(0).clone() ).html();
};

var currentlySelected;
var currentSearchText = "";
var envTemplate;
var appTemplate;


function preload_sidebar() {
	var url = window.location.href;
	if (url.match("text=")) {
		currentSearchText = url.substr(url.indexOf("text=") + 5);
		search_for(currentSearchText);
	}
	else { search_for(""); }
}

function search_again() {
	search_for(currentSearchText);
}

function search_for(searchText) {
    $('#search_input').val(searchText);
	var href = 'altui';
	if (searchText != "") { href += '?text='+ searchText }
	$('.search_header a').attr('href', href);
	search_for_json('/altui/search/' + searchText);	
}

function search_for_json(url) {
	clear_search();
	$.getJSON(url,
        function(data) {
            $.each(data["envs"], function(i, envName) {
				create_environment(envName);
            });
            $.each(data["apps"], function(i, appName) {
				add_application(appName);
            });
            if (data["envs"].length == 1) { select_environment(data["envs"][0]); }
        }
    );
}

function create_environment(envName) {
	var env = envTemplate.clone().attr("id", "env_" + envName).show();
	env.find("a").text(envName);
	$('#environments').append(env);
}

function add_application(appName) {
	var app = appTemplate.clone().attr("id", "app_" + appName).show();
	app.find("a").text(appName);
	$('#applications').append(app);
}

function clear_search() {
	clear_selected();
    currentlySelected = null;
	$('#environments').empty();
	$('#applications').empty();
}

function select_environment(newlySelected) {
    $("#env_" + currentlySelected).children().css('fontWeight', 'normal').css('color', '#11366F');
    currentlySelected = newlySelected;
    $("#env_" + newlySelected).children().css('fontWeight', 'bold').css('color', 'green');
	load_environment(newlySelected);
}


function getAndClearVal(what) {
	var val = $.trim(what.val());
	what.val("");
	return val;
}


//----------------------------------------------

$(document).ready(function() {
	
	envTemplate = $('#env____template');
	appTemplate = $('#app____template');

	preload_sidebar();    

	$('#search_form').live("submit", function() {
	    currentSearchText = $.trim($('#search_input').val());
		search_for(currentSearchText);
	});

	$('#environments > dt > a').live("click", function() {
		select_environment($(this).text());
	});

	$('.add_div a').live("click", function() {
		$(this).parent().toggleClass("add_div_active");
		$(this).siblings('form').toggle();
	});

	$('#create_environment form').submit(function() {
		var envName = getAndClearVal($("#create_environment :text"));
		if (notDefined(envName)) { alert("Unable to add blank environment"); return; }

	    $.ajax({
	        type: "PUT",
	        url: "/environments/" + envName,
	        data: "",
	        success: function(XMLHttpRequest, textStatus) {
				search_for(envName);
	        },
		    error: function(XMLHttpRequest, textStatus, errorThrown) {
		        alert("Error adding environment '" + envName +"'\n" + XMLHttpRequest.responseText);
		    },
	    });
	});
});