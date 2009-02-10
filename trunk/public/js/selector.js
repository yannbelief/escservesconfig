

getTargetLabel = function(target) {
    return "label[for='" + target.replace(/#/, '') + "']";
}

loadSelectorDataFromUrl = function(target, url) {
    $(target).empty();

    $.getJSON(url, function(data){
        var options = '';
        $.each(data, function(i, item){
            options += '<option value="' + item + '">' + item + '</option>';
            $(target).html(options);
            $(target + ' option:first').attr('selected', 'selected');
            $(getTargetLabel(target)).show();
            $(target).show();
        });
        $(target).change();
    });
}

hideSelector = function(target) {
    $(target).empty();
    $(getTargetLabel(target)).hide();
    $(target).hide();
}

validateName = function(name) {
    if ((name == "default") || (name == "")) {
        return false;
    } else {
        return true;
    }
}

$(document).ready(function() {
    $('#env_list').change(function() {
        var envName = $(this).val();
        if (envName != null) {
            loadSelectorDataFromUrl('#app_list', '/environments/' + envName);
        }
    }).change();

    loadSelectorDataFromUrl('#env_list', '/environments');

    $('#new_env_form').submit(function() {
        var newName = $('#new_env_name').val();
        if (validateName(newName)) {
            $('#new_env_name').val("");
            $.ajax({
                type: "POST",
                url: "/environments/" + newName,
                data: {},
                success: function(data, textStatus) {
                    loadSelectorDataFromUrl('#env_list', '/environments');
                },
                error: function(XMLHttpRequest, textStatus, errorThrown) {
                    alert("Error creating new environment '" + newName);
                },
                });
            
        } else {
            alert("Not going to create new environment called " + newName);
        }
    });

    $('#new_app_form').submit(function() {
        var newName = $('#new_app_name').val();
        var envName = $('#env_list').val();
        if (validateName(newName)) {
            $('#new_app_name').val("");
            $.ajax({
                type: "POST",
                url: "/environments/" + envName + "/" + newName,
                data: {},
                success: function(data, textStatus) {
                    loadSelectorDataFromUrl('#app_list', '/environments/' + $('#env_list').val());
                },
                error: function(XMLHttpRequest, textStatus, errorThrown) {
                    alert("Error creating new environment '" + newName);
                },
                });
            
        } else {
            alert("Not going to create new environment called " + newName);
        }
    });

});


