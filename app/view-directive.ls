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
      yf = if @year_from then "from #{@year_from} " else ''
      yt = if @year_to then "to #{@year_to}" else ''
      yf + yt

const HIDE =
  class: -> \hide

const META =
  create-user:
    href: -> get-user-href @meta?create_user_id
    text: ->
      return '(deleted user)' unless creator = C.Users.find-by-id @meta?create_user_id
      creator.get \login
  create-date:
    text: -> new Date @meta?create_date

const SHOW-IF-CREATOR =
  -> \hide unless S.is-signed-in @meta?create_user_id

const URL =
  href: -> @url
  text: -> @url

exports
  ..edge = _.extend do
    EDGE
    btn-edit:
      class: SHOW-IF-CREATOR
      href : -> "#/edge/edit/#{@_id}"
  ..edges = EDGE
  ..evidences = _.extend do
    META
    btn-edit:
      class: SHOW-IF-CREATOR
      href : -> "#/#{B.history.fragment}/evi-edit/#{@_id}"
    url: URL
  ..evidences-head =
    btn-new:
      href: -> "#/#{B.history.fragment}/evi-new"
  ..meta = META
  ..nodes =
    name:
      href: -> get-node-href @_id
  ..node =
    btn-edit:
      class: SHOW-IF-CREATOR
      href : -> "#/node/edit/#{@_id}"
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
  ..users =
    login:
      href: -> get-user-href @_id
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

function get-node-href then "#/node/#{it}"
function get-user-href then "#/user/#{it}" if it
