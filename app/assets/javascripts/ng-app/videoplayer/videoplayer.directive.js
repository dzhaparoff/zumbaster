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

                    if(playlist.f4m !== null){
                      if( /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) )
                        elem.append('<video controls src="' + playlist.m3u8 + '"></video>');
                      else
                        construct_player();
                    }
                    else
                        elem.parent().remove();

                });

                function onJSBridge(a,e,l){
                    console.log(a,e,l);
                }

                function construct_player() {
                    var flashvars = {
                        src: playlist.f4m,
                        autoPlay: false,
                        javascriptCallbackFunction: onJSBridge
                    };
                    var name = "player_" + scope.id;
                    var params = {
                        allowFullScreen: true, allowScriptAccess: "always", bgcolor: "#000000"
                    };
                    var attrs = {
                        name: name
                    };
                    console.log('player.init', name, flashvars, params, attrs);
                    swfobject.embedSWF("/system/swf/player.swf?v=2", name, "854", "480", "10.2", null, flashvars, params, attrs);

                }
            }
        }
    }
})();