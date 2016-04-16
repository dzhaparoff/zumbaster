googleAnalyticsTracker = ->
  strict: 'AE',
  scope: true
  link: (scope, element, attrs) ->
    page = attrs.page
    title = attrs.title

    if window.ga?
      ga('send', {
        hitType: 'pageview',
        page: page
      });


angular
.module "zumbaster"
.directive "googleAnalyticsTracker", googleAnalyticsTracker