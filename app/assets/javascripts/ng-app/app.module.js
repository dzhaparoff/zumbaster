(function() { 'use strict';

    angular
        .module('zumbaster', [])
        .config(["$httpProvider", function(provider) {
            provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
        }]);

    $(document).on('ready page:load', function() {
        angular.bootstrap(document.body, ['zumbaster'], { strictDi : true });
    })

})();