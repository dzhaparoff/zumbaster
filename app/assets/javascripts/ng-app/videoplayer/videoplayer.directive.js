(function(){
    "use strict";
   angular
        .module('zumbaster')
        .directive('videoplayer', videoplayer);

    videoplayer.$inject = ['$http', '$q', '$timeout'];

    function videoplayer($http, $q, $timeout){

        function Playlists(id){
            this.id = id;
            this.getPlaylists($http, $q);
        }

        Playlists.prototype = {
            constructor : Playlists,
            getPlaylists : function ($http, $q) {
                var id = this.id;
                var q = $q.defer();
                var self = this;
                $http.get('/api/player_playlists_for?id='+id)
                    .success(function (d) {
                        self.f4m = d.f4m;
                        self.m3u8 = d.m3u8;
                        q.resolve();
                    })
                    .error(function(error){
                        q.reject(error);
                    });
                this.promise = q.promise;
            }
        };

        return {
            scope : {
                id : '@videoplayer'
            },
            link : function(scope, elem, attr){

                var playlist = new Playlists(scope.id);
                var player;

                playlist.promise.then(function(){
                    construct_player();
                });

                function construct_player() {
                    var flashvars = {
                        src: playlist.f4m,
                        autoPlay: false,
                        javascriptCallbackFunction: "onJSBridge"
                    };
                    var name = "player_" + scope.id;
                    var params = {
                        allowFullScreen: true, allowScriptAccess: "always", bgcolor: "#000000"
                    };
                    var attrs = {
                        name: name
                    };
                    swfobject.embedSWF("/system/swf/player.swf?v=1", name, "854", "480", "10.2", null, flashvars, params, attrs);

                }
            }
        }
    }
})();