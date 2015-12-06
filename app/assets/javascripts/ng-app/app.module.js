(function() { 'use strict';

    angular
        .module('zumbaster', ['ngAnimate', 'ngResource', 'ngDialog', 'angular-cache']);

    $(document).on('ready page:load', function() {
        angular.bootstrap(document.body, ['zumbaster'], { strictDi : true });
    })

})();