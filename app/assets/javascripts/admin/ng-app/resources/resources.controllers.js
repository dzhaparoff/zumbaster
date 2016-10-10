(function(){
  "use strict";

  Array.prototype.contains = function (v) {
    return this.indexOf(v) > -1;
  };

  angular
      .module('admin')
      .controller('resourcesCtrl', ["$state", "$mdDialog", "Model", resourcesCtrl])
      .controller('resourceEditorCtrl', ['$scope', '$state', '$mdComponentRegistry', '$toastMessage', 'Model', 'Links', resourceEditorCtrl])

  function resourcesCtrl($state, $mdDialog, Model, Seos){
    var vm = this;

    vm.model = Model;
    vm.index = Model.index = Model.resource.query();
    vm.new  = _new;
    vm.edit = _edit;

    vm.items_count = function(){
      return vm.index.length
    };

    function _edit(resource, ev){
      var id = (typeof resource.id == "string" || typeof resource.id == "number") ? resource.id : resource.id.$oid;
      $state.go(Model.model_slug + '.edit',{ resource_id : id });
    }
    function _new(ev){
      $state.go(Model.model_slug + '.new');
    }
  }

  function resourceEditorCtrl($scope, $state, $mdComponentRegistry, $toastMessage, Model, Links){
    var editor = this;
    var id = $state.params.resource_id;

    $scope.$sidebar = $mdComponentRegistry.get('right');

    $scope.$watch('$sidebar.isOpen()', function(opened, old){
      if(!opened && old) editor.$$close_and_go_to_resource_root();
    });

    editor.init(Model, Links);
    editor.load(Model, Links, id, $toastMessage, $state);

    $scope.$on('locale:change', function(){
      editor.load(Model, Links, id, $toastMessage, $state);
      editor.states.reset();
    });

    editor.cancel = function() {
      $scope.$sidebar.close();
    };

    editor.save = function(main) {
      if(typeof $scope.form !== 'undefined' && !$scope.form.$valid){
        $toastMessage.show('Ошибка! Проверьте введенную информацию', 'error_outline');
        $scope.form.$submitted = true;
        return false;
      }
      if(typeof main !== 'undefined')
        main.closeContextMenu();
      if(editor.item.$config.action == "create")
        Model.$addToIndex(editor.item);
      else
        Model.$updateIndex(editor.item);
      editor.item.$update().then(function(){
        $scope.$sidebar.close();
        $toastMessage.show('Объект успешно сохранен', 'save');
      });
    };

    editor.add_embedded_item = function(embedded, item, main) { // MONGODB EMBEDDED ITEM ADD
      if(typeof main !== 'undefined')
        main.closeContextMenu();
      editor.item.$update({mode: 'add_embedded', embedded: embedded}).then(function(){
        delete editor.item.new_embedded;
        $toastMessage.show('Объект успешно добавлен', 'save');
        editor.states.reset();
      });
    };

    editor.save_embedded_item = function(embedded, item, main) { // MONGODB EMBEDDED ITEM UPDATE
      if(typeof main !== 'undefined')
        main.closeContextMenu();
      editor.item.$update({mode: 'update_embedded', embedded_id: embedded['_id']}).then(function(){
        $toastMessage.show('Объект успешно сохранен', 'save');
        editor.states.reset();
      });
    };

    editor.delete_embedded_item = function(embedded, item, main) { // MONGODB EMBEDDED ITEM DELETE
      if(typeof main !== 'undefined')
        main.closeContextMenu();
      editor.item.$update({mode: 'delete_embedded', embedded_id: embedded['_id']}).then(function(){
        $toastMessage.show('Объект успешно удален', 'save');
        editor.states.reset();
      });
    };

    editor.delete = function(main) {
      if(typeof main !== 'undefined') main.closeContextMenu();
      console.log(editor.item);
      Model.$removeFromIndex(editor.item);
      editor.item.$delete().then(function(){
        $scope.$sidebar.close();
        $toastMessage.show('Объект успешно удален', 'save');
      });
    };

    editor.create_new = function(main) {
      if(typeof $scope.form !== 'undefined' && !$scope.form.$valid){
        $toastMessage.show('Ошибка! Проверьте введенную информацию', 'error_outline');
        $scope.form.$submitted = true;
        return false;
      }
      if(typeof main !== 'undefined') main.closeContextMenu();
      editor.item.$create().then(function(d){
        if(d.hasOwnProperty('_id'))
          editor.item.id = d._id.$oid;
        Model.$addToIndex(editor.item);
        $scope.$sidebar.close();
        $toastMessage.show('Объект успешно создан', 'save');
      });
    };

    editor.reset = function(item, main) {
      if(typeof main !== 'undefined') main.closeContextMenu();
      item.$get()
    };

    editor.$$not_found = function(){
      $toastMessage.show('Ошибка 404! Запрашиваемый элемент не найден', 'error_outline');
      editor.$$close_and_go_to_resource_root();
    };

    editor.$$close_and_go_to_resource_root = function(){
      $state.go(Model.model_slug);
    }
  }

  resourceEditorCtrl.prototype.init = function(Model, Links){
    var editor = this;

    editor.model = Model;
    editor.linked_models = Links;

    /*FAB*/

    editor.fab = {
      isOpen: false,
      selectedDirection: 'left',
      theme: 'dark-grey'
    };

    /*ACE*/

    editor.ace_config = {
      useWrapMode : true,
      showGutter: true,
      mode: 'html',
      onLoad: function (_editor) {
        _editor.$blockScrolling = Infinity;
      }
    };

    /*STATES*/

    editor.states = {
      current : "",
      equal : function(state){
        return editor.states.current === state;
      },
      set : function(state, ev){
        editor.states.current = state;
      },
      reset : function(){
        editor.states.current = "";
      }
    };

    /*TRANSLITERATION*/

    editor.transliterate = true;

    editor.lockTransliteraion = function(){
      editor.transliterate = !editor.transliterate
    }

    /*ACTIONS*/

    editor.edit_linked = function(linked_model){
      editor.states.set(linked_model);
      if(editor.item.hasOwnProperty(linked_model + '_id')){
        if(!editor.item.hasOwnProperty(linked_model)) {
          var id = editor.item[linked_model + '_id'];
          if(typeof id == 'object') id = id.$oid;
          editor.item[linked_model] = Links[linked_model.capitalizeFirstLetter()].resource.get({ id : id });
        }
      }
      else {
        if(!editor.item.hasOwnProperty(linked_model))
          editor.item[linked_model] = Links[linked_model.capitalizeFirstLetter()].resource.new();
      }
    };

    editor.edit_linked_from_many = function(linked_model, item){
      var item_id = item.id;
      if(typeof item_id == 'object') item_id = item.id.$oid;
      if(!editor.item.hasOwnProperty('linked'))
        editor.item.linked = {};
      editor.states.set(linked_model + "_" + item_id);
      editor.item.linked[linked_model] = Links[linked_model.capitalizeFirstLetter()].resource.get({ id : item_id });
    };

    /*HELPERS*/

    editor.humanize = function(k){
      if(angular.isDefined(editor.item.$config.humanize[k]))
        return editor.item.$config.humanize[k];
    };

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
      if(editor.item.$config.hasOwnProperty('enum'))
        if(editor.item.$config.enum.hasOwnProperty(k))
          return "select";
    };

    editor.select_values = function(k){
      var values = [];
      if(editor.item.hasOwnProperty('$config'))
        if(editor.item.$config.hasOwnProperty('enum'))
          if(editor.item.$config.enum.hasOwnProperty(k)) values = editor.item.$config.enum[k];
      return values;
    };

    editor.readonly = function(k){
      return editor.item.$config.readonly_columns.contains(k);
    };

    /*GETTERS*/

    Object.defineProperties(this, {
      'loading:get': {
        get: function(){ //__defineGetter__
          return this.model.loading[Model.model_slug + ':get'];
        }
      },
      'loading:update': {
        get: function(){ //__defineGetter__
          return this.model.loading[Model.model_slug + ':update'];
        }
      },
      'model_name': {
        get: function(){ //__defineGetter__
          if(this.item.hasOwnProperty('$config'))
          return this.item.$config.names.model_name;
        }
      }
    });
  }

  resourceEditorCtrl.prototype.load = function(Model, Links, id){
    var editor = this;
    if(typeof id == 'undefined'){
      editor.item = Model.resource.new();
    }
    else {
      editor.item = Model.resource.get({id: id});
      editor.item.$promise.catch(function(responce){
        if(responce.status == 404) {
          editor.$$not_found()
        }
      });

    }
  }

})();