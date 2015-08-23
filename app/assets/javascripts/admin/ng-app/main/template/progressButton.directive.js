(function(){
    "use strict";
    angular
        .module('admin')
        .directive('progressButton', progressButton);

    progressButton.$inject = ['$timeout'];

    function progressButton($timeout){
        return {
            restrict : "AE",
            scope : {
                progress : "=progressButton",
                title : "@title",
                click : "&",
                class : "@"
            },
            template :
                '<button ' +
                'class="progress-button {{class}}" ' +
                'data-ng-class="progressClass()"' +
                'data-ng-click="click()"' +
                '>' +
                    '<span>{{title}}</span>' +
                    '<span ' +
                        'data-ng-if="inProgress()" ' +
                        'class="progress">' +
                        '<span class="bar" style="width: {{progress.status.percentage}}%"></span>' +
                    '</span>' +
                '</button>',
            link : function(scope){
                scope.progressClass = progressClass;
                scope.inProgress = inProgress;

                var in_progress = false;

                function inProgress(){
                    if(!_.isObject(scope.progress)) return false;
                    if(scope.progress.status.in_progress)
                        in_progress = true;
                    else
                        $timeout(function(){
                            in_progress = false;
                        },500);
                    return in_progress;
                }

                function progressClass(){
                    var _class = [];
                    if(_.isObject(scope.progress))
                    {
                        if(inProgress()) {
                            _class.push('in-progress');
                            switch (true) {
                                case scope.progress.status <= 33 : _class.push('progress-starting'); break;
                                case scope.progress.status  > 33 : _class.push('progress-middle'); break;
                                case scope.progress.status <= 66 : _class.push('progress-ending'); break;
                            }
                        }
                        else
                            _class.push('progress-completed');
                    }
                    else {
                        _class.push('not-in-progress');
                    }
                    return _class.join(' ')
                }
            }
        }
    }
})();