B = require \backbone
T = require \transparency
_ = require \underscore
S = require \../session

const CLASS-EDITING = \editing

B.on \routed, ->
  $ \.view .removeClass CLASS-EDITING

module.exports =
  EditView: B.View.extend do
    events:
      'click button.cancel'    : \cancel
      'click button.delete-ask': \delete-ask
      'click button.delete-no' : \delete-ask
      'click button.delete-yes': \delete-yes
      'submit form'            : \save
      'validated'              : \validated
    initialize: ->
      @opts     = it.opts
      @template = it.template
      _.extend this, B.Events
    cancel: -> @trigger \cancelled
    'delete-ask': -> $ \.button-bar .toggleClass \mode-delete-ask .toggleClass \mode-edit
    'delete-yes': -> @coll.destroy @model, success: ~> @trigger \destroyed, @model
    render: (@model, @coll, opts) ->
      @delegateEvents!
      $ \.view .addClass CLASS-EDITING
      B.Validation.bind this
      @model.bind \validated:valid ~> @trigger \validated, @model
      ($tem = $ @template).addClass if is-new = @model.isNew! then \create else \update
      return render @model if is-new or opts?fetch is no
      @model.fetch success: -> render it
      ~function render model
        @$el.html $tem.render(model.toJSON-T!, opts?directive).set-access S .show!
        @trigger \rendered model # before focus, for bootstrap-typeahead
        @$el.find 'input[type=text],textarea,select' .filter \:visible:first .focus!
    save: ->
      it.preventDefault!
      unless (m = @model) then alert "ERROR! @model is void. Check $el isn't used by other edit views!"
      is-new = m.isNew!
      m.set ($ it.currentTarget .serializeObject!)
      m.on \error ~>
        $ \.button-bar .enable-buttons!
        @trigger \error m
      m.on \request -> $ \.button-bar .disable-buttons!
      m.on \sync    -> $ \.button-bar .enable-buttons!
      @trigger \serialized m
      @coll.create m, { +merge, +wait, success: ~> @trigger \saved m, is-new }
      false
