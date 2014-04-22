q = require 'q'
three = require 'three'
#EffectComposer = (require 'three-effectcomposer') three
{ check } = require './check'
{ read } = require './meta'
GameObject = require './GameObject'

module.exports = class Graphics extends GameObject
	constructor: ->
		@renderer =
			new three.WebGLRenderer
				alpha: yes

		depthTextureOptions =
			magFilter: three.NearestFilter
			minFilter: three.NearestFilter
			wrapS: three.ClampToEdgeWrapping
			wrapT: three.ClampToEdgeWrapping
			type: three.FloatType

		@depthTexture =
			# TODO: don't hard-code size
			new three.WebGLRenderTarget 800, 600, depthTextureOptions

		@strokeMeshes =
			[]

		@_divDefer = q.defer()

	read @, 'camera'

	divPromise: ->
		@_divDefer.promise

	bindToDiv: (div) ->
		@_width =
			div.width()
		@_height =
			div.height()

		@renderer.setSize @_width, @_height

		@resetAspect()

		div.append @renderer.domElement

		@_divDefer.resolve div.get 0

	resetAspect: ->
		check @_width?
		@_camera.aspect = @_width / @_height
		@_camera.updateProjectionMatrix()

	restart: ->
		@scene =
			new three.Scene()

		@setupLights()

		@_camera =
			# aspect ratio will be changed in `bindToDiv`
			new three.PerspectiveCamera 75, 1, 0.1, 1000

		if @_width?
			@resetAspect()

		@scene.add @_camera

	setupLights: ->
		@ambientLight =
			new three.AmbientLight 0x222222
		@scene.add @ambientLight

		@dirLights =
			[]

		dirLight1 =
			new three.DirectionalLight 0xffffff, 1.0
		dirLight1.position.set -1, 0, -1
		@dirLights.push dirLight1

		dirLight2 =
			new three.DirectionalLight 0xffff00, 2.0
		dirLight2.position.set 0, -1, 1
		@dirLights.push dirLight2

		for dirLight in @dirLights
			@scene.add dirLight

	setOriginalMeshesVisibility: (visibility) ->
		for strokeMesh in @strokeMeshes
			strokeMesh.setOriginalMeshVisibility visibility

	setDepthMeshesVisibility: (visibility) ->
		for strokeMesh in @strokeMeshes
			strokeMesh.setDepthMeshVisibility visibility

	setStrokeMeshesVisibility: (visibility) ->
		for strokeMesh in @strokeMeshes
			strokeMesh.setStrokeMeshVisibility visibility

	draw: ->
		@setOriginalMeshesVisibility false
		@setDepthMeshesVisibility true
		@setStrokeMeshesVisibility false

		@renderer.render @scene, @_camera, @depthTexture, true

		@setOriginalMeshesVisibility true
		@setDepthMeshesVisibility false
		@setStrokeMeshesVisibility true

		@renderer.render @scene, @_camera
