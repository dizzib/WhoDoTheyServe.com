# http://stackoverflow.com/questions/542938/how-do-i-get-the-number-of-days-between-two-dates-in-javascript?rq=1
module.exports =
  get-current-year: ->
    new Date!getFullYear!

  get-current-deciweek-of-year: ->
    return Math.floor(get-current-day-of-year! / 10)

    function get-current-day-of-year then
      new-year = new Date (now = new Date!).getFullYear!, 0, 1
      get-days-between new-year, now

    function get-days-between date-start, date-end then
      const MS-PER-DAY = 24h * 60m * 60s * 1000ms
      return Math.floor((utcify(date-end) - utcify(date-start)) / MS-PER-DAY)

      function utcify date then
        d = new Date date
        d.setMinutes (d.getMinutes! - d.getTimezoneOffset!);
        return d

  get-date-yesterday: ->
      d = new Date!
      d.setDate d.getDate! - 1
      return d
