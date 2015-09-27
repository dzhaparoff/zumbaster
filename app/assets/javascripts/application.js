//= require turbolinks
//= require jquery
//= require lodash
//= require swfobject
//= require foundation
//= require_self
//= require ng-app

Turbolinks.enableTransitionCache();
Turbolinks.enableProgressBar();

var mobile = false;

$(document).on('ready page:load', function(){
    $(document).foundation();

    if( /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ) {
        mobile = true;
        $('body').addClass('mobile')
    }
    else mobile = false;
});