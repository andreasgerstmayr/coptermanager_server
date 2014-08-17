var gulp = require('gulp');
var gutil = require('gulp-util');
var coffee = require('gulp-coffee');
var stylus = require('gulp-stylus');
var concat = require('gulp-concat');
var del = require('del');
var gulpFilter = require('gulp-filter');
var rename = require('gulp-rename');
var mainBowerFiles = require('main-bower-files');

var paths = {
  scripts: './priv/static-src/coffee/**/*.coffee',
  stylesheets: './priv/static-src/stylus/**/*'
};

gulp.task('clean', function(cb) {
  del(['./priv/static'], cb);
});

gulp.task('scripts', ['clean'], function() {
  return gulp.src(paths.scripts)
    .pipe(coffee().on('error', gutil.log))
    .pipe(concat('scripts.js'))
    .pipe(gulp.dest('./priv/static/js'));
});

gulp.task('stylesheets', ['clean'], function() {
  return gulp.src(paths.stylesheets)
    .pipe(stylus())
    .pipe(concat('styles.css'))
    .pipe(gulp.dest('./priv/static/css'));
});

gulp.task('images', ['clean'], function() {
  return gulp.src('./priv/static-src/images/**/*')
    .pipe(gulp.dest('./priv/static/images'));
});

gulp.task('bower', ['clean'], function() {
  var jsFilter = gulpFilter('**/*.js');
  var cssFilter = gulpFilter('**/*.css');
  var fontFilter = gulpFilter('**/fonts/*');
  return gulp.src(mainBowerFiles(), {base: './bower_components'})
    .pipe(jsFilter)
    .pipe(concat('vendor.js'))
    .pipe(gulp.dest('./priv/static/js'))
    .pipe(jsFilter.restore())
    .pipe(cssFilter)
    .pipe(concat('vendor.css'))
    .pipe(gulp.dest('./priv/static/css'))
    .pipe(cssFilter.restore())
    .pipe(fontFilter)
    .pipe(rename({dirname: '.'}))
    .pipe(gulp.dest('./priv/static/fonts'));
});

gulp.task('external', ['clean'], function() {
  return gulp.src('./priv/static-src/external/**/*')
    .pipe(gulp.dest('./priv/static'));
});

gulp.task('build', ['scripts', 'stylesheets', 'images', 'bower', 'external']);

gulp.task('watch', function() {
  gulp.watch(paths.scripts, ['scripts']);
  gulp.watch(paths.scripts, ['stylesheets']);
});

gulp.task('default', ['build', 'watch']);
