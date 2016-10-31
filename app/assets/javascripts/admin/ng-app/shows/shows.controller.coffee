"use strict"

class SearchShowCtrl
  constructor: ($scope, @messages) ->
    @result = []
  searchInMyshow: (editor) ->
    editor.model.$api.$get('pshows/1.0/search_in_myshow', name: @query)
      .then (d) =>
        @result = d.data
  add: (editor, id) ->
    editor.item.id = id
    editor.item.$create()
      .then (d)=>
        editor.model.$addToIndex(angular.extend(editor.item, d.data))
        @messages.show('Объект успешно добавлен', 'save')

class PengingShowCtrl
  constructor: ($scope, @messages) ->
  trakt: (editor, ev) ->
    ev.preventDefault() if ev?
    editor.model.$api.$post('pshows/1.0/sync_with_trakt', editor.item)
      .success (d) =>
        angular.merge(editor.item, d)
        @messages.show('Синхронизован с Trakt.tv', 'save')
  translate: (editor, ev) ->
    ev.preventDefault() if ev?
    editor.model.$api.$post('pshows/1.0/sync_translate', editor.item)
      .success (d) =>
        angular.merge(editor.item, d)
        @messages.show('Перевод синхронизирован', 'save')
  pics: (editor, ev) ->
    ev.preventDefault() if ev?
    editor.model.$api.$post('pshows/1.0/sync_pics', editor.item)
      .success (d) =>
        angular.merge(editor.item, d)
        @messages.show('Изображения синхронизированы', 'save')
  rating: (editor, ev) ->
    ev.preventDefault() if ev?
    editor.model.$api.$post('pshows/1.0/sync_rating', editor.item)
      .success (d) =>
        angular.merge(editor.item, d)
        @messages.show('Рейтинг синхронизирован', 'save')
  people: (editor, ev) ->
    ev.preventDefault() if ev?
    editor.model.$api.$post('pshows/1.0/sync_people', editor.item)
      .success (d) =>
        angular.merge(editor.item, d)
        @messages.show('Персонажи синхронизированы', 'save')
  activate: (editor, ev) ->
    ev.preventDefault() if ev?
    editor.model.$api.$post('pshows/1.0/activate', editor.item)
      .success (d) =>
        angular.merge(editor.item, d)
        @messages.show('Сериал активирован', 'save')
  ids: (editor, ev) ->
    ev.preventDefault() if ev?
    editor.model.$api.$post('pshows/1.0/sync_ids', editor.item)
    .success (d) =>
      angular.merge(editor.item, d)
      @messages.show('Ids синхронизированы', 'save')
  fanart: (editor, ev) ->
    ev.preventDefault() if ev?
    editor.model.$api.$post('pshows/1.0/sync_with_fanart', editor.item)
      .success (d) =>
        angular.merge(editor.item, d)
        @messages.show('Синхронизован с Fanart', 'save')
  tmdb: (editor, ev) ->
    ev.preventDefault() if ev?
    editor.model.$api.$post('pshows/1.0/sync_with_tmdb', editor.item)
    .success (d) =>
      angular.merge(editor.item, d)
      @messages.show('Tmdb синхронизирован', 'save')

class ActiveShowCtrl extends PengingShowCtrl
  constructor: ($scope, @messages) ->
  seasons: (editor, ev) ->
    ev.preventDefault() if ev?
    editor.model.$api.$post('pshows/1.0/sync_seasons', editor.item)
      .success (d) =>
        @messages.show('Сериал в процессе синхронизации', 'save')
  episodes: (editor, ev) ->
    ev.preventDefault() if ev?
    editor.model.$api.$post('pshows/1.0/sync_videos', editor.item)
      .success (d) =>
        @messages.show('Видеозаписи эпизодов синхронизированы', 'save')
  titles: (editor, ev) ->
    ev.preventDefault() if ev?
    editor.model.$api.$post('pshows/1.0/sync_ru_names', editor.item)
      .success (d) =>
        @messages.show('Русскоязычные заголовки эпизодов синхронизированы', 'save')


angular
  .module "admin"
  .controller "SearchShowCtrl", ["$scope", "$toastMessage", SearchShowCtrl]
  .controller "PengingShowCtrl", ["$scope", "$toastMessage", PengingShowCtrl]
  .controller "ActiveShowCtrl", ["$scope", "$toastMessage", ActiveShowCtrl]
