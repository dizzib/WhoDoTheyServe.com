B = require \backbone
T = require \transparency
_ = require \underscore
H = require \../../helper
S = require \../../session

const CLASS-EDITING = \editing

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
    'delete-yes': -> @coll.destroy @model, error:H.on-err, success: ~> @trigger \destroyed, @model
    render: (@model, @coll, opts) ->
      @delegateEvents!
      $ \.view .addClass CLASS-EDITING
      B.Validation.bind this
      @model.bind \validated:valid, ~> @trigger \validated, @model
      ($tem = $ @template).addClass if is-new = @model.isNew! then \create else \update
      return render @model if is-new or opts?fetch is no
      @model.fetch error:H.on-err, success: -> render it
      ~function render model
        @$el.html $tem.render model.toJSON-T! .set-access S .show!
        @$el.find 'input[type=text],textarea,select' .filter \:visible:first .focus!
        @trigger \rendered, model
    save: ->
      it.preventDefault!
      unless (m = @model) then alert "ERROR! @model is void. Check $el isn't used by other edit views!"
      is-new = m.isNew!
      m.set ($ it.currentTarget .serializeObject!)
      @trigger \serialized, m
      ~function on-err
        @trigger \error, m
        H.on-err ...
      @coll.create m, { +merge, +wait, error:on-err, success: ~> @trigger \saved, m, is-new }
      false

  ResetEditView: -> $ \.view .removeClass CLASS-EDITING
