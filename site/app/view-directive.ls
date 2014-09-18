A = require \Autolinker
B = require \backbone
E = require \./view/evidence
C = require \./collection
H = require \./helper
S = require \./session
V = require \./view

const EDGE =
  'a-node':
    href: -> get-node-href @a_node_id
    text: -> @a_node_name
  'b-node':
    href: -> get-node-href @b_node_id
    text: -> @b_node_name
  how:
    href: -> "#/edge/#{@_id}"
    text: -> "----#{@how ? ''}---#{if @a_is_lt then \> else \-}"
  period:
    text: -> @period

const EVI =
  glyph:
    class: ->
      "glyph fa #{@glyph.name} #{get-evi-status @_id}"
  'url-outer':
    href: -> @url
  'url-inner':
    text: -> @url

const EVI-VIDEO =
  video:
    class: -> if @video then @video.service unless get-youtube-embed @url .error
    text : -> get-youtube-embed @url .error if @video
  youtube:
    src: -> get-youtube-embed @url .url if @video

const GLYPH =
  glyph:
    href: -> "#/#{if C.Edges.get @entity_id then \edge else \node}/#{@entity_id}"

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
            <i class='glyph fa #{ev.get-glyph!name} #{get-evi-status ev.id}'/>
          </a>"
      notes = C.Notes.find ~> @_id is it.get \entity_id
      for note in notes.models
        $el.append "<i title='#{note.get \text}' class='glyph fa fa-comment'/>"
      return ''

const REMOVE =
  text: -> it.element.remove!

const META =
  'create-user':
    href: -> get-user-href @meta?create_user_id
    text: -> get-user-text @meta?create_user_id
  'create-date':
    title: -> @meta?create_date # title for timeago
  update:
    class: -> \hide unless @meta?update_date
  'update-user':
    href: -> get-user-href @meta?update_user_id
    text: -> get-user-text @meta?update_user_id
  'update-date':
    title: -> @meta?update_date # title for timeago

const META-COMPACT = # show only the last action
  act:
    text: -> if @meta?.update_user_id then \edited else \added
  user:
    href: -> get-user-href (@meta?update_user_id or @meta?create_user_id)
    text: -> get-user-text (@meta?update_user_id or @meta?create_user_id)
  date:
    title: -> @meta?update_date or @meta?create_date # title for timeago

const SHOW-IF-CREATOR-OR-ADMIN = ->
  \hide unless S.is-signed-in @meta?create_user_id or S.is-signed-in-admin!

# _.extend seems to work better then livescript's with (aka the cloneport)
module.exports =
  edge: _.extend do
    'btn-edit':
      class: SHOW-IF-CREATOR-OR-ADMIN
      href : -> "#/edge/edit/#{@_id}"
    EDGE
  edges: _.extend {}, EDGE, GLYPHS
  evidences: _.extend do
    'btn-edit':
      class: SHOW-IF-CREATOR-OR-ADMIN
      href : -> "#/#{B.history.fragment}/evi-edit/#{@_id}"
    META-COMPACT
    EVI
    EVI-VIDEO
  evidences-head:
    'btn-new':
      href: -> "#/#{B.history.fragment}/evi-new"
  glyph: GLYPH
  map:
    link:
      href: -> "#/map/#{@id or @_id or \new}"
    name:
      text: -> @name or @get \name or 'New map'
    description:
      html: -> htmlify-text @description
    when:
      text: -> "Date: #{@when}" if @when
  maps:
    map:
      class: -> \active if @_id is V.map.map?id
    'edit-indicator':
      class: -> "fa fa-chevron-left" if @_id is V.map.map?id
    link:
      href: -> "#/map/#{@_id}"
      text: -> @name
  meta: META
  meta-compact: META-COMPACT
  node:
    'btn-edit':
      class: SHOW-IF-CREATOR-OR-ADMIN
      href : -> "#/node/edit/#{@_id}"
  nodes: _.extend do
    name:
      href: -> get-node-href @_id
    GLYPHS
  notes: _.extend do
    note:
      html: -> htmlify-text @text
    META-COMPACT
  notes-head:
    'btn-edit':
      href: -> "#/#{B.history.fragment}/note-edit"
    'btn-new':
      href: -> "#/#{B.history.fragment}/note-new"
    creatable:
      class: -> \hide unless _.isEmpty this
    editable:
      class: -> \hide if _.isEmpty this
  user:
    actions:
      class: -> \hide unless S.is-signed-in @_id
    'btn-edit':
      class: -> \hide unless S.is-signed-in @_id or S.is-signed-in-admin!
      href : -> "#/user/edit/#{@_id}"
    url:
      href: -> @info
      text: -> @info
  user-evidences: _.extend do
    btn  : REMOVE
    meta : REMOVE
    video: REMOVE
    EVI
  user-notes:
    note:
      html: -> A.link @text if @text
    meta: REMOVE
  users:
    user:
      href: -> get-user-href @_id

## helpers

function get-evi-status then if E.is-dead it then \dead else \live
function get-node-href then "#/node/#{it}"
function get-user-href then "#/user/#{it}" if it
function get-user-text then if (u = C.Users.find-by-id it) then "#{u.get \name} " else '(deleted user) '

function get-youtube-embed url
  # http://stackoverflow.com/questions/21607808/convert-a-youtube-video-url-to-embed-code
  matches = url.match /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/
  return url:"//www.youtube.com/embed/#{matches.2}" if matches?2.length is 11
  error:"Cannot get a valid video id from #url. Please check the url is correct."

function htmlify-text
  return unless it
  A.link it.replace /\r\n/g, \<br/>
