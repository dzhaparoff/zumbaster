(function(){
    "use strict";
    angular
        .module('admin')
        .controller('MainCtrl', MainCtrl);

    MainCtrl.$inject = ['$scope', '$sce'];

    var $_sce;

    function MainCtrl($scope, $sce){
        var vm = this;
        vm.scope_name = 'main';
        $_sce = $sce;
        vm.helpers = Helpers;
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