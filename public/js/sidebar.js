
var EscSidebar = function() {
    var toggleMinus = '/images/minus.jpg';
    var togglePlus = '/images/plus.jpg';

    return {
        toggleMinus : toggleMinus,
        togglePlus : togglePlus,

        clearDefault : function(what) {
            if (what.value == what.defaultValue) {
                what.value = "";
            }
        },

        setDefault : function(what) {
            if (what.value == "") {
                what.value = what.defaultValue;
                what.type = "text";
            }
        },

        loadApplicationsForEnvironment : function(envId, envName) {
            var url = "/environments/" + envName;
            $.getJSON(url, function(appData) {
                var appList = '<ul class="application_list" style="display: none;"';
                $.each(appData, function(appId, thisApp) {
                    appList += ("<li id='" + thisApp + "' class='application'>");
                    appList += ("<img class='appdelete' src='/images/delete.png' alt='Delete " + thisApp +" application'/>");
                    appList += ("<img class='appedit' src='/images/edit.png' alt='Edit " + thisApp +" application'/>");
                    appList += ("<span class='appName'>" + thisApp + "</span></li>");
                });
                appList += ('<li><form id="' + envName + '_new_app_form" class="new_app_form" action="javascript:void(0);">');
                appList += ('<img src="/images/add.png" alt="Add a new application" />&nbsp;');
                appList += ('<input type="text" onFocus="EscSidebar.clearDefault(this)" onBlur="EscSidebar.setDefault(this)" id="new_app_name" value="Add Application"/>');
                appList += ('</form></li>');
                appList += ('<li><form id="' + envName + '_copy_form" class="copy_form" action="javascript:void(0);">');
                appList += ('<img src="/images/copy.png" alt="Copy this environment" />&nbsp;');
                appList += ('<input type="text" onFocus="EscSidebar.clearDefault(this)" onBlur="EscSidebar.setDefault(this)" id="copy_env_name" value="Copy Environment"/></form></li>');
                appList += "</ul>";
                var envObj = $('#sidebar .environment:eq(' + envId + ')');
                envObj.append(appList);
                envObj.children('ul').slideDown('fast');
                $('#sidebar' + " .new_app_form").submit(EscSidebar.createNewApp);
				$('#sidebar' + " .copy_form").submit(EscSidebar.copyEnvironment);
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
					envList += ('<li id="' + envName + '" class="environment">');
					envList += ("<img class='envdelete' src='/images/delete.png' alt='Delete " + envName +" environment'/>");
					envList += ("<img class='envedit' src='/images/edit.png' alt='Edit " + envName +" environment'/>");
					envList += ('<img src="' + toggleState + '" class="expander_img" class="clickable"/>');
                    envList += ('<span class="envName">' + envName + '</span>');
                    envList += ('</li>');
                });
                envList += ('<li><form id="new_env_form" action="javascript:void(0);">');
                envList += ('<img src="/images/add.png" alt="Add a new environment"/>&nbsp;');
                envList += ('<input type="text" onFocus="EscSidebar.clearDefault(this)" onBlur="EscSidebar.setDefault(this)" id="new_env_name" name="new_env_name" value="Add Environment"/>');
                envList += ('</form></li>');
                envList += "</ul>";
                $('#sidebar').html(envList);
                $('#sidebar' + " #new_env_form").submit(EscSidebar.createNewEnv);
            });
        },

        createNewEnv : function() {
            var newName = $('#new_env_name').val();
            $('#new_env_name').val("");
            $.ajax({
                type: "PUT",
                url: "/environments/" + newName,
                data: {},
                success: function(data, textStatus) {
                    EscSidebar.loadEnvironments();
                },
                error: function(XMLHttpRequest, textStatus, errorThrown) {
                    alert("Error creating new environment '" + newName +"': " + XMLHttpRequest.responseText);
                },
            });
        },

        createNewApp : function() {
            var envName = $(this).attr("id").replace('_new_app_form', '');
            var newName = $(this).find(":input").val();
            $(this).find(":input").val("");
            $.ajax({
                type: "PUT",
                url: "/environments/" + envName + "/" + newName,
                data: {},
                success: function(data, textStatus) {
                    EscSidebar.loadEnvironments();
                },
                error: function(XMLHttpRequest, textStatus, errorThrown) {
                    alert("Error creating new application '" + newName +"': " + XMLHttpRequest.responseText);
                },
            });
        },

        copyEnvironment : function() {
            var envName = $(this).attr("id").replace('_copy_form', '');
            var newEnvName = $(this).find(":input").val();
            $(this).find(":input").val("");
            $.ajax({
				beforeSend: function(request) {request.setRequestHeader("Content-Location", envName)},
                type: "POST",
                url: "/environments/" + newEnvName,
                data: {},
                success: function(data, textStatus) {
                    EscSidebar.loadEnvironments();
                },
                error: function(XMLHttpRequest, textStatus, errorThrown) {
                    alert("Error copying " + envName + " to " + newEnvName + ": " + XMLHttpRequest.responseText);
                },
            });
        },

        expandAll : function() {
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
        },

        contractAll : function() {
            $('#sidebar > ul > li > ul').slideUp('fast');
            $('img', $('#sidebar > ul > li')).attr('src', EscSidebar.togglePlus);
            // Loop through all envs, set collapsed = true
            $.each($('#sidebar > ul > li > span'), function(id, span) {
                var myEnv = $(span).text();
                $('#sidebar').data(myEnv + '_expanded', false);
                $(this).siblings('ul').remove();
            });
            EscSidebar.loadEnvironments();
        },

        userManagement : function() {
            EscSidebar.hideEditor();
            EscEditor.editUsers();
            $('#editor').show();
            $('#new_user').show();
        },

        hideEditor : function() {
            $('#new_user').hide();
            $('#new_key').hide();
            $('#editor').hide();
        },

        showEditor : function(env, app) {
            EscSidebar.hideEditor();
            if ((app != null) && (app != "") && (env != null) && (env != "")) {
                EscEditor.editPropertiesFor(env, app);
                $('#new_key').show();
                $('#editor').show();
            };
        },

        showEnvEditor : function(env) {
            EscSidebar.hideEditor();
            if ((env != null) && (env != "")) {
                EscEditor.editEnvironment(env);
				$('#new_key').hide();
                $('#editor').show();
            };
        },

        toggleEnv : function(env, img) {
            if ($(img).attr('src') == EscSidebar.toggleMinus) {
                $('#sidebar').data(env + '_expanded', false);
                $(img).attr('src', EscSidebar.togglePlus).siblings('ul').slideUp('fast');
                $(img).siblings('ul').remove();
            } else {
                $('#sidebar').data(env + '_expanded', true);
                $(img).attr('src', EscSidebar.toggleMinus).siblings('ul').slideDown('fast');
                $.each($('.environment > span'), function(id, span) {
                    var name = $(span).text();
                    if (name == env) {
                        EscSidebar.loadApplicationsForEnvironment(id, name);
                    };
                });
            };
        },

