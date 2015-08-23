(function(){
    "use strict";
    angular
        .module('admin')
        .directive('searchShow', searchShow)


    searchShow.$inject = ['Api'];

    function searchShow(Api){
        return {
            scope : true,
            restrict : "AE",
            controllerAs : 'search',
            controller : ['$scope', function ($scope) {
                var vm = this;
                vm.found = false;
                vm.go = go;
                vm.addShow = addShow;
                vm.api = Api;

                function go(){
                    var request = {
                        name : vm.show_name
                    };
                    vm.api.action('get', 'shows', 'search_in_myshow', request).then(function(d){
                        vm.found = true;
                        vm.found_items = d;
                    });
                }

                function addShow(show){
                    vm.api.action('post', 'shows', '', show).then(function(d){
                        vm.found = true;
                        show.exist = true;
                    });
                }
            }],
            link : function(scope, elem, attr){

            }
        }
    }
})();