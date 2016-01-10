(function(){
  "use strict";
  angular
      .module('admin')
      .directive('dialogMessage', [
        '$mdDialog',
        function($mdDialog){
          return {
            restrict : 'AE',
            link : postLink
          };
          function postLink(scope, element, attrs){
            var mode = attrs.type;
            var content = element.html();
            element.remove();
            $mdDialog.show(
                $mdDialog.alert()
                    .parent(angular.element(document.querySelector("[role='main']")))
                    .clickOutsideToClose(true)
                    .title(mode)
                    .content(content)
                    .ariaLabel(mode)
                    .ok('Ok!')
                    .targetEvent()
                )
          }
        }
      ])


})();