(function() { 'use strict';

    angular
        .module('admin', ['ngAnimate', 'ngResource'])
        .config(["$httpProvider", function(provider) {
            provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
        }]);

})();