(function(){
  "use strict";
  angular
      .module('admin')
      .factory('API', ApiFactory);

  ApiFactory.$inject = ['$http', '$q', '$compile', '$interval', '$loading', '$resource'];

  function ApiFactory($http, $q, $compile, $interval, $loading, $resource){
    var api_url = '/admin/api/';

    function Api(){
      this.name = 'Api';
      this.resource = Resource;
    }

    function shallowClearAndCopy(src, dst) {
      dst = dst || {};

      angular.forEach(dst, function(value, key) {
        delete dst[key];
      });

      for (var key in src) {
        if (src.hasOwnProperty(key) && !(key.charAt(0) === '$' && key.charAt(1) === '$')) {
          dst[key] = src[key];
        }
      }

      return dst;
    }

      function Resource(resource){
        var self = this;
        self.resource_name = resource;
        self.loading = {};
        self.progress = {};
        self.resource = $resource(
            api_url + resource + '/:id',
            {format: '.json', id: '@id'},
            {
              query : {
                method: 'GET', transformRequest: self.$$beforeSend('query'), transformResponse: self.$$afterSend('query'), isArray: true
              },
              get   : {
                method: 'GET', transformRequest: self.$$beforeSend('get'), transformResponse: self.$$afterSend('get')
              },
              update : {
                method: 'PUT', transformRequest: self.$$beforeSend('update'), transformResponse: self.$$afterSend('update')
              }
          }
        );
      }

      Resource.prototype = {
        constructor : Resource,
        model_name : "",
        model_slug : "",
        $columns_list : {},
        $system_columns : [],
        $updateIndex : function(index, item){
          _.each(index, function(i, key){
            if(i.id == item.id)
              shallowClearAndCopy(item, index[key]);
          });
        },
        $$beforeSend : function(loading_part){
          var self = this;
          return function(data){
            var loading_id = self.resource_name + ":" + loading_part;
            if(!self.loading.hasOwnProperty(loading_id))
              self.loading[loading_id] = $loading.new(loading_id);
            self.loading[loading_id].loading_start(self.resource_name + '-loading');
            return angular.toJson(data);
          }
        },
        $$afterSend : function(loading_part){
          var self = this;
          return function(data){
            var loading_id = self.resource_name + ":" + loading_part;

            if( data.hasOwnProperty('job') ){
              self.__checkJobStatus(data.job.id, loading_id);
            }

            var json_object = angular.fromJson(data);
            if(json_object.hasOwnProperty('$config'))
              self.$$fillConfig(json_object);

            if(loading_part == 'query')
              json_object = json_object.items;

            self.loading[loading_id].loading_stop();

            return json_object
          }
        },
        $$fillConfig : function(json_object){
          var self = this;
          self.$columns_list   = json_object.$config.columns_list;
          self.$system_columns = json_object.$config.system_columns;
          if(self.model_name == "" && !_.isUndefined(json_object.$config.names))
            self.model_name = json_object.$config.names.model_name;
          if(self.model_slug == "" && !_.isUndefined(json_object.$config.names))
          self.model_slug = json_object.$config.names.model_slug;
          //delete json_object.$config;
        },
        __checkJobStatus : function(id, loading_id){
          var self = this;
          if(!self.progress[loading_id].hasOwnProperty('in_progress'))
            self.progress[loading_id] = $loading.newProgressBar('progress-job-' + id);

          var checking_interval = $interval(function(){
            $http.get('/progress-job/' + id)
                .success(function (d) {
                  self.progress[loading_id].setProgress(d.progress_current);
                  self.progress[loading_id].setPercentage(d.percentage);
                  self.progress[loading_id].setProgressMax(d.progress_max);
                })
                .error(function () {
                  self.progress[loading_id].setCompleted();
                  $interval.cancel(checking_interval);
                  checking_interval = undefined;
                })
          },100);
        }
    };

    return new Api();
  }

})();