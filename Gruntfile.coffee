module.exports = (grunt) ->

  grunt.loadNpmTasks 'grunt-mocha-test'

  grunt.initConfig
    mochaTest:
      test:
        options:
          reporter: 'spec'
          queit: false
          clearRequireCache: false
        src: ['test/*.coffee', 'test/*/*.coffee']

  grunt.registerTask 'default', 'mochaTest'

