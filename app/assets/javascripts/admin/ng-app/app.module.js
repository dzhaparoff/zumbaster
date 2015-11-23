(function() { 'use strict';

    angular
        .module('admin', ['ngAnimate', 'ngResource', 'ui.router', 'ngMessages', 'ngMaterial'])
        // CORS
        .config(["$httpProvider", function(provider) {
            provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
        }])
        .constant('ROUTES', (function () {
          return {
            GENRES: '/genres',
            GENRE: '/genre/:id',
            GENRE_SEO: '/genre/:id/seo'
          }
        })())
        .config([
          '$stateProvider',
          '$urlRouterProvider',
          '$locationProvider',
          '$mdThemingProvider',
        function($stateProvider, $urlRouterProvider, $locationProvider, $mdThemingProvider){
          // ROUTER
          $locationProvider.html5Mode(true);
          $urlRouterProvider.otherwise("/main");
          $stateProvider
              .state('main', {
                url: "/",
                templateUrl: "partials/home.tmpl.html"
              })
              //genres
              .state('genres', {
                url: "/genres",
                resolve:{
                  Model:  function(API){
                    return new API.resource('genres');
                  },
                  Seos : function(API){
                    return new API.resource('seos');
                  }
                },
                templateUrl: "partials/genres.tmpl.html",
                controller : "resourcesCtrl as genres"
              })
                .state('genres.edit', {
                  url: "/{resource_id:int}"
                })
                  .state('genres.edit.seo', {
                    url: "/seo"
                  });
              //genres-end

          //THEMING
          $mdThemingProvider.definePalette('docs-blue', $mdThemingProvider.extendPalette('blue', {
            '50': '#DCEFFF',
            '100': '#AAD1F9',
            '200': '#7BB8F5',
            '300': '#4C9EF1',
            '400': '#1C85ED',
            '500': '#106CC8',
            '600': '#0159A2',
            '700': '#025EE9',
            '800': '#014AB6',
            '900': '#013583',
            'contrastDefaultColor': 'light',
            'contrastDarkColors': '50 100 200 A100',
            'contrastStrongLightColors': '300 400 A200 A400'
          }));

          $mdThemingProvider.theme('dark', 'default')
              .primaryPalette('orange')
              .dark();

          $mdThemingProvider.theme('default')
              .primaryPalette('teal')
              .accentPalette('orange');
        }])

})();