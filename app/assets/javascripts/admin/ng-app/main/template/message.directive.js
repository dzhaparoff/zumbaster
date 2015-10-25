(function(){
  "use strict";
  angular
      .module('admin')
      .directive('message', message)

  message.$inject = ['Dialog'];

  function message(Dialog){
    return {
      restrict : "AE",
      scope : true,
      link : function($scope, elem, attr){
        var message_type = attr.message;
        $scope.message = elem.html();
        var dialog = new Dialog({template : "messageMdl", className : "messageMdl " + message_type}, $scope);
        dialog.open();
        elem.remove();
      }
    }
  }
})();