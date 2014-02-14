dev:
  NODE_ENV                        : \development
  PORT                            : 4000
  WDTS_DB_URI                     : \mongodb://localhost/wdts_dev
  WDTS_DB_CACHE_ENABLE            : true
  WDTS_DB_CACHE_SWEEP_PERIOD_MINS : 10
test:
  NODE_ENV                        : \test
  PORT                            : 4001
  WDTS_DB_URI                     : \mongodb://localhost/wdts_test
  WDTS_USER_SIGNIN_BAD_FREEZE_SECS: 0
tester:
  NODE_ENV                        : \tester
test-staging:
  NODE_ENV                        : \staging
  PORT                            : 4002
  WDTS_DB_URI                     : \mongodb://localhost/wdts_test
staging:
  NODE_ENV                        : \staging
  PORT                            : 4003
  WDTS_DB_URI                     : \mongodb://localhost/wdts_staging
