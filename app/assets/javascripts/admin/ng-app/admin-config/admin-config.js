(function(window, angular){
  "use strict";
  angular
      .module('adminConfig', [])
      .constant('LOCALE', (function () {
        return [
            'ru'
        ]
      })())
      .constant('RESOURCES', (function () {
        return [
          {
            slug: 'users',
            model: 'User',
            templates: {
              list: "partials/users/users.tmpl.html",
              new:  "partials/users/user_new.tmpl.html",
              edit: "partials/users/user_edit.tmpl.html"
            }
          },
          {
            slug: 'genres',
            model: 'Genre',
            linked: ['Seo'], // has_one, has_many relation
            templates: {
              list: "partials/genres/genres.tmpl.html",
              new:  "partials/genres/genre_new.tmpl.html",
              edit: "partials/genres/genre_edit.tmpl.html"
            }
          },
          {
            slug: 'pshows',
            model: 'Pshow',
            templates: {
              list: "partials/pshows/shows.tmpl.html",
              new:  "partials/pshows/show_new.tmpl.html",
              edit: "partials/pshows/show_edit.tmpl.html"
            }
          },
          {
            slug: 'shows',
            model: 'Show',
            linked: ['Season','Episode'], // has_one, has_many relation
            templates: {
              list: "partials/shows/shows.tmpl.html",
              new:  "partials/shows/show_new.tmpl.html",
              edit: "partials/shows/show_edit.tmpl.html"
            }
          },
          {
            slug: 'seasons',
            model: 'Season',
            linked: ['Episode','Show'], // has_one, has_many relation
            templates: {
              list: "partials/seasons/seasons.tmpl.html",
              new:  "partials/seasons/season_new.tmpl.html",
              edit: "partials/seasons/season_edit.tmpl.html"
            }
          },
          {
            slug: 'episodes',
            model: 'Episode',
            linked: ['Season','Show'], // has_one, has_many relation
            templates: {
              list: "partials/episodes/episodes.tmpl.html",
              new:  "partials/episodes/episode_new.tmpl.html",
              edit: "partials/episodes/episode_edit.tmpl.html"
            }
          },
          {
            slug: 'pages',
            model: 'Page',
            linked: ['Seo'], // has_one, has_many relation
            templates: {
              list: "partials/pages/pages.tmpl.html",
              new:  "partials/pages/page_new.tmpl.html",
              edit: "partials/pages/page_edit.tmpl.html"
            }
          }
        ]})())
      .constant('MENU', (function () {
        return {
          sections : [
            {
              name: "Пользователи",
              type: "toggle",
              icon: "people",
              pages: [
                {
                  name: "Список пользователей",
                  url: "users"
                }
              ]
            },
            {
              name: "Управление контентом",
              type: "heading",
              children: [
                {
                  name: "Страницы",
                  url: "pages",
                  icon: "description",
                  type: "link"
                }
              ]
            },
            {
              name: "Сериалы",
              type: "heading",
              children: [
                {
                  name: "Жанры",
                  type: "toggle",
                  icon: "folder",
                  pages: [
                    {
                      name: "Список жанров",
                      url: "genres"
                    }
                  ]
                },
                {
                  name: "Сериалы",
                  type: "toggle",
                  icon: "subscriptions",
                  pages: [
                    {
                      name: "Список сериалов",
                      url: "shows"
                    }, {
                      name: "Новые сериалы",
                      url: "pshows"
                    }
                  ]
                }
              ]
            }
          ]
        }
      })())
})(window, window.angular);

//= require_tree .