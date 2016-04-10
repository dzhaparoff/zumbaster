//= require turbolinks
//= require jquery
//= require lodash
//= require swfobject
//= require foundation
//= require disqus_rails
//= require_self
//= require ng-app

//Turbolinks.enableTransitionCache();
//Turbolinks.enableProgressBar();

var mobile = false;

$(document).on('ready page:load', function(){
    $(document).foundation();

    if( /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ) {
        mobile = true;
        $('body').addClass('mobile')
    }
    else mobile = false;
});

$(document).on('page:change', function() {
    if (window._gaq != null) {
        return _gaq.push(['_trackPageview']);
    } else if (window.pageTracker != null) {
        return pageTracker._trackPageview();
    }
});