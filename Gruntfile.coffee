module.exports = (grunt) ->

  grunt.loadNpmTasks 'grunt-mocha-test'

  grunt.initConfig
    mochaTest:
      test:
        options:
          reporter: 'spec'
          queit: false
          clearRequireCache: false
        src: ['test/*/*.coffee']

  grunt.registerTask 'default', 'mochaTest'

