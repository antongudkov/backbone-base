define [
  'routers/base'
  'controllers/main_controller'
], (BaseRouter, Controller) ->

  class MainRouter extends BaseRouter
    initialize: ->
      @controller = new Controller

    appRoutes:
      '': 'index'
