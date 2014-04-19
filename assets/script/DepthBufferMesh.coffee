fs = require 'fs'
three = require 'three'
GameObject = require './GameObject'

module.exports = class DepthBufferMesh extends GameObject
    constructor: (geometry) ->
        @_geometry = geometry

        uniforms =
            {}

        attributes =
            {}

        @_material =
            new three.ShaderMaterial
                uniforms: uniforms
                attributes: attributes

                vertexShader: fs.readFileSync __dirname + '/../shader/depth.vs.glsl'
                fragmentShader: fs.readFileSync __dirname + '/../shader/depth.fs.glsl'

                # transparent: yes
                depthWrite: yes

        @mesh =
            new three.Mesh @_geometry, @_material
