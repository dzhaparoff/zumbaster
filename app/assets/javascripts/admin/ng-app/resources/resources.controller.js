(function(){
  "use strict";
  angular
      .module('admin')
      .controller('resourcesCtrl',
      ["$scope", "$state", "$mdDialog", "Model", "Seos",
        resourcesCtrl]);

      function resourcesCtrl($scope, $state, $mdDialog, Model, Seos){
        var vm = this;
        var dont_load = true;

        vm.index = Model.resource.query();
        vm.edit_seo = edit_seo;
        vm.edit = edit;

        function edit_seo(resource, ev){

          if(ev !== null) {
            $state.go(Model.model_slug + '.edit.seo',{ resource_id : resource.id });
            dont_load = false;
          }

          $mdDialog.show({
            controller: popupEditorCtrl,
            controllerAs: 'editor',
            locals : {
              Model : Seos,
              loading : Seos.loading['seos:get'],
              model_name : 'SEO',
              id : resource.seo_id
            },
            templateUrl: 'partials/model_edit.tmpl.html',
            parent: angular.element(document.body),
            targetEvent: ev,
            clickOutsideToClose:true
          })
              .then(
              function(e) {
                e.$update();
                $state.go(Model.model_slug);
              },
              function() {
                //cancel
                $state.go(Model.model_slug);
              });
        };

        function edit(resource, ev){

          if(ev !== null) {
            $state.go(Model.model_slug + '.edit',{ resource_id : resource.id });
            dont_load = false;
          }

          $mdDialog.show({
            controller: popupEditorCtrl,
            controllerAs: 'editor',
            locals : {
              Model : Model,
              loading : Model.loading[Model.model_slug + ':get'],
              model_name : Model.model_name,
              id : resource.id
            },
            templateUrl: 'partials/model_edit.tmpl.html',
            parent: angular.element(document.body),
            targetEvent: ev,
            clickOutsideToClose:true
          })
              .then(
                function(e) {
                  e.$update();
                  Model.$updateIndex(vm.index, e);
                  $state.go(Model.resource_name);
                },
                function() {
                 //cancel
                  $state.go(Model.resource_name);
                });
        }

        var popupEditorCtrl = ['Model', 'loading', 'model_name', 'id',
          function(Model, loading, model_name, id){
            var editor = this;
            editor.loading = loading;
            editor.model_name = model_name;
            editor.item = Model.resource.get({id: id});
            editor.editable_column = function(k){
              return !_.contains(editor.item.$config.system_columns, k);
            };
            editor.column_maxlength = function(k){
              if(angular.isDefined(editor.item.$config.columns_list[k]))
                return parseInt(editor.item.$config.columns_list[k].cast_type.limit);
            };
            editor.column_type = function(k){
              if(!angular.isDefined(editor.item.$config.columns_list[k]))
                return null;
              if(/character/.test(editor.item.$config.columns_list[k].sql_type))
                return "input";
              if(/text/.test(editor.item.$config.columns_list[k].sql_type))
                return "textarea";
            };
            editor.cancel = function() {
              $mdDialog.cancel();
            };
            editor.save = function() {
              $mdDialog.hide(editor.item);
            };
          }];

        $scope.$on('$stateChangeSuccess',function(e,v){
          if( /\./.test(v.name)) {
            var id = $state.params.resource_id;
            vm.index.$promise.then(function(){
              var item = _.find(vm.index, function(i){
                return (i.id == id)
              });
              if(dont_load) {
                if(v.name == Model.model_slug + '.edit')
                  vm.edit(item, null);
                if(v.name == Model.model_slug + '.edit.seo')
                  vm.edit_seo(item, null);
              }
              dont_load = true;
            });
          }
        });
      }
})();