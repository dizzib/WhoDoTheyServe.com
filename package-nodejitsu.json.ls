# https://www.nodejitsu.com/documentation/appendix/package-json/
name   : \wdts
version: \0.1.0
private: true
scripts:
  start: 'boot.js'
dependencies:
  bcrypt    : \0.7.5
  crypto    : \0.0.3
  express   : \3.1.0
  mongoose  : \3.5.5
  underscore: \1.4.4
  zombie    : \2.0.0-alpha18
# https://www.nodejitsu.com/documentation/features/dns/ 
domains:
  \whodotheyserve.com
  \www.whodotheyserve.com
subdomain: \wdts
engines:
  node: \0.8.x
