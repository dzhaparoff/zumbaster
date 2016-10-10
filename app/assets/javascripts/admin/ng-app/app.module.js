(function() { 'use strict';

    angular
        .module('admin', ['adminCore', 'adminConfig', 'nlLoading', 'ngAnimate', 'ngResource', 'ui.router', 'ui.ace', 'ngMessages', 'ngMaterial', 'ngFileUpload'])
        .config([
          '$localeProvider',
          'LOCALE',
        function($localeProvider, LOCALE){
          $localeProvider.build(LOCALE);
        }])
        .config([
          '$stateProvider',
          '$urlRouterProvider',
          '$locationProvider',
          '$mdThemingProvider',
          '$routerRailsResourceStatesProvider',
          'RESOURCES',
        function($stateProvider, $urlRouterProvider, $locationProvider, $mdThemingProvider, $routerRailsResourceStatesProvider, RESOURCES){
          // ROUTER
          $locationProvider.html5Mode(true);
          $urlRouterProvider.otherwise("/main");

          $routerRailsResourceStatesProvider
              .resources(RESOURCES)
              .build($stateProvider);

          //THEMING
          $mdThemingProvider.theme('default')
              .primaryPalette('teal')
              .accentPalette('orange');

          $mdThemingProvider.theme('dark-grey')
              .primaryPalette('grey',{
                'default': '900',
                'hue-1': '800',
                'hue-2': '700',
                'hue-3': '600'
              })
              .accentPalette('amber')
              .dark();

          $mdThemingProvider.theme('yellow')
              .primaryPalette('amber')
              .accentPalette('blue');

          $mdThemingProvider.theme('dark', 'default')
              .primaryPalette('blue-grey')
              .accentPalette('orange')
              .dark();
        }]);

  String.prototype.capitalizeFirstLetter = function() {
    return this.charAt(0).toUpperCase() + this.slice(1);
  };
  String.prototype.lowercaseFirstLetter = function() {
    return this.charAt(0).toLowerCase() + this.slice(1);
  };
  String.prototype.pluralize = function() {
    return this + 's';
  };
})();