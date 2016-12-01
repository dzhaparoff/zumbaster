(function(){
  "use strict";
  angular
      .module('zumbaster')
      .directive('rotatorAdEpisode', ['$timeout', rotator])
      .directive('rotatorAd', ['$timeout', rotator2]);

      function rotator($timeout) {
        return {
          restrict: 'AC',
          link: function(scope, element, attrs) {
            var rotator_script = $(element).children('noindex').html();
            var rotator_id = $(element).children('noindex').attr('id');
            $(element).children('noindex').remove();


            $(element)[0].show = function() {
              $(element).append("<script id=\""+rotator_id+"\">"+rotator_script+"</script>");
              $(element).addClass('show');
              return $(element)[0];
            }

            $(element)[0].play = function() {
              $timeout(function(){
                $(element).find('iframe')[0].src += "&autoplay=1";
              }, 1000);
              return $(element)[0];
            }
          }
        }
      }

      function rotator2($timeout) {
        return {
          restrict: 'AC',
          link: function(scope, element, attrs) {
            var rotator_script = $(element).children('noindex').html();
            var rotator_id = $(element).children('noindex').attr('id');
            $(element).children('noindex').remove();


            $(element)[0].show = function() {
              $(element).append("<script id=\""+rotator_id+"\">"+rotator_script+"</script>");
              $(element).addClass('show');
              return $(element)[0];
            }

            $(element)[0].show();

            //
            // $(element)[0].play = function() {
            //   $timeout(function(){
            //     $(element).find('iframe')[0].src += "&autoplay=1";
            //   }, 1000);
            //   return $(element)[0];
            // }
          }
        }
      }

})();