// End of namespace
    };
}();

$(document).ready(function() {
    $('#refresh_env').click(function() {
        EscSidebar.loadEnvironments();
    })

    // Expand All 
    $('.expand').live("click", function() { EscSidebar.expandAll() });

    // Contract All 
    $('.contract').live("click", function() { EscSidebar.contractAll() });

    // User Management
    $('.usermgmt').live("click", function() { EscSidebar.userManagement() });

    // Expand or Contract one particular env
    $('.expander_img').live("click", function() {
        var thisEnv = $(this).siblings("span").text();
        EscSidebar.toggleEnv(thisEnv, this);
    });

    $('.envName').live("click", function() {
        EscSidebar.toggleEnv($(this).text(), $(this).siblings('.expander_img'));
    });

    $('.appName').live("click", function() {
        var thisEnv = $(this).parent().parent().siblings("span").text();
        var thisApp = $(this).text();
        EscSidebar.showEditor(thisEnv, thisApp);
    });

    // Click on an app edit button to get stuff in the content pane
    $('.appedit').live("click", function() {
        var thisEnv = $(this).parent().parent().siblings("span").text();
        var thisApp = $(this).parent().text();
        EscSidebar.showEditor(thisEnv, thisApp);
    });

    // Click on an env edit button to get stuff in the content pane
    $('.envedit').live("click", function() {
        var thisEnv = $(this).siblings("span").text();
        EscSidebar.showEnvEditor(thisEnv);
    });

    // Grab ownership of an environment

    // Click on an app delete button
    $('.appdelete').live("click", function() {
        var thisEnv = $(this).parent().parent().siblings("span").text();
        var thisApp = $(this).parent().text();
		var confirmation = confirm("Are you sure you want to delete application '" + thisApp + "' from environment '" + thisEnv + "'?");

        if ((confirmation) && (thisApp != null) && (thisApp != "")) {
			// Delete the app
			$.ajax({
                type: "DELETE",
                url: "/environments/" + thisEnv + "/" + thisApp,
                data: {},
                success: function(data, textStatus) {
                    EscSidebar.hideEditor();
                    EscSidebar.loadEnvironments();
                },
                error: function(XMLHttpRequest, textStatus, errorThrown) {
                    alert("Error deleting '" + thisApp +"': " + XMLHttpRequest.responseText);
                },
            })
        };
    });

    // Click on an env delete button
    $('.envdelete').live("click", function() {
        var thisEnv = $(this).siblings("span").text();
		var confirmation = confirm("Are you sure you want to delete environment '" + thisEnv + "'?");
        if ( (confirmation) && (thisEnv != null) && (thisEnv!= "")) {
			// Delete the env
			$.ajax({
                type: "DELETE",
                url: "/environments/" + thisEnv,
                data: {},
                success: function(data, textStatus) {
                    EscSidebar.hideEditor();
                    EscSidebar.loadEnvironments();
                },
                error: function(XMLHttpRequest, textStatus, errorThrown) {
                    alert("Error deleting '" + thisEnv +"': " + XMLHttpRequest.responseText);
                },
            })
        };
    });

    EscSidebar.hideEditor();
    EscSidebar.loadEnvironments();
});

