module.exports = (grunt) ->

  grunt.loadNpmTasks 'grunt-mocha-test'

  grunt.initConfig
    mochaTest:
      test:
        options:
          reporter: 'spec'
          quiet: false
          clearRequireCache: false
        src: ['test/*.coffee', 'test/*/*.coffee', 'test/*/*/*.coffee']

  grunt.registerTask 'default', 'mochaTest'
