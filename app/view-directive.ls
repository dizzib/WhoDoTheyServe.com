B = require \backbone
_ = require \underscore
C = require \./collection
H = require \./helper
S = require \./session

const EDGE =
  a-node:
    href: -> get-node-href @a_node_id
    text: -> @a_node_name
  b-node:
    href: -> get-node-href @b_node_id
    text: -> @b_node_name
  how:
    href: -> "#/edge/#{@_id}"
    text: -> "----#{@how ? ''}---#{if @a_is_lt then \> else \-}"
  period:
    text: ->
      if @year_from and @year_from is @year_to then return "in #{@year_to}"
      yf = "from #{@year_from or '?'} "
      yt = if @year_to then "to #{@year_to}" else ''
      yf + yt

const GLYPH =
  glyph:
    href: ->
      "#/#{if C.Edges.get @entity_id then \edge else \node}/#{@entity_id}"

const GLYPHS =
  glyphs:
    null: ->
      $el = $ it.element
      evs = C.Evidences.find ~> @_id is it.get \entity_id
      for ev in evs.models
        $el.append "
          <a target='_blank' title='#{@tip}' href='#{ev.get \url}'>
            <i class='icon-camera'/>
          </a>"
      notes = C.Notes.find ~> @_id is it.get \entity_id
      for note in notes.models
        $el.append "<i title='#{note.get \text}' class='icon-comment'/>"
      return ''

const HIDE =
  class: -> \hide

const META =
  create-user:
    href: -> get-user-href @meta?create_user_id
    text: ->
      return '(deleted user) ' unless creator = C.Users.find-by-id @meta?create_user_id
      "#{creator.get \login} "
  create-date:
    title: -> @meta?create_date # https://github.com/rmm5t/jquery-timeago

const SHOW-IF-CREATOR = -> \hide unless S.is-signed-in @meta?create_user_id

const URL =
  href: -> @url
  text: -> @url

exports
  ..edge = _.extend do
    EDGE
    btn-edit:
      class: SHOW-IF-CREATOR
      href : -> "#/edge/edit/#{@_id}"
  ..edges = _.extend do
    GLYPHS
    EDGE
  ..evidences = _.extend do
    META
    btn-edit:
      class: SHOW-IF-CREATOR
      href : -> "#/#{B.history.fragment}/evi-edit/#{@_id}"
    url: URL
  ..evidences-head =
    btn-new:
      href: -> "#/#{B.history.fragment}/evi-new"
  ..glyph = GLYPH
  ..meta = META
  ..node =
    btn-edit:
      class: SHOW-IF-CREATOR
      href : -> "#/node/edit/#{@_id}"
  ..nodes = _.extend do
    GLYPHS
    name:
      href: -> get-node-href @_id
  ..notes = META
  ..notes-head =
    btn-edit:
      href: -> "#/#{B.history.fragment}/note-edit"
    btn-new:
      href: -> "#/#{B.history.fragment}/note-new"
    creatable:
      class: -> \hide unless _.isEmpty this
    editable:
      class: -> \hide if _.isEmpty this
  ..user =
    btn-edit:
      class: -> \hide unless S.is-signed-in-admin! or S.is-signed-in @_id
      href : -> "#/user/edit/#{@_id}"
    url:
      href: -> @info
      text: -> @info
  ..user-evidences =
    btn : HIDE
    meta: HIDE
    url : URL
  ..user-notes =
    meta: HIDE
  ..users =
    login:
      href: -> get-user-href @_id

function get-node-href then "#/node/#{it}"
function get-user-href then "#/user/#{it}" if it
