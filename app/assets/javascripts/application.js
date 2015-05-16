// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery.turbolinks
//= require jquery-ui
//= require jquery_ujs
//= require bootstrap
//= require turbolinks

//= require jquery.raty
//= require ratyrate.js.erb
//= require metisMenu

var ready;
ready = (function() {
    $("#term").autocomplete({
        source: '/products/autocomplete.json?locale=' + $('#locale').val(),
        delay: 500,
        minLength: 2,
        select: function(event, ui) {
            // prevent autocomplete from updating the textbox
            event.preventDefault();
            // navigate to the selected item's url
            location.href = ui.item.url;
        },
        response: function (event, ui) {

            if (ui.content.length >= 7) {
                ui.content.push({
                    label: "Показать все результаты",
                    url: event.target.baseURI
                });
            }
        }
    }).data("ui-autocomplete")._renderItem = function(ul, item) {
        var $a = $("<a></a>").attr('href', item.url);
        if (item.icon) {
            var $img = $('<img>').attr('src', item.icon);
            $img.appendTo($a);
        }
        $a.append(item.label);
        $("<span class='price'></span>").html(item.price).appendTo($a);
        $a.append("<div class='clearfix'></div>");
        return $("<li></li>").append($a).appendTo(ul);
    };
});

$(document).ready(ready);
$(document).on('page:load', ready);
