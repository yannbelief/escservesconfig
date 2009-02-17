
var EscSidebar = function() {
    var toggleMinus = '/images/minus.jpg';
    var togglePlus = '/images/plus.jpg';
    var newEnvLabel = '+env:';
    var newAppLabel = '+app:';

    return {
        toggleMinus : toggleMinus,
        togglePlus : togglePlus,
        newEnvLabel : newEnvLabel,
        newAppLabel : newAppLabel,

        loadApplicationsForEnvironment : function(envId, envName) {
            var url = "/environments/" + envName;
            $.getJSON(url, function(appData) {
                var appList = '<ul class="application_list" style="display: none;"';
                $.each(appData, function(appId, thisApp) {
                    appList += "<li class='application'>" + thisApp + "<img class='appedit' src='/images/edit.png' alt='Edit " + thisApp +" application'/><img class='appdelete' src='/images/delete.png' alt='Delete " + thisApp +" application'/></li>";
                });
                appList += '<li><form id="' + envName + '_new_app_form" class="new_app_form" action="javascript:void(0);"><input type="text" id="new_app_name"/>&nbsp;<img src="/images/add.png" alt="Add a new application" /></form></li>';
                appList += "</ul>";
                var envObj = $('#sidebar .environment:eq(' + envId + ')');
                envObj.append(appList);
                envObj.children('ul').slideDown('fast');
                $('#sidebar' + " .new_app_form").submit(EscSidebar.createNewApp);
            });
        },

        loadEnvironments : function() {
            $.getJSON("/environments", function(envData) {
                var envList = "<ul class='environment_list'>";
                $.each(envData, function(envId, envName) {
                    var toggleState;
                    if ($('#sidebar').data(envName + '_expanded')) {
                        toggleState = toggleMinus;
                        EscSidebar.loadApplicationsForEnvironment(envId, envName);
                    } else {
                        toggleState = togglePlus;
                    };
                    envList += ('<li class="environment"><img src="' + toggleState + '" class="expander_img" class="clickable"><span>' + envName + '</span>');
					envList += (" <img class='envdelete' src='/images/delete.png' alt='Delete " + envName +" environment'/>")
                    envList += ('</li>');
                });
                envList += '<li><form id="new_env_form" action="javascript:void(0);"><img src="/images/add.png" alt="Add a new environment"/> <input type="text" id="new_env_name" name="new_env_name"/></form></li>';
                envList += "</ul>";
                $('#sidebar').html(envList);
                $('#sidebar' + " #new_env_form").submit(EscSidebar.createNewEnv);
            });
        },

        validateEnvName : function(name) {
            // TODO: Put some propper rules in here
            if ((name == "default") || (name == "")) {
                return false;
            } else {
                return true;
            }
        },

        validateAppName : function(name) {
            // TODO: Put some propper rules in here
            return true;
        },

        createNewEnv : function() {
            var newName = $('#new_env_name').val();
            if (EscSidebar.validateEnvName(newName)) {
                $('#new_env_name').val("");
                $.ajax({
                    type: "POST",
                    url: "/environments/" + newName,
                    data: {},
                    success: function(data, textStatus) {
                        EscSidebar.loadEnvironments();
                    },
                    error: function(XMLHttpRequest, textStatus, errorThrown) {
                        alert("Error creating new environment '" + newName +"': " + XMLHttpRequest.responseText);
                    },
                });
            } else {
                alert("Invalid environment name '" + newName + "'. Valid characters are A-Z, a-z, 0-9, - and _");
            }
        },

        createNewApp : function() {
            var envName = $(this).attr("id").replace('_new_app_form', '');
            var newName = $(this).find(":input").val();
            if (EscSidebar.validateAppName(newName)) {
                $(this).find(":input").val("");
                $.ajax({
                    type: "POST",
                    url: "/environments/" + envName + "/" + newName,
                    data: {},
                    success: function(data, textStatus) {
                        EscSidebar.loadEnvironments();
                    },
                    error: function(XMLHttpRequest, textStatus, errorThrown) {
                        alert("Error creating new application '" + newName +"': " + XMLHttpRequest.responseText);
                    },
                });
            } else {
                alert("Invalid application name '" + newName + "'. Valid characters are A-Z, a-z, 0-9, - and _");
            }
        },

// End of namespace
    };
}();

