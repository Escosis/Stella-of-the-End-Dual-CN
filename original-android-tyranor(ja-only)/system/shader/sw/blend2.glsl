varying vec2 resultCoord0;
varying vec2 resultCoord1;

uniform sampler2D textureBack;
uniform sampler2D textureFore;
uniform sampler2D textureMask;


uniform float  alpha;
uniform vec3 colorMultiply;
uniform float  maskTransitionVague;
uniform float  maskTransitionStep;

const vec3 graydata = vec3(0.298912, 0.586611, 0.114478);


void main()
{
	vec4 fore = texture2D(textureFore, resultCoord1);
	vec4 mask = texture2D(textureMask, resultCoord1);
	float mask_a = 1.0;

	float f = vec3(fore.r, fore.g, fore.b);
	float a = f > 0.78 ? 1.0 - f : 1.0;

	fore.a = mask_a * alpha * a;
	gl_FragColor = fore;
}

