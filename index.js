require('coffee-script');

module.exports = {
  PACKAGE_INFO: require('./package.json'),
  CLI:          require('./lib/cli'),
  LANGUAGES:    require('./lib/languages'),
  DOC_TAGS:     require('./lib/doctags'),
  Project:      require('./lib/project'),
  styles:       require('./lib/styles')
};
