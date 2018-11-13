/** This is an example on how to override javascript files.
  * To override check the web/pom.xml file in maven-war-plugin config */

(function() {
  goog.provide('gn_locale');
  goog.require('gn_cat_controller');

  var module = angular.module('gn_locale', [
    'pascalprecht.translate',
    'angular-md5',
    'gn_cat_controller'
  ]);

  module.constant('$LOCALE_MAP', function(threeCharLang) {
    var specialCases = {
      'spa' : 'es',
      'ger' : 'de',
      'bra' : 'pt_BR',
      'swe' : 'sv',
      'tur' : 'tr',
      'por' : 'pt',
      'gre' : 'el',
      'per' : 'fa',
      'chi' : 'zh',
      'pol' : 'pl',
      'wel' : 'cy',
      'dut' : 'nl',
      'ice' : 'is',
      'ita' : 'it'
    };
    var lang = specialCases[threeCharLang];
    if (angular.isDefined(lang)) {
      return lang;
    }

    return threeCharLang.substring(0, 2) || 'en';
  });
  module.constant('$LOCALES', ['core']);

  module.factory('localeLoader', [
    '$http', '$q', 'gnLangs', '$translate', '$timeout',
    function($http, $q, gnLangs, $translate, $timeout) {
      return function(options) {

        function buildUrl(prefix, lang, value, suffix) {
          if (value.indexOf('/') === 0) {
            return value.substring(1);
          } else if (value.indexOf('|') > -1) {
            /* Allows to configure locales for custom views,
               providing the path and the locale type
               separated by a |:

             module.config(['$LOCALES', function($LOCALES) {
              $LOCALES.push('../../catalog/views/sdi/locales/|search');
             }]);

             */
            var localPrefix = value.split('|')[0];
            var localValue = value.split('|')[1];
            return localPrefix + gnLangs.getIso2Lang(lang) +
                '-' + localValue + suffix;
          } else {
            return prefix + gnLangs.getIso2Lang(lang) + '-' + value + suffix;
          }
        };
        var allPromises = [];

        angular.forEach(options.locales, function(value, index) {
          var langUrl = buildUrl(options.prefix, options.key,
              value, options.suffix);

          var deferredInst = $q.defer();
          allPromises.push(deferredInst.promise);

          $http({
            method: 'GET',
            url: langUrl,
            headers: {
              'Accept-Language': options.key
            }
          }).success(function(data) {
            deferredInst.resolve(data);
          }).error(function() {
            // Load english locale file if not available
            var url = buildUrl(options.prefix, 'en', value, options.suffix);
            $http({
              method: 'GET',
              url: url
            }).success(function(data) {
              deferredInst.resolve(data);
            }).error(function() {
              deferredInst.resolve({});
            });
          });
        });

        // Finally, create a single promise containing all the promises
        // for each app module:
        var deferred = $q.all(allPromises);

        return deferred;
      };
    }]);


  module.config(['$translateProvider', '$LOCALES', 'gnGlobalSettings',
    'gnLangs',
    function($translateProvider, $LOCALES, gnGlobalSettings, gnLangs) {
      $translateProvider.useLoader('localeLoader', {
        locales: $LOCALES,
        prefix: (gnGlobalSettings.locale.path || '../../') + 'catalog/locales/',
        suffix: '.json'
      });

      gnLangs.detectLang(
          gnGlobalSettings.gnCfg.langDetector,
          gnGlobalSettings
      );

      $translateProvider.preferredLanguage(gnGlobalSettings.iso3lang);
      // $translateProvider.useSanitizeValueStrategy('escape');
      $translateProvider.useSanitizeValueStrategy('sanitizeParameters');

      moment.locale(gnGlobalSettings.lang);
    }]);

})();
