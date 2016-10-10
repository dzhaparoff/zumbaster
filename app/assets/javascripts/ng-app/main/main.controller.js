(function() {
    "use strict";
    angular
        .module('zumbaster')
        .controller('MainCtrl', ['$scope', MainCtrl]);

    function MainCtrl($scope){
        var vm = this;
        vm.name = 'HdSerials';
    }

})();