attribute vec3 strokeVertexNormal;

uniform float strokeSize;

uniform sampler2D depthTexture;

uniform vec3 ambientLightColor;
uniform vec3 directionalLightDirection[MAX_DIR_LIGHTS];
uniform vec3 directionalLightColor[MAX_DIR_LIGHTS];

/*
Three.js also gives us these:
position
color
modelViewMatrix
projectionMatrix
*/

varying vec4 strokeShadedColor;
varying vec2 strokeOrientation;
varying vec4 mvPosition;
varying float strokeZDifference;

const float Pi =
	3.1415926535897932384626433832795;

void main()
{
	vec4 mvNormal =
		// TODO: lighting normals don't work with quaternions; use normalMatrix ?
		// Use 0.0 so there's no translation
		modelViewMatrix * vec4(strokeVertexNormal, 0.0);

	vec3 lightTotal = ambientLightColor;
	for(int i = 0; i < MAX_DIR_LIGHTS; i++) {
		vec3 dirToLight =
			-directionalLightDirection[i];
		float phongDiffuse =
			max(0.0, dot(dirToLight, vec3(mvNormal)));
			// 1.0;
		float phongSpecular =
			0.0; //specular * pow(reflDir * dirToCamera, shininess);
		vec3 lightColor =
			directionalLightColor[i];
			// vec3(1, 1, 1);
		vec3 phongLight =
			lightColor * (phongDiffuse + phongSpecular);

		lightTotal += phongLight;
	}
	lightTotal = clamp(lightTotal, 0.0, 1.0);

	strokeShadedColor =
		vec4(color * lightTotal, 1.0);

	mvPosition =
		modelViewMatrix * vec4(position, 1.0);

	gl_Position =
		projectionMatrix * mvPosition;

	vec4 projectedNormal =
		normalize(projectionMatrix * mvNormal);

	strokeOrientation =
		normalize(projectedNormal.xy);

	vec2 screenSpace =
		// Convert to (0, 0) to (1, 1) coordinates.
		(vec2(1, 1) + gl_Position.xy / gl_Position.w) / 2.0;
	float depthTextureZ =
		texture2D(depthTexture, screenSpace).z;
	strokeZDifference =
		abs(mvPosition.z - depthTextureZ);

	const float strokeZEpsilon =
		// TODO: This should vary by object size
		1.0;
	float zQuality =
		// 1 when z is perfect.
		// 0 when z is not good enough.
		// Negative when strokeZDifference exceeds strokeZEpsilon
		1.0 - (strokeZDifference / strokeZEpsilon);

	if (zQuality <= 0.0) {
		gl_PointSize =
			0.0;
		gl_Position =
			vec4(-100, -100, -100, 1);
	}
	else
	{
		strokeShadedColor.a *= min(zQuality, 1.0);
		float shrinkInDistance =
			1.0 / gl_Position.z;
		gl_PointSize =
			shrinkInDistance * strokeSize;
	}
}

