var onJSBridge, setQualityLabels, flashPlayer, onPlayerEvent, setupPlayerGUI, onPlayerPlaybackTimeChangedEvent;


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
        this.mobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
        var type = this.mobile ? "m3u8" : "f4m";
        if(typeof location.origin == 'undefined') location.origin = 'http://hd-serials.tv';
        this.manifest = location.origin + '/api/manifest/' + id + '.' + type;
      }
    };

    return {
      scope : {
        id : '@videoplayer',
        title : '@title',
        subtitles : '@'
      },
      link : function(scope, elem, attr){

        console.log(scope.title);

        var playlist = new Playlists(scope.id);

        function construct_player(manifest) {
          var subtitles;

          if(typeof scope.subtitles != 'undefined') {
            subtitles = JSON.stringify({
              subtitles: [ {
                src: scope.subtitles,
                label: "Russian",
                language: "ru"
              }],
              config: {
                fontSize: 0.035,
                minFontSize: 14,
                maxFontSize: 36,
                textColor: 0xDFDFDF,
                bgColor: 0x101010,
                bgAlpha: 0.65
              }
            });
          }

          var buffer_time = 30;

          var name = "player_" + scope.id;

          var flash_vars = {
            src: encodeURIComponent(manifest),
            volumeInfoPattern: encodeURI("Звук $$%"),
            volumeInfoMutedString: "Звук выключен",
            emptyBufferTime: 4,
            expandedBufferTime: buffer_time,
            autoPlay: false,
            javascriptCallbackFunction: "onJSBridge",
            qualityLabelsFunction: "setQualityLabels",
            controlBarAutoHideTimeout: 8,
            autoRewind: false,
            "src_http://kutu.ru/osmf/plugins/subtitles": encodeURIComponent(subtitles)
          };

          if(typeof scope.subtitles != 'undefined') {
            flash_vars.subtitles = encodeURIComponent(JSON.stringify({
              subtitles: [{
                url: scope.subtitles,
                label: "Russian"
              }],
              config: {
                fontSize: 20,
                textColor: 0xDFDFDF,
                bgColor: 0x101010,
                bgAlpha: 0.65
              }
            }));
          }

          var params = {
            wmode: "opaque",
            allowFullScreen: true,
            allowScriptAccess: "always"
          };

          var attrs = {
            name: name
          };

          var player_url = '/system/swf/player_base.swf';
          swfobject.embedSWF(player_url, name, "854", "480", "10.2", null, flash_vars, params, attrs);
        }

        onJSBridge = function(playerId, event, data){
          switch(event)
          {
            case "onJavaScriptBridgeCreated":
              flashPlayer = document.getElementById(playerId);
              addPlayerListeners();
              setupPlayerGUI();
              break;
          }
        };

        setQualityLabels = function(tracks) {
          for (var i in tracks) {
            var track = tracks[i];

            switch (track.width) {
              case 1920:
                track.label = "1080";
                break;

              case 1280:
                track.label = "720";
                break;

              case 854:
                track.label = "480";
                break;

              case 640:
                track.label = "360";
                break;

              default:
                track.label = track.height;
                break;
            }
          }

          return tracks;
        }

        function addPlayerListeners()
        {
          // flashPlayer.addEventListener("fragDownloadComplete", "onPlayerEvent");
          flashPlayer.addEventListener("playbackStateChanged", "onPlayerEvent");
          // flashPlayer.addEventListener("playbackTimeChanged", "onPlayerEvent");
          flashPlayer.addEventListener("playbackTimeChanged", "onPlayerPlaybackTimeChangedEvent");
          // flashPlayer.addEventListener("playbackDurationChanged", "onPlayerEvent");
          // flashPlayer.addEventListener("seekingChanged", "onPlayerEvent");
          // flashPlayer.addEventListener("bufferingChanged", "onPlayerEvent");
        }

        var old_event = '';

        onPlayerEvent = function()
        {
          if(typeof window.ga !== 'undefined') {
            if(arguments[1] == 'playing' && old_event == 'ready') {
              ga('send', 'event', 'TV Shows', 'play', scope.title);
            }
            if(arguments[1] == 'finished') {
              ga('send', 'event', 'TV Shows', 'finish', scope.title);
            }
          }
          old_event = arguments[1];
        };

        var old_heartbeat_mark = 60 * 5;

        onPlayerPlaybackTimeChangedEvent = function(player_id , playback){
          if(typeof window.ga !== 'undefined' && playback.time > old_heartbeat_mark ) {
            console.log('heartbeat', playback);
            ga('send', 'event', 'TV Shows', 'playing-heartbeat', scope.title, parseInt(playback.time));
            old_heartbeat_mark += (60 * 5)
          }
        };

        setupPlayerGUI = function() {
          var default_layout = {
            "items": [
              {
                "id": "video"
              },
              {
                "vertical-alignment": "top",
                "margin-right": 5,
                "horizontal-alignment": "right",
                "id": "full_screen_volume_label",
                "margin-top": 5
              },
              {
                "horizontal-alignment": "middle",
                "id": "subtitles_label",
                "margin-bottom": 70,
                "vertical-alignment": "bottom"
              },
              {
                "style": "buffering",
                "id": "buffering"
              },
              {
                "style": "control_bar",
                "margin-left": 5,
                "items": [
                  {
                    "width": 38,
                    "items": [
                      {
                        "style": "default",
                        "x": 0,
                        "height": 30,
                        "y": 0,
                        "width": 38,
                        "id": "play_button"
                      },
                      {
                        "style": "default",
                        "x": 0,
                        "height": 30,
                        "y": 0,
                        "width": 38,
                        "id": "pause_button"
                      }
                    ],
                    "items-layout": "absolute",
                    "id": "left",
                    "height": 30
                  },
                  {
                    "items": [
                      {
                        "style": "default",
                        "id": "progress_bar",
                        "height": 30
                      },
                      {
                        "x": 25,
                        "vertical-alignment": "middle",
                        "id": "time_label",
                        "y": 5
                      }
                    ],
                    "items-layout": "absolute",
                    "height": 30,
                    "margin-left": 5,
                    "margin-right": 5,
                    "id": "central"
                  },
                  {
                    "id": "right",
                    "items": [
                      {
                        "style": "volume_background",
                        "horizontal-alignment": "center",
                        "items-layout": "absolute",
                        "height": 30,
                        "width": 66,
                        "id": "volume_control"
                      },
                      {
                        "style": "default",
                        "width": 44,
                        "id": "quality_button",
                        "height": 30
                      },
                      {
                        "style":"subtitles_style",
                        "width":44,
                        "id":"subtitles_button",
                        "height":30
                      },
                      {
                        "style": "default",
                        "width": 44,
                        "id": "full_screen_button",
                        "height": 30
                      }
                    ]
                  }
                ],
                "vertical-alignment": "bottom",
                "margin-right": 5,
                "margin-bottom": 5,
                "id": "controlbar"
              }
            ],
            "items-layout": "absolute"
          };

          var player_controls_background_color,
              player_default_background,
              player_current_background,
              player_progress_background,
              player_buffered_background,
              player_volume_background,
              player_controls_hover_background;

          player_controls_background_color = '#333333';
          player_progress_background = '#333333';
          player_current_background = '#444444';
          player_buffered_background = '#333333';
          player_default_background = '#222222';
          player_volume_background = '#555555';
          player_controls_hover_background = '#eeeeee';

          var default_style = {
            "containers": {
              "control_bar": {
                "starts-hidden": true,
                "hide-time": 300,
                "auto-hide-timeout": 3500
              },
              "progress_bar_play_head": {
                "background-color": player_current_background,
                "background-opacity": 1
              },
              "volume_background": {
                "background-color": player_controls_background_color,
                "background-opacity": 1
              },
              "menu": {
                "background-color": player_controls_background_color,
                "background-opacity": 1
              },
              "time_hint": {
                "background-color": player_controls_background_color,
                "background-opacity": 1
              },
              "volumeBar_active": {
                "background-color": 16777215,
                "background-opacity": 1
              },
              "volumeBar_background": {
                "background-color": player_volume_background,
                "background-opacity": 1
              },
              "progress_bar_buffered_track": {
                "background-color": player_buffered_background,
                "background-opacity": 1
              },
              "buffering": {
                "background-color": player_buffered_background,
                "background-opacity": 1
              },
              "progress_bar_played_track": {
                "background-color": player_progress_background,
                "background-opacity": 1
              },
              "default": {
                "background-color": player_default_background,
                "background-opacity": 1
              }
            },
            "buttons": {
              "default": {
                "up": {
                  "background-opacity": 1,
                  "icon-color": '#dddddd',
                  "background-color": player_controls_background_color
                },
                "over": {
                  "background-opacity": 1,
                  "icon-color": player_controls_background_color,
                  "background-color": player_controls_hover_background
                },
                "active": {
                  "background-opacity": 1,
                  "icon-color": player_controls_background_color,
                  "background-color": '#2788BE'
                },
                "down": {
                  "background-opacity": 0.5,
                  "icon-color": player_controls_background_color,
                  "background-color": player_controls_hover_background
                }
              },
              "subtitles_style": {
                "up": {
                  "background-opacity": 1,
                  "icon-color": '#dddddd',
                  "background-color": player_controls_background_color
                },
                "over": {
                  "background-opacity": 1,
                  "icon-color": player_controls_background_color,
                  "background-color": player_controls_hover_background
                },
                "active": {
                  "background-opacity": 1,
                  "icon-color": '#dddddd',
                  "background-color": '#222222'
                },
                "down": {
                  "background-opacity": 0.5,
                  "icon-color": '#bb3333',
                  "background-color": '#bb3333'
                }
              }
            }
          };

          // flashPlayer.setLayout(default_layout);
          // flashPlayer.setStyle(default_style);
        };


        if(playlist.mobile)
          elem.append('<video controls src="' + playlist.manifest + '"></video>');
        else
          construct_player(playlist.manifest);

      }
    }
  }
})();