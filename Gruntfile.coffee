module.exports = (grunt) ->

  grunt.loadNpmTasks 'grunt-mocha-test'

  grunt.initConfig
    coffee:
      glob_to_multiple:
        expand: true
        options: bare: true
        cwd: 'src'
        src: ['**/*.coffee']
        dest: 'lib'
        ext: '.js'

    mochaTest:

      common: src: ['test/common/*.coffee']

      translate: src: ['test/translate/*.coffee']

      facet: src: ['test/components/facet/*.coffee']

      testOptions: src: ['test/components/options/*.coffee']

      query: src: ['test/components/query/*.coffee']

      dataset: src: ['test/dataset/*.coffee']

      mongo: src: ['**/mongo.coffee']

      postgres: src: ['**/postgres.coffee']

      solr: src: ['**/solr.coffee']


  grunt.loadNpmTasks 'grunt-contrib-coffee'

  grunt.registerTask 'compile', 'coffee'

  grunt.registerTask 'default',
    ['compile', 'mochaTest:common', 'mochaTest:translate', 'mochaTest:facet',
     'mochaTest:testOptions', 'mochaTest:query', 'mochaTest:dataset']

  grunt.registerTask 'mongo', 'mochaTest:mongo'

  grunt.registerTask 'postgres', 'mochaTest:postgres'

  grunt.registerTask 'solr', 'mochaTest:solr'

