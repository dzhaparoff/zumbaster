(function(){
  "use strict";
  angular
      .module('admin')
      .factory('Menu', [
        '$location',
        '$rootScope',
        '$http',
        '$window',
        'MENU',
        function($location, $rootScope, $http, $window, MENU) {
          var sections = MENU.sections;

          function sortByName(a,b) {
            return a.name < b.name ? -1 : 1;
          }

          var self;

          $rootScope.$on('$locationChangeSuccess', onLocationChange);

          return self = {
            sections: sections,

            selectSection: function(section) {
              self.openedSection = section;
            },
            toggleSelectSection: function(section) {
              self.openedSection = (self.openedSection === section ? null : section);
            },
            isSectionSelected: function(section) {
              return self.openedSection === section;
            },
            selectPage: function(section, page) {
              self.currentSection = section;
              self.currentPage = page;
            },
            isPageSelected: function(page) {
              return self.currentPage === page;
            }
          };

          function onLocationChange() {
            var path = $location.path();
            var introLink = {
              name: "Консоль",
              url: "/",
              type: "link"
            };

            if (path == '/') {
              self.selectSection(introLink);
              self.selectPage(introLink, introLink);
              return;
            }

            var matchPage = function (section, page) {
              if (path.indexOf(page.url) !== -1) {
                self.selectSection(section);
                self.selectPage(section, page);
              }
            };

            sections.forEach(function (section) {
              if (section.children) {
                section.children.forEach(function (childSection) {
                  if (childSection.type === 'link') {
                    matchPage(childSection, childSection);
                  }
                  else if (childSection.pages) {
                    childSection.pages.forEach(function (page) {
                      matchPage(childSection, page);
                    });
                  }

                });
              }
              else if (section.pages) {
                section.pages.forEach(function (page) {
                  matchPage(section, page);
                });
              }
              else if (section.type === 'link') {
                matchPage(section, section);
              }
            });
          }

        }])
})();