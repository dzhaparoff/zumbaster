(function(){
  "use strict";

  var _extend = angular.extend;
  var _copy = angular.copy;

  angular
      .module('adminCore')
      .provider('$routerRailsResourceStates', [$routerRailsResourceStates]);

      function $routerRailsResourceStates(){
        var RailsResourceState = function(config){
          this.init(config);
        };
        RailsResourceState.prototype = {
          constructor: RailsResourceState,
          defaults: {
            slug: '',
            model: '',
            linked: [],
            templates: {
              list: "partials/resource.tmpl.html",
              new:  "partials/resource_new.tmpl.html",
              edit: "partials/resource_edit.tmpl.html"
            },
            theme: "default"
          },
          init: function(config){
            this.config = _extend(_copy(this.defaults), config);
          },
          state: function($stateProvider){
            var self = this;

            var resolve = (function(){
              var resolveItems = {};

              resolveItems.Model = ['API', function(API){
                return new API.resource(self.config.slug);
              }];

              resolveItems.Links = ['API',function(API){
                var links = {};

                _.forEach(self.config.linked, function(model){
                  links[model.capitalizeFirstLetter()] = new API.resource(model.lowercaseFirstLetter().pluralize());
                });

                return links;
              }];

              return resolveItems;
            })();

            return $stateProvider
                .state(self.config.slug, {
                  url: "/" + self.config.slug,
                  resolve: resolve,
                  templateUrl: self.config.templates.list,
                  controller : "resourcesCtrl as items" // + self.config.slug
                })
                  .state(self.config.slug + '.new', {
                    url: "/new",
                    views: {
                      'right@': {
                        controller: 'resourceEditorCtrl as editor',
                        templateUrl: self.config.templates.new
                      }
                    },
                    onEnter: ["$mdSidenav", "$interval", function($mdSidenav, $interval){
                      var sidebar = $mdSidenav('right');
                      var checking = $interval(function(){
                        if(!sidebar.isOpen()) {
                          sidebar.open();
                          $interval.cancel(checking);
                        }
                      },50);
                    }],
                    onExit: ["$mdSidenav", function($mdSidenav){
                      $mdSidenav('right').close();
                    }]
                  })
                  .state(self.config.slug + '.edit', {
                    url: "/{resource_id}",
                    views: {
                      'right@': {
                        controller: 'resourceEditorCtrl as editor',
                        templateUrl: self.config.templates.edit
                      }
                    },
                    onEnter: ["$mdSidenav", "$interval", function($mdSidenav, $interval){
                      var sidebar = $mdSidenav('right');
                      var checking = $interval(function(){
                        if(!sidebar.isOpen()) {
                          sidebar.open();
                          $interval.cancel(checking);
                        }
                      },50);
                    }],
                    onExit: ["$mdSidenav", function($mdSidenav){
                      $mdSidenav('right').close();
                    }]
                  })
          }
        };

        var provider = this;
        provider.resources_config = [];

        return {
          resources : function(resources){
            this.resources_config = resources;
            return this;
          },
          $get : function(){
            return this.resources;
          },
          build : function($stateProvider){
            var self = this;

            $stateProvider
                .state('main', {
                  url: "/",
                  templateUrl: "partials/home.tmpl.html"
                });

            _.forEach(self.resources_config, function(resource){
              var resource_route = new RailsResourceState(resource);
              resource_route.state($stateProvider)
            });
            return this;
          }
        }
      }
})(window, window.angular);