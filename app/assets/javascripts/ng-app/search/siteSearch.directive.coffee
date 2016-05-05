siteSearchDirective = (API)->
  class siteSearchController
    constructor: ($scope, $element, $attrs) ->
      @element = $element
      @name = 'search'
      @phrase = ''
      @api = new API.resource("search")
      @result_existed = []
      @result_not_existed = []
      @found = false
      @not_found = false

      close = () =>
        $scope.$applyAsync(=> @phrase = '')

      close_on_blur = (e)=>
        console.log($(e.target).parents('.site-search'))
        if($(e.target).parents('.site-search').length == 0)
          close()

      $('body').on('click', close_on_blur )

      $scope.$watch('search.phrase', => @result_existed = []; @result_not_existed = []; @found = false; @not_found = false)

    goSearch: () ->
      @result_existed = []
      @result_not_existed = []
      @found = false
      if @phrase == ''
        return false
      result = @api.resource.get({id: @phrase});
      result.$promise.then(
        (d) =>
          @result_existed = _.filter(d.result, (item) -> item.existed != null )
          @result_not_existed = _.filter(d.result, (item) -> item.existed == null )
          @found = d.result.length > 0
          @not_found = d.result.length == 0
      )

    showFounded: () ->
      @found

    nothingFound: () ->
      @not_found

    otherShows: () ->
      @result_not_existed.length > 0

    getSeasonLink: (item, slug) ->
      '/' + item.existed.slug_ru + '/' + slug.replace('s', 'season-')
      
  {
  strict: 'AE',
  scope: true,
  controllerAs: 'search',
  controller: ["$scope","$element", "$attrs", siteSearchController]
  }

angular
.module "zumbaster"
.directive "siteSearch", [ "API", siteSearchDirective ]