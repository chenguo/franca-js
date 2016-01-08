module.exports = (grunt) ->

  grunt.loadNpmTasks 'grunt-mocha-test'

  grunt.initConfig
    mochaTest:

      common: src: ['test/common/*.coffee']

      translate: src: ['test/translate.coffee']

      facet: src: ['test/components/facet/*.coffee']

      testOptions: src: ['test/components/options/*.coffee']

      query: src: ['test/components/query/*.coffee']

      mongo: src: ['**/mongo.coffee']

      postgres: src: ['**/postgres.coffee']

      solr: src: ['**/solr.coffee']


  grunt.registerTask 'default',
    ['mochaTest:common', 'mochaTest:translate', 'mochaTest:facet',
     'mochaTest:testOptions', 'mochaTest:query']

  grunt.registerTask 'mongo', 'mochaTest:mongo'

  grunt.registerTask 'postgres', 'mochaTest:postgres'

  grunt.registerTask 'solr', 'mochaTest:solr'
