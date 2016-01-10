"use strict"

validateUsernameExist = ($q) ->
  require: 'ngModel',
  restrict: 'AC',
  link: ( scope, elem, attr, ngModel ) ->
    console.error('model object missing in directive scope') if typeof scope.editor.model == 'undefined'
    ngModel.$asyncValidators.exist = (value) ->
      defer = $q.defer()
      scope.editor.model.$api.$get('check_username', {username: value}).success (d) ->
        if !d.exist
          defer.resolve()
        else
          delete scope.login
          defer.reject()
        defer
      defer.promise

validateEmailExist = ($q) ->
  require: 'ngModel',
  restrict: 'AC',
  link: ( scope, elem, attr, ngModel ) ->
    console.error('model object missing in directive scope') if typeof scope.editor.model == 'undefined'
    ngModel.$asyncValidators.exist = (value) ->
      defer = $q.defer()
      scope.editor.model.$api.$get('check_email', {email: value}).success (d) ->
        if !d.exist
          defer.resolve()
        else
          delete scope.login
          defer.reject()
        defer
      defer.promise

validatePassword = ->
  require: 'ngModel',
  restrict: 'AC',
  link: (scope, elem, attr, ngModel) ->
    ngModel.incorrect_part = {};
    ngModel.$validators.correct = (modelValue, viewValue) ->
      value = modelValue || viewValue;
      correct_numeric      =  /[0-9]+/.test(value);
      correct_letter_small =  /[a-z]+/.test(value);
      correct_letter_big   =  /[A-Z]+/.test(value);
      correct_non_letter   =  /\W+/.test(value);

      ngModel.incorrect_part.numeric      = !correct_numeric
      ngModel.incorrect_part.letter_small = !correct_letter_small
      ngModel.incorrect_part.letter_big   = !correct_letter_big
      ngModel.incorrect_part.non_letter   = !correct_non_letter

      correct_numeric && correct_letter_small && correct_letter_big && correct_non_letter;


angular
.module 'admin'
.directive 'validateUsernameExist', ['$q', validateUsernameExist]
.directive 'validateEmailExist', ['$q', validateEmailExist]
.directive 'validatePassword', validatePassword
