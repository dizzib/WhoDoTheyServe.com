H = require \./helper
C = require \./collection
S = require \./session

exports
  ..nodes =
    name:
      href: -> node-info @_id
  ..node-edges-head =
    btn-edge-new:
      href: -> \#/edge-new
      text: -> 'New '
  ..node-evidences = evidence \node
  ..node-evidences-head = evidence-head \node
  ..node-info =
    btn-edit:
      class: show-if-creator
      href : -> node-edit @_id
      text : -> 'Edit '
  ..edges =
    a-node: node-a!
    b-node: node-b!
    how:
      href: edge-info
      text: edge-how
    period: edge-period!
  ..edge-evidences = evidence \edge
  ..edge-evidences-head = evidence-head \edge
  ..edge-info =
    btn-edit:
      class: show-if-creator
      href : edge-edit
      text : -> 'Edit '
    a-node: node-a!
    b-node: node-b!
    how:
      text: edge-how
    period: edge-period!
  ..meta =
    create-user:
      href: -> user-info @meta?create_user_id
      text: -> find-user-by-meta(@meta)?get(\login) ? '(deleted user)'
    create-date:
      text: -> new Date @meta?create_date
  ..users =
    login:
      href: -> user-info @_id
  ..user-info =
    btn-edit:
      class: -> \hide unless S.is-signed-in-admin! or S.is-signed-in @_id
      href : -> "#/user-edit/#{@_id}"
      text : -> 'Edit '
    url:
      href: -> @info
      text: -> @info
  ..user-nodes =
    name:
      href: -> node-info @_id
  ..user-edges =
    a-node: node-a!
    b-node: node-b!
    how:
      href: edge-info
      text: edge-how
    period: edge-period!

## helpers
function evidence entity-type then
  btn-delete:
    class: show-if-creator
    href : -> "#/#{entity-type}-evi-del/#{@entity_id}/#{@_id}"
  btn-new:
    href: -> "#/#{entity-type}-evi-new/#{@_id}"
    text: -> 'New '
  url:
    href  : -> @url
    text  : -> @url
    target: -> \_blank  # open in new tab
function evidence-head entity-type then
  btn-new:
    href: -> "#/#{entity-type}-evi-new/#{@_id}"
    text: -> 'New '
function edge-edit then "#/edge-edit/#{@_id}"
function edge-info then "#/edge-info/#{@_id}"
function edge-how then "----#{@how ? ''}---#{if @a_is_lt then \> else \-}"
function edge-period then
  text: ->
    if @year_from and @year_from is @year_to then return "in #{@year_to}"
    yf = if @year_from then "from #{@year_from} " else ''
    yt = if @year_to then "to #{@year_to}" else ''
    yf + yt
function node-edit then "#/node-edit/#{it}"
function node-info then "#/node-info/#{it}"
function node-a then
  href: -> node-info @a_node_id
  text: -> @a_node_name
function node-b then
  href: -> node-info @b_node_id
  text: -> @b_node_name
function show-if-creator then
  \hide unless S.is-signed-in @meta?create_user_id
function user-edit then "#/user-edit"
function user-info then "#/user-info/#{it}" if it
function find-user-by-meta then C.Users.find-by-id it?create_user_id
