env = process.env

function get-host domain = \SITE_DOMAIN_NAME
  return domain unless env.NODE_ENV in <[ development staging test ]>
  "#domain:#{env.PORT}"

module.exports =
  get-host-api : -> get-host(env.API_DOMAIN_NAME or env.SITE_DOMAIN_NAME) # differs only in production
  get-host-site: -> get-host env.SITE_DOMAIN_NAME
