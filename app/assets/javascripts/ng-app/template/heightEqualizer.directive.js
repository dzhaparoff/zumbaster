(function(){
  "use strict";
  angular
      .module('zumbaster')
      .directive('heightEqualize', [heightEqualize]);

  function heightEqualize(){
    return {
      restrict : "AE",
      link : function(scope, elem, attr){
        var height, width;
        var _class = attr.class;
        var a_ratio = parseFloat(attr.heightEqualize);

        elem.parents('ul').find('[class="'+_class+'"]').each(function () {
          var ratio = parseFloat($(this).data('heightEqualize'));
          if(a_ratio < ratio) a_ratio = ratio;
        });

        function equalizer(){
          width  = elem.width();
          height = width / a_ratio;
          elem.height(height);
        }

        equalizer();

        window.addEventListener("resize", equalizer)
      }
    }
  }
})();