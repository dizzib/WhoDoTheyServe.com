When = require \../when

const TEXT =
  info: 'a string of up to 200 letters, numbers or symbols !@"#%&*:\'<>/-.+$,()?'
  regex: /^[a-z 0-9!@"#%&*:'<>/\-\.\+\$\,\(\)\?\r\n]{1,200}$/i
const WHEN-RX = When.constants.RX

module.exports =
  edge:
    how:
      info: 'a string of 2 to 50 alphanumerics e.g. chairman'
      regex: /^[a-z0-9 &,-\/]{2,50}$/i
    when:
      info: 'a valid From-To time period of format F-T or F- or -T, where F or T is dd/mm/yyyy or mm/yyyy or yyyy'
      regex: new RegExp "^#{WHEN-RX}-$|^-#{WHEN-RX}$|^#{WHEN-RX}-#{WHEN-RX}$"
  email:     # regex copied from backbone-validation
    info : 'a valid email address e.g. foo@bar.com'
    regex: /^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$/i,
  handle:
    info : 'a string of 2 to 12 lower-case letters or numbers (a-z 0-9) e.g. foobar123'
    regex: /^[a-z]{2,2}[a-z0-9]{2,10}$/
  map:
    description: TEXT
    name:
      info: "a string of 4 to 50 letters, numbers or symbols !&,'() e.g. Mainstream Media"
      regex: /^(?!( ))([a-z0-9!&'\,\(\)]|[- ](?=[a-z0-9&\(])){4,50}$/i
    when:
      info: 'a valid date, month or year of format dd/mm/yyyy or mm/yyyy or yyyy'
      regex: new RegExp "^#{WHEN-RX}$"
  node:
    name:
      info: 'a string of 4 to 50 letters or numbers e.g. Bank of England'
      regex: /^(?!(the| ))([a-z0-9\,!&\(\)]|[- ](?=[a-z0-9&\(])){4,50}$/i
    tag:
      info: 'a string of 2 to 20 lower-case letters'
      regex: /^[a-z]{2,20}$/
  note: TEXT
  password:  # http://www.zorched.net/2009/05/08/password-strength-validation-with-regular-expressions/
    info : 'a mix of 6 to 16 uppercase A-Z, lowercase a-z, digits 0-9 and symbols !@#$%^&*?_~-'
    regex: /^(?=.{6,16}$)(?=.*[a-z])(?=.*[A-Z])(?=.*[\d])(?=.*[\W]).*$/
  url:       # regex copied from backbone-validation
    info : 'a valid url e.g. http://whodotheyserve.com'
    regex: /^(https?):\/\/(((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:)*@)?(((\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]))|((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?)(:\d*)?)(\/((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)+(\/(([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)*)*)?)?(\?((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|[\uE000-\uF8FF]|\/|\?)*)?(\#((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|\/|\?)*)?$/i