$(document).ready(function() {
    $('#refresh_env').click(function() {
        EscSidebar.loadEnvironments();
    })

    //Expand All Code
    $('.expand').live("click", function() {
        $('img', $('#sidebar > ul > li')).attr('src', EscSidebar.toggleMinus);
        // Loop through all envs, set collapsed = true
        $.each($('#sidebar > ul > li > span'), function(id, span) { 
            var name = $(span).text();
            if (! $('#sidebar').data(name + '_expanded')) {
                $('#sidebar').data(name + '_expanded', true);
                EscSidebar.loadApplicationsForEnvironment(id, name);
            };
        });
		EscSidebar.loadEnvironments();
    });

    //Contract All Code
    $('.contract').live("click", function() {
        $('#sidebar > ul > li > ul').slideUp('fast');
        $('img', $('#sidebar > ul > li')).attr('src', EscSidebar.togglePlus);
        // Loop through all envs, set collapsed = true
        $.each($('#sidebar > ul > li > span'), function(id, span) { 
            var myEnv = $(span).text();
            $('#sidebar').data(myEnv + '_expanded', false);
            $(this).siblings('ul').empty();
        });
		EscSidebar.loadEnvironments();
    });

    // Click on an app edit button to get stuff in the content pane
    $('.appedit').live("click", function() {

        var thisEnv = $(this).parent().parent().siblings("span").text();
        var thisApp = $(this).parent().text();
    
        if ((thisApp != null) && (thisApp != "") && (thisApp != EscSidebar.newAppLabel)) {
            EscEditor.editPropertiesFor(thisEnv, thisApp);
            $('#new_key').show();
            $('#editor').show();
        } else {
            $('#new_key').hide();
            $('#editor').hide();
        };
    });

    // Click on an app delete button
    $('.appdelete').live("click", function() {

        var thisEnv = $(this).parent().parent().siblings("span").text();
        var thisApp = $(this).parent().text();
    
        if ((thisApp != null) && (thisApp != "") && (thisApp != EscSidebar.newAppLabel)) {
			// Delete the app
			alert(thisApp + " in " + thisEnv + " Deleting!")
        } else {
           // Throw something meaningful.
			alert(thisApp + " in " + thisEnv + " has NOT been deleted. Something went wrong.")
        };
    });

    // Click on an env delete button
    $('.envdelete').live("click", function() {
        var thisEnv = $(this).siblings("span").text();
        if ((thisEnv != null) && (thisEnv!= "") && (thisEnv != EscSidebar.newEnvLabel)) {
			// Delete the app
			alert(thisEnv + " Deleting!")
        } else {
           // Throw something meaningful.
			alert(thisEnv + " has NOT been deleted. Something went wrong.")
        };
    });

    //Expand or Contract one particular Nested ul
    $('.expander_img').live("click", function() {
        var toggleSrc = $(this).attr('src');
        var thisEnv = $(this).siblings("span").text();

        if ( toggleSrc == EscSidebar.toggleMinus ) {
            $('#sidebar').data(thisEnv + '_expanded', false);
            $(this).attr('src', EscSidebar.togglePlus).siblings('ul').slideUp('fast');
            $(this).siblings('ul').empty();
        } else{
            $('#sidebar').data(thisEnv + '_expanded', true);
            $(this).attr('src', EscSidebar.toggleMinus).siblings('ul').slideDown('fast');
            $.each($('.environment > span'), function(id, span) {
                var name = $(span).text();
                if (name == thisEnv) {
                    EscSidebar.loadApplicationsForEnvironment(id, name);
                };
            });
        };
    });

    EscSidebar.loadEnvironments();
    $('#new_key').hide();
    $('#editor').hide();
});

