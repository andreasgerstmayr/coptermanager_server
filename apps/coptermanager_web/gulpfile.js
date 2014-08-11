var gulp = require('gulp');
var gutil = require('gulp-util');
var coffee = require('gulp-coffee');

var paths = {
  scripts: './priv/static-src/coffee/**/*.coffee'
};

gulp.task('scripts', function() {
  return gulp.src(paths.scripts)
    .pipe(coffee().on('error', gutil.log))
    .pipe(gulp.dest('./priv/static/js/'));
});

gulp.task('watch', function() {
  gulp.watch(paths.scripts, ['scripts']);
});
