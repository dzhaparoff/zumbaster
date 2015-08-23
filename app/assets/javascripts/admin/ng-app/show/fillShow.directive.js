(function(){
    "use strict";
    angular
        .module('admin')
        .directive('fillShow', fillShow);

    fillShow.$inject = ['Api', 'Loading'];

    function fillShow(Api, Loading){
        return {
            scope : true,
            restrict : "AE",
            controllerAs : 'show',
            controller : ['$scope', '$attrs', function ($scope, $attrs) {
                var vm = this;
                vm.api = Api;
                vm.id = $attrs.fillShow;
                vm.model = {};

                vm.actions = {
                    post : post_member_api_action
                };

                function post_member_api_action(action){
                    var request = {
                        id : vm.id
                    };
                    vm.api.action('post', 'shows', action, request)
                        .then(
                            function(d){
                                vm.model = d;
                            });
                }
            }],
            link : function(scope, elem, attr){

            }
        }
    }
})();