(function(){ 'use strict';

  angular
      .module('admin')
      .factory('Dialog', Dialog);

  Dialog.$inject = ["ngDialog"];

  function Dialog(ngDialog){

    //var dialogs = [];

    function DialogService(params, $scope){
      this.id = undefined;
      this.params = {
        template : 'modalMdl',
        scope : $scope
      };
      this.init(params);
    }

    DialogService.prototype = {
      constructor : DialogService,
      init : function(params){
        angular.extend(this.params, params);
      },
      open : function($event){
        if(angular.isDefined($event))
          $event.preventDefault();
        ngDialog.closeAll();
        this.id = ngDialog.open(this.params);
      }
    };

    return DialogService;
  }


})();