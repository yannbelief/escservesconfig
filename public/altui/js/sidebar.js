jQuery.fn.outerHTML = function() {    // returns html including the element itself, not just the innerhtml that JQuery's html() returns
    return $('<div>').append( this.eq(0).clone() ).html();
};

var currentlySelected;
var envTemplate;
var searchText;

function clear_search() {
	clear_selected();
    currentlySelected = null;
	$('#environments').empty();
}

function find_environments() {
    searchText = $('#search_input').val();
	find_environments_json('/altui/search?text=' + searchText);
}

function find_all_environments() {
	find_environments_json('/environments');
}  

function find_environments_json(url) {
	clear_search();
	$.getJSON(url,
        function(data) {
            $.each(data, function(i, envName) {
				add_environment(envName);
            });
            if (data.length == 1) { select_environment(data[0]); }
        }
    );
}

function add_environment(envName) {
	var env = envTemplate.clone().attr("id", "env_" + envName).show();
	env.find("a").text(envName);
	$('#environments').append(env);
}

function select_environment(newlySelected) {
    $("#env_" + currentlySelected).children().css('fontWeight', 'normal').css('color', '#11366F');
    currentlySelected = newlySelected;
    $("#env_" + newlySelected).children().css('fontWeight', 'bold').css('color', 'green');
	load_environment(newlySelected);
}



//----------------------------------------------

$(document).ready(function() {
	
	envTemplate = $('#env____template');	
    find_all_environments();

	$('#environments > dt > a').live("click", function() {
		select_environment($(this).text());
	});

	$('.add_environment_submit').live("click", function() {
		var textField = $(this).siblings(".add_environment_text");
		var envName = textField.val();
		textField.val("");
		if (notDefined(envName)) { alert("Unable to add blank environment"); return; }

	    $.ajax({
	        type: "PUT",
	        url: "/environments/" + envName,
	        data: "",
	        success: function(XMLHttpRequest, textStatus) {
				add_environment(envName);
	        },
		    error: function(XMLHttpRequest, textStatus, errorThrown) {
		        alert("Error adding environment '" + envName +"'\n" + XMLHttpRequest.responseText);
		    },
	    });
	});
	
});