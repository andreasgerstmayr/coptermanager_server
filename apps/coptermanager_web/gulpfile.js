var gulp = require('gulp');
var gutil = require('gulp-util');
var coffee = require('gulp-coffee');

var paths = {
  coffee: './priv/static-src/coffee/**/*.coffee'
};

gulp.task('coffee', function() {
  return gulp.src(paths.coffee)
    .pipe(coffee().on('error', gutil.log))
    .pipe(gulp.dest('./priv/static/js/'));
});

gulp.task('watch', function() {
  gulp.watch(paths.coffee, ['coffee']);
});
