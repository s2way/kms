'use strict';

module.exports = function (grunt) {

    // Set commands
    var compileJsCommand = "node_modules/.bin/coffee --compile --output js/ coffee/";
    var compileWatch = "node_modules/.bin/coffee --compile --watch --output js/ coffee/";
    // Load grunt tasks automatically
    require('load-grunt-tasks')(grunt);

    // Define the configuration for all the tasks
    grunt.initConfig({
        exec: {
            'compile': compileJsCommand,
            'compilewatch': compileWatch
        },
        // Watches files for changes and runs tasks based on the changed files
        watch: {
            src: {
                files: [
                     'coffee/**/*.coffee',
                     'coffee/*.coffee'
                    ],
                tasks: ['compile']
            },
            gruntfile: {
                files: ['Gruntfile.js']
            }
        }
    });

    grunt.registerTask('default', 'Watch files', function (app) {
        grunt.task.run(['watch']);
    });

    grunt.registerTask('compile', 'Coffee2Js', 'exec:compile');
    grunt.registerTask('watch', 'Coffee2Js Watch', 'exec:compilewatch');
};
