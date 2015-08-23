//= require jquery
//= require lodash
//= require angular
//= require foundation
//= require_self
//= require ng-app

$(function(){
    $(document).foundation();
    var sticky_sidebar = $('.sticky-sidebar');
    if(sticky_sidebar.length > 0) {
        var offset = sticky_sidebar.offset().top;
        $(document).on("scroll",function(e){
            var scroll_top = window.scrollY;
            var width = sticky_sidebar.width();
            if(scroll_top > offset - 60)
                $('.sticky-sidebar').css({position: 'fixed', top: 60, width: width});
            else
                $('.sticky-sidebar').css({position: 'relative', top: 0});
            })
    }
});
