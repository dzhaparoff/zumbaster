"use strict"

selectSetOfItemsTemplate = "<md-chips ng-model=\"item\"
                                  md-autocomplete-snap
                                  md-require-match=\"true\">
                                <md-autocomplete
                                  md-selected-item=\"c.selectedItem\"
                                  md-search-text=\"c.searchText\"
                                  md-items=\"item in c.querySearch(c.searchText)\"
                                  md-item-text=\"item.name\"
                                  placeholder=\"{{placeholder}}\">
                                    <span md-highlight-text=\"c.searchText\">{{item.name}}</span>
                                </md-autocomplete>
                                  <md-chip-template>
                                    <span>
                                      <strong>{{$chip.name}}</strong>
                                    </span>
                                  </md-chip-template>
                              </md-chips>"

class selectSetOfItemsCtrl
  constructor: ($scope, API) ->
    api = new API.resource $scope.model

    self = this;
    self.selectedItem = null
    self.searchText = null

    self.items = []

    items = api.resource.query();
    items.$promise.then ->
      self.items = queryItems(items)

  querySearch: (query) ->
    if query then @items.filter(createFilterFor(query)) else [];

  createFilterFor = (query) ->
    lowercaseQuery = angular.lowercase query
    (item) ->
      (item._lowername.indexOf(lowercaseQuery) is 0) or (item._lowerslug.indexOf(lowercaseQuery) is 0)

  queryItems = (items)->
    items.map (item)->
      item._lowername = item.name.toLowerCase()
      item._lowerslug = item.slug.toLowerCase()
      item


selectSetOfItems = ->
  restrict: "AEC"
  template: selectSetOfItemsTemplate
  controller: ["$scope", "API", selectSetOfItemsCtrl]
  controllerAs: "c"
  scope:
    model: "@selectSetOfItems"
    item: "=ngModel"
    placeholder: "@"


angular
.module "admin"
.directive "selectSetOfItems", selectSetOfItems