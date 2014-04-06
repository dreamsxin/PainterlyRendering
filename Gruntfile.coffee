module.exports = (grunt) ->
	grunt.initConfig
		pkg:
			grunt.file.readJSON 'package.json'

		browserify:
			dev:
				files:
					'public/script/index.js':
						[ 'assets/script/index.coffee' ]
				options:
					extensions: [ '.js', '.coffee' ]
					transform: [ 'coffeeify', 'brfs' ] #, 'uglifyify'
					debug: yes # enables source maps

		clean:
			all: [ 'doc', 'node_modules', 'public' ]
			pre: [ 'public' ]

		codo:
			options:
				inputs: [ 'assets/script' ]
				output: 'doc'

		coffeelint:
			app: [ 'assets/script/**/*.coffee', 'server/**/*.coffee' ]
			options:
				camel_case_classes:
					level: 'error'
				indentation:
					value: 1
					level: 'error'
				max_line_length:
					value: 80
					level: 'error'
				no_plusplus:
					level: 'error'
				no_tabs:
					level: 'ignore'
				no_throwing_strings:
					level: 'error'
				no_trailing_semicolons:
					level: 'error'
				no_trailing_whitespace:
					level: 'error'

		concurrent:
			dev:
				tasks: [ 'nodemon', 'watch' ]
				options:
					logConcurrentOutput: true

		copy:
			texture:
				expand: yes
				cwd: 'assets/texture'
				src: '**/*'
				dest: 'public/texture'

		jade:
			compile:
				files:
					"public/index.html": [ "assets/view/index.jade" ]

		nodemon:
			dev:
				script: 'server.coffee'
				options:
					watch: [ 'server.coffee' ]

		stylus:
			files:
				expand: yes
				cwd: 'assets/style'
				src: [ 'index.styl' ]
				dest: 'public/style'
				ext: '.css'
			options:
				compress: yes
				linenos: yes
				firebug: yes

		watch:
			options:
				livereload: no
			script:
				files: [ 'assets/script/**/*',  'assets/shader/**/*' ]
				tasks: [ 'browserify:dev' ]
			style:
				files: 'assets/style/**/*'
				tasks: [ 'stylus' ]
			texture:
				files: 'assets/texture/**/*'
				tasks: [ 'copy:texture' ]
			view:
				files: 'assets/view/**/*'
				tasks: [ 'jade' ]

	(require 'load-grunt-tasks') grunt

	grunt.registerTask 'deploy-assets', [
		'clean:pre',
		'browserify',
		'copy',
		'jade',
		'stylus'
	]

	grunt.registerTask 'default', [
		'coffeelint',
		'codo',
		'deploy-assets',
		'concurrent:dev'
	]
