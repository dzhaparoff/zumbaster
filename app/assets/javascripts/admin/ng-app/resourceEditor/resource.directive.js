(function(){
    "use strict";
    angular
        .module('admin')
        .directive('resource', resource)
        .directive('modelItem', modelItem)
        .directive('contenteditable', contenteditable);

    resource.$inject = ['Resource'];
    modelItem.$inject = [];
    contenteditable.$inject = [];

    function resource(Resource){

        function ResourceEditor(){
            var re = this;
            re.controllerAs = 'editor';
            re.controller = ['$scope', '$element', '$attrs', function ($scope, $element, $attrs) {
                var vm = this;
                re.name = $attrs.resource;
                vm.service = Resource;

                vm.edit_item = function(item){
                    Resource.show(re.name, item.id).then(function(d){
                        item.model = d;
                        item._cache_model = angular.extend({}, d);
                    });

                    item.editable = true;
                };

                vm.save_item = function (item) {
                    Resource.update(re.name, item.id, item.model);
                    item.editable = false;
                };

                vm.cancel_edit_item = function(item){
                    item.model = item._cache_model;
                    delete item._cache_model;
                    item.editable = false;
                }
            }];
        }

        ResourceEditor.prototype = {
            constructor : 'ResourceEditor',
            restrict    : 'AE',
            scope       : true
        };
       return new ResourceEditor;
    }

    function modelItem(){
        function ResourceItem(){
            var re = this;
            re.require = "^resource";
            re.controllerAs = 'item';
            re.controller = ['$scope', '$element', '$attrs', function ($scope, $element, $attrs) {
                var vm = this;
                vm.model = {};
                vm.id = $attrs.modelItem;
                vm.editable = false;
            }];
        }

        ResourceItem.prototype = {
            constructor : 'ResourceItem',
            restrict    : 'AE',
            scope       : true
        };
        return new ResourceItem;
    }

    function contenteditable() {
        return {
            restrict: 'A',
            require: '?ngModel',
            link: function(scope, element, attrs, ngModel) {
                var itemType; /*int, float, string*/

                if(angular.isDefined(attrs.itemType)) {
                    itemType = attrs.itemType;
                }
                else
                    itemType = 'string';

                if (!ngModel) return;

                // Specify how UI should be updated
                ngModel.$render = function() {
                    element.html(ngModel.$viewValue);
                };

                // Listen for change events to enable binding
                element.on('blur keyup change', function() {
                    scope.$evalAsync(read);
                });
                read(); // initialize

                // Write data to the model
                function read() {
                    var html = element.html();
                    // When we clear the content editable the browser leaves a <br> behind
                    // If strip-br attribute is provided then we strip this out
                    if ( attrs.stripBr && html == '<br>' ) {
                        html = '';
                    }

                    switch(true){
                        case itemType == 'int':
                            html = parseInt(html);
                            break;
                        case itemType == 'float':
                            html = parseFloat(html);
                            break;
                    }

                    ngModel.$setViewValue(html);
                }
            }
        };
    }
})();