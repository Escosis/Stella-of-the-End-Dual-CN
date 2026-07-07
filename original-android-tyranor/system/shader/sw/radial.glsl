varying vec2 resultCoord0;
varying vec2 resultCoord1;

//--------------------------------------
// スクリーン合成
//--------------------------------------
uniform sampler2D textureBack;
uniform sampler2D textureFore;
uniform sampler2D textureMask;
uniform sampler2D textureUser;


uniform float  alpha;
uniform vec3 colorMultiply;
uniform float  maskTransitionVague;
uniform float  maskTransitionStep;
uniform float  ax;
uniform float  ay;
uniform float  size;
uniform float  fade;


void main()
{
	vec4 mask = texture2D(textureMask, resultCoord1);
	vec2 uv = resultCoord1;
	vec2 cent = vec2(ax, ay);			// 中心値
	vec2 poss = uv - cent;				// 中心を基準にする
	float dist = length(poss);				// 中心からの距離
	float factor = size / 8.0 * dist;		// 配分

	float ave = 1.0 / 8.0;					// 一個あたりの割合

	vec4 fadd = vec4(0.0, 0.0, 0.0, 0.0);
	vec4 fore = texture2D(textureFore, resultCoord1);
	fadd += texture2D(textureFore, poss * (1.0 - factor * 1.0) + cent) * ave;
	fadd += texture2D(textureFore, poss * (1.0 - factor * 2.0) + cent) * ave;
	fadd += texture2D(textureFore, poss * (1.0 - factor * 3.0) + cent) * ave;
	fadd += texture2D(textureFore, poss * (1.0 - factor * 4.0) + cent) * ave;
	fadd += texture2D(textureFore, poss * (1.0 - factor * 5.0) + cent) * ave;
	fadd += texture2D(textureFore, poss * (1.0 - factor * 6.0) + cent) * ave;
	fadd += texture2D(textureFore, poss * (1.0 - factor * 7.0) + cent) * ave;
	fore *= (ave + (1.0 - ave) * (1.0 - fade));
	fore += fadd * fade;

	float mask_a = 1.0;
	fore.a   *= mask_a * alpha;
	gl_FragColor = fore;
}

