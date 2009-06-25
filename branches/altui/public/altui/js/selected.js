var itemTemplate;
var propertyTemplate;


function load_environment(envName) { 
    $.getJSON('/environments/' + envName,
        function(data, textStatus) {
			if (textStatus != 'success') { alert('load_enviroment failed for env ' + envName + ' with response ' + textStatus) }
            var items = $.map(data['apps'], function(appName, i) {
				return load_app(envName, appName);
            });
            set_as_selected(envName, data['owner'], data['public_key'], items);
        }
    );
}

function set_as_selected(envName, owner, public_key, items) {
	$('#selected_name').html(envName);
	var propertiesTable = $('#selected_properties table');
	propertiesTable.empty();
	propertiesTable.append(create_selected_property('Owner', owner));
	propertiesTable.append(create_selected_property('Public Key', public_key));
	$('#clone_environment').attr("title", "clone " + envName);
	$('#delete_environment').attr("title", "delete " + envName);
	$('#selected_details').show();
    var itemsHTML = $('#items');
	itemsHTML.empty();
	$.each(items, function(i, item) {
		itemsHTML.append(item);
	});
}

function clear_selected() {
	$('#selected_name').empty();
 	$('#selected_details').hide();
	$('#items').empty();
}

function load_app(envName, appName) {
 	var item = create_app(appName);
	create_properties(envName, appName, item)
    return item; 
}

function create_app(appName) {
	var app = itemTemplate.clone().attr("id", "item_" + appName).show();
	app.find(".name").text(appName);
	app.find(".property_area").attr("id", "property_area_" + appName);
	app.find("table").attr("id", "table_" + appName);
	app.find(".delete_item").attr("title", "delete " + appName);
	return app;
}            

function refresh_properties(envName, appName, item) {
	var propertiesTable = item.find(".properties table");
	propertiesTable.empty();
	create_properties(envName, appName, item);
}

function create_properties(envName, appName, item) {
    $.ajax({
        type: "GET",
        url: '/environments/' + envName + '/' + appName,
        success: function(data, textStatus) {
			if (data.length == 0) return;
			var table = item.find(".properties table");
		    $.each(data.split('\n'), function(i, prop) {
		        var key = prop.slice(0, prop.indexOf("="));
		        var value = prop.slice(prop.indexOf("=") + 1);
		    	var property = create_property(key, value);
				table.append(property);
			}); 
        },
        error: function(XMLHttpRequest, textStatus, errorThrown) { alert('create_properties failed for: ' + envName + '-->' + appName + "\n" + XMLHttpRequest.responseText) }
    });
}

function create_property(key, value) {
	var property = propertyTemplate.clone().removeAttr("id").show();
	property.find("key").text(key);
	property.find(".value").text(value);
	return property;
}

function create_selected_property(key, value) {
	var property = selectedPropertyTemplate.clone().removeAttr("id").show();
	property.find("key").text(key);
	property.find(".value").text(value);
	return property;
}


function clearDefault(what) {
    if (what.value == what.defaultValue) {
        what.value = "";
    }
}

function setDefault(what) {
    if (what.value == "") {
        what.value = what.defaultValue;
        what.type = "text";
    }
}


//----------------------------------------------

function selected_name() {
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
	
	itemTemplate = $("#item____template");
	selectedPropertyTemplate = $("#selected_property_tr____template");
	propertyTemplate = $("#property_tr____template");
		

	$('#clone_environment a').live("click", function() {
			$(this).parent().siblings().toggle();
	});

	$('#clone_environment form').submit(function() {
		var envName = selected_name();
		var newEnvName = getAndClearVal($("#clone_environment :text"));
		if (!confirm('Are you sure you want to create environment ' + newEnvName + ' as a clone of ' + envName + '?')) { return; }
		$(this).siblings("a").click();    /* close the form */
		$.ajax({
			beforeSend: function(request) {request.setRequestHeader("Content-Location", envName)},
            type: "POST",
            url: "/environments/" + newEnvName,
            data: {},
            success: function(data, textStatus) {
			    search_for(newEnvName);
            },
            error: function(XMLHttpRequest, textStatus, errorThrown) {
                alert("Error cloning " + envName + " to " + newEnvName + ": " + XMLHttpRequest.responseText);
            },
	    })
	});
	

	$('#add_application a').live("click", function() {
			$(this).parent().siblings().toggle();
	});

	$('#add_application form').submit(function() {
		var envName = selected_name();
		var newAppName = getAndClearVal($("#add_application :text"));
		$(this).siblings("a").click();    /* close the form */
		$.ajax({
            type: "PUT",
            url: "/environments/" + envName + "/" + newAppName,
            data: {},
            success: function(data, textStatus) {
                load_environment(envName);
            },
            error: function(XMLHttpRequest, textStatus, errorThrown) {
                alert("Error creating new application '" + newAppName +"': " + XMLHttpRequest.responseText);
            },
	    })
	});
    

	$('#take_ownership').live("click", function() {
		var envName = selected_name();
		if (!confirm('Are you sure you want to take ownership of ' + envName + '?')) { return; }
		$.ajax({
            type: "POST",
            url: "/owner/" + envName,
			success: function(data, textStatus) {
                load_environment(envName);
			},
	        error: function(XMLHttpRequest, textStatus, errorThrown) {
	            alert("Error taking ownership of '" + envName + "'\n" + XMLHttpRequest.responseText);
	        },
		})
	});

	
	$('#delete_environment').live("click", function() {
		var envName = selected_name();
		if (!confirm('Are you sure you want to delete ' + envName + '?')) { return; }
		$.ajax({
	        type: "DELETE",
	        url: "/environments/" + envName,
	        data: {},
	        success: function(data, textStatus) {
			    search_again();
	        },
	        error: function(XMLHttpRequest, textStatus, errorThrown) {
	            alert("Error deleting '" + envName + "'\n" + XMLHttpRequest.responseText);
	        },
	    })
	});


	
	
	$('.open_item').live("click", function() {
		var envName = selected_name();
		var appName = app_name(this);
	    $(this).hide();
	    $(this).siblings('.close_item').show();
		property_area(this).show('normal');

	    $.uiTableEdit($('#table_' + appName), {
	        find: '.value', 
	        editDone: function(newText, oldText, event, td) {
	            if (newText == oldText) return;
	            var key = $.trim(td.siblings('td').text());
				alert(key);
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
		var envName = selected_name();
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



	$('.add_property form').livequery('submit', function() {
		var envName = selected_name();
		var appName = app_name(this);
		var key = getAndClearVal($(this).children(".input-key"));
		var value = getAndClearVal($(this).children(".input-value"));
		if (notDefined(envName) || notDefined(appName) || notDefined(key)) { alert("Unable to add key '" + key + "' to '" + envName + "':'" + appName + "'"); return; }
		var item = jItem(this);
		$(this).siblings("a").click();    /* close the form */

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
		var envName = selected_name();
		var appName = app_name(this);
		var key = $(this).siblings(".keydots").text();
		var item = jItem(this);

		$.ajax({
		    type: "DELETE",
		    url: "/environments/" + envName + "/" + appName + "/" + key,
		    data: {},
		    success: function(data, textStatus) {
				refresh_properties(envName, appName, item)
		    },
		    error: function(XMLHttpRequest, textStatus, errorThrown) {
		        alert("Error deleting '" + key +"': " + XMLHttpRequest.responseText);
		    },
		})
	});
});