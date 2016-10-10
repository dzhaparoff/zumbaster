(function(){
  "use strict";

  var _extend = angular.extend;
  var _copy = angular.copy;

  angular
      .module('adminCore')
      .provider('$locale', [$locale]);

  function $locale(){

    var _locales;

    function Locales(){
      this.init();
    }

    if(!String.prototype.hasOwnProperty('capitalize'))
      String.prototype.capitalize = function(){
        return this.charAt(0).toUpperCase() + this.slice(1);
      };

    Locales.prototype.init = function(){
      var self = this;
      self.locales = _locales;
      self.$scope = null;
      _.forEach(_locales, function(locale){
        if(document.body.lang == locale){
          self[locale] = true;
          self.active = locale;
        }
        else {
          self[locale] = false;
        }
      });
    };

    Locales.prototype.assign_scope = function(scope){
      this.$scope = scope;
    };

    Locales.prototype.change_locale = function(locale){
      var self = this;
      document.body.lang = locale;
      _.forEach(_locales, function(l){
        self[l] = false;
      });
      this[locale] = true;
      this.active = locale;
      if(self.$scope !== null){
        self.$scope.$broadcast('locale:change', locale);
      }
    };

    return {
      $get : function(){
        if(typeof this.locales == 'undefined')
          console.error('LocaleProvider not built!');
        return this.locales;
      },
      build: function(locales){
        _locales = locales;
        this.locales = new Locales();
      }
    }
  }
})(window, window.angular);