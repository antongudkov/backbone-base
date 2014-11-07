gulp = require('gulp')
gulpgrunt = require('gulp-grunt')(gulp)
plumber = require('gulp-plumber')
runSequence = require('run-sequence')
install = require('gulp-install')
clean = require('gulp-clean')
rimraf = require('gulp-rimraf')
ignore = require('gulp-ignore')
coffeelint = require('gulp-coffeelint')
jsonlint = require('gulp-jsonlint')
stylus = require('gulp-stylus')
cssimport = require('gulp-cssimport')
concat = require('gulp-concat')
jade = require('gulp-jade')
source = require('vinyl-source-stream')
browserify = require('browserify')
watchify = require('watchify')
browserSync = require('browser-sync')
notify = require('gulp-notify')
proxy = require("proxy-middleware")
karma = require('karma').server


config =
  appDir: 'app'
  publicDir: 'public'
  testDir: 'specs'
  ports:
    server: 8000
    mocks: 8001
    test: 9999


gulp.task 'install', ->
  gulp.src(['./bower.json'])
    .pipe(install())


gulp.task 'clean', ->
  gulp.src("#{config.publicDir}/", read: false)
    .pipe(rimraf())


gulp.task 'copy', ->
  gulp.src("#{config.appDir}/images/**/*")
    .pipe(gulp.dest("#{config.publicDir}/images/"))


gulp.task 'jsonlint', ->
  gulp.src('mocks/**/*.json')
    .pipe(jsonlint())
    .pipe(jsonlint.reporter())


gulp.task 'coffeelint', ->
  gulp.src("#{config.appDir}/scripts/**/*.coffee")
    .pipe(plumber())
    .pipe(coffeelint())
    .pipe(coffeelint.reporter())


gulp.task 'stylesheets', ->
  gulp.src("#{config.appDir}/stylesheets/**/*.styl")
    .pipe(plumber())
    .pipe(stylus(linenos: true).on('error', notify.onError()))
    .pipe(concat('style.css'))
    .pipe(cssimport())
    .pipe(gulp.dest("#{config.publicDir}"))


gulp.task 'templates', ->
  jadeConfig =
    pretty: true
    data: {}

  gulp.src("#{config.appDir}/*.jade")
    .pipe(plumber())
    .pipe(jade(jadeConfig).on('error', notify.onError()))
    .pipe(gulp.dest("#{config.publicDir}/"))


gulp.task 'browserify', ->
  bundler = browserify(
    cache: {}
    packageCache: {}
    fullPaths: true
    debug: true
    paths: [
      "./#{config.appDir}/scripts"
      "./#{config.appDir}/templates"
    ]
    entries: "./#{config.appDir}/scripts/main.coffee"
  )

  bundle = ->
    bundler
      .bundle()
      .pipe(plumber())
      .pipe(source('application.js'))
      .pipe(gulp.dest("#{config.publicDir}"));

  bundler = watchify(bundler)
  bundler
    .on('error', notify.onError())
    .on('update', bundle)
  bundle()


gulp.task 'browser-sync', ->
  browserSync
    port: config.ports.server
    open: false
    notify: false
    server:
      baseDir: "#{config.publicDir}"
      middleware: [(->
        url = require('url')
        options = url.parse("http://localhost:#{config.ports.mocks}/mocks/api")
        options.route = '/api'
        proxy(options)
      )()]
    files: [
      "#{config.publicDir}/**"
      "!#{config.publicDir}/**.map"
    ]


gulp.task 'karma', ->
  karma.start(
    basePath: ''
    frameworks: ['mocha', 'requirejs', 'chai', 'sinon']
    runnerPort: config.ports.test
    singleRun: true
    browsers: ['PhantomJS']
    files: [
      {pattern: "#{config.publicDir}/bower_components/**/*.js", included: false}
      {pattern: "#{config.publicDir}/vendor/**/*.js", included: false}
      {pattern: "#{config.publicDir}/scripts/**/*.js", included: false}
      {pattern: "#{config.testDir}/**/*_spec.coffee", included: false}
      "#{config.testDir}/runner.coffee"
    ]
    exclude: [
      "#{config.publicDir}/scripts/config.js"
    ]
    reporters: ['dots']
    colors: true
    preprocessors:
      'specs/**/*.coffee': ['coffee']
    plugins: [
      'karma-mocha'
      'karma-chai'
      'karma-sinon'
      'karma-requirejs'
      'karma-chrome-launcher'
      'karma-phantomjs-launcher'
      'karma-coffee-preprocessor'
    ]
    client:
      mocha:
        ui: 'bdd'
  , done)


gulp.task 'watch', ->
  gulp.watch("#{config.appDir}/stylesheets/**/*.styl", ['stylesheets'])
  gulp.watch("#{config.appDir}/*.jade", ['templates'])


gulp.task 'test', ->
  config.publicDir = 'public'
  runSequence(
    [
      'copy'
      'scripts'
    ]
    'karma'
  )


gulp.task 'server', ->
  runSequence(
    [
      'browser-sync'
      'grunt-mocks'
    ]
  )


gulp.task 'build', ->
  runSequence(
    'install'
    'clean'
    [
      'copy'
      'templates'
      'stylesheets'
      'jsonlint'
      'coffeelint'
    ]
    'browserify'
  )


gulp.task 'development', ->
  runSequence(
    'build'
    'server'
    'watch'
  )

gulp.task('default', ['development'])
