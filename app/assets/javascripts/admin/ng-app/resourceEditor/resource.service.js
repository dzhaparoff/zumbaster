(function(){
    "use strict";
    angular
        .module('admin')
        .service('Resource', Resource);

    Resource.$inject = ['Loading', '$http', '$q', '$compile', '$timeout'];

    function Resource(Loading, $http, $q, $compile, $timeout){
        this.name = 'Resource';
        this.loading = Loading.new(this.name);
        this.__private__.fill_providers(arguments);
    }

    var api_url = '/admin/api/';

    Resource.prototype = {
        constructor : Resource,
        index : function(resource) {
            var self = this;
            var result = self.__private__.providers.$q.defer();
            self.loading.loading_start(resource + '-loading');
            self.__private__.resolve_promise (
                self.__private__.get(api_url + resource),
                result,
                resource,
                self
            );
            return result.promise;
        },
        show : function (resource, id) {
            var self = this;
            var result = self.__private__.providers.$q.defer();
            self.loading.loading_start(resource + '-loading');
            self.__private__.resolve_promise (
                self.__private__.get(api_url + resource + '/' + id),
                result,
                resource,
                self
            );
            return result.promise;
        },
        update : function(resource, id, model){
            var self = this;
            var result = self.__private__.providers.$q.defer();
            self.loading.loading_start(resource + '-loading');
            self.__private__.resolve_promise (
                self.__private__.put(api_url + resource + '/' + id, model),
                result,
                resource,
                self
            );
            return result.promise;
        },
        __private__ : {
            providers : {},
            fill_providers : function(providers){
                var self = this;
                Resource.$inject.forEach(function(p, k){
                    self.providers[p] = providers[k]
                });
            },
            resolve_promise : function(promise, defer, resource, self){
                promise
                    .success(function(data){
                        defer.resolve(data);
                        self.loading.loading_stop(resource + '-loaded');
                    })
                    .error(function(error){
                        defer.reject(error);
                        self.loading.loading_stop(resource + '-loaded loading-error');
                    });
            },
            get : function (path) {
                return this.providers.$http.get(path);
            },
            post : function (path, params) {
                return this.providers.$http.post(path, params);
            },
            put : function (path, params) {
                return this.providers.$http.put(path, params);
            },
            delete : function (path) {
                return this.providers.$http.delete(path);
            }
        }
    }

})();