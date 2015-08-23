(function(){
    "use strict";
    angular
        .module('admin')
        .controller('ResourceEditorCtrl', ResourceEditorCtrl);

    ResourceEditorCtrl.$inject = ['$scope', 'Resource'];

    function ResourceEditorCtrl($scope, Resource){
        var vm = this;
        vm.scope_name = 'resource editor';
        vm.resource = Resource;

        vm.genre = vm.resource.show('genres', 1);
        vm.genres = vm.resource.index('genres');
    }
})();