module.exports = function(grunt) {
    // load plugins
    [
        'grunt-contrib-coffee',
        'grunt-coffeelint'
    ].forEach(function(task) {
            grunt.loadNpmTasks(task);
        });

    grunt.initConfig({
        coffee: {
            compile: {
                files: {
                    'GreedCoffee.js': 'Greed.coffee'
                }
            }
        },
        coffeelint: {
            options: {
                configFile: 'coffeelint.json'
              },
              app: [
                  '*.coffee'
              ]
          },
        watch: {
            coffee: {
                files: [
                    '*.coffee'
                ],
                tasks: [
                    'coffeelint'//,
                    //'coffee'
                ]
            }
        }
    });

    //grunt.registerTask('default', ['cafemocha', 'jshint', 'less', 'notify:cafemocha'])
    //grunt.registerTask('default', ['coffee', 'coffeelint'])
    grunt.registerTask('default', ['coffeelint'])
};