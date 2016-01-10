(function(){
  "use strict";

  angular
      .module('admin')
      .factory('API', ['$http', '$q', '$compile', '$interval', '$loading', '$resource', '$locale', ApiFactory]);

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

  function toQueryString(obj) {
    var parts = [];
    for (var i in obj) {
      if (obj.hasOwnProperty(i)) {
        parts.push(encodeURIComponent(i) + "=" + encodeURIComponent(obj[i]));
      }
    }
    return '?' + parts.join("&");
  }

  function ApiFactory($http, $q, $compile, $interval, $loading, $resource, $locale){
    var api_url = '/admin/api/:locale/';

    function Api(){
      this.name = 'Api';
      this.resource = Resource;
    }

    function getLocale(){
      return $locale.active;
    }

    function get_api_url(action){
      return api_url.replace(':locale', getLocale()) + action
    }

    function ApiInterface(resource_name){
      var self = this;
      var loading_id = resource_name + ":" + 'api';
      self.loading = $loading.new(loading_id);
    }

    ApiInterface.prototype = {
      constructor : ApiInterface,
      $get : function(action, data){
        var u = get_api_url(action);
        if(typeof data !== 'undefined') u = u + toQueryString(data);
        return this.$$request_loading($http.get(u));
      },
      $post : function(action, data){
        var u = get_api_url(action);
        return this.$$request_loading($http.post(u, data));
      },
      $put : function(action, data){

      },
      $delete : function(action){
        var u = get_api_url(action);
        return this.$$request_loading($http.delete(u));
      },
      $$request_loading : function(request){
        var self = this;
        self.loading.loading_start();
        request.then(function(){
          self.loading.loading_stop();
        });
        return request;
      }
    };


    function Resource(resource){
      var self = this;
      self.init();
      self.resource_name = resource;
      self.resource = $resource(
          api_url + resource + '/:id',
          {format: '.json', id: '@id', locale: getLocale},
          {
            query : {
              method: 'GET', transformRequest: self.$$beforeSend('query'), transformResponse: self.$$afterSend('query'), isArray: true
            },
            get   : {
              method: 'GET', transformRequest: self.$$beforeSend('get'), transformResponse: self.$$afterSend('get')
            },
            new : {
              method: 'GET', url: api_url + resource + '/new', transformRequest: self.$$beforeSend('new'), transformResponse: self.$$afterSend('new')
            },
            create : {
              method: 'POST', url: api_url + resource, transformRequest: self.$$beforeSend('create'), transformResponse: self.$$afterSend('create')
            },
            update : {
              method: 'PUT', transformRequest: self.$$beforeSend('update'), transformResponse: self.$$afterSend('update')
            }
          }
      );
      self.$api = new ApiInterface(resource);
    }

    Resource.prototype = {
      constructor : Resource,
      init : function(){
        this.loading = {};
        this.progress = {};
        this.model_name = "";
        this.model_slug = "";
        this.$columns_list = {};
        this.$system_columns = [];
        this.$enum = {};
        this.index = {};
      },
      enum_label : function(k, i){
        var value = k,
            self = this;
        if(self.$enum.hasOwnProperty(i)){
          value = _.filter(self.$enum[i], function(item){
            return (item.enum == k)
          })[0];
          if(typeof value === 'undefined') {
            value = k;
          }
          else {
            value = value.label;
          }
        }
        return value;
      },
      $addToIndex : function(item){
        this.index.push(item);
      },
      $removeFromIndex : function(item){
        var self = this;
        _.each(self.index, function(i, key){
          if(typeof i == 'undefined') return false;
          if(_.isEqual(i.id, item.id)) {
            self.index.splice(key,1);
          }
        });
      },
      $updateIndex : function(item){
        if($locale.active !== 'ru') {
          this.index = this.resource.query();
          return true;
        }
        var self = this;
        _.each(self.index, function(i, key){
          if(_.isEqual(i.id, item.id)) {
            shallowClearAndCopy(item, self.index[key]);
          }
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
        if(!_.isUndefined(json_object.$config.enum))
          self.$enum = json_object.$config.enum;
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