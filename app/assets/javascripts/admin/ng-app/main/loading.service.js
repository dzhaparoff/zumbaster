(function(){
    "use strict";
    angular
        .module('admin')
        .service('Loading', Loading);

    Loading.$inject = ['$timeout'];

    function Loading(){
        this.name = 'Loading'
    }

    Loading.prototype = {
        constructor : Loading,
        new : function(name){
            if(this.__private__.get_loading_object_key_by_name(name) > 0)
                return this.get(name);
            this.__private__.loading_objects.push(new LoadingPart(name));
            return this.get(name);
        },
        newProgressBar : function (name) {
            if(this.__private__.get_loading_object_key_by_name(name) > 0)
                return this.get(name);
            this.__private__.loading_objects.push(new ProgressPart(name));
            return this.get(name);
        },
        destroy : function(name){
            var k = this.__private__.get_loading_object_key_by_name(name);
            delete this.__private__.loading_objects[k];
            return true;
        },
        get : function (name) {
            return _.find(this.__private__.loading_objects, function(i){
                return i.name == name;
            })
        },
        __private__ : {
            loading_objects : [],
            get_loading_object_key_by_name : function(name){
                var self = this;
                return _.findIndex(self.loading_objects, function (i) {
                    return i.name == name;
                });
            }
        }
    };

    function ProgressPart(part_name) {
        this.name = part_name;
        this.in_progress = false;
        this.progress = 0;
        this.progress_max = 0;
        this.percentage = 0;
    }

    ProgressPart.prototype = {
        constructor : ProgressPart,
        setProgress : function(progress){
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
        __change : function(){
            this.in_progress = (this.percentage < 100);
        }
    }

    function LoadingPart(part_name) {
        this.name = part_name;
        this.class = 'loaded first-load';
        this.loading = false;
    }

    LoadingPart.prototype = {
        constructor : LoadingPart,
        loading_start : function(dop_class_string){
            this.__private__.loading_start(dop_class_string, this);
        },
        loading_stop : function(dop_class_string){
            this.__private__.loading_stop(dop_class_string, this);
        },
        __private__ : {
            in_progress    : 0,
            loadings_count : 0,
            loading_start  : function(dop_class_string, self){
                this.in_progress += 1;
                self.class = 'loading';
                self.loading = true;

                if(typeof dop_class_string !== 'undefined') {
                    self.class += ' ' + dop_class_string;
                }
            },
            loading_stop : function(dop_class_string, self){
                this.in_progress -= 1;
                if(this.in_progress < 1) {
                    self.class = 'loaded';
                    if(this.loadings_count < 2)
                        self.class += ' first-load';
                    self.loading = false;

                    if(typeof dop_class_string !== 'undefined') {
                        self.class += ' ' + dop_class_string;
                    }
                }
                this.loadings_count += 1;
            }
        }
    }


})();