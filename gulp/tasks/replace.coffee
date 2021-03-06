fs = require('fs')
gulp = require('gulp')
replace = require('gulp-replace-task')
config = require('../config')

gulp.task 'replace', ->
  env = 'development'
  patterns = []
  settings = JSON.parse(fs.readFileSync("#{config.appDir}/config/environments/#{env}.json", 'utf8'))
  settings['env'] = env

  for key, value of settings
    patterns.push
      match: key
      replacement: value

  gulp.src("#{config.appDir}/config/config.coffee")
    .pipe(replace(patterns: patterns))
    .pipe(gulp.dest("#{config.appDir}/scripts"))
