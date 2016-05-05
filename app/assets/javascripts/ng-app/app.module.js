(function() { 'use strict';

    angular
        .module('zumbaster', ['ngAnimate', 'nlLoading', 'ngResource', 'ngDialog', 'angular-cache']);

    $(document).on('turbolinks:load', function() {
        angular.bootstrap(document.body, ['zumbaster'], { strictDi : true });
    })

})();