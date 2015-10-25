(function(){
    "use strict";
    angular
        .module('admin')
        .controller('MainCtrl', ["$scope", "$sce", "Dialog", MainCtrl]);

    var $_sce;

    function MainCtrl($scope, $sce, Dialog){
        var vm = this;
        vm.scope_name = 'main';
        $_sce = $sce;
        vm.helpers = Helpers;
        vm.modals = {
          //error : new Dialog({template : "errorMdl", className : "errorModal"}, $scope)
        };
    }
    
    var Helpers = {
        class : function (expression, class_active, class_passive) {
            if(expression)
                return class_active;
            else
                if(typeof class_passive == 'undefined')
                    return '';
                else
                    return class_passive;
        },
        parseHtml : function(html){
            return $_sce.trustAsHtml(html);
        }
    }
})();