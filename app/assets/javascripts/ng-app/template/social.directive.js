(function() { 'use strict';

  angular
      .module('zumbaster')
      .factory('vk',vk)
      .factory('fb',fb)
      .factory('tw',tw)
      .factory('gp',gp)
      .directive('sharebox', sharebox);

  vk.$inject = ['$http']
  fb.$inject = ['$http']
  tw.$inject = ['$http']
  gp.$inject = ['$http']

  function vk($http){
    return {
      getShareCount: function(page) {
        return $http({
          method: "JSONP",
          responseType : "text/javascript",
          url : 'http://vk.com/share.php?act=count&index=1&url='+page+'&callback=JSON_CALLBACK'
        })
      },
      share: function(page) {
        window.open('http://vk.com/share.php?url='+page,"","toolbar=0,status=0,width=626,height=436")
      }
    }
  }

  function fb($http){
    return {
      getShareCount: function(page) {
        return $http({
          method: "GET",
          url : 'http://graph.facebook.com/fql?q=SELECT share_count, like_count, comment_count, total_count, commentsbox_count, comments_fbid, click_count FROM link_stat WHERE url=%22'+page+'%22',
          headers: {
            "Access-Control-Allow-Origin" : "*"
          }
        })
      },
      share: function(page) {
        window.open('http://facebook.com/sharer.php?p[url]='+page,"","toolbar=0,status=0,width=626,height=436")
      }
    }
  }

  function gp($http){
    return {
      getShareCount: function(page) {
        return $http({
          method: "POST",
          url : 'https://clients6.google.com/rpc',
          headers: {
            "Content-type" : "application/json",
            "Access-Control-Allow-Origin" : "*"
          },
          data : {
            "method" : "pos.plusones.get",
            "id" : "p",
            "params" : {
              "nolog" : true,
              "id" : page,
              "source" : "widget",
              "userId" : "@viewer",
              "groupId" : "@self"
            },
            "jsonrpc":"2.0",
            "key":"p",
            "apiVersion":"v1"
          }
        })
      },
      share: function(page) {
        window.open('https://plus.google.com/share?url=' + page,"","toolbar=0,status=0,width=626,height=436");
      }
    }
  }

  function tw($http){
    return {
      getShareCount: function(page) {
        return $http({
          method: "jsonp",
          url : 'http://urls.api.twitter.com/1/urls/count.json?url='+page+'&callback=JSON_CALLBACK'
        })
      },
      share: function(page, text) {
        window.open('http://twitter.com/share?url='+page+'&text='+text,"","toolbar=0,status=0,width=626,height=436")
      }
    }
  }

  sharebox.$inject = ['vk', 'fb', 'tw', 'gp', '$timeout'];

  function sharebox(vk, fb, tw, gp, $timeout) {
    return {
      restrict : 'A',
      scope : true,
      link : function($scope, $element, $attr) {
        var type = $attr.sharebox,
            link = $attr.link;
        $scope.like = {count: 0};
        if(type == 'vkontakte')
        {
          var t;
          if(!window.VK) window.VK = {};
          window.VK.Share = {
            count: function(idx, number){
              $scope.like.count = number
            }
          };
          vk.getShareCount(link);
          $element.click(function(){
            vk.share(link);
            $scope.like.count += 1;
            t = $timeout(function(){
              vk.getShareCount(link);
              $timeout.cancel(t);
            },4000)
          })
        }

        if(type == 'facebook')
        {
          var t,
              get_count;

          $element.click(function(){
            fb.share(link);
            $scope.like.count += 1;
            t = $timeout(function(){
              get_count();
              $timeout.cancel(t);
            },4000)
          });

          get_count = function(){
            fb.getShareCount(link).success(function(d){
              $scope.like.count = d.data[0].total_count
            });
          };
          get_count();
        }

        if(type == 'twitter')
        {
          var t,
              get_count,
              text;

          text = $attr.text;
          $element.click(function(){
            tw.share(link,text);
            $scope.like.count += 1;
            t = $timeout(function(){
              get_count();
              $timeout.cancel(t);
            },4000)
          });

          get_count = function(){
            tw.getShareCount(link).success(function(d){
              $scope.like.count = d.count
            });
          };
          get_count();
        }

        if(type == 'google')
        {
          var t,
              get_count;

          $element.click(function(){
            gp.share(link);
            $scope.like.count += 1;
            t = $timeout(function(){
              get_count();
              $timeout.cancel(t);
            },4000)
          });

          get_count = function(){
            gp.getShareCount(link).success(function(d){
              console.log(d)
              $scope.like.count = d.count;
            });
          };
          get_count();
        }
      } //end LINK
    } //end RETURN
  } //end FUNC

})();