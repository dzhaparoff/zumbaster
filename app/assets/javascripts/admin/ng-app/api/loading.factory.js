(function(){
    "use strict";
    angular
        .module('admin')
        .factory('$loading',
        ['$timeout',
        function ($timeout) {

          function Loading(){
            var self = this;
            this.name = 'Loading Factory';
            this.active = false;
            this.mode = null;
            this.checkLoadingStatus = checkLoadingStatus;

            function checkLoadingStatus(){
              var loadings_count = 0;
              _.each(loading_objects, function (loading) {
                if(loading.loading) loadings_count++;
              });
              self.active = loadings_count > 0;
              if(self.active)
                self.mode = 'indeterminate';
              else
                self.mode = null;
            }
          }

          var loading_objects = [];

          var get_loading_object_key_by_name = function(name){
            return _.findIndex(loading_objects, function (i) {
              return i.name == name;
            });
          };

          Loading.prototype = {
            constructor : Loading,
            new : function(name){
              if(get_loading_object_key_by_name(name) > 0)
                return this.get(name);
              loading_objects.push(new LoadingPart(name, this));
              return this.get(name);
            },
            newProgressBar : function (name) {
              if(get_loading_object_key_by_name(name) > 0)
                return this.get(name);
              loading_objects.push(new ProgressPart(name, this));
              return this.get(name);
            },
            destroy : function(name){
              var k = get_loading_object_key_by_name(name);
              loading_objects.splice(k, 1);
              return true;
            },
            get : function (name) {
              return _.find(loading_objects, function(i){
                return i.name == name;
              })
            }
          };

          function ProgressPart(part_name, Loading_self) {
            this.name = part_name;
            this.mode = null;
            this.in_progress = false;
            this.loading = false;
            this.progress = 0;
            this.progress_max = 0;
            this.percentage = 0;
            this.emitter = Loading_self;
          }

          ProgressPart.prototype = {
            constructor : ProgressPart,
            setProgress : function(progress){
              this.mode = 'determinate';
              this.progress = parseInt(progress);
              this.__change();
            },
            setPercentage : function (percentage) {
              this.percentage = parseFloat(percentage);
              this.__change();
            },
            setProgressMax : function(max) {
              this.progress_max = parseInt(max);
              this.__change();
            },
            setCompleted : function(){
              this.progress = this.progress_max;
              this.percentage = 100;
              this.mode = null;
              this.__change();
            },
            __change : function(){
              this.in_progress = this.loading = (this.percentage < 100);
              this.emitter.checkLoadingStatus();
            }
          };

          function LoadingPart(part_name, Loading_self) {
            this.name = part_name;
            this.mode = null;
            this.class = 'loaded first-load';
            this.loading = false;
            this.emitter = Loading_self;
          }

          LoadingPart.prototype = {
            constructor : LoadingPart,
            in_progress    : 0,
            loadings_count : 0,
            loading_start : function(dop_class_string){
              this.mode = 'indeterminate';
              this.in_progress += 1;
              this.class = 'loading';
              this.loading = true;
              if(typeof dop_class_string !== 'undefined') {
                this.class += ' ' + dop_class_string;
              }
              this.emitter.checkLoadingStatus();
            },
            loading_stop : function(dop_class_string){
              this.in_progress -= 1;
              if(this.in_progress < 1) {
                this.in_progress = 0;
                this.class = 'loaded';
                if(this.loadings_count < 2)
                  this.class += ' first-load';
                this.loading = false;
                this.mode = null;

                if(typeof dop_class_string !== 'undefined') {
                  this.class += ' ' + dop_class_string;
                }
              }
              this.loadings_count += 1;

              this.emitter.checkLoadingStatus();
            }
          };

          return new Loading;
        }]);
})();