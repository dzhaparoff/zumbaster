do ->

  showTranslations = ->
    strict: 'AE',
    scope: true
    controller: ["$scope", "$attrs", "mainCache", ShowTranslationsCtrl]
    controllerAs: 'translation'


  class ShowTranslationsCtrl
    constructor: ($scope, $attrs, mainCache) ->
      vm = this
      vm.list = $attrs.showTranslations.split ','

      cache = mainCache.playerCache

      vm.setCacheValue = (id) -> cache.put('translator', id)
      vm.getCacheValue = -> cache.get('translator')

      if vm.getCacheValue()?
        vm.active = vm.getCacheValue()
      else
        vm.active = parseInt vm.list[0]

    is_active: (id) ->
      this.active == id

    set: (id) ->
      this.active = id
      this.setCacheValue(id)

    bclass: (id) ->
      "active success" if this.active == id


  angular
    .module "zumbaster"
    .directive "showTranslations", showTranslations