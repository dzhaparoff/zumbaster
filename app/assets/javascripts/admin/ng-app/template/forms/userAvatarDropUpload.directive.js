(function(){
  "use strict";

  angular
      .module('admin')
      .directive('userAvatarDropUpload',[
          "$timeout",
          "Upload",
      function($timeout, Upload){
        return {
          restrict : 'AEC',
          template : '\
                      <div ngf-drop ngf-select ngf-change="upload($file, $event)" \
                           ngf-reset-on-click\
                           ngf-drag-over-class="calcDragOverClass($event)"\
                           ngf-pattern="\'image/*\'" accept="image/*" \
                           ng-model="item.userpic" \
                           class="drop-box" layout="row" layout-align="center center">\
                        <span>Изменить</span>\
                      </div>\
                      <div ng-class="loading_class()" class="user-avatar"\
                        ngf-size="thumbnail()"\
                        ngf-thumbnail="item.userpic || item.avatar"\
                        ngf-as-background="true"></div>\
                      <svg class="loading-bar" ng-class="loading_class()" width="150" height="150" viewPort="0 0 150 150">\
                        <circle id="bar" r="75" cx="75" cy="75" fill="transparent" stroke-dasharray="472" stroke-dashoffset="0"></circle>\
                      </svg>\
                     ',
          scope: {
            item : "=item"
          },
          controller : ['$scope', '$element', controller]
        };
        function controller($scope, $element){
          $scope.loading = false;
          $scope.upload = function (file, ev) {
            $scope.loading = true;
            if(file == null) return false;
            if (!file.$error) {
              Upload.upload({
                url: '/api/1.0/save_user_avatar',
                method: 'POST',
                data: {
                  user: {
                    id: $scope.item.id,
                    userpic: file
                  }
                }
              }).progress(function (evt) {
                var progressPercentage = parseInt(100.0 * evt.loaded / evt.total);
                setLoadingPercentage(progressPercentage);
              }).success(function (data, status, headers, config) {
                $timeout(function() {
                  $scope.loading = false;
                  $scope.item.avatar = data.avatar;
                });
              });
            }
          };
          $scope.calcDragOverClass = function($event){
            console.log($event);
            return {
              pattern: 'image/*',
              accept:'dragover',
              reject:'dragover-not-allowed',
              delay:100
            }
          };
          $scope.thumbnail = function(){
            return { width: 300, height: 300, quality: 1}
          };
          $scope.loading_class = function(){
              return $scope.loading ? "loading" : "";
          };
          function setLoadingPercentage(val){
            var $circle = angular.element($element).find(".loading-bar circle");
            var r = $circle.attr('r');
            var c = Math.PI*(r*2);

            if (val < 0) { val = 0;}
            if (val > 100) { val = 100;}

            var pct = ((100-val)/100)*c;

            if(val == 100) {
              $scope.loading = false;
              $timeout(function() {
                $circle.css({ strokeDashoffset: c});
              },500);
            }

            $circle.css({ strokeDashoffset: pct});
          }
        }
      }]
  )


})();