(function(){
  "use strict";
  angular
      .module('admin')
      .controller('MenuCtrl', ["$scope", "Menu",  MenuCtrl]);

  function MenuCtrl($scope, Menu){
    var vm = this;
    vm.scope_name = 'menu';
    vm.autoFocusContent = false;
    vm.isOpen = isOpen;
    vm.isSelected = isSelected;
    vm.isSectionSelected = isSectionSelected;
    vm.toggleOpen = toggleOpen;

    vm.sections = Menu.sections;
    
    function isOpen(section) {
      return Menu.isSectionSelected(section);
    }
    
    function isSelected(page) {
      return Menu.isPageSelected(page);
    }

    function isSectionSelected(section) {
      var selected = false;
      var openedSection = menu.openedSection;
      if(openedSection === section){
        selected = true;
      }
      else if(section.children) {
        section.children.forEach(function(childSection) {
          if(childSection === openedSection){
            selected = true;
          }
        });
      }
      return selected;
    }

    function toggleOpen(section) {
      Menu.toggleSelectSection(section);
    }
    
    
  }
})();