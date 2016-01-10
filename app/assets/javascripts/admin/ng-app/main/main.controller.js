(function(){
    "use strict";
    angular
        .module('admin')
        .controller('MainCtrl',
          ["$scope", "$state", "$timeout", "$mdSidenav", "$loading", "Menu", "$mdMedia", "$document", "$locale",
          MainCtrl]
        );

    var $_sce;

    function MainCtrl($scope, $state, $timeout, $mdSidenav, $loading, Menu, $mdMedia, $document, $locale){

      var vm = this;
      vm.loading = $loading;
      vm.menu = Menu;
      vm.scope_name = 'main';
      vm.autoFocusContent = false;
      vm.closeMenu = closeMenu;
      vm.openMenu = openMenu;
      vm.goHome = goHome;
      vm.openPage = openPage;
      vm.openContextMenu = openContextMenu;
      vm.closeContextMenu = closeContextMenu;
      vm.go = $state.go;
      var mainContentArea = document.querySelector("[role='main']");

      vm.locale = $locale;
      vm.locale.assign_scope($scope);

      $scope.$watch(
          function(){
            return $mdMedia('gt-md')
          },
          function(md) {
            if(!md)
              angular.element('body').addClass('md');
            else
              angular.element('body').removeClass('md');
          });

      $scope.$watch(
          function(){
            return $mdMedia('sm')
          },
          function(sm) {
            if(sm)
              angular.element('body').addClass('sm');
            else
              angular.element('body').removeClass('sm');
          });

      function closeMenu() {
        $timeout(function() { $mdSidenav('left').close(); });
      }

      function openMenu() {
        $timeout(function() { $mdSidenav('left').open(); });
      }

      function path() {
        return $location.path();
      }

      function goHome($event) {
        menu.selectPage(null, null);
        $location.path( '/' );
      }

      function openPage() {
        $scope.closeMenu();

        if (vm.autoFocusContent) {
          focusMainContent();
          vm.autoFocusContent = false;
        }
      }

      function focusMainContent($event) {
        // prevent skip link from redirecting
        if ($event) { $event.preventDefault(); }

        $timeout(function(){
          mainContentArea.focus();
        },90);

      }

      var originatorEv;
      function openContextMenu($mdOpenMenu, ev){
          originatorEv = ev;
          $mdOpenMenu(ev);
      }
      function closeContextMenu(){
        originatorEv = null;
      }
    }
    
    var Helpers = (function () {
      return {
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
    })()
})();