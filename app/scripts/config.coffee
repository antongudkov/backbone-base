requirejs.config
  baseUrl: '/scripts'
  paths:
    'underscore': '../bower_components/underscore/underscore'
    'jquery': '../bower_components/jquery/jquery'
    'backbone': '../bower_components/backbone/backbone'
    'backbone.routefilter': '../bower_components/backbone-route-filter/backbone-route-filter'
    'marionette': '../bower_components/marionette/lib/backbone.marionette'
    'bootstrap': '../bower_components/bootstrap/dist/js/bootstrap'

    'jade': '../vendor/scripts/runtime'
  shim:
    'underscore':
      exports: '_'
    'jquery':
      exports: '$'
    'backbone':
      deps: ['underscore', 'jquery']
      exports: 'Backbone'
    'backbone.routefilter':
      deps: ['backbone']
    'marionette':
      deps: ['backbone', 'backbone.routefilter']
      exports: 'Marionette'
    'bootstrap':
      deps: ['jquery']
    'templates':
      deps: ['jade']
