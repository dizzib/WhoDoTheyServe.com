A = require \Autolinker
B = require \backbone
C = require \../collection
S = require \../session
V = require \../view

const NODE-NAME =
  name:
    text: -> @name
  'node-title':
    href : -> get-node-href @_id
    class: -> "node-title #{if @is-live then '' else 'dead'}".trim!
  'node-when':
    text: -> @when-text
  'person-glyph':
    class: -> 'glyph fe fe-male' if @is-person
    title: -> "person #{if @is-live then '' else '(deceased)'}".trim!

const EDGE =
  'a-node': NODE-NAME
  'b-node': NODE-NAME
  'edge-when':
    text: -> @when-text
  how:
    href: -> "#/edge/#{@_id}"
    text: -> "----#{@how ? ''}---#{if @a_is_lt then \> else \-}"

const EVI =
  glyph:
    class: ->
      "glyph fe #{@glyph.name} #{get-evi-class @}"
  'url-outer':
    href: -> @href
  'url-inner':
    text: -> @url

const EVI-VIDEO =
  video:
    class: -> @video.service if @video?id
    text : ->
      if @video?service and not @video.id
        "Cannot get a valid video id from #{@url}. Please check the url is correct."
  youtube:
    src: -> @video?href

const GLYPH =
  glyph:
    href: -> "#/#{if C.Edges.get @entity_id then \edge else \node}/#{@entity_id}"

const GLYPHS =
  glyphs:
    fn: ->
      $el = $ it.element
      for ev in evs = C.Evidences.where entity_id:@_id
        evj = ev.toJSON-T!
        $el.append "<a target='_blank' title='#{@tip}' href='#{evj.href}'
          class='glyph fe #{evj.glyph.name} #{get-evi-class evj}'/></a>"
      unless evs.length
        $el.append "<a title='Please add some evidence'
          class='glyph fe fe-lg fe-attention'/></a>"
      for note in C.Notes.where entity_id:@_id
        $el.append "<span title='#{note.get \text}' class='glyph fe fe-comment'/>"
      return ''

const MAP =
  link:
    href: -> "#/map/#{@id or @_id or \new}"
  name:
    text: -> @name or 'New map'
  description:
    html: -> htmlify-text @description
  shortname:
    text: ->
      return s unless (s = @name or 'New map').length > 3
      s.substr(0, 3) + \...
  when:
    text: -> "Date: #{@when}" if @when

const META =
  'create-by':
    class: -> \hide if get-is-admin @meta?create_user_id
  'create-date':
    title: -> @meta?create_date # title for timeago
  'create-user':
    href: -> get-user-href @meta?create_user_id
    text: -> get-user-text @meta?create_user_id
  update:
    class: -> \hide unless @meta?update_user_id
  'update-by':
    class: -> \hide if get-is-admin @meta?update_user_id
  'update-date':
    title: -> @meta?update_date # title for timeago
  'update-user':
    href: -> get-user-href @meta?update_user_id
    text: -> get-user-text @meta?update_user_id

const META-COMPACT = # show only the last action
  act:
    text: -> if @meta?update_user_id then \edited else \added
  by:
    class: -> \hide if get-is-admin (@meta?update_user_id or @meta?create_user_id)
  date:
    title: -> @meta?update_date or @meta?create_date # title for timeago
  user:
    href: -> get-user-href (@meta?update_user_id or @meta?create_user_id)
    text: -> get-user-text (@meta?update_user_id or @meta?create_user_id)

const NODE-TAGS =
  tags:
    tag:
      href: -> "#/nodes/#{@value}"
      text: -> @value

const NOTES =
  note:
    html: -> htmlify-text @text

const REMOVE =
  text: -> it.element.remove!

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
  latest: _.extend do
    EDGE
    GLYPHS
    MAP
    META-COMPACT
    NODE-NAME
    NODE-TAGS
    NOTES
    item:
      fn: ->
        $ it.element .find ".entity>:not(._type-#{@_type})" .remove!
        void
      class: ->
        return unless @_type is \map
        "#{it.element.className} seo-remove"
  map: MAP
  map-edit:
    'flags.private':
      checked: -> @flags?private
  meta: META
  meta-compact: META-COMPACT
  nav-maps:
    map:
      class: -> 'map active' if V.maps.is-current @_id
    'edit-indicator':
      class: -> "fe fe-chevron-left" if V.maps.is-current @_id
    link:
      href: -> "#/map/#{@_id}"
      text: -> @name
  node: _.extend do
    'btn-edit':
      class: SHOW-IF-CREATOR-OR-ADMIN
      href : -> "#/node/edit/#{@_id}"
    NODE-NAME
    NODE-TAGS
  nodes: _.extend do
    GLYPHS
    NODE-NAME
    NODE-TAGS
  notes: _.extend do
    NOTES
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
    info:
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

function get-evi-class ev then if ev.is-href-archive then \href-archive else \href-live
function get-is-admin then (C.Users.get it)?get-is-admin!
function get-node-href then "#/node/#{it}"
function get-user-href then "#/user/#{it}" if it
function get-user-text then if (u = C.Users.get it) then "#{u.get \name}" else '(deleted user)'

function htmlify-text
  return unless it
  A.link it.replace /\r\n/g, \<br/>
