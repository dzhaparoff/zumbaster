(function(){
    "use strict";
    angular
        .module('admin')
        .factory('Api', ApiFactory);

    ApiFactory.$inject = ['Loading', '$http', '$q', '$compile', '$timeout'];

    function ApiFactory(Loading, $http, $q, $compile, $timeout){

        function Api(){
            this.name = 'Api';
            this.api_ver = '1.0';
            this.loading = {};
            this.progress = {};
        }

        var api_url = '/admin/api/';

        Api.prototype = {
            constructor : Api,
            action : function(method, controller, action, params){
                var self = this;
                var result = $q.defer();
                var loading_id = controller + '_' + action;

                if(!this.loading.hasOwnProperty(loading_id))
                    this.loading[loading_id] = Loading.new(loading_id);

                if(typeof params !== 'undefined') {
                    if(method == 'get')
                        params = {
                            params: params
                        };
                }
                else
                    params = {};
                self.loading[loading_id].loading_start();
                self.__resolve_promise (
                    self['__' + method](controller + '/' + self.api_ver + '/' + action, params),
                    result,
                    loading_id
                );
                return result.promise;
            },
            __resolve_promise : function(promise, defer, loading_id){
                var self = this;
                promise
                    .success(function(data){

                        if( data.hasOwnProperty('job')){
                            defer.resolve(data.model);
                            self.progress[loading_id] = self.__checkJobStatus(data.job.id);
                        }
                        else
                            defer.resolve(data);

                        self.loading[loading_id].loading_stop();
                    })
                    .error(function(error){
                        defer.reject(error);
                        self.loading[loading_id].loading_stop('loading-error');
                    });
            },
            __checkJobStatus : function(id){
                var self = this;
                var progress_bar = Loading.newProgressBar('progress-job-' + id);
                $timeout(function(){
                    $http.get('/progress-job/' + id)
                        .success(function (d) {
                            progress_bar.setProgress(d.progress_current);
                            progress_bar.setPercentage(d.percentage);
                            progress_bar.setProgressMax(d.progress_max);
                            self.__checkJobStatus(id)
                        })
                        .error(function () {
                            Loading.destroy('progress-job-' + id);
                        })
                },100);
                return {
                    status : progress_bar
                }
            },
            __get : function (method, params) {
                return $http.get(api_url + method, params);
            },
            __post : function (method, params) {
                return $http.post(api_url + method, params);
            },
            __put : function (method, params) {
                return $http.put(api_url + method, params);
            },
            __delete : function (method) {
                return $http.delete(api_url + method);
            }
        };

        return new Api();
    }

})();