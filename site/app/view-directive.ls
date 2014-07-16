B = require \backbone
E = require \./view/evidence
C = require \./collection
H = require \./helper
S = require \./session
V = require \./view

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
    text: -> @period

const GLYPH =
  glyph:
    href: -> "#/#{if C.Edges.get @entity_id then \edge else \node}/#{@entity_id}"

const GLYPH-EVI =
  glyph:
    class: ->
      "glyph fa #{@glyph.name} #{if E.is-dead @_id then \dead else ''}"

const GLYPHS =
  glyphs:
    null: ->
      $el = $ it.element
      evs = C.Evidences.find ~> @_id is it.get \entity_id
      if evs.models.length is 0
        $el.append "
          <a title='Please add some evidence'>
            <i class='glyph fa fa-lg fa-exclamation'/>
          </a>"
      else for ev in evs.models
        $el.append "
          <a target='_blank' title='#{@tip}' href='#{ev.get \url}'>
            <i class='glyph fa #{ev.get-glyph!name} #{if E.is-dead ev.id then \dead else ''}'/>
          </a>"
      notes = C.Notes.find ~> @_id is it.get \entity_id
      for note in notes.models
        $el.append "<i title='#{note.get \text}' class='fa fa-comment'/>"
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

const SHOW-IF-CREATOR = ->
  \hide unless S.is-signed-in @meta?create_user_id

const URL-EVI =
  url-outer:
    href: -> @url
  url-inner:
    text: -> @url

# for some reason livescript's cloneport doesn't work with multiple constants
# e.g. GLYPHS with EDGE, so we'll use _.extend instead
module.exports =
  edge: {
    btn-edit:
      class: SHOW-IF-CREATOR
      href : -> "#/edge/edit/#{@_id}"
    } <<< EDGE
  edges:
    (_.deepClone EDGE) <<< GLYPHS
  evidences: _ {} .extend {
    btn-edit:
      class: SHOW-IF-CREATOR
      href : -> "#/#{B.history.fragment}/evi-edit/#{@_id}"
    }, GLYPH-EVI, META, URL-EVI
  evidences-head:
    btn-new:
      href: -> "#/#{B.history.fragment}/evi-new"
  glyph:
    GLYPH
  map:
    link:
      href: -> "#/map/#{@id or \new}"
    glyph:
      text: -> @get \name or 'New map'
  maps:
    map:
      class: -> \active if @_id is V.graph.map?id
    'edit-indicator':
      class: -> "fa fa-edit" if @_id is V.graph.map?id
    link:
      href: -> "#/map/#{@_id}"
      text: -> @name
  meta:
    META
  node:
    btn-edit:
      class: SHOW-IF-CREATOR
      href : -> "#/node/edit/#{@_id}"
  nodes: {
    name:
        href: -> get-node-href @_id
    } <<< GLYPHS
  notes:
    META
  notes-head:
    btn-edit:
      href: -> "#/#{B.history.fragment}/note-edit"
    btn-new:
      href: -> "#/#{B.history.fragment}/note-new"
    creatable:
      class: -> \hide unless _.isEmpty this
    editable:
      class: -> \hide if _.isEmpty this
  user:
    btn-edit:
      class: -> \hide unless S.is-signed-in-admin! or S.is-signed-in @_id
      href : -> "#/user/edit/#{@_id}"
    url:
      href: -> @info
      text: -> @info
  user-evidences: _ {} .extend {
    btn : HIDE
    meta: HIDE
    }, GLYPH-EVI, URL-EVI
  user-notes:
    meta: HIDE
  users:
    user:
      href: -> get-user-href @_id

function get-node-href then "#/node/#{it}"
function get-user-href then "#/user/#{it}" if it
