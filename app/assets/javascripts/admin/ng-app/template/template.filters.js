(function(){
  "use strict";
  angular
      .module('admin')
      .filter('nospace', function () {
        return function (value) {
          return (!value) ? '' : value.replace(/ /g, '');
        };
      })
      .filter('humanizeDoc', function() {
        return function(doc) {
          if (!doc) return;
          if (doc.type === 'directive') {
            return doc.name.replace(/([A-Z])/g, function($1) {
              return '-'+$1.toLowerCase();
            });
          }
          return doc.label || doc.name;
        };
      })
      .filter('humanizeDate', function() {
        return function(date) {
          if (!date) return;
          var date = moment(date, moment.ISO_8601);
          moment.locale('ru');
          date.local();
          if(moment().diff(date,'days') <= 2)
            return date.fromNow();
          else
            return date.format('Do MMMM YYYY H:mm:ss');
        };
      })
      .filter('directiveBrackets', function() {
        return function(str) {
          if (str.indexOf('-') > -1) {
            return '<' + str + '>';
          }
          return str;
        };
      })
      .filter('filesize', function(){
        return function(str) {
          var n = +str;
          if(n > 1000 && n < 1000000) return "~ " + (n/1000).toFixed(1) + " КБ";
          if(n >= 1000000) return "~ " + (n/1000000).toFixed(1) + " МБ";
        }
      })
})();