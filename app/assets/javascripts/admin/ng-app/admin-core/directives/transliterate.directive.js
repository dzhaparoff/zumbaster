(function(){
  "use strict";

  var a = {"Ё":"YO","Й":"I","Ц":"TS","У":"U","К":"K","Е":"E","Н":"N","Г":"G","Ш":"SH","Щ":"SCH","З":"Z","Х":"H","Ъ":"'","ё":"yo","й":"i","ц":"ts","у":"u","к":"k","е":"e","н":"n","г":"g","ш":"sh","щ":"sch","з":"z","х":"h","ъ":"'","Ф":"F","Ы":"I","В":"V","А":"a","П":"P","Р":"R","О":"O","Л":"L","Д":"D","Ж":"ZH","Э":"E","ф":"f","ы":"i","в":"v","а":"a","п":"p","р":"r","о":"o","л":"l","д":"d","ж":"zh","э":"e","Я":"Ya","Ч":"CH","С":"S","М":"M","И":"I","Т":"T","Ь":"'","Б":"B","Ю":"YU","я":"ya","ч":"ch","с":"s","м":"m","и":"i","т":"t","ь":"'","б":"b","ю":"yu"};

  function _transliterate(word){
    if(word != null)
    return word.split('')
        .map(function (char) {
          return a[char] || char;
        })
        .join("")
        .toLowerCase()
        .replace(/[^\w ]+/g,'')
        .replace(/ +/g,'-');
    else return null
  }

  angular
      .module('adminCore')
      .directive('transliterate',
        function(){
          return {
            restrict : 'AE',
            require : 'ngModel',
            scope: {
              bindTo : "=",
              transliterate : "=",
              value : "=ngModel"
            },
            link : postLink
          };
          function postLink(scope, element, attrs, ngModel){
            var watch = false;
            scope.$watch('value', function(v){
              if(scope.value != _transliterate(scope.bindTo))
                scope.transliterate = false;
              if(!watch)
                addWatcher();
            });

            scope.$watch('transliterate', function(v,o){
              if(v && !o) {
                ngModel.$viewValue = _transliterate(scope.bindTo);
                element.val(ngModel.$viewValue);
                ngModel.$commitViewValue();
              }
            });

            function addWatcher(){
              watch = true;
              scope.$watch('bindTo', function(v){
                if(scope.transliterate !== false){
                  if(v)
                    ngModel.$viewValue = _transliterate(v);
                  else
                    ngModel.$viewValue = "";
                  element.val(ngModel.$viewValue);
                  ngModel.$commitViewValue();
                }
              });
            }
          }
        }
      )


})();