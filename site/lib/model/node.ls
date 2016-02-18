const NAMECH = require \./constants .RX.NAMECHAR
const PROPER = "[A-Z][#NAMECH]+"

const RX-PERSON = new RegExp do
  "^(#PROPER[ -])*#PROPER, #PROPER([ -]\\(?[#NAMECH]+[\\),]?)*$"

module.exports =
  is-person: -> RX-PERSON.test it and not /(, [tT]he(\s|$))/.test it
