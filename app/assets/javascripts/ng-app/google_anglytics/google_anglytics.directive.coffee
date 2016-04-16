googleAnalyticsTracker = ->
  strict: 'AE',
  scope: true
  link: (scope, element, attrs) ->
    page = attrs.page
    title = attrs.title

    if window.ga?
      console.log('google_send_pageview', page, title)
      ga('send', {
        hitType: 'pageview',
        page: page,
        title: title
      });


angular
.module "zumbaster"
.directive "googleAnalyticsTracker", googleAnalyticsTracker