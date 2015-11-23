(function(){
  "use strict";
  angular
      .module('admin')
      .factory('Menu', [
        '$location',
        '$rootScope',
        '$http',
        '$window',
        function($location, $rootScope, $http, $window) {
          var sections = [
            {
              name: "Жанры",
              type: "toggle",
              icon: "library_books",
              pages: [
                {
                  name: "Список жанров",
                  url: "genres"
                }
              ]
            },
            {
              name: "Управление контентом",
              type: "heading",
              children: [
                {
                  name: "Сериалы",
                  type: "toggle",
                  pages: [
                    {
                      name: "Список сериалов",
                      url: "shows"
                    },
                    {
                      name: "Очередь на добавление",
                      url: "shows/pending"
                    },
                    {
                      name: "Поиск новых сериалов",
                      url: "shows/new"
                    }
                  ]
                }
              ]
            },
            {
              name: "Выход",
              type: "link",
              url: "/logout",
              icon: "exit_to_app"
            }
          ];

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
                // matches nested section toggles, such as API or Customization
                section.children.forEach(function (childSection) {
                  if (childSection.pages) {
                    childSection.pages.forEach(function (page) {
                      matchPage(childSection, page);
                    });
                  }
                });
              }
              else if (section.pages) {
                // matches top-level section toggles, such as Demos
                section.pages.forEach(function (page) {
                  matchPage(section, page);
                });
              }
              else if (section.type === 'link') {
                // matches top-level links, such as "Getting Started"
                matchPage(section, section);
              }
            });
          }

        }])
})();