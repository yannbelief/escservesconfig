jQuery.fn.outerHTML = function() {    // returns html including the element itself, not just the innerhtml that JQuery's html() returns
    return $('<div>').append( this.eq(0).clone() ).html();
};

var currentlySelected;

function select_search_result(newlySelected) {
    $("#env_" + currentlySelected).children().css('fontWeight', 'normal').css('color', '#11366F');
    currentlySelected = newlySelected;
    $("#env_" + newlySelected).children().css('fontWeight', 'bold').css('color', 'green');
	load_environment(newlySelected);
}

function clear_search() {
    $(currentlySelected).css('fontWeight', 'normal').css('color', '#11366F');
    currentlySelected = null;
	$('#selected_name').empty();
    $('#items').html($('#item____template'));

	var environments = $('#environments');
    var envTemplate = $('#env____template');
	environments.empty();
	environments.append(envTemplate);
}

function find_environments() {
    var text = $('#search_input').val();
	find_environments_json('/altui/search?text=' + text);
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
            if (data.length == 1) { select_search_result(data[0]); }
        }
    );
}

function add_environment(envName) {
	var env = $("#env____template").clone().attr("id", "env_" + envName).show();
	env.find("a").text(envName);
	$('#environments').append(env);	
}


function load_environment(envName) { 
    $.getJSON('/environments/' + envName,
        function(data, textStatus) {
			if (textStatus != 'success') { alert('load_enviroment failed for env ' + envName + ' with response ' + textStatus) }
            var items = $.map(data['apps'], function(appName, i) {
				return load_app(envName, appName);
            });
            set_environment(envName, items);
        }
    );
}

function set_environment(envName, items) {
	$('#selected_name').html(envName);
	var itemTemplate = $('#item____template');
    var itemsHTML = $('#items');
	itemsHTML.empty();
	items.push(itemTemplate);
	$.each(items, function(i, item) {
		itemsHTML.append(item);
	});
}

function load_app(envName, appName) {
 	var item = create_app(appName);
	create_properties(envName, appName, item)
    return item; 
}

function create_app(appName) {
	var app = $("#item____template").clone().attr("id", "item_" + appName).show();
	app.find(".name").text(appName);
	app.find(".property_area").attr("id", "property_area_" + appName);
	return app;
}            

function refresh_properties(envName, appName, item) {
	var propertiesTable = item.find(".properties table");
	var propertyTemplate = item.find("#property_tr____template");
	propertiesTable.empty();
	propertiesTable.append(propertyTemplate);
	create_properties(envName, appName, item);
}

function create_properties(envName, appName, item) {
    $.ajax({
        type: "GET",
        url: '/environments/' + envName + '/' + appName,
        success: function(data, textStatus) {
		    $.each(data.split('\n'), function(i, prop) {
		        var key = prop.slice(0, prop.indexOf("="));
		        var value = prop.slice(prop.indexOf("=") + 1);
		    	create_property(item, key, value);
			}); 
        },
        error: function(XMLHttpRequest, textStatus, errorThrown) { alert('create_properties failed for: ' + envName + '-->' + appName + "\n" + XMLHttpRequest.responseText) }
    });
}

function create_property(item, key, value) {
	var property = $("#property_tr____template").clone().attr("id", "property_tr_" + key).show();
	property.find("key").text(key);
	property.find(".value").text(value);
	item.find(".properties table").append(property);
}



//----------------------------------------------

function env_name() {
	return $('#selected_name').text();
}

function app_name(child) {
	return $(child).parents().filter('.content_wrapper').find('.name').text();
}

function jItem(child) {
	return $(child).parents('.item');
}

function property_area(child) {
	return $(child).parent().siblings('.property_area');
}

function notDefined(value) {
	return (value == null) || (value.length == 0);
}


$(document).ready(function() {
    find_all_environments();

	$('#environments > dt > a').live("click", function() {
		select_search_result($(this).text());
	});
		
	
	$('.delete_selected').live("click", function() {
		var envName = env_name();
		if (!confirm('Are you sure you want to delete ' + envName + '?')) { return; }
		$.ajax({
	        type: "DELETE",
	        url: "/environments/" + envName,
	        data: {},
	        success: function(data, textStatus) {
			    find_all_environments();
	        },
	        error: function(XMLHttpRequest, textStatus, errorThrown) {
	            alert("Error deleting '" + envName + "'\n" + XMLHttpRequest.responseText);
	        },
	    })
	});
	
	
	$('.open_item').live("click", function() {
		var envName = env_name();
		var appName = app_name(this);
	    $(this).hide();
	    $(this).siblings('.close_item').show();
		property_area(this).show('normal');

	    $.uiTableEdit($('#table-' + appName), {
	        find: '.value', 
	        editDone: function(newText, oldText, event, td) {
	            if (newText == oldText) return;
	            var key = td.siblings('td').text();
	            $.ajax({
	                type: 'PUT',
	                url: '/environments/' + envName + '/' + appName + '/' + key,
	                data: newText,
	                error: function(XMLHttpRequest, textStatus, errorThrown) { 
	                    alert('Failed to update property (' + key + ', ' + value + ')\n' + XMLHttpRequest.responseText); }
	            });
	        },
			dataVerify: function(newText, oldText, event, td) {
				return $.trim(newText);     // trim both for ajax and on page
			}
	    });
	});


	$('.close_item').live("click", function() {
	    $(this).hide();
	    $(this).siblings('.open_item').show();
		property_area(this).hide('normal');
	});

	
	$('.delete_item').live("click", function() {
		var envName = env_name();
		var appName = app_name(this);
		var item = jItem(this);
		if (!confirm('Are you sure you want to delete ' + appName + '?')) { return; }
		$.ajax({
	        type: "DELETE",
	        url: "/environments/" + envName + "/" + appName,
	        data: {},
	        success: function(data, textStatus) {
			    item.fadeOut(1000);
	        },
	        error: function(XMLHttpRequest, textStatus, errorThrown) {
	            alert("Error deleting '" + envName + "', '" + appName + "'\n" + XMLHttpRequest.responseText);
	        },
	    })
	});


	$('.add_key').live("click", function() {
		$(this).siblings("form").toggle();
	});


	$('.add_property_submit').live("click", function() {
		var envName = env_name();
		var appName = app_name(this);
		var keyField = $(this).siblings(".add_property_text");
		var key = keyField.val();
		keyField.val("");
		var value = "";
		var item = jItem(this);
		if (notDefined(envName) || notDefined(appName) || notDefined(key)) { alert("Unable to add key '" + key + "' to '" + envName + "':'" + appName + "'"); return; }

	    $.ajax({
	        type: "PUT",
	        url: "/environments/" + envName + "/" + appName + "/" + key,
	        data: value,
	        success: function(XMLHttpRequest, textStatus) {
				refresh_properties(envName, appName, item);
	        },
		    error: function(XMLHttpRequest, textStatus, errorThrown) {
		        alert("Error adding '" + key +"'\n" + XMLHttpRequest.responseText);
		    },
	    });
	});
	
	
	$('.delete_property').live("click", function() {
		var envName = env_name();
		var appName = app_name(this);
		var key = $(this).siblings(".keydots").text();
		var item = jItem(this);

		$.ajax({
		    type: "DELETE",
		    url: "/environments/" + envName + "/" + appName + "/" + key,
		    data: {},
		    success: function(data, textStatus) {
				$(item).find('#property_tr_' + key).remove();
		    },
		    error: function(XMLHttpRequest, textStatus, errorThrown) {
		        alert("Error deleting '" + key +"': " + XMLHttpRequest.responseText);
		    },
		})
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