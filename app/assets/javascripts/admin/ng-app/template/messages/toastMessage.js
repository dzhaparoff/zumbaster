(function(){
  "use strict";
  angular
      .module('admin')
      .service('$toastMessage', [
        '$mdToast',
        function($mdToast){
          return {
            show : function(message, icon){
              return $mdToast.show({
                controller: function(){
                  var toast = this;
                  toast.show_icon = false;
                  if(typeof icon !== 'undefined') {
                    toast.show_icon = true;
                    toast.icon = icon;
                  }
                  toast.text = message;
                },
                controllerAs: "toast",
                templateUrl: 'partials/toast.directive.html',
                parent : angular.element('[role="main"] > md-content')[0],
                hideDelay: 3000,
                position: 'top left'
              });
            }
          };
        }
      ])
})();