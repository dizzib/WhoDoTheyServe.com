module.exports = class EventEmitter
  listeners = {}

  on: (eventName, listener) ->
    (listeners[eventName] ||= []).push listener
  emit: (eventName /* , args... */) ->
    for l in listeners[eventName]
      l.apply this, Array.prototype.slice.call(arguments, 1)
