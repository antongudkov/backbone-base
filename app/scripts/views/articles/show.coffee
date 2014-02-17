define [
  'marionette'
  'views/comments/item'
], (Marionette, CommentsItemView) ->

  class ArticlesShowView extends Marionette.CompositeView
    className: 'media'
    template: JST['templates/articles/show']
    itemView: CommentsItemView
    itemViewContainer: '.comments'

    initialize: ->
      @collection = @model.get('comments')
