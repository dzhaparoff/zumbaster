(function(){
    "use strict";
   angular
        .module('zumbaster')
        .directive('videoplayer', videoplayer);

    function videoplayer(){

        function Playlists(id){
            this.id = id;
            this.getPlaylists();
        }

        Playlists.prototype = {
            constructor : Playlists,
            getPlaylists : function () {
                var id = this.id;
                this.mobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)
                var type = this.mobile ? "m3u8" : "f4m";
                this.manifest = 'http://192.168.1.200:3000/api/manifest/' + id + '.' + type;
            }
        };

        return {
            scope : {
                id : '@videoplayer'
            },
            link : function(scope, elem, attr){

              var playlist = new Playlists(scope.id);
              var player;

              if(playlist.mobile)
                elem.append('<video controls src="' + playlist.manifest + '"></video>');
              else
                construct_player(playlist.manifest);

              console.log(playlist.manifest)

              //elem.parent().remove();

              function onJSBridge(a,e,l){
                console.log(a,e,l);
              }

              function construct_player(manifest) {
                var flashvars = {
                  src: encodeURIComponent(manifest),
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
                swfobject.embedSWF("/system/swf/player.swf", name, "854", "480", "10.2", null, flashvars, params, attrs);

              }

            }
        }
    }
})();