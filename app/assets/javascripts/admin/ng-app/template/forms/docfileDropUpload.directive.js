(function(){
  "use strict";

  angular
      .module('admin')
      .directive('docfileDropUpload',[
        "$timeout",
        "Upload",
        function($timeout, Upload){
          return {
            restrict : 'AEC',
            template : '\
                      <div ngf-drop ngf-select ngf-change="upload($file, $event)" \
                           ngf-reset-on-click\
                           ngf-drag-over-class="calcDragOverClass($event)"\
                           ngf-pattern="\'application/*\'" accept="application/*" \
                           ngf-max-size="16MB"\
                           ng-model="item[field]" \
                           class="drop-box" layout="row" layout-align="center center">\
                        <span>Загрузить</span>\
                      </div>\
                      <div ng-class="loading_class()" class="file-placeholder">\
                        <span ng-if="!item[field] && item.mime_type" class="existed-file"><md-icon>insert_drive_file</md-icon>{{item.filesize}}</span>\
                        <span ng-if="!item[field] && !item.mime_type" class="no-file"><md-icon>archive</md-icon></span>\
                        <span ng-if="item[field]" class="new-file"><md-icon>insert_drive_file</md-icon>{{item[field].size | filesize}}</span>\
                      </div>\
                      <div class="loading-bar-linear" ng-class="loading_class()"></div>\
                      <div class="info">Макс. объем 16 Мб</div>\
                     ',
            scope: {
              item: "=item",
              model: "=docfileDropUpload",
              field: '@field',
              thumbField: '@thumbField'
            },
            controller : ['$scope', '$element', controller]
          };
          function controller($scope, $element){
            $scope.loading = false;
            $scope.upload = function (file, ev) {
              $scope.loading = true;
              if(file == null) return false;
              if (!file.$error) {
                var upload_conf = {
                  url: $scope.item.$config.action == 'create' ? '/admin/api/' + $scope.model.model_slug : '/admin/api/' + $scope.model.model_slug + "/" + $scope.item.id,
                  method: $scope.item.$config.action == 'create' ? 'POST' : 'PUT',
                  data: {}
                };
                upload_conf.data[$scope.field] = file;
                upload_conf.data['format'] = 'json';

                Upload.upload(upload_conf)
                    .progress(function (evt) {
                      var progressPercentage = parseInt(100.0 * evt.loaded / evt.total);
                      setLoadingPercentage(progressPercentage);
                    })
                    .success(function (data, status, headers, config) {
                      $timeout(function() {
                        $scope.loading = false;
                        $scope.item.id = data.id;
                        if(data.hasOwnProperty("_id"))
                          $scope.item._id = data._id;
                        $scope.item.filesize = data.filesize;
                        $scope.item.mime_type = data.mime_type;
                        $scope.item.filename = data.filename;
                        $scope.item.name = data.name;
                        $scope.item.extension = data.extension;
                      });
                    });
              }
            };
            $scope.calcDragOverClass = function($event){
              return {
                size: {max: '16MB'},
                pattern: 'application/*',
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
              var $bar = angular.element($element).find(".loading-bar-linear");

              if (val < 0) { val = 0;}
              if (val > 100) { val = 100;}

              if(val == 100) {
                $scope.loading = false;
                $timeout(function() {
                  $bar.css({ width: "100%"});
                },500);
              }

              $bar.css({ width: val + "%"});
            }
          }
        }]
  )


})();